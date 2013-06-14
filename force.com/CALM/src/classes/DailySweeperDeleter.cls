global class DailySweeperDeleter implements Database.Batchable<sObject>,Database.Stateful {
	List<cp_calm__Session__c> session_objects;
	List<cp_calm__Action__c> actions_to_delete;
	Map<String, cp_calm__Session__c> sessions;
	Date sweepDay;
	
	global DailySweeperDeleter() {
		sweepDay = date.today().addDays(-1);
	}
	
	// For test
	global DailySweeperDeleter(Date sweep) {
   		sweepDay = sweep;
    }
    
	global Database.QueryLocator start(Database.BatchableContext BC) {
		  sessions = new Map<String, cp_calm__Session__c>();
         
          Integer day = sweepDay.day();
          Integer month = sweepDay.month();
          Integer year = sweepDay.year();
          
          String session_query = 'SELECT id, cp_calm__u__c FROM cp_calm__Session__c WHERE cp_calm__et__c != null AND ' +
								  '(' +
                                      '(' + 
                                           'CALENDAR_YEAR(convertTimezone(cp_calm__st__c)) < ' + year +
                                      ')' +
                                      ' OR ' +
                                      '(' +
                                           'CALENDAR_YEAR(convertTimezone(cp_calm__st__c)) = ' + year +
                                           ' AND ' + 
                                           '(' + 'CALENDAR_MONTH(convertTimezone(cp_calm__st__c)) < ' + month +
                                               ' OR ' + 
                                               '(' + 
                                                   'CALENDAR_MONTH(convertTimezone(cp_calm__st__c)) = ' + month + 
                                                   ' AND DAY_IN_MONTH(convertTimezone(cp_calm__st__c)) < ' + day +
                                               ')' + 
                                           ')' +
                                      ')' +
                                  ')'
                                  ;
          session_objects = database.query(session_query);
          for (cp_calm__Session__c session : session_objects) {
             sessions.put(session.cp_calm__u__c, session);
          }
          
          String query = 'SELECT id, cp_calm__su__c FROM cp_calm__Action__c';
          
          actions_to_delete = new List<cp_calm__Action__c>();
          return Database.getQueryLocator(query);
	}
	global void execute(Database.BatchableContext BC, List<cp_calm__Action__c> scope) {   
		for(cp_calm__Action__c a : scope) {
            if (sessions.containsKey(a.cp_calm__su__c)) {
              actions_to_delete.add(a);
            }          
        }
    }
   
    global void finish(Database.BatchableContext BC)
    {
   		delete actions_to_delete;
        delete session_objects;
    }
}