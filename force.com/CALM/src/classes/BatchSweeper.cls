global class BatchSweeper implements Database.Batchable<sObject>,Database.Stateful
{
   
   global Database.QueryLocator start(Database.BatchableContext BC)
   {
      String query = 'select cp_calm__n__c, cp_calm__dt__c, cp_calm__ct__c from cp_calm__Action__c where cp_calm__ct__c = LAST_N_DAYS:30';

      return Database.getQueryLocator(query);
   }

   global void execute(Database.BatchableContext BC, List<sObject> scope) {
   }
   
   global void finish(Database.BatchableContext BC)
   {
        delete [select Id from cp_calm__SweptAction__c];
        delete [select Id from cp_calm__SweptSessionAttribute__c];
        delete [select Id from cp_calm__Sweeper__c];
   }

}