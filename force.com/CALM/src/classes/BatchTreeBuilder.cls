/**
 * A batch class to build the funnels tree.
 */
global with sharing class BatchTreeBuilder implements Database.Batchable<sObject>,Database.Stateful {
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'select cp_calm__u__c, cp_calm__au__c from cp_calm__Session__c WHERE cp_calm__et__c != null';
        return Database.getQueryLocator(query);
   }

    global void execute(Database.BatchableContext BC, List<cp_calm__Session__c> scope) {
        List<cp_calm__Action__c> actionsPerSession;
        
        for (cp_calm__Session__c session : scope) {
        	
            actionsPerSession = [SELECT u__c, n__c, dt__c, su__c
            					 FROM cp_calm__Action__c 
            					 WHERE cp_calm__su__c =: session.cp_calm__u__c
            					 ORDER BY cp_calm__ct__c ASC];
            					 
            TreeBuilder.insertSessionIntoTree(actionsPerSession, session.au__c, 'f');
        }
   }
   
   global void finish(Database.BatchableContext BC)
   {
   		DailySweeperDeleter deleter = new DailySweeperDeleter();
        Database.executeBatch(deleter);
   }
   
}