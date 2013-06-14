trigger linkActionsToSessions on Action__c (before update, before insert)
{
    for (Action__c act : Trigger.new)
    {
        act.sl__c = [SELECT u__c FROM Session__c WHERE u__c = :act.su__c].id;
    }
}