/**
 * @author Daniel Crawford
 */

@RestResource(urlMapping='/GetSessionsPerSessionLength/*')
global with sharing class SessionsPerSessionLengthWebservice {

    private static List<TimeInterval> intervals = new List<TimeInterval>();
    
    static {
        intervals.add(new TimeInterval(0, 10000, '0 to 10 seconds'));
        intervals.add(new TimeInterval(11000, 30000, '11 to 30 seconds'));
        intervals.add(new TimeInterval(31000, 60000, '31 to 60 seconds'));
        intervals.add(new TimeInterval(61000, 180000, '1 to 3 minutes'));
        intervals.add(new TimeInterval(181000, 600000, '3 to 10 minutes'));
        intervals.add(new TimeInterval(601000, 1800000, '10 to 30 minutes'));
        intervals.add(new TimeInterval(1801000, 3600000, '30 to 60 minutes'));
        intervals.add(new TimeInterval(3601000, 2147483647, '> 1 hour')); // max int
    }
    
    global class SessionLengthDetail implements Comparable {
        public TimeInterval i;    // interval
        public Integer s;         // number of sessions
        
        public SessionLengthDetail(TimeInterval i, Integer s) {
            this.i = i;
            this.s = s;
        }
        
        public Integer compareTo(Object obj) {
            if (obj instanceof SessionLengthDetail) {
                SessionLengthDetail sess = (SessionLengthDetail) obj;
                return this.i.compareTo(sess.i);
            }
            return -1;
        }
    }
    
    global class TimeInterval implements Comparable {
        public Integer start;
        public Integer stop;
        public String description;
        
        public TimeInterval(Integer start, Integer stop, String description) {
            this.start = start;
            this.stop = stop;
            this.description = description;
        }
        
        public Integer compareTo(Object obj) {
            if (obj instanceof TimeInterval) {
                TimeInterval sess = (TimeInterval) obj;
                
                if (this.start < sess.start) {
                    return -1;
                }
                if (this.start > sess.start) {
                    return 1;
                }
                return 0;
            }
            return -1;
        }
    }
    
    
    @HttpPost
    global static List<SessionLengthDetail> post(
        DateTime st, DateTime et, String appKey)
    {
        return getSessionLengthDetails(st, et, appKey);
    }
    
    @RemoteAction
    global static List<SessionLengthDetail> remoteGetSessionLengthDetails(
    DateTime st, DateTime et, String appKey) {
        
        return getSessionLengthDetails(st, et, appKey);
    }
    
    public static List<SessionLengthDetail> getSessionLengthDetails(
        DateTime startTime, DateTime endTime, String appKey) {
             
        List<SessionLengthDetail> sl_res = new List<SessionLengthDetail>();
        Date start_date = startTime.dateGMT();
        Date end_date = endTime.dateGMT();      
        
        // If the date range requested is more than 60 days, query the monthly sweeper instead
		if (WebserviceHelper.shouldUseDailySweeper(start_date, end_date)) {
			Integer num_days = start_date.daysBetween(end_date) + 1;
			cp_calm__BG_Summary__c sweeper =
				[SELECT cp_calm__today__c FROM cp_calm__BG_Summary__c WHERE cp_calm__au__c = :appKey];
			
			String query = WebserviceHelper.getQueryForDailySweeper('cp_calm__BG_Session_Length__c', appKey);
			List<cp_calm__BG_Session_Length__c> sls = database.query(query);
			String currentDate = WebserviceHelper.getAttributeForStartDay(sweeper.cp_calm__today__c, start_date);
			for (cp_calm__BG_Session_Length__c sl : sls) {
				Integer total_count = 0;
				for (Integer i = 0; i < num_days; i++) {
					if ((Integer.valueOf(sl.get('cp_calm__' + currentDate + '__c')) > 0)) {
						total_count += Integer.valueOf(sl.get('cp_calm__' + currentDate + '__c'));
					}
					currentDate = WebserviceHelper.incrementDate(currentDate);
				}
				TimeInterval interval = findIntervalFromDescription((String)sl.get('cp_calm__key__c'));
				SessionLengthDetail app = new SessionLengthDetail(interval, total_count);
				sl_res.add(app);
				currentDate = WebserviceHelper.getAttributeForStartDay(sweeper.cp_calm__today__c, start_date);
			}
		}
        else {
        	Date start_month = start_date.toStartOfMonth();
        	Date end_month = end_date.toStartOfMonth();
        	
        	List<cp_calm__BG_Monthly_Session_Length__c> events = [SELECT cp_calm__key__c, cp_calm__count__c FROM cp_calm__BG_Monthly_Session_Length__c WHERE cp_calm__au__c = :appKey AND cp_calm__Month__c >= :start_month AND cp_calm__Month__c <= :end_month ORDER BY cp_calm__Month__c];
        	
        	Map<TimeInterval, Integer> countPerInterval = new Map<TimeInterval, Integer>();
        	for (cp_calm__BG_Monthly_Session_Length__c e : events) {
				TimeInterval interval = findIntervalFromDescription((String)e.get('cp_calm__key__c'));
        		Integer cnt = Integer.valueOf(e.cp_calm__count__c);
        		if (countPerInterval.containsKey(interval)) {
        			cnt = cnt + countPerInterval.get(interval);
        		}
        		countPerInterval.put(interval, cnt);
        	}
        	for (TimeInterval interval : countPerInterval.keySet()) {
        		Integer cnt = countPerInterval.get(interval);
        		SessionLengthDetail sd = new SessionLengthDetail(interval, (cnt == -1) ? 0 : cnt);
        		sl_res.add(sd);
        	}
        }       

        sl_res.sort(); 
        return sl_res;
    }
    
    private static TimeInterval findIntervalFromDescription(String description) {
      for (TimeInterval interval : intervals) {
      	   if (description == interval.description)
      	       return interval;
      }
      return null;
    }
   
    // return the interval that contains (start, stop)
    private static TimeInterval findInterval(Datetime start, Datetime stop) {
        long duration = stop.getTime() - start.getTime();
        
        for (TimeInterval interval : intervals) {
            if (duration >= interval.start && duration <= interval.stop) {
                return interval;
            }
        }
        return intervals.get(intervals.size()-1);
    }
}