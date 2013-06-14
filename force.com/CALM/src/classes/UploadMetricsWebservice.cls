@RestResource(urlMapping='/UploadMetrics/*')
global with sharing class UploadMetricsWebservice 
{
    /**
     * This value is currently hard coded. It might later be user-configurable 
     * and stored in an SObject. 
     */
    private static final Integer treeDepthLimit = 4;
    
    @HttpPost
    global static void post(List<cp_calm__Session__c> sl, List<cp_calm__Session__c> sel, List<cp_calm__Action__c> al, List<cp_calm__Event_Attribute__c> eal)
    {
        insertMetrics(sl, sel, al, eal);
    }
    
    /**
     * Helper method for the post method. This method can be tested.
     */
    public static void insertMetrics(List<cp_calm__Session__c> sessions, List<cp_calm__Session__c> sessionEnds, List<cp_calm__Action__c> actions, List<cp_calm__Event_Attribute__c> attributes)
    {
        // Insert all the session starts
        insert sessions;
        // For every session end...
        for (cp_calm__Session__c sessionEnd: sessionEnds)
        {
            // ...select the session start and update it's endtime.
            cp_calm__Session__c session = [SELECT cp_calm__u__c, cp_calm__et__c, cp_calm__au__c FROM cp_calm__Session__c WHERE cp_calm__u__c = :sessionEnd.cp_calm__u__c];
            session.cp_calm__et__c = sessionEnd.cp_calm__et__c;
            update session;
        }
        
        // Insert all the actions
        insert actions;
        
        // Insert all the event attributes.
        insert attributes;
    }
}