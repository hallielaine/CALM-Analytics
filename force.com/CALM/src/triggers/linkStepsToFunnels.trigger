trigger linkStepsToFunnels on Step__c (before insert, before update) 
{
	for (Step__c step : Trigger.new)
    {
        step.f__c = [SELECT n__c FROM Funnel__c WHERE n__c = :step.fn__c].id;
    }
}