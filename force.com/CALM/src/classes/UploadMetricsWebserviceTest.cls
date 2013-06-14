@isTest
public with sharing class UploadMetricsWebserviceTest {
    static testMethod void testUploadMetricsWebservice()
    {
        List<cp_calm__Session__c> sessionStarts = new List<cp_calm__Session__c>();
        List<cp_calm__Session__c> sessionEnds = new List<cp_calm__Session__c>();
        List<cp_calm__Action__c> actions = new List<cp_calm__Action__c>();
        List<cp_calm__Event_Attribute__c> eventAttrs = new List<cp_calm__Event_Attribute__c>();
        
        sessionStarts.add(new cp_calm__Session__c(cp_calm__au__c = '1', cp_calm__u__c = '10' ,cp_calm__dov__c = '-1', cp_calm__lv__c = '-1', cp_calm__av__c = '-1', cp_calm__dlc__c = '-1', cp_calm__dma__c = '-1', cp_calm__dmo__c = '-1', cp_calm__dll__c = '-1', cp_calm__st__c = date.newinstance(2000, 1, 1), cp_calm__du__c = '-1', cp_calm__nca__c = 'test carrier'));
        sessionStarts.add(new cp_calm__Session__c(cp_calm__au__c = '1', cp_calm__u__c = '20' ,cp_calm__dov__c = '-1', cp_calm__lv__c = '-1', cp_calm__av__c = '-1', cp_calm__dlc__c = '-1', cp_calm__dma__c = '-1', cp_calm__dmo__c = '-1', cp_calm__dll__c = '-1', cp_calm__st__c = date.newinstance(2000, 1, 1), cp_calm__du__c = '-1', cp_calm__nca__c = 'test carrier'));
        sessionStarts.add(new cp_calm__Session__c(cp_calm__au__c = '1', cp_calm__u__c = '30' ,cp_calm__dov__c = '-1', cp_calm__lv__c = '-1', cp_calm__av__c = '-1', cp_calm__dlc__c = '-1', cp_calm__dma__c = '-1', cp_calm__dmo__c = '-1', cp_calm__dll__c = '-1', cp_calm__st__c = date.newinstance(2222, 1, 1), cp_calm__du__c = '-1', cp_calm__nca__c = 'test carrier'));
        sessionStarts.add(new cp_calm__Session__c(cp_calm__au__c = '1', cp_calm__u__c = '40' ,cp_calm__dov__c = '-1', cp_calm__lv__c = '-1', cp_calm__av__c = '-1', cp_calm__dlc__c = '-1', cp_calm__dma__c = '-1', cp_calm__dmo__c = '-1', cp_calm__dll__c = '-1', cp_calm__st__c = date.newinstance(2001, 1, 1), cp_calm__du__c = '-1', cp_calm__nca__c = 'test carrier'));
        
        sessionEnds.add(new cp_calm__Session__c(cp_calm__au__c = '1', cp_calm__u__c = '10' ,cp_calm__dov__c = '-1', cp_calm__lv__c = '-1', cp_calm__av__c = '-1', cp_calm__dlc__c = '-1', cp_calm__dma__c = '-1', cp_calm__dmo__c = '-1', cp_calm__dll__c = '-1', cp_calm__st__c = date.newinstance(2000, 1, 1), cp_calm__et__c = date.newinstance(2000, 2, 1), cp_calm__du__c = '-1', cp_calm__nca__c = 'test carrier'));
        
        actions.add(new cp_calm__Action__c(cp_calm__n__c ='action1', cp_calm__ct__c =datetime.newinstanceGMT(2000, 1, 2 , 15 , 0 , 0), cp_calm__su__c = '10', cp_calm__u__c = '1'));
        actions.add(new cp_calm__Action__c(cp_calm__n__c ='action1', cp_calm__ct__c =datetime.newinstanceGMT(2000, 1, 6 , 15 , 0 , 0), cp_calm__su__c = '20', cp_calm__u__c = '2'));
        actions.add(new cp_calm__Action__c(cp_calm__n__c ='action1', cp_calm__ct__c =datetime.newinstanceGMT(2000, 1, 3 , 15 , 0 , 0), cp_calm__su__c = '20', cp_calm__u__c = '3'));
        actions.add(new cp_calm__Action__c(cp_calm__n__c ='action1', cp_calm__ct__c =datetime.newinstanceGMT(2000, 1, 2 , 15 , 0 , 0), cp_calm__su__c = '20', cp_calm__u__c = '4'));
        actions.add(new cp_calm__Action__c(cp_calm__n__c ='action1', cp_calm__ct__c =datetime.newinstanceGMT(2000, 1, 1 , 15 , 0 , 0), cp_calm__su__c = '30', cp_calm__u__c = '5'));
                
        eventAttrs.add(new cp_calm__Event_Attribute__c(cp_calm__u__c = '1', cp_calm__k__c = 'key', cp_calm__v__c = 'val'));        
        
        UploadMetricsWebservice.post(sessionStarts, sessionEnds, actions, eventAttrs);
        
        system.assertEquals(4, database.countquery('SELECT COUNT()'
                +' FROM cp_calm__Session__c'));
        
        system.assertEquals(5, database.countquery('SELECT COUNT()'
                +' FROM cp_calm__Action__c'));
    }
}