@isTest
private class DailySweeperDeleterTest {

    static testMethod void testDelete()
    {
        List<cp_calm__Session__c> sessions = BaseTest.setupDeleteSessions();
        List<cp_calm__Action__c> actions = BaseTest.setupDeleteActions();
        
        //insert the sessions and actions
        insert sessions;
        insert actions;
        
        System.AssertEquals(4, database.countquery('SELECT COUNT() FROM cp_calm__Session__c'));
        System.AssertEquals(1, database.countquery('SELECT COUNT() FROM cp_calm__Session__c WHERE cp_calm__et__c = NULL'));
        System.AssertEquals(9, database.countquery('SELECT COUNT() FROM cp_calm__Action__c'));
        
        DailySweeperDeleter deleter = new DailySweeperDeleter();
        Database.executeBatch(deleter);
        
        System.AssertEquals(2, database.countquery('SELECT COUNT() FROM cp_calm__Session__c'));
        System.AssertEquals(1, database.countquery('SELECT COUNT() FROM cp_calm__Session__c WHERE cp_calm__et__c = NULL'));
        System.AssertEquals(3, database.countquery('SELECT COUNT() FROM cp_calm__Action__c'));
    }
}