@isTest
private class NewReturningSessionsWebserviceTest
{
    static testMethod void testNewReturningSessions()
    {
        List<NewReturningSessionsWebservice.NewReturning> result1, result2;
        DateTime startDate = BaseTest.getTestStartDate();
    	DateTime enddate = BaseTest.getTestEndDate();
    	
    	String appKey = 'testKey1';
    	cp_calm__LG_Summary__c lg_summary = BaseTest.setupLGSummary(appKey, 60);
    	insert lg_summary;
    	
        System.AssertEquals(1, database.countquery('SELECT COUNT() FROM cp_calm__LG_Summary__c'));
        
        cp_calm__LG_New_Sessions__c sessions = BaseTest.setupLGNewSessions(appKey);
        insert sessions;
        
        System.AssertEquals(1, database.countquery('SELECT COUNT() FROM cp_calm__LG_New_Sessions__c'));
               
        cp_calm__LG_Returning_Sessions__c sessions2 = BaseTest.setupLGReturningSessions(appKey);
        insert sessions2;
        
        System.AssertEquals(1, database.countquery('SELECT COUNT() FROM cp_calm__LG_Returning_Sessions__c'));
        
        result1 = NewReturningSessionsWebservice.post(startDate, endDate, appKey);
        result2 = NewReturningSessionsWebservice.remoteGetSessionDetails(startDate, endDate, appKey);
        
        system.assertEquals(120, result1.size());
        for (Integer i = 0; i < 60; i++) {
        	system.assertEquals(i+1, result1[i].c);
        	system.assertEquals(startDate.addDays(i), result1[i].d);
        	system.assertEquals(i+1, result1[60 + i].c);
        	system.assertEquals(startDate.addDays(i), result1[60 + i].d);
        }
    }
}