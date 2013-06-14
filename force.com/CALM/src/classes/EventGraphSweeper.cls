global class EventGraphSweeper implements Database.Batchable<sObject>,Database.Stateful {
 	 global List<cp_calm__BG_Summary__c> sweepers;
     global Set<String> appKeys = new Set<String>();
     global Map<String, cp_calm__BG_Summary__c> appKeysToSweeper = new Map<String, cp_calm__BG_Summary__c>();
     global String new_day = 'd0';
     global Date sweepDay = date.today().addDays(-1);
     global Set<String> appKeysSeen = new Set<String>();
     global Map<String, Map<String, Integer>> event_counts = new Map<String, Map<String, Integer>>();
     global Map<String, cp_calm__Session__c> sessions = new Map<String, cp_calm__Session__c>();
      
     global EventGraphSweeper() {
     	
     }
     
     // For Test
     global EventGraphSweeper(Date sweep) {
   		sweepDay = sweep;
     }
    
	 global Database.QueryLocator start(Database.BatchableContext BC) {
          Integer day = sweepDay.day();
          Integer month = sweepDay.month();
          Integer year = sweepDay.year();
          
          String session_query = 'SELECT cp_calm__au__c, cp_calm__u__c, cp_calm__st__c, cp_calm__et__c FROM cp_calm__Session__c WHERE cp_calm__et__c != NULL AND DAY_IN_MONTH(convertTimezone(cp_calm__st__c)) = ' +day+ 'AND CALENDAR_MONTH(convertTimezone(cp_calm__st__c)) = '+month+' AND CALENDAR_YEAR(convertTimezone(cp_calm__st__c)) = '+year;
          List<cp_calm__Session__c> session_objects = database.query(session_query);
          for (cp_calm__Session__c session : session_objects) {
             sessions.put(session.cp_calm__u__c, session);
          }
          
          String query = 'SELECT cp_calm__su__c, cp_calm__n__c FROM cp_calm__Action__c WHERE cp_calm__dt__c = \'e\'';
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
          
          // Get the "today" value from a sweeper
          for (cp_calm__BG_Summary__c sweeper : sweepers) {
		      if (new_day == 'd0') {
		          String past_day = sweeper.cp_calm__today__c;
		          Integer past_day_int =  Integer.valueOf(past_day.removeStart('d'));
		          new_day = 'd' + past_day_int;
		          break;
		  	  }
          }
                    
          return Database.getQueryLocator(query);
   }

   global void execute(Database.BatchableContext BC, List<cp_calm__Action__c> scope) {   
      for(cp_calm__Action__c a : scope) {
      	if (sessions.containsKey(a.cp_calm__su__c)) {
	        String app = sessions.get(a.cp_calm__su__c).cp_calm__au__c;
	        // App key does not exist already
	        if (appKeysSeen.add(app)) {
	            event_counts.put(app, new Map<String, Integer>());
	        }
	       
	        Integer cnt;
	        event_counts.get(app).put(a.cp_calm__n__c, 
	        	((cnt = event_counts.get(app).get(a.cp_calm__n__c)) == null) ? 1 : cnt + 1);
      	}	        
      }
   }
   
   global void finish(Database.BatchableContext BC)
   {
        for (cp_calm__BG_Summary__c s : sweepers) {
            String app = s.cp_calm__au__c;
            String day = 'cp_calm__' + new_day + '__c';
            
            Map<String, Integer> new_fields = event_counts.get(app);
            if (new_fields != NULL) {
            	new_fields = new_fields.clone();
            }
            List<cp_calm__BG_Events__c> event_sweepers = database.query('SELECT cp_calm__key__c, '+day+' FROM cp_calm__BG_Events__c WHERE cp_calm__au__c = \''+app+'\'');
            for (cp_calm__BG_Events__c event : event_sweepers) {
            	if (new_fields != NULL && event_counts.get(app).containsKey(event.cp_calm__key__c)) {
            		event.put(day, event_counts.get(app).get(event.cp_calm__key__c));
            	}
            	else {
            		event.put(day, 0);
            	}
            	if (new_fields != NULL) {
            		new_fields.remove(event.cp_calm__key__c);
            	}
            }
            update event_sweepers;
            
            if (new_fields != NULL) {
	            for (String event : new_fields.keySet()) {
	              cp_calm__BG_Events__c new_event = new cp_calm__BG_Events__c();
	              new_event.cp_calm__au__c = app;
	              new_event.cp_calm__key__c = event;
	              createDailyFields(new_event);
	              new_event.put(day, (event_counts.get(app).get(event)));
	              insert new_event;
	            }         
            }
        }
        
        /*if (sweepDay < date.today().addDays(-1)) {
        	LineGraphSweeper sweeper = new LineGraphSweeper(sweepDay.addDays(1));
       		Database.executeBatch(sweeper);
        }*/
        
        /*DailySweeperDeleter deleter = new DailySweeperDeleter(sweepDay);
        Database.executeBatch(deleter);*/
        
        // Call MonthlySweeperUpdate 
        MonthlySweeper sweeper = new MonthlySweeper();
        Database.executeBatch(sweeper);
   }

	private void createDailyFields(cp_calm__BG_Events__c obj) {
	 obj.cp_calm__d1__c = -1;
	 obj.cp_calm__d2__c = -1;
	 obj.cp_calm__d3__c = -1;
	 obj.cp_calm__d4__c = -1;
	 obj.cp_calm__d5__c = -1;
	 obj.cp_calm__d6__c = -1;
	 obj.cp_calm__d7__c = -1;
	 obj.cp_calm__d8__c = -1;
	 obj.cp_calm__d9__c = -1;
	 obj.cp_calm__d10__c = -1;
	 obj.cp_calm__d11__c = -1;
	 obj.cp_calm__d12__c = -1;
	 obj.cp_calm__d13__c = -1;
	 obj.cp_calm__d14__c = -1;
	 obj.cp_calm__d15__c = -1;
	 obj.cp_calm__d16__c = -1;
	 obj.cp_calm__d17__c = -1;
	 obj.cp_calm__d18__c = -1;
	 obj.cp_calm__d19__c = -1;
	 obj.cp_calm__d20__c = -1;
	 obj.cp_calm__d21__c = -1;
	 obj.cp_calm__d22__c = -1;
	 obj.cp_calm__d23__c = -1;
	 obj.cp_calm__d24__c = -1;
	 obj.cp_calm__d25__c = -1;
	 obj.cp_calm__d26__c = -1;
	 obj.cp_calm__d27__c = -1;
	 obj.cp_calm__d28__c = -1;
	 obj.cp_calm__d29__c = -1;
	 obj.cp_calm__d30__c = -1;
	 obj.cp_calm__d31__c = -1;
	 obj.cp_calm__d32__c = -1;
	 obj.cp_calm__d33__c = -1;
	 obj.cp_calm__d34__c = -1;
	 obj.cp_calm__d35__c = -1;
	 obj.cp_calm__d36__c = -1;
	 obj.cp_calm__d37__c = -1;
	 obj.cp_calm__d38__c = -1;
	 obj.cp_calm__d39__c = -1;
	 obj.cp_calm__d40__c = -1;
	 obj.cp_calm__d41__c = -1;
	 obj.cp_calm__d42__c = -1;
	 obj.cp_calm__d43__c = -1;
	 obj.cp_calm__d44__c = -1;
	 obj.cp_calm__d45__c = -1;
	 obj.cp_calm__d46__c = -1;
	 obj.cp_calm__d47__c = -1;
	 obj.cp_calm__d48__c = -1;
	 obj.cp_calm__d49__c = -1;
	 obj.cp_calm__d50__c = -1;
	 obj.cp_calm__d51__c = -1;
	 obj.cp_calm__d52__c = -1;
	 obj.cp_calm__d53__c = -1;
	 obj.cp_calm__d54__c = -1;
	 obj.cp_calm__d55__c = -1;
	 obj.cp_calm__d56__c = -1;
	 obj.cp_calm__d57__c = -1;
	 obj.cp_calm__d58__c = -1;
	 obj.cp_calm__d59__c = -1;
	 obj.cp_calm__d60__c = -1;
   } 
}