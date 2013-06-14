@RestResource(urlMapping='/GetUsersPerCarrier/*')
global with sharing class UsersPerCarrierWebservice {

    global class CarrierDetail implements Comparable
    {
        public String c;
        public Integer u;
        
        public CarrierDetail(String c, Integer u)
        {
            this.c = c;
            this.u = u;
        }
        
        global Integer compareTo(Object compareTo) {
            CarrierDetail compareToCD = (CarrierDetail)compareTo;
            if (u == compareToCD.u) return 0;
            if (u > compareToCD.u) return -1;
            return 1;        
        }    
    }
    
    @HttpPost
    global static List<CarrierDetail> post(DateTime st, DateTime et, String appKey)
    {
        return getCarrierDetails(st, et, appKey);
    }
    
    @RemoteAction
    global static List<CarrierDetail> remoteGetCarrierDetails(DateTime st, DateTime et, String appKey)
    {
        return getCarrierDetails(st, et,appKey);
    }
    
    public static List<CarrierDetail> getCarrierDetails(DateTime startTime, DateTime endTime, String appKey)
    {  
        List<CarrierDetail> nc_res = new List<CarrierDetail>();
        Date start_date = startTime.dateGMT();
        Date end_date = endTime.dateGMT();      
        
        // If the date range requested is more than 60 days, query the monthly sweeper instead
		if (WebserviceHelper.shouldUseDailySweeper(start_date, end_date)) {
			Integer num_days = start_date.daysBetween(end_date) + 1;
			cp_calm__BG_Summary__c sweeper =
				[SELECT cp_calm__today__c FROM cp_calm__BG_Summary__c WHERE cp_calm__au__c = :appKey];
			
			String query = WebserviceHelper.getQueryForDailySweeper('cp_calm__BG_Network_Carrier_Users__c', appKey);
			List<cp_calm__BG_Network_Carrier_Users__c> ncu = database.query(query);
			String currentDate = WebserviceHelper.getAttributeForStartDay(sweeper.cp_calm__today__c, start_date);
			for (cp_calm__BG_Network_Carrier_Users__c nc : ncu) {
				Integer total_count = 0;
				for (Integer i = 0; i < num_days; i++) {
					if ((Integer.valueOf(nc.get('cp_calm__' + currentDate + '__c')) > 0)) {
						total_count += Integer.valueOf(nc.get('cp_calm__' + currentDate + '__c'));
					}
					currentDate = WebserviceHelper.incrementDate(currentDate);
				}
				CarrierDetail app = new CarrierDetail((String)nc.get('cp_calm__key__c'), total_count);
				nc_res.add(app);
				currentDate = WebserviceHelper.getAttributeForStartDay(sweeper.cp_calm__today__c, start_date);
			}
		}
        else {
        	Date start_month = start_date.toStartOfMonth();
        	Date end_month = end_date.toStartOfMonth();
        	
        	List<cp_calm__BG_Monthly_Network_Carrier__c> events = [SELECT cp_calm__key__c, cp_calm__uc__c FROM cp_calm__BG_Monthly_Network_Carrier__c WHERE cp_calm__au__c = :appKey AND cp_calm__Month__c >= :start_month AND cp_calm__Month__c <= :end_month ORDER BY cp_calm__Month__c];
        	
        	Map<String, Integer> countPerEvent = new Map<String, Integer>();
        	for (cp_calm__BG_Monthly_Network_Carrier__c e : events) {
        		Integer cnt = Integer.valueOf(e.cp_calm__uc__c);
        		if (countPerEvent.containsKey(e.cp_calm__key__c)) {
        			cnt = cnt + countPerEvent.get(e.cp_calm__key__c);
        		}
        		countPerEvent.put(e.cp_calm__key__c, cnt);
        	}
        	for (String event : countPerEvent.keySet()) {
        		Integer cnt = countPerEvent.get(event);
        		CarrierDetail sd = new CarrierDetail(event, (cnt == -1) ? 0 : cnt);
        		nc_res.add(sd);
        	}
        }       

        nc_res.sort(); 
        return nc_res;
    }
}