global class BGDailyAppVersionSessionsSweeper implements Database.Batchable<sObject>,Database.Stateful {
   global List<cp_calm__BG_Summary__c> sweepers;
   global Set<String> appKeys = new Set<String>();
   global Map<String, cp_calm__BG_Summary__c> appKeysToSweeper = new Map<String, cp_calm__BG_Summary__c>();
   global String new_day = 'd0';
   global Date sweepDay = date.today().addDays(-1);
   global Set<String> appKeysSeen = new Set<String>();
   global Map<String, Map<String, Integer>> app_version_session_counts = new Map<String, Map<String, Integer>>();
         
   global BGDailyAppVersionSessionsSweeper(String today_index, Date sweepDay) {
   		new_day = today_index;
   		sweepDay = sweepDay;
   }
    
   global Database.QueryLocator start(Database.BatchableContext BC) {
          Integer day = sweepDay.day();
          Integer month = sweepDay.month();
          Integer year = sweepDay.year();
          
          String query = 'SELECT cp_calm__au__c, cp_calm__av__c FROM cp_calm__Session__c WHERE cp_calm__et__c != NULL AND DAY_IN_MONTH(convertTimezone(cp_calm__st__c)) = ' +day+ 'AND CALENDAR_MONTH(convertTimezone(cp_calm__st__c)) = '+month+' AND CALENDAR_YEAR(convertTimezone(cp_calm__st__c)) = '+year;
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
          
          return Database.getQueryLocator(query);
   }

   global void execute(Database.BatchableContext BC, List<cp_calm__Session__c> scope) {   
      for(cp_calm__Session__c s : scope) {
        String app = s.cp_calm__au__c;
        // App key does not exist already
        if (appKeysSeen.add(app)) {
            app_version_session_counts.put(app, new Map<String, Integer>());
        }
       
        Integer cnt;
        app_version_session_counts.get(app).put(s.cp_calm__av__c, 
        	((cnt = app_version_session_counts.get(app).get(s.cp_calm__av__c)) == null) ? 1 : cnt + 1);
      }
   }
   
   global void finish(Database.BatchableContext BC)
   {
        for (cp_calm__BG_Summary__c s : sweepers) {
            String app = s.cp_calm__au__c;
            String day = 'cp_calm__' + new_day + '__c';
            
            // App Version Sessions
            Map<String, Integer> new_fields = app_version_session_counts.get(app);
            if (new_fields != NULL) {
            	new_fields = new_fields.clone();
            }
            List<cp_calm__BG_App_Version_Sessions__c> av_session_sweepers = database.query('SELECT cp_calm__key__c, '+day+' FROM cp_calm__BG_App_Version_Sessions__c WHERE cp_calm__au__c = \''+app+'\'');
            for (cp_calm__BG_App_Version_Sessions__c av_session : av_session_sweepers) {
            	if (new_fields != NULL && app_version_session_counts.get(app).containsKey(av_session.cp_calm__key__c)) {
            		av_session.put(day, app_version_session_counts.get(app).get(av_session.cp_calm__key__c));
            	}
            	else {
            		av_session.put(day, 0);
            	}
            	if (new_fields != NULL) {
            		new_fields.remove(av_session.cp_calm__key__c);
            	}
            }
            update av_session_sweepers;
            
            if (new_fields != NULL) {
	            for (String av : new_fields.keySet()) {
	              cp_calm__BG_App_Version_Sessions__c new_av = new cp_calm__BG_App_Version_Sessions__c();
	              new_av.cp_calm__au__c = app;
	              new_av.cp_calm__key__c = av;
	              DailyFieldSetup.createDailyFields(new_av);
	              new_av.put(day, (app_version_session_counts.get(app).get(av)));
	              insert new_av;
	            }
            }
        }
        
        // Call next Sweeper
        BGDailyAppVersionUsersSweeper sweeper = new BGDailyAppVersionUsersSweeper(new_day, sweepDay);
        Database.executeBatch(sweeper);
   }
}