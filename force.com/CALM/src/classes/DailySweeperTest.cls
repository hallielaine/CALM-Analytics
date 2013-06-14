@isTest
private class DailySweeperTest {

    public static testMethod void testDailySweeper() {
        List<cp_calm__Session__c> sessions = BaseTest.setupSessions();
        List<cp_calm__Action__c> actions = BaseTest.setupActions();
        
        //insert the sessions and actions
        insert sessions;
        insert actions;
        
        System.AssertEquals(3, database.countquery('SELECT COUNT() FROM cp_calm__Session__c'));
        System.AssertEquals(1, database.countquery('SELECT COUNT() FROM cp_calm__Session__c WHERE cp_calm__et__c = NULL'));
        System.AssertEquals(8, database.countquery('SELECT COUNT() FROM cp_calm__Action__c'));
       
        Test.StartTest();
        LineGraphSweeper sweeper = new LineGraphSweeper();
        ID batchprocessid = Database.executeBatch(sweeper);
        Test.StopTest();
    
        System.AssertEquals(2, database.countquery('SELECT COUNT() FROM cp_calm__LG_Summary__c'));
        System.AssertEquals(2, database.countquery('SELECT COUNT() FROM cp_calm__BG_Summary__c'));
    }
    
    public static testMethod void testLGMonthlySweeper() {
      List<cp_calm__Session__c> sessions = BaseTest.setupSessions();
      //List<cp_calm__Action__c> actions = BaseTest.setupMonthlyActions();
      
      //insert the sessions and actions
      insert sessions;
      //insert actions;
      
      
      System.AssertEquals(3, database.countquery('SELECT COUNT() FROM cp_calm__Session__c'));
      System.AssertEquals(1, database.countquery('SELECT COUNT() FROM cp_calm__Session__c WHERE cp_calm__et__c = NULL'));
      //System.AssertEquals(61, database.countquery('SELECT COUNT() FROM cp_calm__Action__c'));
      
      String appKey = 'testKey1';
      
      cp_calm__LG_Summary__c lg_summary = BaseTest.setupLGSummary(appKey, 60);
      insert lg_summary;
        
      cp_calm__LG_New_Sessions__c sessions1 = BaseTest.setupLGNewSessions(appKey);
      insert sessions1;
               
      cp_calm__LG_Returning_Sessions__c sessions2 = BaseTest.setupLGReturningSessions(appKey);
      insert sessions2;
      
      cp_calm__LG_New_Users__c sessions3 = BaseTest.setupLGNewUsers(appKey);
      insert sessions3;
        
      cp_calm__LG_Returning_Users__c sessions4 = BaseTest.setupLGReturningUsers(appKey);
      insert sessions4;
      
      cp_calm__LG_Sessions__c sessions5 = BaseTest.setupLGSessions(appKey);
      insert sessions5;
      
      cp_calm__LG_Users__c users = BaseTest.setupLGUsers(appKey);
      insert users;
      
   
      Test.StartTest();
      //LineGraphSweeper sweeper = new LineGraphSweeper();
      //ID batchprocessid = Database.executeBatch(sweeper);
      MonthlySweeper sweeper = new MonthlySweeper();
      Database.executeBatch(sweeper);
      Test.StopTest();
           
      system.debug('WHERE CALENDAR_MONTH(cp_calm__Month__c) = ' + date.today().addDays(-61).month());
            
      cp_calm__LG_Monthly_Summary__c monthSummary = database.query('SELECT cp_calm__Month__c, cp_calm__au__c, cp_calm__New_Sessions__c, cp_calm__New_Users__c, cp_calm__Returning_Sessions__c, cp_calm__Returning_Users__c, cp_calm__Sessions__c, cp_calm__Users__c FROM cp_calm__LG_Monthly_Summary__c WHERE CALENDAR_MONTH(cp_calm__Month__c) = ' + date.today().month());

      System.AssertEquals(60, monthSummary.cp_calm__New_Sessions__c);
      System.AssertEquals(60, monthSummary.cp_calm__New_Users__c);
      System.AssertEquals(60, monthSummary.cp_calm__Returning_Sessions__c);
      System.AssertEquals(60, monthSummary.cp_calm__Returning_Users__c);
      System.AssertEquals(120, monthSummary.cp_calm__Sessions__c);
      System.AssertEquals(120.00, monthSummary.cp_calm__Users__c);
      //System.AssertEquals(2, database.countquery('SELECT COUNT() FROM cp_calm__BG_Summary__c'));
    }
    
