@isTest
public class EventDetailsWebserviceTest
{
    static testMethod void testGetEventDetails()
    {
    	DateTime startDate = BaseTest.getTestStartDate();
    	DateTime enddate = BaseTest.getTestEndDate();
    	
    	String appKey = 'testKey1';
    	cp_calm__BG_Summary__c bg_summary = BaseTest.setupBGSummary(appKey, 60);
    	insert bg_summary;
    	
        System.AssertEquals(1, database.countquery('SELECT COUNT() FROM cp_calm__BG_Summary__c'));
        
        List<cp_calm__BG_Events__c> events = BaseTest.setupBGEvents(appKey, 1);
        insert events;
        
        System.AssertEquals(1, database.countquery('SELECT COUNT() FROM cp_calm__BG_Events__c'));
        
        List<EventDetailsWebservice.EventDetail> result1, result2;
               
        result1 = EventDetailsWebservice.post(startDate, endDate, 'event1', appKey);
        result2 = EventDetailsWebservice.remoteGetEventDetails(startDate, endDate, 'event1', appKey);
        
        system.assertEquals(60, result1.size());
        for (Integer i = 0; i < 60; i++) {
        	system.assertEquals(i+1, result1[i].c);
        	system.assertEquals(startDate.addDays(i), result1[i].d);
        }
    }
    
    // TODO(Erik) Add test for Monthly sweeper
}