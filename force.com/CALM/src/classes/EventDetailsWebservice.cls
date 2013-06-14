@RestResource(urlMapping='/GetEventDetails/*')
global with sharing class EventDetailsWebservice
{
    global class EventDetail implements Comparable
    {
        public Date d;
        public Integer c;
        
        public EventDetail(Date d, Integer eventCount)
        {
            this.d = d;
            this.c = eventCount;
        }    
        
        global Integer compareTo(Object compareTo) {
            EventDetail compareToED = (EventDetail)compareTo;
            if (d == compareToED.d) return 0;
            if (d > compareToED.d) return 1;
            return -1;        
        }
    }
    
    @HttpPost
    global static List<EventDetail> post(DateTime st, DateTime et, String n, String appKey)
    {
        return getEventDetails(st, et, n, appKey);
    }
    
    @RemoteAction
    global static List<EventDetail> remoteGetEventDetails(DateTime st, DateTime et, String n, String appKey)
    {
        return getEventDetails(st, et, n, appKey);
    }
    
    /**
     * Helper method for the post method. This method can be tested.
     */
    public static List<EventDetail> getEventDetails(DateTime startTime, DateTime endTime, String name, String appKey)
    {
    	List<EventDetail> graph_data = new List<EventDetail>();
        Date start_date = startTime.dateGMT();
        Date end_date = endTime.dateGMT();      
        
        // If the date range requested is more than 60 days, query the monthly sweeper instead
		if (WebserviceHelper.shouldUseDailySweeper(start_date, end_date)) {
			Integer num_days = start_date.daysBetween(end_date) + 1;
			cp_calm__BG_Summary__c sweeper =
				[SELECT cp_calm__today__c FROM cp_calm__BG_Summary__c WHERE cp_calm__au__c = :appKey];
			
			String query = WebserviceHelper.getQueryForDailySweeper('cp_calm__BG_Events__c', appKey, 'cp_calm__key__c = \'' + String.escapeSingleQuotes(name) +'\'');
			cp_calm__BG_Events__c sessions = database.query(query);
			String currentDate = WebserviceHelper.getAttributeForStartDay(sweeper.cp_calm__today__c, start_date);
			
			for (Integer i = 0; i < num_days; i++) {
				Integer cnt = Integer.valueOf(sessions.get('cp_calm__' + currentDate + '__c'));
				EventDetail sd = new EventDetail(start_date.addDays(i), (cnt == -1) ? 0 : cnt);
				graph_data.add(sd);
				currentDate = WebserviceHelper.incrementDate(currentDate);
			}
		}
        else {
        	Date start_month = start_date.toStartOfMonth();
        	Date end_month = end_date.toStartOfMonth();
        	
        	List<cp_calm__BG_Monthly_Events__c> sweepers = [SELECT cp_calm__Month__c, cp_calm__key__c, cp_calm__count__c FROM cp_calm__BG_Monthly_Events__c WHERE cp_calm__au__c = :appKey AND cp_calm__key__c = :name AND cp_calm__Month__c >= :start_month AND cp_calm__Month__c <= :end_month ORDER BY cp_calm__Month__c];
        	
        	for (cp_calm__BG_Monthly_Events__c s : sweepers) {
        		Integer cnt = Integer.valueOf(s.cp_calm__count__c);
        		EventDetail sd = new EventDetail(s.cp_calm__Month__c, (cnt == -1) ? 0 : cnt);
        		graph_data.add(sd);
        	}
        }       
        
		return graph_data;
    } 
}