    /*public static testMethod void testBGMonthlySweeper() {
      List<cp_calm__Session__c> sessions = BaseTest.setupSessions();
      List<cp_calm__Action__c> actions = BaseTest.setupActions();
      
      //insert the sessions and actions
      insert sessions;
      insert actions;
      
      System.AssertEquals(3, database.countquery('SELECT COUNT() FROM cp_calm__Session__c'));
      System.AssertEquals(1, database.countquery('SELECT COUNT() FROM cp_calm__Session__c WHERE cp_calm__et__c = NULL'));
      System.AssertEquals(8, database.countquery('SELECT COUNT() FROM cp_calm__Action__c'));
      
      String appKey = 'testKey1';
      
      cp_calm__BG_Summary__c bg_summary = BaseTest.setupBGSummary(appKey, 60);
      insert bg_summary;
        
      List<cp_calm__BG_Events__c> events = BaseTest.setupBGEventsConstant(appKey, 1, 3);
      insert events;
      
      
      
      List<cp_calm__BG_App_Version_Sessions__c> sessions1 = BaseTest.setupBGApp_Version_SessionsConstant(appKey, 'a', 1, 1);
      List<cp_calm__BG_App_Version_Sessions__c> sessions2 = BaseTest.setupBGApp_Version_SessionsConstant(appKey, 'b', 2, 1);
      List<cp_calm__BG_App_Version_Sessions__c> sessions3 = BaseTest.setupBGApp_Version_SessionsConstant(appKey, 'c', 3, 1);
      insert sessions1;
      insert sessions2;
      insert sessions3;
      
      
      
      List<cp_calm__BG_Network_Carrier_Sessions__c> sessions11 = BaseTest.setupBGCarrier_SessionsConstant(appKey, 'a', 1, 1);
      List<cp_calm__BG_Network_Carrier_Sessions__c> sessions21 = BaseTest.setupBGCarrier_SessionsConstant(appKey, 'b', 2, 1);
      List<cp_calm__BG_Network_Carrier_Sessions__c> sessions31 = BaseTest.setupBGCarrier_SessionsConstant(appKey, 'c', 3, 1);
      insert sessions11;
      insert sessions21;
      insert sessions31;
        
        
        
      List<cp_calm__BG_Country_Sessions__c> sessions12 = BaseTest.setupBGCountry_SessionsConstant(appKey, 'a', 1, 1);
      List<cp_calm__BG_Country_Sessions__c> sessions22 = BaseTest.setupBGCountry_SessionsConstant(appKey, 'b', 2, 1);
      List<cp_calm__BG_Country_Sessions__c> sessions32 = BaseTest.setupBGCountry_SessionsConstant(appKey, 'c', 3, 1);
      insert sessions12;
      insert sessions22;
      insert sessions32;
      
      
      
      List<cp_calm__BG_Session_Length__c> sessions4 = BaseTest.setupSessionLengths(appKey);
      insert sessions4;
      
      
      
      List<cp_calm__BG_App_Version_Users__c> users1 = BaseTest.setupBGApp_Version_UsersConstant(appKey, 'a', 1, 1);
      List<cp_calm__BG_App_Version_Users__c> users2 = BaseTest.setupBGApp_Version_UsersConstant(appKey, 'b', 2, 1);
      List<cp_calm__BG_App_Version_Users__c> users3 = BaseTest.setupBGApp_Version_UsersConstant(appKey, 'c', 3, 1);
      insert users1;
      insert users2;
      insert users3;
      
      
      
      List<cp_calm__BG_Network_Carrier_Users__c> users11 = BaseTest.setupBGCarrier_UsersConstant(appKey, 'a', 1, 1);
      List<cp_calm__BG_Network_Carrier_Users__c> users21 = BaseTest.setupBGCarrier_UsersConstant(appKey, 'b', 2, 1);
      List<cp_calm__BG_Network_Carrier_Users__c> users31 = BaseTest.setupBGCarrier_UsersConstant(appKey, 'c', 3, 1);
      insert users11;
      insert users21;
      insert users31;
      
      
      
      List<cp_calm__BG_Country_Users__c> users12 = BaseTest.setupBGCountry_UsersConstant(appKey, 'a', 1, 1);
      List<cp_calm__BG_Country_Users__c> users22 = BaseTest.setupBGCountry_UsersConstant(appKey, 'b', 2, 1);
      List<cp_calm__BG_Country_Users__c> users32 = BaseTest.setupBGCountry_UsersConstant(appKey, 'c', 3, 1);
      insert users12;
      insert users22;
      insert users32;
      
      
   
      Test.StartTest();
      BGMonthlyAppVersionSessionsSweeper sweeper = new BGMonthlyAppVersionSessionsSweeper(60);
      Database.executeBatch(sweeper);
      Test.StopTest();
      
      
      
      cp_calm__BG_Monthly_App_Version__c     app      = database.query('SELECT cp_calm__Month__c, cp_calm__au__c, cp_calm__sc__c, cp_calm__uc__c, cp_calm__Key__c FROM cp_calm__BG_Monthly_App_Version__c WHERE cp_calm__Key__c = \'b\' AND cp_calm__au__c = \'' + appKey + '\' AND CALENDAR_MONTH(cp_calm__Month__c) = ' + date.today().month());
      cp_calm__BG_Monthly_Country__c         country  = database.query('SELECT cp_calm__Month__c, cp_calm__au__c, cp_calm__sc__c, cp_calm__uc__c, cp_calm__Key__c FROM cp_calm__BG_Monthly_Country__c WHERE cp_calm__Key__c = \'b\' AND cp_calm__au__c = \'' + appKey + '\' AND CALENDAR_MONTH(cp_calm__Month__c) = ' + date.today().month());
      cp_calm__BG_Monthly_Events__c          event    = database.query('SELECT cp_calm__Month__c, cp_calm__au__c, cp_calm__Count__c, cp_calm__Key__c FROM cp_calm__BG_Monthly_Events__c WHERE cp_calm__Key__c = \'b\' AND cp_calm__au__c = \'' + appKey + '\' AND CALENDAR_MONTH(cp_calm__Month__c) = ' + date.today().month());
      cp_calm__BG_Monthly_Network_Carrier__c carrier  = database.query('SELECT cp_calm__Month__c, cp_calm__au__c, cp_calm__sc__c, cp_calm__uc__c, cp_calm__Key__c FROM cp_calm__BG_Monthly_Network_Carrier__c WHERE cp_calm__Key__c = \'b\' AND cp_calm__au__c = \'' + appKey + '\' AND CALENDAR_MONTH(cp_calm__Month__c) = ' + date.today().month());
      cp_calm__BG_Monthly_Session_Length__c  length   = database.query('SELECT cp_calm__Month__c, cp_calm__au__c, cp_calm__Count__c, cp_calm__Key__c FROM cp_calm__BG_Monthly_Session_Length__c WHERE cp_calm__Key__c = \'b\' AND cp_calm__au__c = \'' + appKey + '\' AND CALENDAR_MONTH(cp_calm__Month__c) = ' + date.today().month());
      
      System.AssertEquals(2, app.cp_calm__sc__c);
      System.AssertEquals(2, app.cp_calm__uc__c);
      System.AssertEquals(2, country.cp_calm__sc__c);
      System.AssertEquals(2, country.cp_calm__uc__c);
      System.AssertEquals(2, event.cp_calm__Count__c);
      System.AssertEquals(2, carrier.cp_calm__sc__c);
      System.AssertEquals(2, carrier.cp_calm__uc__c);
      System.AssertEquals(2, length.cp_calm__Count__c);
    }*/
}