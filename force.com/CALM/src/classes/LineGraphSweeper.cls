global class LineGraphSweeper implements Database.Batchable<sObject>,Database.Stateful, Schedulable {
   global List<cp_calm__LG_Summary__c> sweepers;
   global Set<String> appKeys = new Set<String>();
   global Map<String, cp_calm__LG_Summary__c> appKeysToSweeper = new Map<String, cp_calm__LG_Summary__c>();
   global String new_day = 'd0';
   global Date sweepDay = date.today().addDays(-1);
   global Set<String> appKeysSeen = new Set<String>();
   global Map<String, Integer> session_counts = new Map<String, Integer>();
   global Map<String, Integer> user_counts = new Map<String, Integer>();
   global Map<String, Integer> new_session_counts = new Map<String, Integer>();
   global Map<String, Integer> ret_session_counts = new Map<String, Integer>();
   global Map<String, Set<String>> devices_seen = new Map<String, Set<String>>();
   global Map<String, Set<String>> new_devices_seen = new Map<String, Set<String>>();
   
   global void execute(SchedulableContext SC) {
   		LineGraphSweeper sweeper = new LineGraphSweeper();
        Database.executeBatch(sweeper);
   }
   
   global LineGraphSweeper() {
   	
   }
   
   // For Test
   global LineGraphSweeper(Date sweep) {
         sweepDay = sweep;
   }
           
   global Database.QueryLocator start(Database.BatchableContext BC) {
          Integer day = sweepDay.day();
          Integer month = sweepDay.month();
          Integer year = sweepDay.year();
          
          String query = 'select cp_calm__au__c, cp_calm__st__c, cp_calm__nr__c, cp_calm__du__c from cp_calm__Session__c WHERE cp_calm__et__c != NULL AND DAY_IN_MONTH(convertTimezone(cp_calm__st__c)) = ' +day+ 'AND CALENDAR_MONTH(convertTimezone(cp_calm__st__c)) = '+month+' AND CALENDAR_YEAR(convertTimezone(cp_calm__st__c)) = '+year;
          // get existing sweepers
          sweepers = [SELECT cp_calm__au__c, cp_calm__today__c FROM cp_calm__LG_Summary__c];
                    
          // get the all app keys
          List<AggregateResult> appKeyAggregate = [SELECT cp_calm__au__c FROM cp_calm__Session__c WHERE DAY_ONLY(convertTimezone(cp_calm__st__c)) = :sweepDay GROUP BY cp_calm__au__c];
          for (AggregateResult aggregate : appKeyAggregate) {
              appKeys.add((String)aggregate.get('cp_calm__au__c'));
          }
          
          System.debug('Key size: ' + appKeys.size());
          System.debug('Sweeper size: ' + sweepers.size());
          
          // Map app keys to sweepers
          for (cp_calm__LG_Summary__c swp : sweepers) {
              appKeysToSweeper.put(swp.cp_calm__au__c, swp);
          }
          
          // Update exising sweepers to have the correct "today" value
          for (cp_calm__LG_Summary__c sweeper : sweepers) {
              if (new_day == 'd0') {
                  String past_day = sweeper.cp_calm__today__c;
                  Integer past_day_int = Integer.valueOf(past_day.removeStart('d'));
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
          
          // get a list of app keys that don't have sweeper objects
          Set<String> unrecordedAppKeys = appKeys.clone();
          for (cp_calm__LG_Summary__c sweeper : sweepers) {
          		// If the sweeper exists
               if (unrecordedAppKeys.contains(sweeper.cp_calm__au__c)) {
               		unrecordedAppKeys.remove(sweeper.cp_calm__au__c);
         	   }
          }
              
          // if there is not a sweeper for every app key
          if (!unrecordedAppKeys.isEmpty()) {
          	  system.debug('Creating a new sweeper.');      
              // create sweeper objects for missing app keys
              for (String appKey : unrecordedAppKeys) {
                  cp_calm__LG_Summary__c sweeper = new cp_calm__LG_Summary__c();
                  sweeper.cp_calm__au__c = appKey;
                  sweeper.cp_calm__today__c = new_day;
                  sweepers.add(sweeper);
                  
                  appKeysToSweeper.put(sweeper.cp_calm__au__c, sweeper);
                  
                  insert sweeper;
              }
          }
                 
          return Database.getQueryLocator(query);
   }

   global void execute(Database.BatchableContext BC, List<cp_calm__Session__c> scope) {   
      for(cp_calm__Session__c s : scope) {
        String app = s.cp_calm__au__c;
        // App key does not exist already
        if (appKeysSeen.add(app)) {
            session_counts.put(app, 0);
            user_counts.put(app, 0);
            new_session_counts.put(app, 0);
            ret_session_counts.put(app, 0);
            devices_seen.put(app, new Set<String>());
            new_devices_seen.put(app, new Set<String>());
        }
        session_counts.put(app, session_counts.get(app) + 1);
        
        // If the device hasn't been seen before, this is the first instance of a user on the current day
        if (devices_seen.get(app).add(s.cp_calm__du__c)) {
            user_counts.put(app, user_counts.get(app) + 1);
        }

        if (s.cp_calm__nr__c == 'y') {
            new_session_counts.put(app, new_session_counts.get(app) + 1);
            new_devices_seen.get(app).add(s.cp_calm__du__c);
        }
        else {
            ret_session_counts.put(app, ret_session_counts.get(app) + 1);
        }
      }
   }
   
   global void finish(Database.BatchableContext BC)
   {
        for (cp_calm__LG_Summary__c s : sweepers) {
            String app = s.cp_calm__au__c;
            String day = 'cp_calm__' + new_day + '__c';
            
            List<cp_calm__LG_Sessions__c> session_sweepers = database.query('SELECT '+day+' FROM cp_calm__LG_Sessions__c WHERE cp_calm__au__c = \''+app+'\'');
            cp_calm__LG_Sessions__c session_sweeper;
            if (session_sweepers.size() == 0) {
                  cp_calm__LG_Sessions__c sessions = new cp_calm__LG_Sessions__c();
                  sessions.cp_calm__au__c = app;
                  createDailyFields(sessions);
                  session_sweeper = sessions;
            }
            else {
            	session_sweeper = session_sweepers.get(0);
            }
            session_sweeper.put(day, (session_counts.get(app) == null) ? 0 : session_counts.get(app));
            upsert session_sweeper;
            
            List<cp_calm__LG_Users__c> user_sweepers = database.query('SELECT '+day+' FROM cp_calm__LG_Users__c WHERE cp_calm__au__c = \''+app+'\'');
            cp_calm__LG_Users__c user_sweeper;
            if (user_sweepers.size() == 0) {
                  cp_calm__LG_Users__c users = new cp_calm__LG_Users__c();
                  users.cp_calm__au__c = app;
                  createDailyFields(users);
                  user_sweeper = users;
            }
            else {
            	user_sweeper = user_sweepers.get(0);
            }
            user_sweeper.put(day, (user_counts.get(app) == null) ? 0 : user_counts.get(app));
            upsert user_sweeper;
            
            List<cp_calm__LG_New_Sessions__c> new_session_sweepers = database.query('SELECT '+day+' FROM cp_calm__LG_New_Sessions__c WHERE cp_calm__au__c = \''+app+'\'');
            cp_calm__LG_New_Sessions__c new_session_sweeper;
            if (new_session_sweepers.size() == 0) {
                  cp_calm__LG_New_Sessions__c new_sessions = new cp_calm__LG_New_Sessions__c();
                  new_sessions.cp_calm__au__c = app;
                  createDailyFields(new_sessions);
                  new_session_sweeper = new_sessions;
            }
            else {
            	new_session_sweeper = new_session_sweepers.get(0);
            }
            new_session_sweeper.put(day, (new_session_counts.get(app) == null) ? 0 : new_session_counts.get(app));
            upsert new_session_sweeper;
            
            List<cp_calm__LG_Returning_Sessions__c> ret_session_sweepers = database.query('SELECT '+day+' FROM cp_calm__LG_Returning_Sessions__c WHERE cp_calm__au__c = \''+app+'\'');
            cp_calm__LG_Returning_Sessions__c ret_session_sweeper;
            if (ret_session_sweepers.size() == 0) {
                  cp_calm__LG_Returning_Sessions__c ret_sessions = new cp_calm__LG_Returning_Sessions__c();
                  ret_sessions.cp_calm__au__c = app;
                  createDailyFields(ret_sessions);
                  ret_session_sweeper = ret_sessions;
            }
            else {
            	ret_session_sweeper = ret_session_sweepers.get(0);
            }
            ret_session_sweeper.put(day, (ret_session_counts.get(app) == null) ? 0 : ret_session_counts.get(app));
            upsert ret_session_sweeper;
            
            List<cp_calm__LG_New_Users__c> new_user_sweepers = database.query('SELECT '+day+' FROM cp_calm__LG_New_Users__c WHERE cp_calm__au__c = \''+app+'\'');
            cp_calm__LG_New_Users__c new_user_sweeper;
            if (new_user_sweepers.size() == 0) {
                  cp_calm__LG_New_Users__c new_users = new cp_calm__LG_New_Users__c();
                  new_users.cp_calm__au__c = app;
                  createDailyFields(new_users);
                  new_user_sweeper = new_users;
            }
            else {
            	new_user_sweeper = new_user_sweepers.get(0);
            }
            new_user_sweeper.put(day, (new_devices_seen.get(app) == null) ? 0 : new_devices_seen.get(app).size());
            upsert new_user_sweeper;
            
            List<cp_calm__LG_Returning_Users__c> ret_user_sweepers = database.query('SELECT '+day+' FROM cp_calm__LG_Returning_Users__c WHERE cp_calm__au__c = \''+app+'\'');
            cp_calm__LG_Returning_Users__c ret_user_sweeper;
            if (ret_user_sweepers.size() == 0) {
                  cp_calm__LG_Returning_Users__c ret_users = new cp_calm__LG_Returning_Users__c();
                  ret_users.cp_calm__au__c = app;
                  createDailyFields(ret_users);
                  ret_user_sweeper = ret_users;
            }
            else {
            	ret_user_sweeper = ret_user_sweepers.get(0);
            }
            ret_user_sweeper.put(day, ((devices_seen.get(app) == null || new_devices_seen.get(app) == null) ? 
                                                0 : (devices_seen.get(app).size() - new_devices_seen.get(app).size())));
            upsert ret_user_sweeper;
        }
        
        // Call BarGraphSweeper
        BarGraphSweeper sweeper = new BarGraphSweeper();
        Database.executeBatch(sweeper);
   }
   
   private void createDailyFields(cp_calm__LG_Sessions__c obj) {
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
   
   private void createDailyFields(cp_calm__LG_Users__c obj) {
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
   
   private void createDailyFields(cp_calm__LG_New_Sessions__c obj) {
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
   
   private void createDailyFields(cp_calm__LG_Returning_Sessions__c obj) {
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
   
   private void createDailyFields(cp_calm__LG_New_Users__c obj) {
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
   
   private void createDailyFields(cp_calm__LG_Returning_Users__c obj) {
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