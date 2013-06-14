@isTest
private class EventOverviewWebserviceTest
{
    static testMethod void testGetEventOverview()
    {
        List<EventOverviewWebservice.EventCount> result1, result2;
        
    	DateTime startDate = BaseTest.getTestStartDate();
    	DateTime enddate = BaseTest.getTestEndDate();
    	
    	String appKey = 'testKey1';
    	cp_calm__BG_Summary__c bg_summary = BaseTest.setupBGSummary(appKey, 60);
    	insert bg_summary;
    	
        System.AssertEquals(1, database.countquery('SELECT COUNT() FROM cp_calm__BG_Summary__c'));
        
        List<cp_calm__BG_Events__c> events = BaseTest.setupBGEventsConstant(appKey, 1, 3);
        insert events;
        
        System.AssertEquals(3, database.countquery('SELECT COUNT() FROM cp_calm__BG_Events__c'));
               
        result1 = EventOverviewWebservice.post(startDate, endDate, appKey);
        result2 = EventOverviewWebservice.remoteGetEventOverview(startDate, endDate, appKey);
        
        system.assertEquals(3, result1.size());
        system.assertEquals(60, result1[0].count);
        system.assertEquals('event1', result1[0].name);
        
        system.assertEquals(60, result1[1].count);
        system.assertEquals('event2', result1[1].name);
        
        system.assertEquals(60, result1[2].count);
        system.assertEquals('event3', result1[2].name);
    }
    
    static testMethod void testEventOverviewDifferentValues()
    {
    	List<EventOverviewWebservice.EventCount> result1, result2;
        
    	DateTime startDate = BaseTest.getTestStartDate();
    	DateTime enddate = BaseTest.getTestEndDate();
    	
    	String appKey = 'testKey1';
    	cp_calm__BG_Summary__c bg_summary = BaseTest.setupBGSummary(appKey, 60);
    	insert bg_summary;
    	
        System.AssertEquals(1, database.countquery('SELECT COUNT() FROM cp_calm__BG_Summary__c'));
                
        System.AssertEquals(0, database.countquery('SELECT COUNT() FROM cp_calm__BG_Events__c'));
        
        List<cp_calm__BG_Events__c> events1 = BaseTest.setupBGEventsConstant(appKey, 'a', 1, 1);
        insert events1;
        
        List<cp_calm__BG_Events__c> events2 = BaseTest.setupBGEventsConstant(appKey, 'b', 2, 1);
        insert events2;
        
        List<cp_calm__BG_Events__c> events3 = BaseTest.setupBGEventsConstant(appKey, 'c', 3, 1);
        insert events3;
        
        System.AssertEquals(3, database.countquery('SELECT COUNT() FROM cp_calm__BG_Events__c'));
        
        result1 = EventOverviewWebservice.post(startDate, endDate, appKey);
        result2 = EventOverviewWebservice.remoteGetEventOverview(startDate, endDate, appKey);
        
        system.assertEquals(3, result1.size());
        system.assertEquals(180, result1[0].count);
        system.assertEquals('c', result1[0].name);
        
        system.assertEquals(120, result1[1].count);
        system.assertEquals('b', result1[1].name);
        
        system.assertEquals(60, result1[2].count);
        system.assertEquals('a', result1[2].name);
    }
}