global class BaseTest {
	private static Date now = date.today().addDays(-1);
	private static Date tomm = date.today();
	private static Time startTime = Time.newInstance(5, 0, 0, 0);
	private static Time endTime = Time.newInstance(5, 30, 0, 0); 
	
	public static void setTestDate(Date newDate) {
		now = newDate;
	}
    
    public static void setTestStartTime(Time sTime) {
        startTime = sTime;
	}
    
    public static void setTestEndTime(Time eTime) {
    	endTime = eTime;	
    }
    
    public static DateTime getTestStartDate() {
    	return now.addDays(-59);
    }
    
    public static DateTime getTestEndDate() {
    	return now;
    }
    
    public static List<cp_calm__Session__c> setupSessions() {
        List<cp_calm__Session__c > sessions;
        cp_calm__Session__c complete_session1 = new cp_calm__Session__c(cp_calm__au__c = 'appKey1', cp_calm__u__c = '1', cp_calm__dov__c = 'ut', cp_calm__lv__c = 'ut', cp_calm__av__c = 'ut', cp_calm__dlc__c = 'ut', cp_calm__dma__c = 'ut', cp_calm__dmo__c = 'ut', cp_calm__dll__c = 'ut', cp_calm__st__c = datetime.newinstance(now,startTime) , cp_calm__et__c = datetime.newinstance(now,endTime), cp_calm__du__c = 'ut', cp_calm__nca__c = 'ut', cp_calm__nr__c = 'y');
        cp_calm__Session__c complete_session2 = new cp_calm__Session__c(cp_calm__au__c = 'appKey2', cp_calm__u__c = '2', cp_calm__dov__c = 'ut', cp_calm__lv__c = 'ut', cp_calm__av__c = 'ut', cp_calm__dlc__c = 'ut', cp_calm__dma__c = 'ut', cp_calm__dmo__c = 'ut', cp_calm__dll__c = 'ut', cp_calm__st__c = datetime.newinstance(now,startTime), cp_calm__et__c = datetime.newinstance(now,endTime), cp_calm__du__c = 'ut', cp_calm__nca__c = 'ut', cp_calm__nr__c = 'y');
        cp_calm__Session__c incomplete_session = new cp_calm__Session__c(cp_calm__au__c = 'appKey3', cp_calm__u__c = '3', cp_calm__dov__c = 'ut', cp_calm__lv__c = 'ut', cp_calm__av__c = 'ut', cp_calm__dlc__c = 'ut', cp_calm__dma__c = 'ut', cp_calm__dmo__c = 'ut', cp_calm__dll__c = 'ut', cp_calm__st__c = datetime.newinstance(now,startTime), cp_calm__du__c = 'ut', cp_calm__nca__c = 'ut', cp_calm__nr__c = 'y');
      
        //Creates two session with appKey = apex_test and SessionIDs = 1 and 2, with unused dummy values for everything else
        sessions = new List<cp_calm__Session__c>();
        sessions.add(complete_session1);
        sessions.add(complete_session2);
        sessions.add(incomplete_session);
        return sessions;
    }
    
    public static List<cp_calm__Action__c> setupActions() {
        //Create actions
        List<cp_calm__Action__c> actions = new List<cp_calm__Action__c>();
        actions.add(new cp_calm__Action__c(cp_calm__n__c ='screen1', cp_calm__ct__c = now, cp_calm__su__c = '1', cp_calm__u__c = '1', cp_calm__dt__c = 's'));
        actions.add(new cp_calm__Action__c(cp_calm__n__c ='screen2', cp_calm__ct__c = now, cp_calm__su__c = '1', cp_calm__u__c = '2', cp_calm__dt__c = 's'));
        actions.add(new cp_calm__Action__c(cp_calm__n__c ='event1', cp_calm__ct__c = now, cp_calm__su__c = '2', cp_calm__u__c = '3', cp_calm__dt__c = 'e'));
        actions.add(new cp_calm__Action__c(cp_calm__n__c ='event2', cp_calm__ct__c = now, cp_calm__su__c = '2', cp_calm__u__c = '4', cp_calm__dt__c = 'e'));
        actions.add(new cp_calm__Action__c(cp_calm__n__c ='screen2', cp_calm__ct__c = now, cp_calm__su__c = '3', cp_calm__u__c = '5', cp_calm__dt__c = 's'));
        actions.add(new cp_calm__Action__c(cp_calm__n__c ='event2', cp_calm__ct__c = now, cp_calm__su__c = '3', cp_calm__u__c = '6', cp_calm__dt__c = 'e'));
        actions.add(new cp_calm__Action__c(cp_calm__n__c ='event1_session2', cp_calm__ct__c = now, cp_calm__su__c = '1', cp_calm__u__c = '7', cp_calm__dt__c = 'e'));
        actions.add(new cp_calm__Action__c(cp_calm__n__c ='screen1_session2', cp_calm__ct__c = now, cp_calm__su__c = '2', cp_calm__u__c = '8', cp_calm__dt__c = 's'));
        return actions;
    }
    
    public static List<cp_calm__Session__c> setupDeleteSessions() {
        List<cp_calm__Session__c > sessions;
        cp_calm__Session__c complete_session1 = new cp_calm__Session__c(cp_calm__au__c = 'appKey1', cp_calm__u__c = '1', cp_calm__dov__c = 'ut', cp_calm__lv__c = 'ut', cp_calm__av__c = 'ut', cp_calm__dlc__c = 'ut', cp_calm__dma__c = 'ut', cp_calm__dmo__c = 'ut', cp_calm__dll__c = 'ut', cp_calm__st__c = datetime.newinstance(now,startTime) , cp_calm__et__c = datetime.newinstance(now,endTime), cp_calm__du__c = 'ut', cp_calm__nca__c = 'ut', cp_calm__nr__c = 'y');
        cp_calm__Session__c complete_session2 = new cp_calm__Session__c(cp_calm__au__c = 'appKey2', cp_calm__u__c = '2', cp_calm__dov__c = 'ut', cp_calm__lv__c = 'ut', cp_calm__av__c = 'ut', cp_calm__dlc__c = 'ut', cp_calm__dma__c = 'ut', cp_calm__dmo__c = 'ut', cp_calm__dll__c = 'ut', cp_calm__st__c = datetime.newinstance(now,startTime), cp_calm__et__c = datetime.newinstance(now,endTime), cp_calm__du__c = 'ut', cp_calm__nca__c = 'ut', cp_calm__nr__c = 'y');
        cp_calm__Session__c incomplete_session = new cp_calm__Session__c(cp_calm__au__c = 'appKey3', cp_calm__u__c = '3', cp_calm__dov__c = 'ut', cp_calm__lv__c = 'ut', cp_calm__av__c = 'ut', cp_calm__dlc__c = 'ut', cp_calm__dma__c = 'ut', cp_calm__dmo__c = 'ut', cp_calm__dll__c = 'ut', cp_calm__st__c = datetime.newinstance(now,startTime), cp_calm__du__c = 'ut', cp_calm__nca__c = 'ut', cp_calm__nr__c = 'y');
        cp_calm__Session__c future_session = new cp_calm__Session__c(cp_calm__au__c = 'appKey4', cp_calm__u__c = '4', cp_calm__dov__c = 'ut', cp_calm__lv__c = 'ut', cp_calm__av__c = 'ut', cp_calm__dlc__c = 'ut', cp_calm__dma__c = 'ut', cp_calm__dmo__c = 'ut', cp_calm__dll__c = 'ut', cp_calm__st__c = datetime.newinstance(tomm,startTime), cp_calm__et__c = datetime.newinstance(tomm, endTime), cp_calm__du__c = 'ut', cp_calm__nca__c = 'ut', cp_calm__nr__c = 'y');
      
        //Creates two session with appKey = apex_test and SessionIDs = 1 and 2, with unused dummy values for everything else
        sessions = new List<cp_calm__Session__c>();
        sessions.add(complete_session1);
        sessions.add(complete_session2);
        sessions.add(incomplete_session);
        sessions.add(future_session);
        return sessions;
    }
    
    public static List<cp_calm__Action__c> setupDeleteActions() {
        //Create actions
        List<cp_calm__Action__c> actions = new List<cp_calm__Action__c>();
        actions.add(new cp_calm__Action__c(cp_calm__n__c ='screen1', cp_calm__ct__c = now, cp_calm__su__c = '1', cp_calm__u__c = '1', cp_calm__dt__c = 's'));
        actions.add(new cp_calm__Action__c(cp_calm__n__c ='screen2', cp_calm__ct__c = now, cp_calm__su__c = '1', cp_calm__u__c = '2', cp_calm__dt__c = 's'));
        actions.add(new cp_calm__Action__c(cp_calm__n__c ='event1', cp_calm__ct__c = now, cp_calm__su__c = '2', cp_calm__u__c = '3', cp_calm__dt__c = 'e'));
        actions.add(new cp_calm__Action__c(cp_calm__n__c ='event2', cp_calm__ct__c = now, cp_calm__su__c = '2', cp_calm__u__c = '4', cp_calm__dt__c = 'e'));
        actions.add(new cp_calm__Action__c(cp_calm__n__c ='screen2', cp_calm__ct__c = now, cp_calm__su__c = '3', cp_calm__u__c = '5', cp_calm__dt__c = 's'));
        actions.add(new cp_calm__Action__c(cp_calm__n__c ='event2', cp_calm__ct__c = now, cp_calm__su__c = '3', cp_calm__u__c = '6', cp_calm__dt__c = 'e'));
        actions.add(new cp_calm__Action__c(cp_calm__n__c ='event1_session2', cp_calm__ct__c = now, cp_calm__su__c = '1', cp_calm__u__c = '7', cp_calm__dt__c = 'e'));
        actions.add(new cp_calm__Action__c(cp_calm__n__c ='screen1_session2', cp_calm__ct__c = now, cp_calm__su__c = '2', cp_calm__u__c = '8', cp_calm__dt__c = 's'));
        actions.add(new cp_calm__Action__c(cp_calm__n__c ='event2', cp_calm__ct__c = now, cp_calm__su__c = '4', cp_calm__u__c = '9', cp_calm__dt__c = 'e'));
        return actions;
    }
    
    public static cp_calm__LG_Summary__c setupLGSummary(String appKey, Integer day) {
    	cp_calm__LG_Summary__c summary = new cp_calm__LG_Summary__c();
    	summary.cp_calm__au__c = appKey;
    	summary.cp_calm__today__c = 'd' + day;
    	return summary;
    }
    
    public static cp_calm__BG_Summary__c setupBGSummary(String appKey, Integer day) {
    	cp_calm__BG_Summary__c summary = new cp_calm__BG_Summary__c();
    	summary.cp_calm__au__c = appKey;
    	summary.cp_calm__today__c = 'd' + day;
    	return summary;
    }
    
    public static cp_calm__LG_Sessions__c setupLGSessions(String appKey) {
    	cp_calm__LG_Sessions__c sess = new cp_calm__LG_Sessions__c();
    	sess.cp_calm__au__c = appKey;
    	DailyFieldSetup.createDailyFields(sess);
    	for (Integer j = 1; j <= 60; j++) {
    		sess.put('cp_calm__d' + j + '__c', j);
    	}
    	return sess;
    }
    
    public static cp_calm__LG_Users__c setupLGUsers(String appKey) {
    	cp_calm__LG_Users__c user = new cp_calm__LG_Users__c();
    	user.cp_calm__au__c = appKey;
    	DailyFieldSetup.createDailyFields(user);
    	for (Integer j = 1; j <= 60; j++) {
    		user.put('cp_calm__d' + j + '__c', j);
    	}
    	return user;
    }
    
    public static cp_calm__LG_New_Sessions__c setupLGNewSessions(String appKey) {
    	cp_calm__LG_New_Sessions__c new_session = new cp_calm__LG_New_Sessions__c();
    	new_session.cp_calm__au__c = appKey;
    	DailyFieldSetup.createDailyFields(new_session);
    	for (Integer j = 1; j <= 60; j++) {
    		new_session.put('cp_calm__d' + j + '__c', j);
    	}
    	return new_session;
    }
    
    public static cp_calm__LG_Returning_Sessions__c setupLGReturningSessions(String appKey) {
    	cp_calm__LG_Returning_Sessions__c ret_session = new cp_calm__LG_Returning_Sessions__c();
    	ret_session.cp_calm__au__c = appKey;
    	DailyFieldSetup.createDailyFields(ret_session);
    	for (Integer j = 1; j <= 60; j++) {
    		ret_session.put('cp_calm__d' + j + '__c', j);
    	}
    	return ret_session;
    }
    
    public static cp_calm__LG_New_Users__c setupLGNewUsers(String appKey) {
    	cp_calm__LG_New_Users__c new_user = new cp_calm__LG_New_Users__c();
    	new_user.cp_calm__au__c = appKey;
    	DailyFieldSetup.createDailyFields(new_user);
    	for (Integer j = 1; j <= 60; j++) {
    		new_user.put('cp_calm__d' + j + '__c', j);
    	}
    	return new_user;
    }
    
    public static cp_calm__LG_Returning_Users__c setupLGReturningUsers(String appKey) {
    	cp_calm__LG_Returning_Users__c ret_user = new cp_calm__LG_Returning_Users__c();
    	ret_user.cp_calm__au__c = appKey;
    	DailyFieldSetup.createDailyFields(ret_user);
    	for (Integer j = 1; j <= 60; j++) {
    		ret_user.put('cp_calm__d' + j + '__c', j);
    	}
    	return ret_user;
    }
    
    public static List<cp_calm__BG_Events__c> setupBGEvents(String appKey, Integer numEvents) {
    	List<cp_calm__BG_Events__c> events = new List<cp_calm__BG_Events__c>();
    	for (Integer i = 0; i < numEvents; i++) {
    		cp_calm__BG_Events__c event = new cp_calm__BG_Events__c();
    		event.cp_calm__au__c = appKey;
    		event.cp_calm__key__c = 'event' + (i+1);
    		DailyFieldSetup.createDailyFields(event);
    		for (Integer j = 1; j <= 60; j++) {
    			event.put('cp_calm__d' + j + '__c', j);
    		}
    		events.add(event);
    	}
    	return events;
    }
    
    public static List<cp_calm__BG_Events__c> setupBGEventsConstant(String appKey, Integer value, Integer numEvents) {
    	List<cp_calm__BG_Events__c> events = new List<cp_calm__BG_Events__c>();
    	for (Integer i = 0; i < numEvents; i++) {
    		cp_calm__BG_Events__c event = new cp_calm__BG_Events__c();
    		event.cp_calm__au__c = appKey;
    		event.cp_calm__key__c = 'event' + (i+1);
    		DailyFieldSetup.createDailyFields(event);
    		for (Integer j = 1; j <= 60; j++) {
    			event.put('cp_calm__d' + j + '__c', value);
    		}
    		events.add(event);
    	}
    	return events;
    }
    
    public static List<cp_calm__BG_Events__c> setupBGEventsConstant(String appKey, String name, Integer value, Integer numEvents) {
    	List<cp_calm__BG_Events__c> events = new List<cp_calm__BG_Events__c>();
    	for (Integer i = 0; i < numEvents; i++) {
    		cp_calm__BG_Events__c event = new cp_calm__BG_Events__c();
    		event.cp_calm__au__c = appKey;
    		event.cp_calm__key__c = name;
    		DailyFieldSetup.createDailyFields(event);
    		for (Integer j = 1; j <= 60; j++) {
    			event.put('cp_calm__d' + j + '__c', value);
    		}
    		events.add(event);
    	}
    	return events;
    }
    
    public static List<cp_calm__BG_App_Version_Sessions__c> setupBGApp_Version_SessionsConstant(String appKey, String name, Integer value, Integer numApp_Version_Sessions) {
    	List<cp_calm__BG_App_Version_Sessions__c> app_versions = new List<cp_calm__BG_App_Version_Sessions__c>();
    	for (Integer i = 0; i < numApp_Version_Sessions; i++) {
    		cp_calm__BG_App_Version_Sessions__c app_version = new cp_calm__BG_App_Version_Sessions__c();
    		app_version.cp_calm__au__c = appKey;
    		app_version.cp_calm__key__c = name;
    		DailyFieldSetup.createDailyFields(app_version);
    		for (Integer j = 1; j <= 60; j++) {
    			app_version.put('cp_calm__d' + j + '__c', value);
    		}
    		app_versions.add(app_version);
    	}
    	return app_versions;
    }
    
    public static List<cp_calm__BG_App_Version_Users__c> setupBGApp_Version_UsersConstant(String appKey, String name, Integer value, Integer numApp_Version_Users) {
    	List<cp_calm__BG_App_Version_Users__c> app_versions = new List<cp_calm__BG_App_Version_Users__c>();
    	for (Integer i = 0; i < numApp_Version_Users; i++) {
    		cp_calm__BG_App_Version_Users__c app_version = new cp_calm__BG_App_Version_Users__c();
    		app_version.cp_calm__au__c = appKey;
    		app_version.cp_calm__key__c = name;
    		DailyFieldSetup.createDailyFields(app_version);
    		for (Integer j = 1; j <= 60; j++) {
    			app_version.put('cp_calm__d' + j + '__c', value);
    		}
    		app_versions.add(app_version);
    	}
    	return app_versions;
    }
    
    public static List<cp_calm__BG_Network_Carrier_Sessions__c> setupBGCarrier_SessionsConstant(String appKey, String name, Integer value, Integer numNetwork_Carrier_Sessions) {
    	List<cp_calm__BG_Network_Carrier_Sessions__c> app_versions = new List<cp_calm__BG_Network_Carrier_Sessions__c>();
    	for (Integer i = 0; i < numNetwork_Carrier_Sessions; i++) {
    		cp_calm__BG_Network_Carrier_Sessions__c app_version = new cp_calm__BG_Network_Carrier_Sessions__c();
    		app_version.cp_calm__au__c = appKey;
    		app_version.cp_calm__key__c = name;
    		DailyFieldSetup.createDailyFields(app_version);
    		for (Integer j = 1; j <= 60; j++) {
    			app_version.put('cp_calm__d' + j + '__c', value);
    		}
    		app_versions.add(app_version);
    	}
    	return app_versions;
    }
    
    public static List<cp_calm__BG_Network_Carrier_Users__c> setupBGCarrier_UsersConstant(String appKey, String name, Integer value, Integer numNetwork_Carrier_Users) {
    	List<cp_calm__BG_Network_Carrier_Users__c> app_versions = new List<cp_calm__BG_Network_Carrier_Users__c>();
    	for (Integer i = 0; i < numNetwork_Carrier_Users; i++) {
    		cp_calm__BG_Network_Carrier_Users__c app_version = new cp_calm__BG_Network_Carrier_Users__c();
    		app_version.cp_calm__au__c = appKey;
    		app_version.cp_calm__key__c = name;
    		DailyFieldSetup.createDailyFields(app_version);
    		for (Integer j = 1; j <= 60; j++) {
    			app_version.put('cp_calm__d' + j + '__c', value);
    		}
    		app_versions.add(app_version);
    	}
    	return app_versions;
    }
    
    public static List<cp_calm__BG_Country_Sessions__c> setupBGCountry_SessionsConstant(String appKey, String name, Integer value, Integer numCountry_Sessions) {
    	List<cp_calm__BG_Country_Sessions__c> app_versions = new List<cp_calm__BG_Country_Sessions__c>();
    	for (Integer i = 0; i < numCountry_Sessions; i++) {
    		cp_calm__BG_Country_Sessions__c app_version = new cp_calm__BG_Country_Sessions__c();
    		app_version.cp_calm__au__c = appKey;
    		app_version.cp_calm__key__c = name;
    		DailyFieldSetup.createDailyFields(app_version);
    		for (Integer j = 1; j <= 60; j++) {
    			app_version.put('cp_calm__d' + j + '__c', value);
    		}
    		app_versions.add(app_version);
    	}
    	return app_versions;
    }
    
    public static List<cp_calm__BG_Country_Users__c> setupBGCountry_UsersConstant(String appKey, String name, Integer value, Integer numCountry_Users) {
    	List<cp_calm__BG_Country_Users__c> app_versions = new List<cp_calm__BG_Country_Users__c>();
    	for (Integer i = 0; i < numCountry_Users; i++) {
    		cp_calm__BG_Country_Users__c app_version = new cp_calm__BG_Country_Users__c();
    		app_version.cp_calm__au__c = appKey;
    		app_version.cp_calm__key__c = name;
    		DailyFieldSetup.createDailyFields(app_version);
    		for (Integer j = 1; j <= 60; j++) {
    			app_version.put('cp_calm__d' + j + '__c', value);
    		}
    		app_versions.add(app_version);
    	}
    	return app_versions;
    }
    
    public static List<cp_calm__BG_Session_Length__c> setupSessionLengths(String appKey) {
    	List<cp_calm__BG_Session_Length__c> session_lengths = new List<cp_calm__BG_Session_Length__c>();
    	cp_calm__BG_Session_Length__c sl1 = new cp_calm__BG_Session_Length__c();
    	cp_calm__BG_Session_Length__c sl2 = new cp_calm__BG_Session_Length__c();
    	cp_calm__BG_Session_Length__c sl3 = new cp_calm__BG_Session_Length__c();
    	cp_calm__BG_Session_Length__c sl4 = new cp_calm__BG_Session_Length__c();
    	cp_calm__BG_Session_Length__c sl5 = new cp_calm__BG_Session_Length__c();
    	cp_calm__BG_Session_Length__c sl6 = new cp_calm__BG_Session_Length__c();
    	cp_calm__BG_Session_Length__c sl7 = new cp_calm__BG_Session_Length__c();
    	cp_calm__BG_Session_Length__c sl8 = new cp_calm__BG_Session_Length__c();
    	
    	sl1.cp_calm__au__c = appKey;
    	sl1.cp_calm__key__c = '0 to 10 seconds';
    	DailyFieldSetup.createDailyFields(sl1);
    	for (Integer j = 1; j <= 60; j++) {
    		sl1.put('cp_calm__d' + j + '__c', 1);
    	}
    	
    	sl2.cp_calm__au__c = appKey;
    	sl2.cp_calm__key__c = '11 to 30 seconds';
    	DailyFieldSetup.createDailyFields(sl2);
    	for (Integer j = 1; j <= 60; j++) {
    		sl2.put('cp_calm__d' + j + '__c', 1);
    	}
    	
    	sl3.cp_calm__au__c = appKey;
    	sl3.cp_calm__key__c = '31 to 60 seconds';
    	DailyFieldSetup.createDailyFields(sl3);
    	for (Integer j = 1; j <= 60; j++) {
    		sl3.put('cp_calm__d' + j + '__c', 1);
    	}
    	
    	sl4.cp_calm__au__c = appKey;
    	sl4.cp_calm__key__c = '1 to 3 minutes';
    	DailyFieldSetup.createDailyFields(sl4);
    	for (Integer j = 1; j <= 60; j++) {
    		sl4.put('cp_calm__d' + j + '__c', 1);
    	}
    	
    	sl5.cp_calm__au__c = appKey;
    	sl5.cp_calm__key__c = '3 to 10 minutes';
    	DailyFieldSetup.createDailyFields(sl5);
    	for (Integer j = 1; j <= 60; j++) {
    		sl5.put('cp_calm__d' + j + '__c', 1);
    	}
    	
    	sl6.cp_calm__au__c = appKey;
    	sl6.cp_calm__key__c = '10 to 30 minutes';
    	DailyFieldSetup.createDailyFields(sl6);
    	for (Integer j = 1; j <= 60; j++) {
    		sl6.put('cp_calm__d' + j + '__c', 1);
    	}
    	
    	sl7.cp_calm__au__c = appKey;
    	sl7.cp_calm__key__c = '30 to 60 minutes';
    	DailyFieldSetup.createDailyFields(sl7);
    	for (Integer j = 1; j <= 60; j++) {
    		sl7.put('cp_calm__d' + j + '__c', 1);
    	}
    	
    	sl8.cp_calm__au__c = appKey;
    	sl8.cp_calm__key__c = '> 1 hour';
    	DailyFieldSetup.createDailyFields(sl8);
    	for (Integer j = 1; j <= 60; j++) {
    		sl8.put('cp_calm__d' + j + '__c', 1);
    	}
    	
    	session_lengths.add(sl1);
    	session_lengths.add(sl2);
    	session_lengths.add(sl3);
    	session_lengths.add(sl4);
    	session_lengths.add(sl5);
    	session_lengths.add(sl6);
    	session_lengths.add(sl7);
    	session_lengths.add(sl8);
    	
    	return session_lengths;
    }
}