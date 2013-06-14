@RestResource(urlMapping='/GetEventOverview/*')
global with sharing class EventOverviewWebservice
{
    global class EventCount implements Comparable
    {
        public String name = '';
        public Integer count = 0;
        
        public EventCount(String eventName, Integer eventCount)
        {
            name = eventName;
            count = eventCount;
        }
        
        global Integer compareTo(Object compareTo) {
            EventCount compareToEC = (EventCount)compareTo;
            if (count == compareToEC.count) return 0;
            if (count > compareToEC.count) return -1;
            return 1;        
        }
          
    }
    
    @HttpPost
    global static List<EventCount> post(DateTime st, DateTime et, String appKey)
    {
        return getEventOverview(st,et,appKey);
    }
    
    @RemoteAction
    global static List<EventCount> remoteGetEventOverview(DateTime st, DateTime et, String appKey)
    {
        return getEventOverview(st,et,appKey);
    }
    
    public static List<EventCount> getEventOverview(DateTime startTime, DateTime endTime, String appKey)
    {  
        List<EventCount> event_res = new List<EventCount>();
        Date start_date = startTime.dateGMT();
        Date end_date = endTime.dateGMT();      
        
        // If the date range requested is more than 60 days, query the monthly sweeper instead
		if (WebserviceHelper.shouldUseDailySweeper(start_date, end_date)) {
			Integer num_days = start_date.daysBetween(end_date) + 1;
			cp_calm__BG_Summary__c sweeper =
				[SELECT cp_calm__today__c FROM cp_calm__BG_Summary__c WHERE cp_calm__au__c = :appKey];
			
			String query = WebserviceHelper.getQueryForDailySweeper('cp_calm__BG_Events__c', appKey);
			List<cp_calm__BG_Events__c> events = database.query(query);
			String currentDate = WebserviceHelper.getAttributeForStartDay(sweeper.cp_calm__today__c, start_date);
			for (cp_calm__BG_Events__c event : events) {
				Integer total_count = 0;
				for (Integer i = 0; i < num_days; i++) {
					if ((Integer.valueOf(event.get('cp_calm__' + currentDate + '__c'))) > 0) {
						total_count += Integer.valueOf(event.get('cp_calm__' + currentDate + '__c'));
					}
					currentDate = WebserviceHelper.incrementDate(currentDate);
				}
				EventCount ec = new EventCount((String)event.get('cp_calm__key__c'), total_count);
				event_res.add(ec);
				currentDate = WebserviceHelper.getAttributeForStartDay(sweeper.cp_calm__today__c, start_date);
			}
		}
        else {
        	Date start_month = start_date.toStartOfMonth();
        	Date end_month = end_date.toStartOfMonth();
        	
        	List<cp_calm__BG_Monthly_Events__c> events = [SELECT cp_calm__key__c, cp_calm__count__c FROM cp_calm__BG_Monthly_Events__c WHERE cp_calm__au__c = :appKey AND cp_calm__Month__c >= :start_month AND cp_calm__Month__c <= :end_month ORDER BY cp_calm__Month__c];
        	
        	Map<String, Integer> countPerEvent = new Map<String, Integer>();
        	for (cp_calm__BG_Monthly_Events__c e : events) {
        		Integer cnt = Integer.valueOf(e.cp_calm__count__c);
        		if (countPerEvent.containsKey(e.cp_calm__key__c)) {
        			cnt = cnt + countPerEvent.get(e.cp_calm__key__c);
        		}
        		countPerEvent.put(e.cp_calm__key__c, cnt);
        	}
        	for (String event : countPerEvent.keySet()) {
        		Integer cnt = countPerEvent.get(event);
        		EventCount sd = new EventCount(event, (cnt == -1) ? 0 : cnt);
        		event_res.add(sd);
        	}
        }       

        event_res.sort(); 
        return event_res;
    }
}