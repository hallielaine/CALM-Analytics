@RestResource(urlMapping='/AddApp/*')
global with sharing class ApplicationRegistrationWebservice
{
    
    @HttpPost
    global static String post(String n)
    {
        return addApp(n);
    }
    
    @RemoteAction
    global static String remoteAddApp(String n)
    {
         return addApp(n);
    }
    
    @RemoteAction
    global static List<cp_calm__MobileApplication__c> remoteGetApps() {
        return getApps();
    }
    
    @RemoteAction
    global static void remoteDeleteApp(String n, Id i) {
        deleteApp(n, i);
    }
    
    @RemoteAction
    global static void remoteEditApp(Id i, String n, Integer sl, Integer fl) {
        editApp(i, n, sl, fl);
    }
    
    /**
     * Helper method for the post method. This method can be tested.
     */
    public static String addApp(String name)
    {  
        cp_calm__MobileApplication__c newApp = new cp_calm__MobileApplication__c();
        newApp.Name = name;
        
        insert newApp;
        
        for(cp_calm__MobileApplication__c app : 
        [SELECT Name FROM cp_calm__MobileApplication__c WHERE Name = :name])
        {
            return app.Id;
        }
        return null;
    }
    
    public static List<cp_calm__MobileApplication__c> getApps() {
        return [SELECT Name, Id, cp_calm__fl__c, cp_calm__sl__c FROM cp_calm__MobileApplication__c];
    }
    
    public static void deleteApp(String appName, Id appId) {
        delete [SELECT Name, Id FROM cp_calm__MobileApplication__c WHERE Name =: appName AND Id = :appId];
    }
    
    public static void editApp(Id appId, String appName, Integer screenDepth, Integer funnelDepth) {
    	cp_calm__MobileApplication__c app = [SELECT cp_calm__sl__c, cp_calm__fl__c FROM cp_calm__MobileApplication__c WHERE Id =: appId];
    	app.cp_calm__sl__c = screenDepth;
    	app.cp_calm__fl__c = funnelDepth;
    	update app;
    }
}