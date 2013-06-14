global class BGDailyCountrySessionsSweeper implements Database.Batchable<sObject>,Database.Stateful {
   global List<cp_calm__BG_Summary__c> sweepers;
   global Set<String> appKeys = new Set<String>();
   global Map<String, cp_calm__BG_Summary__c> appKeysToSweeper = new Map<String, cp_calm__BG_Summary__c>();
   global String new_day = 'd0';
   global Date sweepDay = date.today().addDays(-1);
   global Set<String> appKeysSeen = new Set<String>();
   global Map<String, Map<String, Integer>> country_session_counts = new Map<String, Map<String, Integer>>();
     
   global BGDailyCountrySessionsSweeper(String today_index, Date sweepDay) {
   		new_day = today_index;
   		sweepDay = sweepDay;
   }
    
   global Database.QueryLocator start(Database.BatchableContext BC) {
          Integer day = sweepDay.day();
          Integer month = sweepDay.month();
          Integer year = sweepDay.year();
          
          // All graphs except Events Overview/Details
          String query = 'SELECT cp_calm__au__c, cp_calm__st__c, cp_calm__et__c, cp_calm__du__c, cp_calm__av__c, cp_calm__dlc__c, cp_calm__nca__c, cp_calm__session_length__c FROM cp_calm__Session__c WHERE cp_calm__et__c != NULL AND DAY_IN_MONTH(convertTimezone(cp_calm__st__c)) = ' +day+ 'AND CALENDAR_MONTH(convertTimezone(cp_calm__st__c)) = '+month+' AND CALENDAR_YEAR(convertTimezone(cp_calm__st__c)) = '+year;
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
            country_session_counts.put(app, new Map<String, Integer>());
        }
       
        Integer cnt;
        country_session_counts.get(app).put(s.cp_calm__dlc__c,
        	((cnt = country_session_counts.get(app).get(s.cp_calm__dlc__c)) == null) ? 1 : cnt + 1);
      }
   }
   
   global void finish(Database.BatchableContext BC)
   {
        for (cp_calm__BG_Summary__c s : sweepers) {
            String app = s.cp_calm__au__c;
            String day = 'cp_calm__' + new_day + '__c';
            Map<String, Integer> new_fields;
            
            // Country Sessions
            new_fields = country_session_counts.get(app);
            if (new_fields != NULL) {
            	new_fields = new_fields.clone();
            }
            List<cp_calm__BG_Country_Sessions__c> country_session_sweepers = database.query('SELECT cp_calm__key__c, '+day+' FROM cp_calm__BG_Country_Sessions__c WHERE cp_calm__au__c = \''+app+'\'');
            for (cp_calm__BG_Country_Sessions__c country_session : country_session_sweepers) {
            	if (new_fields != NULL && country_session_counts.get(app).containsKey(country_session.cp_calm__key__c)) {
            		country_session.put(day, country_session_counts.get(app).get(country_session.cp_calm__key__c));
            	}
            	else {
            		country_session.put(day, 0);
            	}
            	if (new_fields != NULL) {
            		new_fields.remove(country_session.cp_calm__key__c);
            	}
            }
            update country_session_sweepers;
            
            if (new_fields != NULL) {
	            for (String country : new_fields.keySet()) {
	              cp_calm__BG_Country_Sessions__c new_country = new cp_calm__BG_Country_Sessions__c();
	              new_country.cp_calm__au__c = app;
	              new_country.cp_calm__key__c = country;
	              DailyFieldSetup.createDailyFields(new_country);
	              new_country.put(day, (country_session_counts.get(app).get(country)));
	              insert new_country;
	            }
            }
        }
        
        // Call next Sweeper
        BGDailyCountryUsersSweeper sweeper = new BGDailyCountryUsersSweeper(new_day, sweepDay);
        Database.executeBatch(sweeper);
   }
}