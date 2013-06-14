global class BGMonthlyCountryUsersSweeper implements Database.Batchable<sObject>,Database.Stateful
{
   	global Date sweepDay = date.today().addDays(-1);
   	global Date sweepMonth = sweepDay.toStartOfMonth();
   	global Map<String, String> appKeyToDayField = new Map<String, String>();

   	global Database.QueryLocator start(Database.BatchableContext BC)
   	{
   		Integer dayOffset = 0;
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
      	sweepMonth = sweepDay.toStartOfMonth();
      	*/

   		String dayFieldList = '';
      	Set<String> dayFieldSet = new Set<String>();
      	for (cp_calm__BG_Summary__c summary : [SELECT cp_calm__au__c, cp_calm__today__c FROM cp_calm__BG_Summary__c]) {
      		String dayToday = summary.cp_calm__today__c;
      		String dayField = 'cp_calm__' + summary.cp_calm__today__c + '__c';
   			if (dayOffset > 0) {
	   			Integer day_number = Integer.valueOf(dayToday.removeStart('d')) - dayOffset;
	   			while (day_number < 1) {
	   				day_number = day_number + 60;
	   			}
	   			dayField = 'cp_calm__d' + day_number + '__c';
   			}
      		if (!dayFieldSet.contains(dayField)) {
      			dayFieldList = dayFieldList + dayField + ', ';
      			dayFieldSet.add(dayField);
      		}
      		appKeyToDayField.put(summary.cp_calm__au__c, dayField);
      	}
      	
      	String query = 'SELECT ' + dayFieldList + 'cp_calm__key__c, cp_calm__au__c FROM cp_calm__BG_Country_Users__c';
   		
      	return Database.getQueryLocator(query);
   	}
   	
   	global void execute(Database.BatchableContext BC, List<cp_calm__BG_Country_Users__c> scope)
   	{
   		Set<ID> sweeperIDs = new Set<ID>(); 
   		List<cp_calm__BG_Monthly_Country__c> sweepersToUpdate = new List<cp_calm__BG_Monthly_Country__c>();
   		List<cp_calm__BG_Monthly_Country__c> sweepersToInsert = new List<cp_calm__BG_Monthly_Country__c>();
   		for (cp_calm__BG_Country_Users__c s : scope) {
   			String versionKey = s.cp_calm__key__c;
   			String appKey = s.cp_calm__au__c;
   			String day_field = appKeyToDayField.get(appKey);
   			
			List<cp_calm__BG_Monthly_Country__c> sweepers = [SELECT cp_calm__au__c, cp_calm__Month__c, cp_calm__uc__c FROM cp_calm__BG_Monthly_Country__c WHERE CALENDAR_MONTH(cp_calm__Month__c)=:sweepDay.month() AND CALENDAR_YEAR(cp_calm__Month__c)=:sweepDay.year() AND cp_calm__au__c=:appKey AND cp_calm__key__c=:versionKey];
			if (sweepers.size() == 0) {
				cp_calm__BG_Monthly_Country__c sweeper = new cp_calm__BG_Monthly_Country__c();
				sweeper.cp_calm__au__c = appKey;
				sweeper.cp_calm__key__c = versionKey;
				sweeper.cp_calm__Month__c = sweepMonth;
				sweeper.cp_calm__uc__c = Integer.valueOf(s.get(day_field));
				sweepersToInsert.add(sweeper);
			} else {
				cp_calm__BG_Monthly_Country__c sweeper = sweepers.get(0);
				if (sweeper.cp_calm__uc__c == -1) {
				sweeper.cp_calm__uc__c = Integer.valueOf(s.get(day_field));
				} else {
				sweeper.cp_calm__uc__c = sweeper.cp_calm__uc__c + Integer.valueOf(s.get(day_field));
				}
				if (!sweeperIDs.contains(sweeper.id)) {
					sweepersToUpdate.add(sweeper);
				}
				sweeperIDs.add(sweeper.id);
			}
		}
		if (sweepersToInsert.size() > 0) {
			insert sweepersToInsert;
		}
		if (sweepersToUpdate.size() > 0) {
			update sweepersToUpdate;
		}
	}
   
   	global void finish(Database.BatchableContext BC)
   	{
   		// Sweepers run in alphabetical order:
   		// BGMonthlyAppVersionSessionsSweeper
   		// BGMonthlyAppVersionUsersSweeper
   		// BGMonthlyCountrySessionsSweeper
   		// BGMonthlyCountryUsersSweeper
   		// BGMonthlyEventsSweeper
   		// BGMonthlyNetworkCarrierSessionsSweeper
   		// BGMonthlyNetworkCarrierUsersSweeper
   		// BGMonthlySessionLengthSweeper
   		BGMonthlyEventsSweeper sweeper = new BGMonthlyEventsSweeper();
    	Database.executeBatch(sweeper);
   	}
}