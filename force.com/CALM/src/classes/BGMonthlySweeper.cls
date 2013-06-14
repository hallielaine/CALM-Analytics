global class BGMonthlySweeper implements Database.Batchable<sObject>,Database.Stateful
{
	global List<cp_calm__BG_Monthly_App_Version__c> appVersionSweepers;
	global List<cp_calm__BG_Monthly_Country__c> countrySweepers;
	global List<cp_calm__BG_Monthly_Network_Carrier__c> networkCarrierSweepers;
	global List<cp_calm__BG_Monthly_Session_Length__c> sessionLengthSweepers;
   	global Set<String> appKeys = new Set<String>();
   	global Map<String, Map<String, cp_calm__BG_Monthly_App_Version__c>> appKeysToKeysToAppVersionSweeper = new Map<String, Map<String, cp_calm__BG_Monthly_App_Version__c>>();
   	global Map<String, Map<String, cp_calm__BG_Monthly_Country__c>> appKeysToKeysToCountrySweeper = new Map<String, Map<String, cp_calm__BG_Monthly_Country__c>>();
   	global Map<String, Map<String, cp_calm__BG_Monthly_Network_Carrier__c>> appKeysToKeysToNetworkCarrierSweeper = new Map<String, Map<String, cp_calm__BG_Monthly_Network_Carrier__c>>();
   	global Map<String, Map<String, cp_calm__BG_Monthly_Session_Length__c>> appKeysToKeysToSessionLengthSweeper = new Map<String, Map<String, cp_calm__BG_Monthly_Session_Length__c>>();
   	global Integer dayOffset = 0;
   	global Date sweepDay = date.today().addDays(-1);
   	global Date sweepMonth = sweepDay.toStartOfMonth();

   	global Database.QueryLocator start(Database.BatchableContext BC)
   	{
      	String query = 'SELECT cp_calm__au__c, cp_calm__today__c FROM cp_calm__BG_Summary__c';
      	
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
      	filler.cp_calm__offset__c = dayOffset + 1;
      	update filler;
      	
      	sweepDay = sweepDay.addDays(-dayOffset);
      	sweepMonth = sweepDay.toStartOfMonth();
      	*/
      	
      	appVersionSweepers = [SELECT cp_calm__au__c, cp_calm__Month__c, cp_calm__sc__c, cp_calm__uc__c FROM cp_calm__BG_Monthly_App_Version__c WHERE CALENDAR_MONTH(cp_calm__Month__c)=:sweepDay.month() AND CALENDAR_YEAR(cp_calm__Month__c)=:sweepDay.year()]; 
      	countrySweepers = [SELECT cp_calm__au__c, cp_calm__Month__c, cp_calm__sc__c, cp_calm__uc__c FROM cp_calm__BG_Monthly_Country__c WHERE CALENDAR_MONTH(cp_calm__Month__c)=:sweepDay.month() AND CALENDAR_YEAR(cp_calm__Month__c)=:sweepDay.year()]; 
      	networkCarrierSweepers = [SELECT cp_calm__au__c, cp_calm__Month__c, cp_calm__sc__c, cp_calm__uc__c FROM cp_calm__BG_Monthly_Network_Carrier__c WHERE CALENDAR_MONTH(cp_calm__Month__c)=:sweepDay.month() AND CALENDAR_YEAR(cp_calm__Month__c)=:sweepDay.year()]; 
      	sessionLengthSweepers = [SELECT cp_calm__au__c, cp_calm__Month__c, cp_calm__Count__c FROM cp_calm__BG_Monthly_Session_Length__c WHERE CALENDAR_MONTH(cp_calm__Month__c)=:sweepDay.month() AND CALENDAR_YEAR(cp_calm__Month__c)=:sweepDay.year()];
      	
      	// get the all app keys
      	List<AggregateResult> appKeyAggregate = [SELECT cp_calm__au__c FROM cp_calm__BG_Summary__c GROUP BY cp_calm__au__c];
      	for (AggregateResult aggregate : appKeyAggregate) {
      		appKeys.add((String)aggregate.get('cp_calm__au__c'));
      	}
      
      /*
      	// Map app keys to sweepers
      	for (cp_calm__BG_Monthly_App_Version__c swp : appVersionSweepers) {
      		// TODO verify
      		Map<String, cp_calm__BG_Monthly_App_Version__c> keysToAppVersionSweeper = appKeysToKeysToAppVersionSweeper.get(swp.cp_calm__au__c);
      		if (keysToAppVersionSweeper == null) {
      			keysToAppVersionSweeper = new Map<String, cp_calm__BG_Monthly_App_Version__c>();
      		}
      		keysToAppVersionSweeper.put(swp.cp_calm__key__c, swp);
          	appKeysToKeysToAppVersionSweeper.put(swp.cp_calm__au__c, keysToAppVersionSweeper);
      	}
      
      	// Map app keys to sweepers
      	for (cp_calm__BG_Monthly_Country__c swp : countrySweepers) {
      		// TODO verify
      		Map<String, cp_calm__BG_Monthly_Country__c> keysToCountrySweeper = appKeysToKeysToCountrySweeper.get(swp.cp_calm__au__c);
      		if (keysToCountrySweeper == null) {
      			keysToCountrySweeper = new Map<String, cp_calm__BG_Monthly_Country__c>();
      		}
      		keysToCountrySweeper.put(swp.cp_calm__key__c, swp);
          	appKeysToKeysToCountrySweeper.put(swp.cp_calm__au__c, keysToCountrySweeper);
      	}
      
      	// Map app keys to sweepers
      	for (cp_calm__BG_Monthly_Network_Carrier__c swp : networkCarrierSweepers) {
      		// TODO verify
      		Map<String, cp_calm__BG_Monthly_Network_Carrier__c> keysToNetworkCarrierSweeper = appKeysToKeysToNetworkCarrierSweeper.get(swp.cp_calm__au__c);
      		if (keysToNetworkCarrierSweeper == null) {
      			keysToNetworkCarrierSweeper = new Map<String, cp_calm__BG_Monthly_Network_Carrier__c>();
      		}
      		keysToNetworkCarrierSweeper.put(swp.cp_calm__key__c, swp);
          	appKeysToKeysToNetworkCarrierSweeper.put(swp.cp_calm__au__c, keysToNetworkCarrierSweeper);
      	}
      
      	// Map app keys to sweepers
      	for (cp_calm__BG_Monthly_Session_Length__c swp : sessionLengthSweepers) {
      		// TODO verify
      		Map<String, cp_calm__BG_Monthly_Session_Length__c> keysToSessionLengthSweeper = appKeysToKeysToSessionLengthSweeper.get(swp.cp_calm__au__c);
      		if (keysToSessionLengthSweeper == null) {
      			keysToSessionLengthSweeper = new Map<String, cp_calm__BG_Monthly_Session_Length__c>();
      		}
      		keysToSessionLengthSweeper.put(swp.cp_calm__key__c, swp);
          	appKeysToKeysToSessionLengthSweeper.put(swp.cp_calm__au__c, keysToSessionLengthSweeper);
      	}
      	*/
      	
      	return Database.getQueryLocator(query);
   	}
   	
   	global void execute(Database.BatchableContext BC, List<cp_calm__BG_Summary__c> scope)
   	{
   		for (cp_calm__BG_Summary__c s : scope) {
   			String day_field = 'cp_calm__' + s.cp_calm__today__c + '__c';
   			
   			if (dayOffset > 0) {
	   			Integer day_number = Integer.valueOf(s.cp_calm__today__c.removeStart('d')) - dayOffset;
	   			while (day_number < 1) {
	   				day_number = day_number + 60;
	   			}
	   			day_field = 'cp_calm__d' + day_number + '__c';
   			}
   			
   			String appKey = s.cp_calm__au__c;
   			
			List<cp_calm__BG_App_Version_Sessions__c> appVersionSessions = database.query('SELECT cp_calm__key__c, ' + day_field + ' FROM cp_calm__BG_App_Version_Sessions__c WHERE cp_calm__au__c = \''+appKey+'\'');
			for (cp_calm__BG_App_Version_Sessions__c appVersion : appVersionSessions) {
				cp_calm__BG_Monthly_App_Version__c sweeper = [SELECT cp_calm__au__c, cp_calm__Month__c, cp_calm__sc__c FROM cp_calm__BG_Monthly_App_Version__c WHERE CALENDAR_MONTH(cp_calm__Month__c)=:sweepDay.month() AND CALENDAR_YEAR(cp_calm__Month__c)=:sweepDay.year() AND cp_calm__au__c=:appKey AND cp_calm__key__c=:appVersion.cp_calm__key__c];
				if (sweeper == null) {
					sweeper = new cp_calm__BG_Monthly_App_Version__c();
					sweeper.cp_calm__au__c = appKey;
					sweeper.cp_calm__key__c = appVersion.cp_calm__key__c;
					sweeper.cp_calm__Month__c = sweepMonth;
					sweeper.cp_calm__sc__c = Integer.valueOf(appVersion.get(day_field));
					insert sweeper;
				} else {
					if (sweeper.cp_calm__sc__c == -1) {
						sweeper.cp_calm__sc__c = Integer.valueOf(appVersion.get(day_field));
					} else {
						sweeper.cp_calm__sc__c = sweeper.cp_calm__sc__c + Integer.valueOf(appVersion.get(day_field));
					}
					update sweeper;
				}
			}
   			
			List<cp_calm__BG_App_Version_Users__c> appVersionUsers = database.query('SELECT cp_calm__key__c, ' + day_field + ' FROM cp_calm__BG_App_Version_Users__c WHERE cp_calm__au__c = \''+appKey+'\'');
			for (cp_calm__BG_App_Version_Users__c appVersion : appVersionUsers) {
				cp_calm__BG_Monthly_App_Version__c sweeper = [SELECT cp_calm__au__c, cp_calm__Month__c, cp_calm__uc__c FROM cp_calm__BG_Monthly_App_Version__c WHERE CALENDAR_MONTH(cp_calm__Month__c)=:sweepDay.month() AND CALENDAR_YEAR(cp_calm__Month__c)=:sweepDay.year() AND cp_calm__au__c=:appKey AND cp_calm__key__c=:appVersion.cp_calm__key__c];
				if (sweeper == null) {
					sweeper = new cp_calm__BG_Monthly_App_Version__c();
					sweeper.cp_calm__au__c = appKey;
					sweeper.cp_calm__key__c = appVersion.cp_calm__key__c;
					sweeper.cp_calm__Month__c = sweepMonth;
					sweeper.cp_calm__uc__c = Integer.valueOf(appVersion.get(day_field));
					insert sweeper;
				} else {
					if (sweeper.cp_calm__uc__c == -1) {
						sweeper.cp_calm__uc__c = Integer.valueOf(appVersion.get(day_field));
					} else {
						sweeper.cp_calm__uc__c = sweeper.cp_calm__uc__c + Integer.valueOf(appVersion.get(day_field));
					}
					update sweeper;
				}
			}
   			
			List<cp_calm__BG_Country_Sessions__c> countrySessions = database.query('SELECT cp_calm__key__c, ' + day_field + ' FROM cp_calm__BG_Country_Sessions__c WHERE cp_calm__au__c = \''+appKey+'\'');
			for (cp_calm__BG_Country_Sessions__c country : countrySessions) {
				cp_calm__BG_Monthly_Country__c sweeper = [SELECT cp_calm__au__c, cp_calm__Month__c, cp_calm__sc__c FROM cp_calm__BG_Monthly_Country__c WHERE CALENDAR_MONTH(cp_calm__Month__c)=:sweepDay.month() AND CALENDAR_YEAR(cp_calm__Month__c)=:sweepDay.year() AND cp_calm__au__c=:appKey AND cp_calm__key__c=:country.cp_calm__key__c];
				if (sweeper == null) {
					sweeper = new cp_calm__BG_Monthly_Country__c();
					sweeper.cp_calm__au__c = appKey;
					sweeper.cp_calm__key__c = country.cp_calm__key__c;
					sweeper.cp_calm__Month__c = sweepMonth;
					sweeper.cp_calm__sc__c = Integer.valueOf(country.get(day_field));
					insert sweeper;
				} else {
					if (sweeper.cp_calm__sc__c == -1) {
						sweeper.cp_calm__sc__c = Integer.valueOf(country.get(day_field));
					} else {
						sweeper.cp_calm__sc__c = sweeper.cp_calm__sc__c + Integer.valueOf(country.get(day_field));
					}
					update sweeper;
				}
			}
   			
			List<cp_calm__BG_Country_Users__c> countryUsers = database.query('SELECT cp_calm__key__c, ' + day_field + ' FROM cp_calm__BG_Country_Users__c WHERE cp_calm__au__c = \''+appKey+'\'');
			for (cp_calm__BG_Country_Users__c country : countryUsers) {
				cp_calm__BG_Monthly_Country__c sweeper = [SELECT cp_calm__au__c, cp_calm__Month__c, cp_calm__uc__c FROM cp_calm__BG_Monthly_Country__c WHERE CALENDAR_MONTH(cp_calm__Month__c)=:sweepDay.month() AND CALENDAR_YEAR(cp_calm__Month__c)=:sweepDay.year() AND cp_calm__au__c=:appKey AND cp_calm__key__c=:country.cp_calm__key__c];
				if (sweeper == null) {
					sweeper = new cp_calm__BG_Monthly_Country__c();
					sweeper.cp_calm__au__c = appKey;
					sweeper.cp_calm__key__c = country.cp_calm__key__c;
					sweeper.cp_calm__Month__c = sweepMonth;
					sweeper.cp_calm__uc__c = Integer.valueOf(country.get(day_field));
					insert sweeper;
				} else {
					if (sweeper.cp_calm__uc__c == -1) {
						sweeper.cp_calm__uc__c = Integer.valueOf(country.get(day_field));
					} else {
						sweeper.cp_calm__uc__c = sweeper.cp_calm__uc__c + Integer.valueOf(country.get(day_field));
					}
					update sweeper;
				}
			}
   			
			List<cp_calm__BG_Network_Carrier_Sessions__c> networkCarrierSessions = database.query('SELECT cp_calm__key__c, ' + day_field + ' FROM cp_calm__BG_Network_Carrier_Sessions__c WHERE cp_calm__au__c = \''+appKey+'\'');
			for (cp_calm__BG_Network_Carrier_Sessions__c networkCarrier : networkCarrierSessions) {
				cp_calm__BG_Monthly_Network_Carrier__c sweeper = [SELECT cp_calm__au__c, cp_calm__Month__c, cp_calm__sc__c FROM cp_calm__BG_Monthly_Network_Carrier__c WHERE CALENDAR_MONTH(cp_calm__Month__c)=:sweepDay.month() AND CALENDAR_YEAR(cp_calm__Month__c)=:sweepDay.year() AND cp_calm__au__c=:appKey AND cp_calm__key__c=:networkCarrier.cp_calm__key__c];
				if (sweeper == null) {
					sweeper = new cp_calm__BG_Monthly_Network_Carrier__c();
					sweeper.cp_calm__au__c = appKey;
					sweeper.cp_calm__key__c = networkCarrier.cp_calm__key__c;
					sweeper.cp_calm__Month__c = sweepMonth;
					sweeper.cp_calm__sc__c = Integer.valueOf(networkCarrier.get(day_field));
					insert sweeper;
				} else {
					if (sweeper.cp_calm__sc__c == -1) {
						sweeper.cp_calm__sc__c = Integer.valueOf(networkCarrier.get(day_field));
					} else {
						sweeper.cp_calm__sc__c = sweeper.cp_calm__sc__c + Integer.valueOf(networkCarrier.get(day_field));
					}
					update sweeper;
				}
			}
   			
			List<cp_calm__BG_Network_Carrier_Users__c> networkCarrierUsers = database.query('SELECT cp_calm__key__c, ' + day_field + ' FROM cp_calm__BG_Network_Carrier_Users__c WHERE cp_calm__au__c = \''+appKey+'\'');
			for (cp_calm__BG_Network_Carrier_Users__c networkCarrier : networkCarrierUsers) {
				cp_calm__BG_Monthly_Network_Carrier__c sweeper = [SELECT cp_calm__au__c, cp_calm__Month__c, cp_calm__uc__c FROM cp_calm__BG_Monthly_Network_Carrier__c WHERE CALENDAR_MONTH(cp_calm__Month__c)=:sweepDay.month() AND CALENDAR_YEAR(cp_calm__Month__c)=:sweepDay.year() AND cp_calm__au__c=:appKey AND cp_calm__key__c=:networkCarrier.cp_calm__key__c];
				if (sweeper == null) {
					sweeper = new cp_calm__BG_Monthly_Network_Carrier__c();
					sweeper.cp_calm__au__c = appKey;
					sweeper.cp_calm__key__c = networkCarrier.cp_calm__key__c;
					sweeper.cp_calm__Month__c = sweepMonth;
					sweeper.cp_calm__uc__c = Integer.valueOf(networkCarrier.get(day_field));
					insert sweeper;
				} else {
					if (sweeper.cp_calm__uc__c == -1) {
						sweeper.cp_calm__uc__c = Integer.valueOf(networkCarrier.get(day_field));
					} else {
						sweeper.cp_calm__uc__c = sweeper.cp_calm__uc__c + Integer.valueOf(networkCarrier.get(day_field));
					}
					update sweeper;
				}
			}
   			
			List<cp_calm__BG_Session_Length__c> sessionLengthUsers = database.query('SELECT cp_calm__key__c, ' + day_field + ' FROM cp_calm__BG_Session_Length__c WHERE cp_calm__au__c = \''+appKey+'\'');
			for (cp_calm__BG_Session_Length__c sessionLength : sessionLengthUsers) {
				cp_calm__BG_Monthly_Session_Length__c sweeper = [SELECT cp_calm__au__c, cp_calm__Month__c, cp_calm__count__c FROM cp_calm__BG_Monthly_Session_Length__c WHERE CALENDAR_MONTH(cp_calm__Month__c)=:sweepDay.month() AND CALENDAR_YEAR(cp_calm__Month__c)=:sweepDay.year() AND cp_calm__au__c=:appKey AND cp_calm__key__c=:sessionLength.cp_calm__key__c];
				if (sweeper == null) {
					sweeper = new cp_calm__BG_Monthly_Session_Length__c();
					sweeper.cp_calm__au__c = appKey;
					sweeper.cp_calm__key__c = sessionLength.cp_calm__key__c;
					sweeper.cp_calm__Month__c = sweepMonth;
					sweeper.cp_calm__count__c = Integer.valueOf(sessionLength.get(day_field));
					insert sweeper;
				} else {
					if (sweeper.cp_calm__count__c == -1) {
						sweeper.cp_calm__count__c = Integer.valueOf(sessionLength.get(day_field));
					} else {
						sweeper.cp_calm__count__c = sweeper.cp_calm__count__c + Integer.valueOf(sessionLength.get(day_field));
					}
					update sweeper;
				}
			}
   		}
   	}
   
   	global void finish(Database.BatchableContext BC)
   	{
   		// TODO implement
   	}
}