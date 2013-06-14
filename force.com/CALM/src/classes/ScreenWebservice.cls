@RestResource(urlMapping='/GetScreens/*')
global with sharing class ScreenWebservice {
    global class ScreenDetail
    {
        /** name */
        public String n;
        /** count */
        public Integer c = 0;
        
        public ScreenDetail(String n, Integer c)
        {
            this.n = n;
            this.c = c;
        }
    }
    
    @HttpPost
    global static List<ScreenDetail> post(List<String> n,  String appKey)
    {
        return getScreens(n, appKey);
    }
    
    @RemoteAction
    global static Integer remoteGetScreenDepth(String appKey) {
    	return [SELECT cp_calm__sl__c FROM cp_calm__MobileApplication__c WHERE id =: appKey].cp_calm__sl__c.intValue();
    }
    
    @RemoteAction
    global static List<ScreenDetail> remoteGetScreens(List<String> n,  String appKey)
    {
        return getScreens(n, appKey);
    }
    
    /**
     * Helper method for the post method. This method can be tested.
     */
    public static List<ScreenDetail> getScreens(List<String> steps,  String appKey)
    {
        List<ScreenDetail> screens = new List<ScreenDetail>();
        
        // Is there a sequence of preceeding screens to worry about?
        if(steps != null && steps.size() > 0)
        { // Yes. Find all screens that follow the given sequence of screens in "steps"
            
	        cp_calm__ActionNode__c currNode;
	    	try {
		    	currNode = [SELECT cp_calm__count__c
						    FROM cp_calm__ActionNode__c 
						    WHERE cp_calm__au__c =: appKey 
						    AND name =: steps.get(0)
						    AND cp_calm__dt__c =: 's'
						    AND cp_calm__level__c =: 0
						    AND cp_calm__nt__c = 's'];
	    	}
	        catch(System.QueryException e) {
            	// list that came in was invalid, so go ahead and throw the Exception
            	// this try catch block is only here if we decide to do something other than throw in the future
	            if (e.getMessage() == 'List has no rows for assignment to SObject') {
	                throw e;
	            }
	            else {
	                throw e;
	            }
	        }
			    							   
	 		for (integer index = 1; index < steps.size(); index++)
	 		{
				try {
	 				currNode = [SELECT cp_calm__count__c
	 						    FROM cp_calm__ActionNode__c
	 						    WHERE cp_calm__au__c =: appKey 
		    					 AND name =: steps.get(index)
		    					 AND cp_calm__dt__c =: 's'
		    					 AND cp_calm__level__c =: index
		    					 AND cp_calm__Parent__c =: currNode.Id
		    					 AND cp_calm__nt__c = 's'];
	            }
	            catch(System.QueryException e) {
	            	// list that came in was invalid, so go ahead and throw the Exception
	            	// this try catch block is only here if we decide to do something other than throw in the future
	                if (e.getMessage() == 'List has no rows for assignment to SObject') {
	                    throw e;
	                }
	                else {
	                    throw e;
	                }
	            }
	 		}
	 		
	 		// now we want to get all of currNodes children
 			List<cp_calm__ActionNode__c> children = [SELECT name, cp_calm__count__c
	 												 FROM cp_calm__ActionNode__c
								 					 WHERE cp_calm__au__c =: appKey 
									    			 AND cp_calm__dt__c =: 's'
									    			 AND cp_calm__level__c =: steps.size()
									    			 AND cp_calm__Parent__c =: currNode.Id
									    			 AND cp_calm__nt__c = 's'
									    			 ORDER BY cp_calm__count__c DESC];
			
			for (cp_calm__ActionNode__c child : children) {
				screens.add(new ScreenDetail(child.name, child.cp_calm__count__c.intValue()));
			}
			
			return screens;
            
        }
        else
        { // No sequence to worry about. Just get the counts of all screens.
			for (cp_calm__ActionNode__c node : [SELECT name, cp_calm__count__c
										        FROM cp_calm__ActionNode__c 
								                WHERE cp_calm__au__c =: appKey 
										        AND cp_calm__dt__c =: 's'
										        AND cp_calm__level__c =: 0
										        AND cp_calm__nt__c =: 's'
										        ORDER BY cp_calm__count__c DESC]) {
										        	
                screens.add(new ScreenDetail(node.name, node.cp_calm__count__c.intValue()));
            }
            
            return screens;
        }
    }
}