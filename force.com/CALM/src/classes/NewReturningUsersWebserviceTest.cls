@isTest
private class NewReturningUsersWebserviceTest
{
     static testMethod void testNewReturningUsers()
    {
        List<NewReturningUsersWebservice.NewReturning> result1, result2;
        DateTime startDate = BaseTest.getTestStartDate();
    	DateTime enddate = BaseTest.getTestEndDate();
    	
    	String appKey = 'testKey1';
    	cp_calm__LG_Summary__c lg_summary = BaseTest.setupLGSummary(appKey, 60);
    	insert lg_summary;
    	
        System.AssertEquals(1, database.countquery('SELECT COUNT() FROM cp_calm__LG_Summary__c'));
        
        cp_calm__LG_New_Users__c sessions = BaseTest.setupLGNewUsers(appKey);
        insert sessions;
        
        System.AssertEquals(1, database.countquery('SELECT COUNT() FROM cp_calm__LG_New_Users__c'));
               
        cp_calm__LG_Returning_Users__c sessions2 = BaseTest.setupLGReturningUsers(appKey);
        insert sessions2;
        
        System.AssertEquals(1, database.countquery('SELECT COUNT() FROM cp_calm__LG_Returning_Users__c'));
        
        result1 = NewReturningUsersWebservice.post(startDate, endDate, appKey);
        result2 = NewReturningUsersWebservice.remoteGetUserDetails(startDate, endDate, appKey);
        
        system.assertEquals(120, result1.size());
        for (Integer i = 0; i < 60; i++) {
        	system.assertEquals(i+1, result1[i].c);
        	system.assertEquals(startDate.addDays(i), result1[i].d);
        	system.assertEquals(i+1, result1[60 + i].c);
        	system.assertEquals(startDate.addDays(i), result1[60 + i].d);
        }
    }
}