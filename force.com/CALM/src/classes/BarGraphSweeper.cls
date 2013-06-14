global class BarGraphSweeper implements Database.Batchable<sObject>,Database.Stateful {
   global List<cp_calm__BG_Summary__c> sweepers;
   global Set<String> appKeys = new Set<String>();
   global Map<String, cp_calm__BG_Summary__c> appKeysToSweeper = new Map<String, cp_calm__BG_Summary__c>();
   global String new_day = 'd0';
   global Date sweepDay = date.today().addDays(-1);
   global Set<String> appKeysSeen = new Set<String>();
   global List<TimeInterval> intervals = new List<TimeInterval>();
   
   global class TimeInterval implements Comparable {
        public Integer start;
        public Integer stop;
        public String description;
        
        public TimeInterval(Integer start, Integer stop, String description) {
            this.start = start;
            this.stop = stop;
            this.description = description;
        }
        
        public Integer compareTo(Object obj) {
            if (obj instanceof TimeInterval) {
                TimeInterval sess = (TimeInterval) obj;
                
                if (this.start < sess.start) {
                    return -1;
                }
                if (this.start > sess.start) {
                    return 1;
                }
                return 0;
            }
            return -1;
        }
   }
   
   global BarGraphSweeper() {
   	
   }
   
   global BarGraphSweeper(Date sweep) {
   		sweepDay = sweep;
   }
    
   global Database.QueryLocator start(Database.BatchableContext BC) {
          Integer day = sweepDay.day();
          Integer month = sweepDay.month();
          Integer year = sweepDay.year();
          
          // All graphs
          String query = 'SELECT cp_calm__au__c FROM cp_calm__Session__c WHERE cp_calm__et__c != NULL AND DAY_IN_MONTH(convertTimezone(cp_calm__st__c)) = ' +day+ 'AND CALENDAR_MONTH(convertTimezone(cp_calm__st__c)) = '+month+' AND CALENDAR_YEAR(convertTimezone(cp_calm__st__c)) = '+year;
          // get existing sweepers
          sweepers = [SELECT cp_calm__au__c, cp_calm__today__c FROM cp_calm__BG_Summary__c];
                    
          // get the all app keys
          List<AggregateResult> appKeyAggregate = [SELECT cp_calm__au__c FROM cp_calm__Session__c WHERE DAY_ONLY(convertTimezone(cp_calm__st__c)) = :sweepDay GROUP BY cp_calm__au__c];
          for (AggregateResult aggregate : appKeyAggregate) {
              appKeys.add((String)aggregate.get('cp_calm__au__c'));
          }
                    
          // Map app keys to sweepers
          for (cp_calm__BG_Summary__c swp : sweepers) {
              appKeysToSweeper.put(swp.cp_calm__au__c, swp);
          }
          
          // Update exising sweepers to have the correct "today" value
          for (cp_calm__BG_Summary__c sweeper : sweepers) {
		      if (new_day == 'd0') {
		          String past_day = sweeper.cp_calm__today__c;
		          Integer past_day_int =  Integer.valueOf(past_day.removeStart('d'));
		          past_day_int++;
		          if (past_day_int > 60)
		              past_day_int = 1;
		          new_day = 'd' + past_day_int;
		  	  }
		      sweeper.cp_calm__today__c = new_day;
		      update sweeper;
          }
          
          if (sweepers.size() == 0) {
             new_day = 'd1';
          }
          
          // Setup for Session Length Graph
          if (intervals.size() == 0) {
	          intervals.add(new TimeInterval(0, 10000, '0 to 10 seconds'));
	          intervals.add(new TimeInterval(11000, 30000, '11 to 30 seconds'));
	          intervals.add(new TimeInterval(31000, 60000, '31 to 60 seconds'));
	          intervals.add(new TimeInterval(61000, 180000, '1 to 3 minutes'));
	          intervals.add(new TimeInterval(181000, 600000, '3 to 10 minutes'));
	          intervals.add(new TimeInterval(601000, 1800000, '10 to 30 minutes'));
	          intervals.add(new TimeInterval(1801000, 3600000, '30 to 60 minutes'));
	          intervals.add(new TimeInterval(3601000, 2147483647, '> 1 hour')); // max int
          }
          
          // get a list of app keys that don't have sweeper objects
          Set<String> unrecordedAppKeys = appKeys.clone();
          for (cp_calm__BG_Summary__c sweeper : sweepers) {
	          // If the sweeper exists
	          if (unrecordedAppKeys.contains(sweeper.cp_calm__au__c)) {
	               unrecordedAppKeys.remove(sweeper.cp_calm__au__c);
	          }    
          }
           
          // if there is not a sweeper for every app key
          if (!unrecordedAppKeys.isEmpty()) {             
              // create sweeper objects for missing app keys
              for (String appKey : unrecordedAppKeys) {
                  cp_calm__BG_Summary__c sweeper = new cp_calm__BG_Summary__c();
                  sweeper.cp_calm__au__c = appKey;
                  
                  sweeper.cp_calm__today__c = new_day;
                  sweepers.add(sweeper);
                  
                  appKeysToSweeper.put(sweeper.cp_calm__au__c, sweeper);
                  
                  insert sweeper;
                  
                  // Create sweeper object for Session Lengths with predefined fields
                  for (TimeInterval interval : intervals) {
                     cp_calm__BG_Session_Length__c session_length = new cp_calm__BG_Session_Length__c();
                     session_length.cp_calm__key__c = interval.description;
                     DailyFieldSetup.createDailyFields(session_length);
                     session_length.cp_calm__au__c = appKey;
                     insert session_length;
                  }
              }
          }
          
          return Database.getQueryLocator(query);
   }

   global void execute(Database.BatchableContext BC, List<cp_calm__Session__c> scope) {   
   		
   }
   
   global void finish(Database.BatchableContext BC)
   {      
        // Call next Sweeper
        BGDailyAppVersionSessionsSweeper sweeper = new BGDailyAppVersionSessionsSweeper(new_day, sweepDay);
        Database.executeBatch(sweeper);
   }
}