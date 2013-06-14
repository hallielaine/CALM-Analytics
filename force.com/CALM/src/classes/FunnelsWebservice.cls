@RestResource(urlMapping='/GetFunnel/*')
global with sharing class FunnelsWebservice {


    global class StepDetail
    {
        public String n;
        public String dt;
        public Integer c = 0;
        
        public StepDetail(String n, String dt, Integer c)
        {
            this.n = n;
            this.dt = dt;
            this.c = c;
        }    
    }
    
    @HttpPost
    global static List<StepDetail> post(List<StepDetail> n,  String appKey)
    {
        return getTreeFunnel(n, appKey);
    }
    
    @RemoteAction
    global static List<StepDetail> remoteGetFunnel(List<StepDetail> n,  String appKey)
    {
        return getTreeFunnel(n, appKey);
    }
    
    @RemoteAction
    global static Integer remoteGetFunnelDepth(String appKey) {
        return [SELECT cp_calm__fl__c FROM cp_calm__MobileApplication__c WHERE id =: appKey].cp_calm__fl__c.intValue();
    }
    
    /**
     * Returns a Funnel for a list of actions (steps)
     * @param A List of StepDetails with c (count) initialized to 0
     * @return An identical list of StepDetails with the counts modified to their proper values
     */  
    @RemoteAction
    global static List<StepDetail> getTreeFunnel(List<StepDetail> n, String appKey)
    {
        cp_calm__ActionNode__c currNode;
        try {
                currNode = [SELECT cp_calm__count__c
                                            FROM cp_calm__ActionNode__c 
                                            WHERE cp_calm__au__c =: appKey 
                                            AND name =: n.get(0).n
                                            AND cp_calm__dt__c =: n.get(0).dt
                                            AND cp_calm__level__c =: 0
                                            AND cp_calm__nt__c = 'f'];
                
                n.get(0).c = currNode.cp_calm__Count__c.intValue();
        }
        catch(System.QueryException e) {
                // no node at the root, so return with counts of 0
            if (e.getMessage() == 'List has no rows for assignment to SObject') {
                return n;
            }
            else {
                throw e;
            }
        }
                                                                           
                for (integer index = 1; index < n.size(); index++)
                {
                        try {
                                currNode = [SELECT cp_calm__count__c
                                                FROM cp_calm__ActionNode__c
                                                WHERE cp_calm__au__c =: appKey 
                                         AND name =: n.get(index).n
                                         AND cp_calm__dt__c =: n.get(index).dt
                                         AND cp_calm__level__c =: index
                                         AND cp_calm__Parent__c =: currNode.Id
                                         AND cp_calm__nt__c = 'f'];
                        
                n.get(index).c = currNode.cp_calm__Count__c.intValue();
            }
            catch(System.QueryException e) {
                // no node with the given parent happened, so the count should be marked as 0
                if (e.getMessage() == 'List has no rows for assignment to SObject') {
                    n.get(index).c = 0;
                }
                else {
                    throw e;
                }
            }
                }
                
        
        return n;
    }
    
    
    @RemoteAction
    global static void remoteSaveFunnel(FunnelDetail newFunnel, String appKey)
    {
        cp_calm__Funnel__c funnel = new cp_calm__Funnel__c(cp_calm__n__c = newFunnel.n, cp_calm__au__c = appKey);
        remoteDeleteFunnels(newFunnel.n, appKey);
        insert funnel;
        
        Integer i = 0;
        /*Inserts steps - assumes they are in order of their position*/
        for(StepDetail sd: newFunnel.sd)
        {
            insert (new cp_calm__Step__c(cp_calm__an__c = sd.n, cp_calm__dt__c = sd.dt, cp_calm__fn__c = newFunnel.n, cp_calm__p__c = i));
            i++;
        }
    }
    
    @RemoteAction
    global static void remoteDeleteFunnels(String funnel, String appKey)
    {
        delete [SELECT cp_calm__au__c, cp_calm__n__c FROM cp_calm__Funnel__c WHERE cp_calm__n__c = :funnel and cp_calm__au__c = :appKey];
    }
    
    global class FunnelDetail
    {
        String n;
        List<StepDetail> sd ;
        
        public FunnelDetail(String n, List<StepDetail> sd)
        {
            this.n = n;
            this.sd = sd;
        }
    }
    
    @RemoteAction
    global static List<FunnelDetail> remoteGetSavedFunnels(String appKey)
    {
        List<StepDetail> currStepDetails;
        List<FunnelDetail> funnels = new List<FunnelDetail>();
        FunnelDetail fd;
        
        for(cp_calm__Funnel__c f : [SELECT cp_calm__au__c, cp_calm__n__c 
                                                           FROM cp_calm__Funnel__c 
                                                           WHERE cp_calm__au__c =: appKey 
                                                           ORDER BY createdDate ASC])
        {
            currStepDetails = new List<StepDetail>();
            
            for(cp_calm__Step__c s : [SELECT cp_calm__an__c, cp_calm__dt__c 
                                                          FROM cp_calm__Step__c 
                                                          WHERE cp_calm__f__r.au__c =: appkey
                                                          AND cp_calm__f__r.n__c = :f.cp_calm__n__c
                                                          ORDER BY cp_calm__p__c])
            {
                currStepDetails.add(new StepDetail(s.cp_calm__an__c, s.cp_calm__dt__c, 0));
            }
            
            fd = new FunnelDetail(f.cp_calm__n__c, getTreeFunnel(currStepDetails, appKey));
            funnels.add(fd);
        }
        return funnels;
    }
    
    @RemoteAction
    global static List<Id> remoteGetSavedFunnelIds(String appKey)
    {
        List<Id> result = new List<Id>();
        
        for(Funnel__c funnel: [SELECT Id FROM cp_calm__Funnel__c WHERE cp_calm__au__c =: appKey])
        {
            result.add(funnel.Id);
        }
        return result;
    }
    @RemoteAction
    public static List<StepDetail> remoteGetFunnelById(Id funnelID, String appKey)
    {
        List<StepDetail> steps = new List<StepDetail>();
        
        for (cp_calm__Step__c step: [SELECT cp_calm__an__c FROM cp_calm__Step__c WHERE f__r.id =: funnelID AND f__r.cp_calm__au__c =: appKey ORDER BY cp_calm__p__c])
        {
            steps.add(new StepDetail(step.cp_calm__an__c, step.cp_calm__dt__c, 0));
        }
        
        return getTreeFunnel(steps, appKey);
    }
     
    @RemoteAction
    global static Map<String, List<String>> remoteGetActionNames(String appKey)
    {
        return getActionNames(appKey);
    }
   
    @RemoteAction
    global static List<String> remoteGetEventNames(String appKey)
    {
       return getEventNames(appKey);
    }
   
    @RemoteAction
    global static List<String> remoteGetScreenNames(String appKey)
    {
       return getScreenNames(appKey);
    }
  
   
   /**
    * Helper method for getting the unique names of all of the events, 
    * and the unique names of all of the screens
    */
    public static Map<String, List<String>> getActionNames(String appKey)
    {
        Map<String, List<String>> ret = new Map<String, List<String>>();
        ret.put('events', getEventNames(appKey));
        ret.put('screens', getScreenNames(appKey));
        return ret;
    }
   
   /**
    * Helper method for getting the unique names of all of the events.
    */
    public static List<String> getEventNames(String appKey)
    {
       Set<String> eventNames = new Set<String>();
       
       for (cp_calm__ActionNode__c action : [SELECT name
                                                                                     FROM cp_calm__ActionNode__c 
                                                                             WHERE cp_calm__au__c =: appKey 
                                                                                     AND cp_calm__dt__c =: 'e'
                                                                                     AND cp_calm__level__c =: 0
                                                                                     AND cp_calm__nt__c =: 'f'])
       {
         eventNames.add(action.name);
       }
       
       List<String> ret = new List<String>();
       ret.addAll(eventNames);
       return ret;
    }

    /**
     * Helper method for getting the unique names of all of the screens.
     */
    public static List<String> getScreenNames(String appKey)
    {
        Set<String> screenNames = new Set<String>();
              
        for (cp_calm__ActionNode__c action : [SELECT name
                                                                                      FROM cp_calm__ActionNode__c 
                                                                              WHERE cp_calm__au__c =: appKey 
                                                                                      AND cp_calm__dt__c =: 's'
                                                                                      AND cp_calm__level__c =: 0
                                                                                      AND cp_calm__nt__c =: 'f'])
        {
          screenNames.add(action.name);
        }
          
        List<String> ret = new List<String>();
        ret.addAll(screenNames);
        return ret;
    }
    
}