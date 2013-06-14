@isTest
private class ActionNamesWebserviceTest {

    private static String APP_KEY = '1';
    private static String SCREEN_A = 'screen a';
    private static String SCREEN_B = 'screen b';
    private static String SCREEN_C = 'screen c';
    
    static testMethod void testGetActionNames()
    {
		insert new cp_calm__ActionNode__c(cp_calm__Count__c = 3,cp_calm__Level__c = 0, cp_calm__au__c = '1', cp_calm__dt__c = 'e', cp_calm__nt__c = 'f', Name = 'Eaction');
        insert new cp_calm__ActionNode__c(cp_calm__Count__c = 3,cp_calm__Level__c = 0, cp_calm__au__c = '1', cp_calm__dt__c = 's', cp_calm__nt__c = 'f', Name = 'Saction1');
        insert new cp_calm__ActionNode__c(cp_calm__Count__c = 3,cp_calm__Level__c = 0, cp_calm__au__c = '1', cp_calm__dt__c = 's', cp_calm__nt__c = 'f', Name = 'Saction2');
        
        Map<String, List<String>> names = FunnelsWebservice.remoteGetActionNames('1');
        
        system.assertEquals(1, names.get('events').size());
        system.assertEquals(2, names.get('screens').size());
    }
}