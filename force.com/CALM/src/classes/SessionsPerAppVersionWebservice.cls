@RestResource(urlMapping='/GetSessionsPerAppVersion/*')
global with sharing class SessionsPerAppVersionWebservice {
    global class AppVersionDetail implements Comparable
    {
        public String av;
        public Integer s;
        
        public AppVersionDetail(String av, Integer s)
        {
            this.av = av;
            this.s = s;
        }
        
        global Integer compareTo(Object compareTo) {
            AppVersionDetail other = (AppVersionDetail)compareTo;
            if (s == other.s) return 0;
            if (s > other.s) return -1;
            return 1;        
        }  
    }
    
    @HttpPost
    global static List<AppVersionDetail> post(DateTime st, DateTime et, String appKey)
    {
        return getAppVersionDetail(st,et,appKey);
    }
    
    @RemoteAction
    global static List<AppVersionDetail> remoteGetAppVersionDetail(DateTime st, DateTime et, String appKey)
    {
        return getAppVersionDetail(st,et,appKey);
    }
    
    /**
     * Helper method for the post method. This method can be tested.
     */
    public static List<AppVersionDetail> getAppVersionDetail(DateTime startTime, DateTime endTime, String appKey)
    {  
        List<AppVersionDetail> av_res = new List<AppVersionDetail>();
        Date start_date = startTime.dateGMT();
        Date end_date = endTime.dateGMT();      
        
        // If the date range requested is more than 60 days, query the monthly sweeper instead
		if (WebserviceHelper.shouldUseDailySweeper(start_date, end_date)) {
			Integer num_days = start_date.daysBetween(end_date) + 1;
			cp_calm__BG_Summary__c sweeper =
				[SELECT cp_calm__today__c FROM cp_calm__BG_Summary__c WHERE cp_calm__au__c = :appKey];
			
			String query = WebserviceHelper.getQueryForDailySweeper('cp_calm__BG_App_Version_Sessions__c', appKey);
			List<cp_calm__BG_App_Version_Sessions__c> avs = database.query(query);
			String currentDate = WebserviceHelper.getAttributeForStartDay(sweeper.cp_calm__today__c, start_date);
			for (cp_calm__BG_App_Version_Sessions__c av : avs) {
				Integer total_count = 0;
				for (Integer i = 0; i < num_days; i++) {
					if ((Integer.valueOf(av.get('cp_calm__' + currentDate + '__c')) > 0)) {
						total_count += Integer.valueOf(av.get('cp_calm__' + currentDate + '__c'));
					}
					currentDate = WebserviceHelper.incrementDate(currentDate);
				}
				AppVersionDetail app = new AppVersionDetail((String)av.get('cp_calm__key__c'), total_count);
				av_res.add(app);
				currentDate = WebserviceHelper.getAttributeForStartDay(sweeper.cp_calm__today__c, start_date);
			}
		}
        else {
        	Date start_month = start_date.toStartOfMonth();
        	Date end_month = end_date.toStartOfMonth();
        	
        	List<cp_calm__BG_Monthly_App_Version__c> events = [SELECT cp_calm__key__c, cp_calm__sc__c FROM cp_calm__BG_Monthly_App_Version__c WHERE cp_calm__au__c = :appKey AND cp_calm__Month__c >= :start_month AND cp_calm__Month__c <= :end_month ORDER BY cp_calm__Month__c];
        	
        	Map<String, Integer> countPerEvent = new Map<String, Integer>();
        	for (cp_calm__BG_Monthly_App_Version__c e : events) {
        		Integer cnt = Integer.valueOf(e.cp_calm__sc__c);
        		if (countPerEvent.containsKey(e.cp_calm__key__c)) {
        			cnt = cnt + countPerEvent.get(e.cp_calm__key__c);
        		}
        		countPerEvent.put(e.cp_calm__key__c, cnt);
        	}
        	for (String event : countPerEvent.keySet()) {
        		Integer cnt = countPerEvent.get(event);
        		AppVersionDetail sd = new AppVersionDetail(event, (cnt == -1) ? 0 : cnt);
        		av_res.add(sd);
        	}
        }       

        av_res.sort(); 
        return av_res;
    }
}