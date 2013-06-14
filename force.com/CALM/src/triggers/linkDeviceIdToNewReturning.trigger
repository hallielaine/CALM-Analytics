trigger linkDeviceIdToNewReturning on Session__c (before insert) {
    for (Session__c session : Trigger.new)
    {
        Integer existing = 0;
        existing = [SELECT COUNT() FROM Session__c WHERE du__c = :session.du__c];
        
        if(existing == 0)
        {
        	session.nr__c = 'Y';
        }
        else
        {
         	session.nr__c = 'N';   
        }
    }
}