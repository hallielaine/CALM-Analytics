@isTest
public with sharing class SessionsOverTimeWebserviceTest {
    static testMethod void testSessionsOverTime()
    {
        List<SessionsOverTimeWebservice.SessionDetail> result1, result2;
        DateTime startDate = BaseTest.getTestStartDate();
        DateTime enddate = BaseTest.getTestEndDate();
        
        String appKey = 'testKey1';
        cp_calm__LG_Summary__c lg_summary = BaseTest.setupLGSummary(appKey, 60);
        insert lg_summary;
        
        System.AssertEquals(1, database.countquery('SELECT COUNT() FROM cp_calm__LG_Summary__c'));
        
        cp_calm__LG_Sessions__c sessions = BaseTest.setupLGSessions(appKey);
        insert sessions;
        
        System.AssertEquals(1, database.countquery('SELECT COUNT() FROM cp_calm__LG_Sessions__c'));
               
        result1 = SessionsOverTimeWebservice.post(startDate, endDate, appKey);
        result2 = SessionsOverTimeWebservice.remoteGetSessionDetails(startDate, endDate, appKey);
        
        system.assertEquals(60, result1.size());
        for (Integer i = 0; i < 60; i++) {
            system.assertEquals(i+1, result1[i].c);
            system.assertEquals(startDate.addDays(i), result1[i].d);
        }
    }
    
    static testMethod void testSessionsOverTimeFirstOfMonth()
    {
        List<SessionsOverTimeWebservice.SessionDetail> result1, result2;
        DateTime endDate = BaseTest.getTestEndDate();
        Integer numDays = endDate.day() + 1;
        DateTime startDate = date.today().addDays(-1*(numDays));
        
        String appKey = 'testKey1';
        cp_calm__LG_Summary__c lg_summary = BaseTest.setupLGSummary(appKey, numDays);
        insert lg_summary;
        
        System.AssertEquals(1, database.countquery('SELECT COUNT() FROM cp_calm__LG_Summary__c'));
        
        cp_calm__LG_Sessions__c sessions = BaseTest.setupLGSessions(appKey);
        insert sessions;
        
        System.AssertEquals(1, database.countquery('SELECT COUNT() FROM cp_calm__LG_Sessions__c'));
               
        result1 = SessionsOverTimeWebservice.post(startDate, endDate, appKey);
        result2 = SessionsOverTimeWebservice.remoteGetSessionDetails(startDate, endDate, appKey);
        
        system.assertEquals(numDays, result1.size());
        for (Integer i = 0; i < numDays; i++) {
            system.assertEquals(i+1, result1[i].c);
            system.assertEquals(startDate.addDays(i), result1[i].d);
        }
    }
}