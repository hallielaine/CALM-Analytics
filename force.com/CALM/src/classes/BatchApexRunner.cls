@RestResource(urlMapping='/RunBatch/*')
global with sharing class BatchApexRunner
{     
	
	@HttpGet
    global static void get()
    {
        remoteRunTreeBuilder();
    }
	
	@RemoteAction
	global static String remoteSetNodeTypeToFunnel() {
		List<cp_calm__ActionNode__c> nodes = [SELECT cp_calm__nt__c
										FROM cp_calm__ActionNode__c];
	    for (cp_calm__ActionNode__c node : nodes) {
	    	node.cp_calm__nt__c = 'f';
	    }
	    
	    update nodes;
	    return 'OK';
	}
    
    @RemoteAction
	global static String remoteSetNodeTypeToScreen() {
		List<cp_calm__ActionNode__c> nodes = [SELECT cp_calm__nt__c
										FROM cp_calm__ActionNode__c];
	    for (cp_calm__ActionNode__c node : nodes) {
	    	node.cp_calm__nt__c = 's';
	    }
	    
	    update nodes;
	    return 'OK';
	}
	
    @RemoteAction
    global static String remoteRunDailyBarSweeper()
    {
        return runBatchDailyBarSweeper();
    }
    
    @RemoteAction
    global static String remoteDeleteBarEntries()
    {
        return deleteBarEntries();
    }
    
    @RemoteAction
    global static String remoteRunDailyLineSweeper()
    {
        return runBatchDailyLineSweeper();
    }
    
    @RemoteAction
    global static String remoteDeleteLineEntries()
    {
        return deleteLineEntries();
    }
    
    @RemoteAction
    global static String remoteRunMonthlySweeper()
    {
        return runBatchMonthlySweeper();
    }
    
    @RemoteAction
    global static String remoteScheduleDailySweepers()
    {
        return scheduleDailySweepers();
    }

    @RemoteAction
    global static String remoteDeleteTree()
    {
        return deleteTree();
    }
            
    /**
     * Helper method for the post method. This method can be tested.
     */
    public static String runBatchDailyBarSweeper()
    {  
        BarGraphSweeper sweep = new BarGraphSweeper();
        ID abatchprocessid = Database.executeBatch(sweep, 1);
        return abatchprocessid;
    }
    
    public static String scheduleDailySweepers()
    {
        String sch = '0 30 0 * * ?';
        system.schedule('Daily Sweeper', sch, new LineGraphSweeper());
        return 'Scheduled.';
    }
    
    public static String deleteBarEntries()
    {
        delete [select id from cp_calm__BG_Summary__c] ;
        
        delete [select id from cp_calm__BG_App_Version_Sessions__c] ;
        
        delete [select id from cp_calm__BG_App_Version_Users__c] ;
        
        delete [select id from cp_calm__BG_Country_Sessions__c] ;
        
        delete [select id from cp_calm__BG_Country_Users__c] ;
        
        delete [select id from cp_calm__BG_Network_Carrier_Sessions__c] ;
        
        delete [select id from cp_calm__BG_Network_Carrier_Users__c] ;
        
        delete [select id from cp_calm__BG_Session_Length__c] ;
        
        delete [select id from cp_calm__BG_Events__c] ;
        
        return 'Done';
    }
    
    public static String runBatchDailyLineSweeper()
    {  
    	Date start = date.newinstance(2013, 4, 3);
        LineGraphSweeper sweep = new LineGraphSweeper(start);
        ID abatchprocessid = Database.executeBatch(sweep);
        return abatchprocessid;
    }
    
    public static String deleteLineEntries()
    {
        delete [select id from cp_calm__LG_Summary__c] ;
        
        delete [select id from cp_calm__LG_New_Sessions__c] ;
        
        delete [select id from cp_calm__LG_New_Users__c] ;
        
        delete [select id from cp_calm__LG_Returning_Sessions__c] ;
        
        delete [select id from cp_calm__LG_Returning_Users__c] ;
        
        delete [select id from cp_calm__LG_Sessions__c] ;
        
        delete [select id from cp_calm__LG_Users__c] ;
        
        return 'Done';
    }
    
    private static void deleteMonthlySweepers()
    {
    	delete [select id from cp_calm__LG_Monthly_Summary__c];
    	delete [select id from cp_calm__BG_Monthly_App_Version__c];
    	delete [select id from cp_calm__BG_Monthly_Country__c];
    	delete [select id from cp_calm__BG_Monthly_Events__c];
    	delete [select id from cp_calm__BG_Monthly_Network_Carrier__c];
    	delete [select id from cp_calm__BG_Monthly_Session_Length__c];
    	delete [select id from cp_calm__Monthly_Filler__c];
    }
        
    /**
     * Helper method for the post method. This method can be tested.
     */
    public static String runBatchMonthlySweeper()
    {
        deleteMonthlySweepers();
        MonthlySweeper sweep = new MonthlySweeper();
        //BGMonthlyAppVersionSessionsSweeper sweep = new BGMonthlyAppVersionSessionsSweeper();
        ID abatchprocessid = Database.executeBatch(sweep);
        return abatchprocessid;
    }
    
    @RemoteAction
    public static String remoteRunTreeBuilder() {
        BatchTreeBuilder builder = new BatchTreeBuilder();
        ID abatchprocessid = Database.executeBatch(builder, 1);
        return abatchprocessid;
    }
    
    @RemoteAction
    public static String remoteRunScreenTreeBuilder() {
        BatchScreenTreeBuilder builder = new BatchScreenTreeBuilder();
        ID abatchprocessid = Database.executeBatch(builder, 1);
        return abatchprocessid;
    }
    
    public static String deleteTree() {
        delete [select id from cp_calm__ActionNode__c];
        return 'Done';
    }
}