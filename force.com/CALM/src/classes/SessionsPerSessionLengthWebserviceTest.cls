/**
 * @author Daniel Crawford
 */

@isTest
global with sharing class SessionsPerSessionLengthWebserviceTest {
    
    static testMethod void testSessionLength() {
        
        List<SessionsPerSessionLengthWebservice.SessionLengthDetail> result1, result2;
      
    	DateTime startDate = BaseTest.getTestStartDate();
    	DateTime enddate = BaseTest.getTestEndDate();
    	
    	String appKey = 'testKey1';
    	cp_calm__BG_Summary__c bg_summary = BaseTest.setupBGSummary(appKey, 60);
    	insert bg_summary;
    	
        System.AssertEquals(1, database.countquery('SELECT COUNT() FROM cp_calm__BG_Summary__c'));
                
        System.AssertEquals(0, database.countquery('SELECT COUNT() FROM cp_calm__BG_Session_Length__c'));
        
        List<cp_calm__BG_Session_Length__c> sessions = BaseTest.setupSessionLengths(appKey);
        insert sessions;
        
        System.AssertEquals(8, database.countquery('SELECT COUNT() FROM cp_calm__BG_Session_Length__c'));
        
        result1 = SessionsPerSessionLengthWebservice.post(startDate, endDate, appKey);
        result2 = SessionsPerSessionLengthWebservice.remoteGetSessionLengthDetails(startDate, endDate, appKey);
        
        // check correct order of returned list
        system.assertEquals('0 to 10 seconds', result1[0].i.description);
        system.assertEquals('11 to 30 seconds', result1[1].i.description);
        system.assertEquals('31 to 60 seconds', result1[2].i.description);
        system.assertEquals('1 to 3 minutes', result1[3].i.description);
        system.assertEquals('3 to 10 minutes', result1[4].i.description);
        system.assertEquals('10 to 30 minutes', result1[5].i.description);
        system.assertEquals('30 to 60 minutes', result1[6].i.description);
        system.assertEquals('> 1 hour', result1[7].i.description);
        
        // check correct results
        system.assertEquals(60, result1[0].s);
        system.assertEquals(60, result1[1].s);
        system.assertEquals(60, result1[2].s);
        system.assertEquals(60, result1[3].s);
        system.assertEquals(60, result1[4].s);
        system.assertEquals(60, result1[5].s);
        system.assertEquals(60, result1[6].s);
        system.assertEquals(60, result1[7].s);
        
    }
}