@RestResource(urlMapping='/GetUsersOverTime/*')
global with sharing class UsersOverTimeWebservice {

    global class UserDetail implements Comparable
    {
        public Date d;
        public Integer c;
        
        public UserDetail(Date d, Integer sessionCount)
        {
            this.d = d;
            this.c = sessionCount;
        } 
        
        global Integer compareTo(Object compareTo) {
            UserDetail compareToUD = (UserDetail)compareTo;
            if (d == compareToUD.d) return 0;
            if (d < compareToUD.d) return -1;
            return 1;        
        }    
    }
    
    @HttpPost
    global static List<UserDetail> post(DateTime st, DateTime et, String appKey)
    {
        return getUserDetails(st, et, appKey);
    }
    
    @RemoteAction
    global static List<UserDetail> remoteGetUserDetails(DateTime st, DateTime et, String appKey)
    {
        return getUserDetails(st, et,appKey);
    }
    
    /**
     * Helper method for the post method. This method can be tested.
     */
    public static List<UserDetail> getUserDetails(DateTime startTime, DateTime endTime, String appKey)
    {  
        List<UserDetail> graph_data = new List<UserDetail>();
        Date start_date = startTime.dateGMT();
        Date end_date = endTime.dateGMT();      
        
        // If the date range requested is more than 60 days, query the monthly sweeper instead
		if (WebserviceHelper.shouldUseDailySweeper(start_date, end_date)) {
			Integer num_days = start_date.daysBetween(end_date) + 1;
			cp_calm__LG_Summary__c sweeper =
				[SELECT cp_calm__today__c FROM cp_calm__LG_Summary__c WHERE cp_calm__au__c = :appKey];
			
			String query = WebserviceHelper.getQueryForDailySweeper('cp_calm__LG_Users__c', appKey);
			cp_calm__LG_Users__c users = database.query(query);
			String currentDate = WebserviceHelper.getAttributeForStartDay(sweeper.cp_calm__today__c, start_date);
			
			for (Integer i = 0; i < num_days; i++) {
				Integer cnt = Integer.valueOf(users.get('cp_calm__' + currentDate + '__c'));
				UserDetail ud = new UserDetail(start_date.addDays(i), (cnt == -1) ? 0 : cnt);
				graph_data.add(ud);
				currentDate = WebserviceHelper.incrementDate(currentDate);
			}
		}
        else {
        	Date start_month = start_date.toStartOfMonth();
        	Date end_month = end_date.toStartOfMonth();
        	
        	List<cp_calm__LG_Monthly_Summary__c> sweepers = [SELECT cp_calm__Month__c, cp_calm__Users__c FROM cp_calm__LG_Monthly_Summary__c WHERE cp_calm__au__c = :appKey AND cp_calm__Month__c >= :start_month AND cp_calm__Month__c <= :end_month ORDER BY cp_calm__Month__c];
        	
        	for (cp_calm__LG_Monthly_Summary__c s : sweepers) {
        		Integer cnt = Integer.valueOf(s.cp_calm__Users__c);
        		UserDetail sd = new UserDetail(s.cp_calm__Month__c, (cnt == -1) ? 0 : cnt);
        		graph_data.add(sd);
        	}
        }
		return graph_data;
    }
}