global class MonthlySweeper implements Database.Batchable<sObject>,Database.Stateful
{
	global List<cp_calm__LG_Monthly_Summary__c> sweepers;
   	global Set<String> appKeys = new Set<String>();
   	global Map<String, cp_calm__LG_Monthly_Summary__c> appKeysToSweeper = new Map<String, cp_calm__LG_Monthly_Summary__c>();
   	global Integer dayOffset = 0;
   	global Date sweepDay = date.today().addDays(-1);

   	global Database.QueryLocator start(Database.BatchableContext BC)
   	{
      	String query = 'SELECT cp_calm__au__c, cp_calm__today__c FROM cp_calm__LG_Summary__c';
      	
      	/* This was used to backfill the monthly sweeper without having to manually run the sweeper 60 times
      	List<cp_calm__Monthly_Filler__c> fillerList = [SELECT cp_calm__offset__c FROM cp_calm__monthly_filler__c LIMIT 1];
      	cp_calm__Monthly_Filler__c filler;
      	if (fillerList.size() == 0) {
      		filler = new cp_calm__Monthly_Filler__c();
      		filler.cp_calm__offset__c = 0;
      		insert filler;
      	}
      	else {
      		filler = fillerList.get(0);
      	}
      	dayOffset = Integer.valueOf(filler.cp_calm__offset__c);
      	
      	sweepDay = sweepDay.addDays(-dayOffset);
      	*/
      	
      	sweepers = [SELECT cp_calm__au__c, cp_calm__Month__c, cp_calm__New_Sessions__c, cp_calm__New_Users__c, cp_calm__Returning_Sessions__c, cp_calm__Returning_Users__c FROM cp_calm__LG_Monthly_Summary__c WHERE CALENDAR_MONTH(cp_calm__Month__c)=:sweepDay.month() AND CALENDAR_YEAR(cp_calm__Month__c)=:sweepDay.year()];
      
      	// get the all app keys
      	List<AggregateResult> appKeyAggregate = [SELECT cp_calm__au__c FROM cp_calm__LG_Summary__c GROUP BY cp_calm__au__c];
      	for (AggregateResult aggregate : appKeyAggregate) {
      		appKeys.add((String)aggregate.get('cp_calm__au__c'));
      	}
      
      	// Map app keys to sweepers
      	for (cp_calm__LG_Monthly_Summary__c swp : sweepers) {
          	appKeysToSweeper.put(swp.cp_calm__au__c, swp);
      	}
      
      	if (sweepers.size() != appKeys.size()) {
          	// get a list of app keys that don't have sweeper objects
          	Set<String> unrecordedAppKeys = appKeys.clone();
          	for (cp_calm__LG_Monthly_Summary__c sweeper : sweepers) {
      	    	unrecordedAppKeys.remove(sweeper.cp_calm__au__c);
          	}
      
	      	// create sweeper objects for missing app keys
	      	for (String appKey : unrecordedAppKeys) {
	      		cp_calm__LG_Monthly_Summary__c sweeper = new cp_calm__LG_Monthly_Summary__c();
				sweeper.cp_calm__au__c = appKey;
	      		sweeper.cp_calm__Month__c = sweepDay.toStartOfMonth();
	      		sweeper.cp_calm__New_Sessions__c = -1;
	      		sweeper.cp_calm__New_Users__c = -1;
	      		sweeper.cp_calm__Returning_Sessions__c = -1;
	      		sweeper.cp_calm__Returning_Users__c = -1;
          		appKeysToSweeper.put(appKey, sweeper);
	      		insert sweeper;
	      	}
      	}
      
      	return Database.getQueryLocator(query);
	}
   
   	global void execute(Database.BatchableContext BC, List<cp_calm__LG_Summary__c> scope)
   	{
   		for (cp_calm__LG_Summary__c s : scope) {
   			String day_field = 'cp_calm__' + s.cp_calm__today__c + '__c';
   			
   			system.debug(dayOffset);
   			if (dayOffset > 0) {
	   			Integer day_number = Integer.valueOf(s.cp_calm__today__c.removeStart('d')) - dayOffset;
	   			while (day_number < 1) {
	   				day_number = day_number + 60;
	   			}
	   			day_field = 'cp_calm__d' + day_number + '__c';
   			}
   			
   			String appKey = s.cp_calm__au__c;
   			cp_calm__LG_Monthly_Summary__c sweeper = appKeysToSweeper.get(appKey);

   			cp_calm__LG_New_Sessions__c new_sessions = database.query('SELECT ' + day_field + ' FROM cp_calm__LG_New_Sessions__c WHERE cp_calm__au__c = \''+appKey+'\'');
   			if (new_sessions != null) {
   				if(sweeper.cp_calm__New_Sessions__c == -1) {
   					sweeper.cp_calm__New_Sessions__c = 0;
   				}
   				system.debug(new_sessions);
   				system.debug(new_sessions.get(day_field));
   				system.debug(sweeper);
   				system.debug(sweeper.cp_calm__New_Sessions__c);
   				sweeper.cp_calm__New_Sessions__c = sweeper.cp_calm__New_Sessions__c + Integer.valueOf(new_sessions.get(day_field));
   			}
   			
   			cp_calm__LG_New_Users__c new_users = database.query('SELECT ' + day_field + ' FROM cp_calm__LG_New_Users__c WHERE cp_calm__au__c = \''+appKey+'\'');
	   		if (new_users != null) {
	   			if(sweeper.cp_calm__New_Users__c == -1) {
	   				sweeper.cp_calm__New_Users__c = 0;
	   			}
	   			sweeper.cp_calm__New_Users__c = sweeper.cp_calm__New_Users__c + Integer.valueOf(new_users.get(day_field));
	   		}
	   		
   			cp_calm__LG_Returning_Sessions__c ret_sessions = database.query('SELECT ' + day_field + ' FROM cp_calm__LG_Returning_Sessions__c WHERE cp_calm__au__c = \''+appKey+'\'');
   			if (ret_sessions != null) {
	   			if(sweeper.cp_calm__Returning_Sessions__c == -1) {
	   				sweeper.cp_calm__Returning_Sessions__c = 0;
	   			}
	   			sweeper.cp_calm__Returning_Sessions__c = sweeper.cp_calm__Returning_Sessions__c + Integer.valueOf(ret_sessions.get(day_field));
   			}
   			
   			cp_calm__LG_Returning_Users__c ret_users = database.query('SELECT ' + day_field + ' FROM cp_calm__LG_Returning_Users__c WHERE cp_calm__au__c = \''+appKey+'\'');
   			if (ret_users != null) {
	   			if(sweeper.cp_calm__Returning_Users__c == -1) {
	   				sweeper.cp_calm__Returning_Users__c = 0;
	   			}
	   			sweeper.cp_calm__Returning_Users__c = sweeper.cp_calm__Returning_Users__c + Integer.valueOf(ret_users.get(day_field));
   			}
   			   			
   			update sweeper;
   		}
  	}
   
   	global void finish(Database.BatchableContext BC)
   	{
   		/*
   		if (dayOffset + 1 < 60) {
   			MonthlySweeper sweeper = new MonthlySweeper();
        	Database.executeBatch(sweeper);
   		} else {
   		*/
   		BGMonthlyAppVersionSessionsSweeper sweeper = new BGMonthlyAppVersionSessionsSweeper();
        Database.executeBatch(sweeper);
        /*
        }
        */
   	}
}