@RestResource(urlMapping='/GetSessionsOverTime/*')
global with sharing class SessionsOverTimeWebservice 
{
    global class SessionDetail implements Comparable
    {
        public Date d;
        public Integer c;
        
        public SessionDetail(Date d, Integer sessionCount)
        {
            this.d = d;
            this.c = sessionCount;
        }
        
        global Integer compareTo(Object compareTo) {
            SessionDetail compareToSD = (SessionDetail)compareTo;
            if (d == compareToSD.d) return 0;
            if (d < compareToSD.d) return -1;
            return 1;        
        }
    }
    
    @HttpPost
    global static List<SessionDetail> post(DateTime st, DateTime et, String appKey)
    {
        return getSessionDetails(st, et, appKey);
    }
    
    @RemoteAction
    global static List<SessionDetail> remoteGetSessionDetails(DateTime st, DateTime et, String appKey)
    {
        return getSessionDetails(st, et,appKey);
    }

    public static List<SessionDetail> getSessionDetails(DateTime startTime, DateTime endTime, String appKey)
    {  
        List<SessionDetail> graph_data = new List<SessionDetail>();
        Date start_date = startTime.dateGMT();
        Date end_date = endTime.dateGMT();      

        // If the date range requested is more than 60 days, query the monthly sweeper instead
        if (WebserviceHelper.shouldUseDailySweeper(start_date, end_date)) {
        system.debug('Using detailed days.');
            Integer num_days = start_date.daysBetween(end_date) + 1;
            cp_calm__LG_Summary__c sweeper =
                [SELECT cp_calm__today__c FROM cp_calm__LG_Summary__c WHERE cp_calm__au__c = :appKey];
            
            String query = WebserviceHelper.getQueryForDailySweeper('cp_calm__LG_Sessions__c', appKey);
            cp_calm__LG_Sessions__c sessions = database.query(query);
            String currentDate = WebserviceHelper.getAttributeForStartDay(sweeper.cp_calm__today__c, start_date);

            for (Integer i = 0; i < num_days; i++) {
                Integer cnt = Integer.valueOf(sessions.get('cp_calm__' + currentDate + '__c'));
                SessionDetail sd = new SessionDetail(start_date.addDays(i), (cnt == -1) ? 0 : cnt);
                graph_data.add(sd);
                currentDate = WebserviceHelper.incrementDate(currentDate);
            }
        }
        else {
        system.debug('Using monthly values.');
            Date start_month = start_date.toStartOfMonth();
            Date end_month = end_date.toStartOfMonth();
            
            List<cp_calm__LG_Monthly_Summary__c> sweepers = [SELECT cp_calm__Month__c, cp_calm__Sessions__c FROM cp_calm__LG_Monthly_Summary__c WHERE cp_calm__au__c = :appKey AND cp_calm__Month__c >= :start_month AND cp_calm__Month__c <= :end_month ORDER BY cp_calm__Month__c];
            
            for (cp_calm__LG_Monthly_Summary__c s : sweepers) {
                Integer cnt = Integer.valueOf(s.cp_calm__Sessions__c);
                SessionDetail sd = new SessionDetail(s.cp_calm__Month__c, (cnt == -1) ? 0 : cnt);
                graph_data.add(sd);
            }
        }
        
        return graph_data;
    }
}