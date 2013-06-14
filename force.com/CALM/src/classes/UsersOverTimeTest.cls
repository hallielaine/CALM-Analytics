@isTest
public with sharing class UsersOverTimeTest {
   static testMethod void testUsersOverTime()
    {
        List<UsersOverTimeWebservice.UserDetail> result1, result2;
        DateTime startDate = BaseTest.getTestStartDate();
    	DateTime enddate = BaseTest.getTestEndDate();
    	
    	String appKey = 'testKey1';
    	cp_calm__LG_Summary__c lg_summary = BaseTest.setupLGSummary(appKey, 60);
    	insert lg_summary;
    	
        System.AssertEquals(1, database.countquery('SELECT COUNT() FROM cp_calm__LG_Summary__c'));
        
        cp_calm__LG_Users__c users = BaseTest.setupLGUsers(appKey);
        insert users;
        
        System.AssertEquals(1, database.countquery('SELECT COUNT() FROM cp_calm__LG_Users__c'));
               
        result1 = UsersOverTimeWebservice.post(startDate, endDate, appKey);
        result2 = UsersOverTimeWebservice.remoteGetUserDetails(startDate, endDate, appKey);
        
        system.assertEquals(60, result1.size());
        for (Integer i = 0; i < 60; i++) {
        	system.assertEquals(i+1, result1[i].c);
        	system.assertEquals(startDate.addDays(i), result1[i].d);
        }
    }
}