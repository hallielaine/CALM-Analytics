@isTest
global with sharing class SessionsPerCountryWebserviceTest {
  static testMethod void testSessionsPerCountry()
    {
    	List<SessionsPerCountryWebservice.CountryDetail> result1, result2;
        
    	DateTime startDate = BaseTest.getTestStartDate();
    	DateTime enddate = BaseTest.getTestEndDate();
    	
    	String appKey = 'testKey1';
    	cp_calm__BG_Summary__c bg_summary = BaseTest.setupBGSummary(appKey, 60);
    	insert bg_summary;
    	
        System.AssertEquals(1, database.countquery('SELECT COUNT() FROM cp_calm__BG_Summary__c'));
                
        System.AssertEquals(0, database.countquery('SELECT COUNT() FROM cp_calm__BG_Country_Sessions__c'));
        
        List<cp_calm__BG_Country_Sessions__c> sessions1 = BaseTest.setupBGCountry_SessionsConstant(appKey, 'a', 1, 1);
        insert sessions1;
        
        List<cp_calm__BG_Country_Sessions__c> sessions2 = BaseTest.setupBGCountry_SessionsConstant(appKey, 'b', 2, 1);
        insert sessions2;
        
        List<cp_calm__BG_Country_Sessions__c> sessions3 = BaseTest.setupBGCountry_SessionsConstant(appKey, 'c', 3, 1);
        insert sessions3;
        
        System.AssertEquals(3, database.countquery('SELECT COUNT() FROM cp_calm__BG_Country_Sessions__c'));
        
        result1 = SessionsPerCountryWebservice.post(startDate, endDate, appKey);
        result2 = SessionsPerCountryWebservice.remoteGetCountryDetails(startDate, endDate, appKey);
        
        system.assertEquals(3, result1.size());
        system.assertEquals(180, result1[0].s);
        system.assertEquals('c', result1[0].c);
        
        system.assertEquals(120, result1[1].s);
        system.assertEquals('b', result1[1].c);
        
        system.assertEquals(60, result1[2].s);
        system.assertEquals('a', result1[2].c);
    }
}