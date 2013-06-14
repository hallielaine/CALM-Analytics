trigger linkEventAttributesToActions on Event_Attribute__c (before update, before insert)
{
    for (Event_Attribute__c ea : Trigger.new)
    {
        ea.al__c = [SELECT u__c FROM Action__c WHERE u__c = :ea.u__c].id;
    }
}