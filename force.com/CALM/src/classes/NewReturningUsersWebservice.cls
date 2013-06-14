@RestResource(urlMapping='/GetNewReturningUsers/*')
global with sharing class NewReturningUsersWebservice
{    
    global class NewReturning implements Comparable
    {
      public Date d;
      public Integer c;
      public Boolean n;
      
      public NewReturning(Date d, Integer c, Boolean newAppKey)
      {
        this.d = d;
        this.c = c;
        this.n = newAppKey;
      }
      
      public Integer compareTo(Object other)
      {
        if(!(other instanceof NewReturning))
            return -1;
        
        if(((NewReturning)other).d > d)
            return -1;
      
        if(((NewReturning)other).d < d)
            return 1;
            
        return 0;
      }
    }
    
    @HttpPost
    global static List<NewReturning> post(DateTime st, DateTime et, String appKey)
    {
        return getUserDetails(st, et, appKey);
    }
    
    @RemoteAction
    global static List<NewReturning> remoteGetUserDetails(DateTime st, DateTime et, String appKey)
    {
        return getUserDetails(st, et, appKey);
    }
    
    /**
     * Helper method for the post method. This method can be tested.
     */
    public static List<NewReturning> getUserDetails(DateTime startTime, DateTime endTime, String appKey)
    {  
        List<NewReturning> graph_data = new List<NewReturning>();
        Date start_date = startTime.dateGMT();
        Date end_date = endTime.dateGMT();     
        
        // If the date range requested is more than 60 days, query the monthly sweeper instead
		if (WebserviceHelper.shouldUseDailySweeper(start_date, end_date)) {
			Integer num_days = start_date.daysBetween(end_date) + 1;
			cp_calm__LG_Summary__c sweeper =
				[SELECT cp_calm__today__c FROM cp_calm__LG_Summary__c WHERE cp_calm__au__c = :appKey];
			
			String query = WebserviceHelper.getQueryForDailySweeper('cp_calm__LG_New_Users__c', appKey);
			cp_calm__LG_New_Users__c new_sessions = database.query(query);
			String currentDate = WebserviceHelper.getAttributeForStartDay(sweeper.cp_calm__today__c, start_date);
			
			for (Integer i = 0; i < num_days; i++) {
				Integer cnt = Integer.valueOf(new_sessions.get('cp_calm__' + currentDate + '__c'));
				NewReturning sd = new NewReturning(start_date.addDays(i), (cnt == -1) ? 0 : cnt, true);
				graph_data.add(sd);
				currentDate = WebserviceHelper.incrementDate(currentDate);
			}
			
			query = WebserviceHelper.getQueryForDailySweeper('cp_calm__LG_Returning_Users__c', appKey);
			cp_calm__LG_Returning_Users__c ret_sessions = database.query(query);
			currentDate = WebserviceHelper.getAttributeForStartDay(sweeper.cp_calm__today__c, start_date);
			
			for (Integer i = 0; i < num_days; i++) {
				Integer cnt = Integer.valueOf(ret_sessions.get('cp_calm__' + currentDate + '__c'));
				NewReturning sd = new NewReturning(start_date.addDays(i),  (cnt == -1) ? 0 : cnt, false);
				graph_data.add(sd);
				currentDate = WebserviceHelper.incrementDate(currentDate);
			}
		}
        else {
        	Date start_month = start_date.toStartOfMonth();
        	Date end_month = end_date.toStartOfMonth();
        	
        	List<cp_calm__LG_Monthly_Summary__c> sweepers = [SELECT cp_calm__Month__c, cp_calm__New_Users__c, cp_calm__Returning_Users__c FROM cp_calm__LG_Monthly_Summary__c WHERE cp_calm__au__c = :appKey AND cp_calm__Month__c >= :start_month AND cp_calm__Month__c <= :end_month ORDER BY cp_calm__Month__c];
        	
        	for (cp_calm__LG_Monthly_Summary__c s : sweepers) {
        		Integer cnt = Integer.valueOf(s.cp_calm__New_Users__c);
        		NewReturning sd = new NewReturning(s.cp_calm__Month__c, (cnt == -1) ? 0 : cnt, true);
        		graph_data.add(sd);
        		cnt = Integer.valueOf(s.cp_calm__Returning_Users__c);
        		sd = new NewReturning(s.cp_calm__Month__c, (cnt == -1) ? 0 : cnt, false);
        		graph_data.add(sd);
        	}
        }
		return graph_data;
    }
}