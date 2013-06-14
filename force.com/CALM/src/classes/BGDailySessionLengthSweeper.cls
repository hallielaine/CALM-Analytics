global class BGDailySessionLengthSweeper implements Database.Batchable<sObject>,Database.Stateful {
   global List<cp_calm__BG_Summary__c> sweepers;
   global Set<String> appKeys = new Set<String>();
   global Map<String, cp_calm__BG_Summary__c> appKeysToSweeper = new Map<String, cp_calm__BG_Summary__c>();
   global String new_day = 'd0';
   global Date sweepDay = date.today().addDays(-1);
   global Set<String> appKeysSeen = new Set<String>();
   global Map<String, Map<TimeInterval, Integer>> session_length_counts = new Map<String, Map<TimeInterval, Integer>>();
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
   
   global BGDailySessionLengthSweeper(String today_index, Date sweep) {
   		new_day = today_index;
   		sweepDay = sweep;
   }
    
   global Database.QueryLocator start(Database.BatchableContext BC) {
          Integer day = sweepDay.day();
          Integer month = sweepDay.month();
          Integer year = sweepDay.year();
          
          // All graphs except Events Overview/Details
          String query = 'SELECT cp_calm__au__c, cp_calm__st__c, cp_calm__et__c, cp_calm__session_length__c FROM cp_calm__Session__c WHERE cp_calm__et__c != NULL AND  DAY_IN_MONTH(convertTimezone(cp_calm__st__c)) = ' +day+ 'AND CALENDAR_MONTH(convertTimezone(cp_calm__st__c)) = '+month+' AND CALENDAR_YEAR(convertTimezone(cp_calm__st__c)) = '+year;
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
          return Database.getQueryLocator(query);
   }

   global void execute(Database.BatchableContext BC, List<cp_calm__Session__c> scope) {   
      for(cp_calm__Session__c s : scope) {
        String app = s.cp_calm__au__c;
        // App key does not exist already
        if (appKeysSeen.add(app)) {
            session_length_counts.put(app, new Map<TimeInterval, Integer>());
            // initialize counts
	        for (TimeInterval interval : intervals) {
	            session_length_counts.get(app).put(interval, 0);
	        }
        }
        
        if (s.cp_calm__et__c != null) {
            TimeInterval interval = findInterval(s.cp_calm__st__c, s.cp_calm__et__c);
            session_length_counts.get(app).put(interval, session_length_counts.get(app).get(interval)+1);
        }
      }
   }
   
   global void finish(Database.BatchableContext BC)
   {
        for (cp_calm__BG_Summary__c s : sweepers) {
            String app = s.cp_calm__au__c;
            String day = 'cp_calm__' + new_day + '__c';
            Map<String, Integer> new_fields;
                        
            List<cp_calm__BG_Session_Length__c> session_length_sweepers = database.query('SELECT cp_calm__key__c, '+day+' FROM cp_calm__BG_Session_Length__c WHERE cp_calm__au__c = \''+app+'\'');
            for (cp_calm__BG_Session_Length__c session_length : session_length_sweepers) {
            	TimeInterval interval = findIntervalFromDescription(session_length.cp_calm__key__c);
            	if (interval != null) {
            		if (session_length_counts.get(app) != NULL) {
            	  		session_length.put(day, session_length_counts.get(app).get(interval));
            		}
            	}
            }    
            update session_length_sweepers;       
        }
        
        // Call EventGraphSweeper
        EventGraphSweeper sweeper = new EventGraphSweeper(sweepDay);
        Database.executeBatch(sweeper);
   }
   
   // return the interval that contains (start, stop)
   private TimeInterval findInterval(Datetime start, Datetime stop) {
       long duration = stop.getTime() - start.getTime();
        
       for (TimeInterval interval : intervals) {
           if (duration >= interval.start && duration <= interval.stop) {
               return interval;
           }
       }
       return intervals.get(intervals.size()-1);
   }
   
   private TimeInterval findIntervalFromDescription(String description) {
      for (TimeInterval interval : intervals) {
      	   if (description == interval.description)
      	       return interval;
      }
      return null;
   }
}