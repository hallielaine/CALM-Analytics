@isTest
global with sharing class UsersPerCountryWebserviceTest {
  static testMethod void testUsersPerCountry()
    {
    	List<UsersPerCountryWebservice.CountryDetail> result1, result2;
        
    	DateTime startDate = BaseTest.getTestStartDate();
    	DateTime enddate = BaseTest.getTestEndDate();
    	
    	String appKey = 'testKey1';
    	cp_calm__BG_Summary__c bg_summary = BaseTest.setupBGSummary(appKey, 60);
    	insert bg_summary;
    	
        System.AssertEquals(1, database.countquery('SELECT COUNT() FROM cp_calm__BG_Summary__c'));
                
        System.AssertEquals(0, database.countquery('SELECT COUNT() FROM cp_calm__BG_Country_Users__c'));
        
        List<cp_calm__BG_Country_Users__c> users1 = BaseTest.setupBGCountry_UsersConstant(appKey, 'a', 1, 1);
        insert users1;
        
        List<cp_calm__BG_Country_Users__c> users2 = BaseTest.setupBGCountry_UsersConstant(appKey, 'b', 2, 1);
        insert users2;
        
        List<cp_calm__BG_Country_Users__c> users3 = BaseTest.setupBGCountry_UsersConstant(appKey, 'c', 3, 1);
        insert users3;
        
        System.AssertEquals(3, database.countquery('SELECT COUNT() FROM cp_calm__BG_Country_Users__c'));
        
        result1 = UsersPerCountryWebservice.post(startDate, endDate, appKey);
        result2 = UsersPerCountryWebservice.remoteGetCountryDetails(startDate, endDate, appKey);
        
        system.assertEquals(3, result1.size());
        system.assertEquals(180, result1[0].u);
        system.assertEquals('c', result1[0].c);
        
        system.assertEquals(120, result1[1].u);
        system.assertEquals('b', result1[1].c);
        
        system.assertEquals(60, result1[2].u);
        system.assertEquals('a', result1[2].c);
    }
}