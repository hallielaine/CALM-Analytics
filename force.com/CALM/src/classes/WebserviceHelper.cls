public with sharing class WebserviceHelper {
    public static Boolean shouldUseDailySweeper(Date start_date, Date end_date) {
        Boolean ret = (start_date >= date.today().addDays(-61));           
        ret = ret && ((start_date.daysBetween(end_date)+1) <= 60);
        return ret;
    }
    
    public static String getQueryForDailySweeper(String sweeper, String appKey) {
        String query = 'SELECT ';
            
        Map <String, Schema.SObjectType> gdMap = Schema.getGlobalDescribe();
        Map <String, Schema.SObjectField> fieldMap = gdMap.get(sweeper).getDescribe().fields.getMap();
        for(Schema.SObjectField sfield : fieldMap.Values()) {
            if (sfield.getDescribe().getName().contains('cp_calm')) {
              query += sfield.getDescribe().getName() + ',';
            }
        }
        query = query.substring(0, query.lastIndexOf(','));
        query += ' FROM ' + sweeper + ' WHERE cp_calm__au__c = \'' + appKey + '\'';

        return query;   
    }
    
    public static String getQueryForDailySweeper(String sweeper, String appKey, String addToWhere) {
        String query = 'SELECT ';
            
        Map <String, Schema.SObjectType> gdMap = Schema.getGlobalDescribe();
        Map <String, Schema.SObjectField> fieldMap = gdMap.get(sweeper).getDescribe().fields.getMap();
        for(Schema.SObjectField sfield : fieldMap.Values()) {
            if (sfield.getDescribe().getName().contains('cp_calm')) {
              query += sfield.getDescribe().getName() + ',';
            }
        }
        query = query.substring(0, query.lastIndexOf(','));
        query += ' FROM ' + sweeper + ' WHERE cp_calm__au__c = \'' + appKey + '\'' + ' AND ' + addToWhere;

        return query;   
    }
    
    public static String getAttributeForStartDay(String sweeper_day, Date start_date) {
        String day;
        Date last_swept_date = date.today().addDays(-1);
        Integer num_days_back = start_date.daysBetween(last_swept_date);
        
        if (num_days_back != 0) {
            Integer day_offset = Integer.valueOf(sweeper_day.removeStart('d'));
            if (day_offset - num_days_back >= 1) {
                day = 'd' + (day_offset - num_days_back);
            }
            else {
                Integer overflow = -1 * (day_offset - num_days_back);
                day = 'd' + (60 - overflow);
            }
        }
        else {
            day = sweeper_day;
        }
        return day;
    }
    
    public static String incrementDate(String currentDate) {
        Integer day_offset = Integer.valueOf(currentDate.removeStart('d'));
        day_offset++;
        if (day_offset > 60) {
            day_offset = 1;
        }
        return 'd' + day_offset;
    }
    
    public static Map<Date, Integer> getDataFromMonthSweeper(
        String graph, Date start_month, Date end_month, String app) {
        Map<Date, Integer> result= new Map<Date, Integer>();
        
        return result;
    }
}