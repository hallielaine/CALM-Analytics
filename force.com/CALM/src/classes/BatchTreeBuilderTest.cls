@isTest
public with sharing class BatchTreeBuilderTest {
    
    static testMethod void testTreeOneSession() {
    	
    	cp_calm__MobileApplication__c app = new cp_calm__MobileApplication__c(name = 'unit-test', 
    																	      cp_calm__fl__c = 4, 
    																	      cp_calm__sl__c = 4);
        insert app;
    	
        List<cp_calm__Session__c> sessionStarts = new List<cp_calm__Session__c>();
        List<cp_calm__Session__c> sessionEnds = new List<cp_calm__Session__c>();
        List<cp_calm__Action__c> actions = new List<cp_calm__Action__c>();
        List<cp_calm__Event_Attribute__c> eventAttrs = new List<cp_calm__Event_Attribute__c>();
        
        // create a session
        sessionStarts.add(new cp_calm__Session__c(
	    						cp_calm__u__c = '1', 
	                            cp_calm__st__c = date.newinstance(2000, 1, 1), 
	                            cp_calm__au__c = app.Id, cp_calm__dov__c = '-1', 
	                            cp_calm__lv__c = '-1', cp_calm__av__c = '-1', 
	                            cp_calm__dlc__c = '-1', cp_calm__dma__c = '-1', 
	                            cp_calm__dmo__c = '-1', cp_calm__dll__c = '-1', 
	                            cp_calm__du__c = '-1', cp_calm__nca__c = '-1'));
        
        // create actions that belong to the above session
        actions.add(new cp_calm__Action__c(
	    					cp_calm__n__c ='A', 
	                        cp_calm__ct__c = datetime.newinstanceGMT(2000,1,2,15,0,0),
	                        cp_calm__su__c = '1', 
	                        cp_calm__u__c = '1'));
                        
        actions.add(new cp_calm__Action__c(
	                        cp_calm__n__c ='B', 
	                        cp_calm__ct__c =datetime.newinstanceGMT(2000,1,2,15,1,0),
	                        cp_calm__su__c = '1', 
	                        cp_calm__u__c = '2'));
                        
        actions.add(new cp_calm__Action__c(
	                        cp_calm__n__c ='C', 
	                        cp_calm__ct__c =datetime.newinstanceGMT(2000,1,2,15,2,0),
	                        cp_calm__su__c = '1', 
	                        cp_calm__u__c = '3'));
                        
        actions.add(new cp_calm__Action__c(
	                        cp_calm__n__c ='D', 
	                        cp_calm__ct__c =datetime.newinstanceGMT(2000,1,2,15,3,0),
	                        cp_calm__su__c = '1', 
	                        cp_calm__u__c = '4'));
        
        // close the session
        sessionEnds.add(new cp_calm__Session__c(
	        					cp_calm__u__c = '1', 
	                            cp_calm__et__c = date.newinstance(2000, 2, 1), 
	                            cp_calm__au__c = app.Id, cp_calm__dov__c = '-1', 
	                            cp_calm__lv__c = '-1', cp_calm__av__c = '-1', 
	                            cp_calm__dlc__c = '-1', cp_calm__dma__c = '-1', 
	                            cp_calm__dmo__c = '-1', cp_calm__dll__c = '-1', 
	                            cp_calm__du__c = '-1', cp_calm__nca__c = '-1'));
	                     
        Test.StartTest();
        UploadMetricsWebservice.insertMetrics(sessionStarts, sessionEnds, actions, eventAttrs);
        BatchTreeBuilder builder = new BatchTreeBuilder();
        ID batchprocessid = Database.executeBatch(builder);
        Test.StopTest();
        
        /* There were 4 actions in the session. The tree should look like the following:
         * A(1) -> B(1) -> C(1) -> D(1)
         * B(1) -> C(1) -> D(1)
         * C(1) -> D(1)
         * D(1)
         */
       
    	Integer numNodes;         
        numNodes = [SELECT COUNT() FROM cp_calm__ActionNode__c];
        system.assertEquals(10, numNodes);
        
        /***************************
         * check the level 0 nodes *
         ***************************/
        List<cp_calm__ActionNode__c> actionNodes = [SELECT name, cp_calm__Count__c 
        											FROM cp_calm__ActionNode__c 
        										    WHERE level__c = 0];
        										    
	    Set<String> actionNodeNames = new Set<String>();
	    for (cp_calm__ActionNode__c actionNode : actionNodes) {
	    	actionNodeNames.add(actionNode.name);
	    }
	    
	    for (cp_calm__ActionNode__c actionNode : actionNodes) {
	    	system.assertEquals(1, actionNode.cp_calm__Count__c.intValue());
	    }
        system.assertEquals(4, actionNodes.size());
        system.assert(actionNodeNames.contains('A'));
        system.assert(actionNodeNames.contains('B'));        
        system.assert(actionNodeNames.contains('C'));
        system.assert(actionNodeNames.contains('D'));        
	    actionNodeNames.clear();
	    
        /***************************
         * check the level 1 nodes *
         ***************************/
    	actionNodes = [SELECT name, cp_calm__Count__c
        			   FROM cp_calm__ActionNode__c 
        			   WHERE level__c = 1];
	    
	    for (cp_calm__ActionNode__c actionNode : actionNodes) {
	    	actionNodeNames.add(actionNode.name);
	    }
	    
	    for (cp_calm__ActionNode__c actionNode : actionNodes) {
	    	system.assertEquals(1, actionNode.cp_calm__Count__c.intValue());
	    }
        system.assertEquals(Integer.valueOf('3'), actionNodes.size());
        system.assert(actionNodeNames.contains('B'));
        system.assert(actionNodeNames.contains('C'));        
        system.assert(actionNodeNames.contains('D'));        
	    actionNodeNames.clear();
        
        /***************************
         * check the level 2 nodes *
         ***************************/
    	actionNodes = [SELECT name, cp_calm__Count__c
        			   FROM cp_calm__ActionNode__c 
        			   WHERE level__c = 2];
	    
	    for (cp_calm__ActionNode__c actionNode : actionNodes) {
	    	actionNodeNames.add(actionNode.name);
	    }
	    
	    for (cp_calm__ActionNode__c actionNode : actionNodes) {
	    	system.assertEquals(1, actionNode.cp_calm__Count__c.intValue());
	    }
        system.assertEquals(2, actionNodes.size());
        system.assert(actionNodeNames.contains('C'));        
        system.assert(actionNodeNames.contains('D'));        
	    actionNodeNames.clear();
        
        /***************************
         * check the level 3 nodes *
         ***************************/
    	actionNodes = [SELECT name, cp_calm__Count__c 
        			   FROM cp_calm__ActionNode__c 
        			   WHERE level__c = 3];
	    
	    for (cp_calm__ActionNode__c actionNode : actionNodes) {
	    	actionNodeNames.add(actionNode.name);
	    }
	    
	    for (cp_calm__ActionNode__c actionNode : actionNodes) {
	    	system.assertEquals(1, actionNode.cp_calm__Count__c.intValue());
	    }
        system.assertEquals(1, actionNodes.size());
        system.assert(actionNodeNames.contains('D'));
    }
    
    static testMethod void testTreeLongSession() {
    	
    	cp_calm__MobileApplication__c app = new cp_calm__MobileApplication__c(name = 'unit-test', 
    																	      cp_calm__fl__c = 4, 
    																	      cp_calm__sl__c = 4);
        insert app;
    	
        List<cp_calm__Session__c> sessionStarts = new List<cp_calm__Session__c>();
        List<cp_calm__Session__c> sessionEnds = new List<cp_calm__Session__c>();
        List<cp_calm__Action__c> actions = new List<cp_calm__Action__c>();
        List<cp_calm__Event_Attribute__c> eventAttrs = new List<cp_calm__Event_Attribute__c>();
        
        // create a session
        sessionStarts.add(new cp_calm__Session__c(
	                            cp_calm__u__c = '1', 
	                            cp_calm__st__c = date.newinstance(2000, 1, 1), 
	                            cp_calm__au__c = app.Id, cp_calm__dov__c = '-1', 
	                            cp_calm__lv__c = '-1', cp_calm__av__c = '-1', 
	                            cp_calm__dlc__c = '-1', cp_calm__dma__c = '-1', 
	                            cp_calm__dmo__c = '-1', cp_calm__dll__c = '-1', 
	                            cp_calm__du__c = '-1', cp_calm__nca__c = '-1'));
        
        // create actions that belong to the above session
        actions.add(new cp_calm__Action__c(
	                        cp_calm__n__c ='A', 
	                        cp_calm__ct__c =datetime.newinstanceGMT(2000,1,2,15,0,0),
	                        cp_calm__su__c = '1', 
	                        cp_calm__u__c = '1'));
                        
        actions.add(new cp_calm__Action__c(
	                        cp_calm__n__c ='B', 
	                        cp_calm__ct__c =datetime.newinstanceGMT(2000,1,2,15,1,0),
	                        cp_calm__su__c = '1', 
	                        cp_calm__u__c = '2'));
        
        actions.add(new cp_calm__Action__c(
	                        cp_calm__n__c ='C', 
	                        cp_calm__ct__c =datetime.newinstanceGMT(2000,1,2,15,2,0),
	                        cp_calm__su__c = '1', 
	                        cp_calm__u__c = '3'));
                        
        actions.add(new cp_calm__Action__c(
	                        cp_calm__n__c ='D', 
	                        cp_calm__ct__c =datetime.newinstanceGMT(2000,1,2,15,3,0),
	                        cp_calm__su__c = '1', 
	                        cp_calm__u__c = '4'));
                        
        actions.add(new cp_calm__Action__c(
	                        cp_calm__n__c ='E', 
	                        cp_calm__ct__c =datetime.newinstanceGMT(2000,1,2,15,4,0),
	                        cp_calm__su__c = '1', 
	                        cp_calm__u__c = '5'));  
                                              
        actions.add(new cp_calm__Action__c(
	                        cp_calm__n__c ='F', 
	                        cp_calm__ct__c =datetime.newinstanceGMT(2000,1,2,15,4,0),
	                        cp_calm__su__c = '1', 
	                        cp_calm__u__c = '6'));
                        
        // close the session
        sessionEnds.add(new cp_calm__Session__c(
	                            cp_calm__u__c = '1', 
	                            cp_calm__et__c = date.newinstance(2000, 2, 1), 
	                            cp_calm__au__c = app.Id, cp_calm__dov__c = '-1', 
	                            cp_calm__lv__c = '-1', cp_calm__av__c = '-1', 
	                            cp_calm__dlc__c = '-1', cp_calm__dma__c = '-1', 
	                            cp_calm__dmo__c = '-1', cp_calm__dll__c = '-1', 
	                            cp_calm__du__c = '-1', cp_calm__nca__c = '-1'));
        
        Test.StartTest();
        UploadMetricsWebservice.insertMetrics(sessionStarts, sessionEnds, actions, eventAttrs);
        BatchTreeBuilder builder = new BatchTreeBuilder();
        ID batchprocessid = Database.executeBatch(builder);
        Test.StopTest();
                
        /* There were 6 actions in the session. The tree should look like the following:
         * A(1) -> B(1) -> C(1) -> D(1)
         * E(1) -> F(1)
         * B(1) -> C(1) -> D(1) -> E(1)
         * F(1)
         * C(1) -> D(1) -> E(1) -> F(1)
         * D(1) -> E(1) -> F(1)
         */
		
		Integer numNodes;
        numNodes = [SELECT COUNT() FROM cp_calm__ActionNode__c];
        system.assertEquals(18, numNodes);
        
        /***************************
         * check the level 0 nodes *
         ***************************/
        List<cp_calm__ActionNode__c> actionNodes = [SELECT name, cp_calm__Count__c 
        											FROM cp_calm__ActionNode__c 
        										    WHERE level__c = 0];
        										    
	    Set<String> actionNodeNames = new Set<String>();
	    for (cp_calm__ActionNode__c actionNode : actionNodes) {
	    	actionNodeNames.add(actionNode.name);
	    }
	    
	    for (cp_calm__ActionNode__c actionNode : actionNodes) {
	    	system.assertEquals(1, actionNode.cp_calm__Count__c.intValue());
	    }
        system.assertEquals(6, actionNodes.size());
        system.assert(actionNodeNames.contains('A'));
        system.assert(actionNodeNames.contains('B'));        
        system.assert(actionNodeNames.contains('C'));
        system.assert(actionNodeNames.contains('D'));
        system.assert(actionNodeNames.contains('E'));
        system.assert(actionNodeNames.contains('F'));        
	    actionNodeNames.clear();
	    
        /***************************
         * check the level 1 nodes *
         ***************************/
    	actionNodes = [SELECT name, cp_calm__Count__c 
        			   FROM cp_calm__ActionNode__c 
        			   WHERE level__c = 1];
	    
	    for (cp_calm__ActionNode__c actionNode : actionNodes) {
	    	actionNodeNames.add(actionNode.name);
	    }
	    
	    for (cp_calm__ActionNode__c actionNode : actionNodes) {
	    	system.assertEquals(1, actionNode.cp_calm__Count__c.intValue());
	    }
        system.assertEquals(5, actionNodes.size());
        system.assert(actionNodeNames.contains('B'));
        system.assert(actionNodeNames.contains('C'));        
        system.assert(actionNodeNames.contains('D'));        
        system.assert(actionNodeNames.contains('E'));        
        system.assert(actionNodeNames.contains('F'));        
	    actionNodeNames.clear();
        
        /***************************
         * check the level 2 nodes *
         ***************************/
    	actionNodes = [SELECT name, cp_calm__Count__c 
        			   FROM cp_calm__ActionNode__c 
        			   WHERE level__c = 2];
	    
	    for (cp_calm__ActionNode__c actionNode : actionNodes) {
	    	actionNodeNames.add(actionNode.name);
	    }
	    
	    for (cp_calm__ActionNode__c actionNode : actionNodes) {
	    	system.assertEquals(1, actionNode.cp_calm__Count__c.intValue());
	    }
        system.assertEquals(4, actionNodes.size());
        system.assert(actionNodeNames.contains('C'));        
        system.assert(actionNodeNames.contains('D'));        
        system.assert(actionNodeNames.contains('E'));        
        system.assert(actionNodeNames.contains('F'));        
	    actionNodeNames.clear();
        
        /***************************
         * check the level 3 nodes *
         ***************************/
    	actionNodes = [SELECT name, cp_calm__Count__c 
        			   FROM cp_calm__ActionNode__c 
        			   WHERE level__c = 3];
	    
	    for (cp_calm__ActionNode__c actionNode : actionNodes) {
	    	actionNodeNames.add(actionNode.name);
	    }
	    
	    for (cp_calm__ActionNode__c actionNode : actionNodes) {
	    	system.assertEquals(1, actionNode.cp_calm__Count__c.intValue());
	    }
        system.assertEquals(3, actionNodes.size());
        system.assert(actionNodeNames.contains('D'));        
        system.assert(actionNodeNames.contains('E'));        
        system.assert(actionNodeNames.contains('F'));        
	    actionNodeNames.clear();
    }
    
    static testMethod void testTreeTwoLongSessions() {
    	
    	cp_calm__MobileApplication__c app = new cp_calm__MobileApplication__c(name = 'unit-test', 
    																	      cp_calm__fl__c = 4, 
    																	      cp_calm__sl__c = 4);
        insert app;
        
        List<cp_calm__Session__c> sessionStarts = new List<cp_calm__Session__c>();
        List<cp_calm__Session__c> sessionEnds = new List<cp_calm__Session__c>();
        List<cp_calm__Action__c> actions = new List<cp_calm__Action__c>();
        List<cp_calm__Event_Attribute__c> eventAttrs = new List<cp_calm__Event_Attribute__c>();
        
        // create two sessions
        sessionStarts.add(new cp_calm__Session__c(
	                            cp_calm__u__c = '1', 
	                            cp_calm__st__c = date.newinstance(2000, 1, 1), 
	                            cp_calm__au__c = app.Id, cp_calm__dov__c = '-1', 
	                            cp_calm__lv__c = '-1', cp_calm__av__c = '-1', 
	                            cp_calm__dlc__c = '-1', cp_calm__dma__c = '-1', 
	                            cp_calm__dmo__c = '-1', cp_calm__dll__c = '-1', 
	                            cp_calm__du__c = '-1', cp_calm__nca__c = '-1'));
                            
        sessionStarts.add(new cp_calm__Session__c(
	                            cp_calm__u__c = '2', 
	                            cp_calm__st__c = date.newinstance(2000, 2, 1), 
	                            cp_calm__au__c = app.Id, cp_calm__dov__c = '-1', 
	                            cp_calm__lv__c = '-1', cp_calm__av__c = '-1', 
	                            cp_calm__dlc__c = '-1', cp_calm__dma__c = '-1', 
	                            cp_calm__dmo__c = '-1', cp_calm__dll__c = '-1', 
	                            cp_calm__du__c = '-1', cp_calm__nca__c = '-1'));
        
        // create actions that belong to the above session
        actions.add(new cp_calm__Action__c(
	                        cp_calm__n__c ='A', 
	                        cp_calm__ct__c =datetime.newinstanceGMT(2000,1,2,15,0,0),
	                        cp_calm__su__c = '1', 
	                        cp_calm__u__c = '1'));
                        
        actions.add(new cp_calm__Action__c(
	                        cp_calm__n__c ='B', 
	                        cp_calm__ct__c =datetime.newinstanceGMT(2000,1,2,15,1,0),
	                        cp_calm__su__c = '1', 
	                        cp_calm__u__c = '2'));
        
        actions.add(new cp_calm__Action__c(
	                        cp_calm__n__c ='C', 
	                        cp_calm__ct__c =datetime.newinstanceGMT(2000,1,2,15,2,0),
	                        cp_calm__su__c = '1', 
	                        cp_calm__u__c = '3'));
                        
        actions.add(new cp_calm__Action__c(
	                        cp_calm__n__c ='D', 
	                        cp_calm__ct__c =datetime.newinstanceGMT(2000,1,2,15,3,0),
	                        cp_calm__su__c = '1', 
	                        cp_calm__u__c = '4'));
                        
        actions.add(new cp_calm__Action__c(
	                        cp_calm__n__c ='A', 
	                        cp_calm__ct__c =datetime.newinstanceGMT(2000,2,2,15,0,0),
	                        cp_calm__su__c = '2', 
	                        cp_calm__u__c = '5'));
                        
        actions.add(new cp_calm__Action__c(
	                        cp_calm__n__c ='B', 
	                        cp_calm__ct__c =datetime.newinstanceGMT(2000,2,2,15,1,0),
	                        cp_calm__su__c = '2', 
	                        cp_calm__u__c = '6'));
        
        actions.add(new cp_calm__Action__c(
	                        cp_calm__n__c ='C', 
	                        cp_calm__ct__c =datetime.newinstanceGMT(2000,2,2,15,2,0),
	                        cp_calm__su__c = '2', 
	                        cp_calm__u__c = '7'));
	                        
        actions.add(new cp_calm__Action__c(
	                        cp_calm__n__c ='E', 
	                        cp_calm__ct__c =datetime.newinstanceGMT(2000,2,2,15,3,0),
	                        cp_calm__su__c = '2', 
	                        cp_calm__u__c = '8'));
        
        // close the sessions
        sessionEnds.add(new cp_calm__Session__c(
	                            cp_calm__u__c = '1', 
	                            cp_calm__et__c = date.newinstance(2000, 2, 1), 
	                            cp_calm__au__c = app.Id, cp_calm__dov__c = '-1', 
	                            cp_calm__lv__c = '-1', cp_calm__av__c = '-1', 
	                            cp_calm__dlc__c = '-1', cp_calm__dma__c = '-1', 
	                            cp_calm__dmo__c = '-1', cp_calm__dll__c = '-1', 
	                            cp_calm__du__c = '-1', cp_calm__nca__c = '-1'));
                            
        sessionEnds.add(new cp_calm__Session__c(
	                            cp_calm__u__c = '2', 
	                            cp_calm__et__c = date.newinstance(2000, 3, 1), 
	                            cp_calm__au__c = app.Id, cp_calm__dov__c = '-1', 
	                            cp_calm__lv__c = '-1', cp_calm__av__c = '-1', 
	                            cp_calm__dlc__c = '-1', cp_calm__dma__c = '-1', 
	                            cp_calm__dmo__c = '-1', cp_calm__dll__c = '-1', 
	                            cp_calm__du__c = '-1', cp_calm__nca__c = '-1'));
        
        Test.StartTest();
        UploadMetricsWebservice.insertMetrics(sessionStarts, sessionEnds, actions, eventAttrs);
        BatchTreeBuilder builder = new BatchTreeBuilder();
        ID batchprocessid = Database.executeBatch(builder);
        Test.StopTest();
        
        /* The tree should look like the following:
         * A(2) -> B(2) -> C(2) -> D(1)
         *                     \-> E(1)
         * B(2) -> C(2) -> D(1)
         *             \-> E(1)
         * C(2) -> D(1)
         *     \-> E(1)
         * D(1)
         * E(1)
         */
         
        Integer numNodes;
        numNodes = [SELECT COUNT() FROM cp_calm__ActionNode__c];
        system.assertEquals(14, numNodes);
        
        /***************************
         * check the level 0 nodes *
         ***************************/
        List<cp_calm__ActionNode__c> actionNodes = [SELECT name, cp_calm__Count__c 
        											FROM cp_calm__ActionNode__c 
        										    WHERE level__c = 0];
        										    
	    Set<String> actionNodeNames = new Set<String>();
	    for (cp_calm__ActionNode__c actionNode : actionNodes) {
	    	actionNodeNames.add(actionNode.name);
	    }
	    
	    for (cp_calm__ActionNode__c actionNode : actionNodes) {
	    	if (actionNode.name == 'D' || actionNode.name == 'E') {
	    		system.assertEquals(1, actionNode.cp_calm__Count__c.intValue());
	    	}
	    	else {
	    		system.assertEquals(2, actionNode.cp_calm__Count__c.intValue());
	    	}

	    }
        system.assertEquals(5, actionNodes.size());
        system.assert(actionNodeNames.contains('A'));
        system.assert(actionNodeNames.contains('B'));        
        system.assert(actionNodeNames.contains('C'));
        system.assert(actionNodeNames.contains('D'));
        system.assert(actionNodeNames.contains('E'));        
	    actionNodeNames.clear();
	    
        /***************************
         * check the level 1 nodes *
         ***************************/
    	actionNodes = [SELECT name, cp_calm__Count__c, cp_calm__parent__c 
        			   FROM cp_calm__ActionNode__c 
        			   WHERE level__c = 1];
	    
	    for (cp_calm__ActionNode__c actionNode : actionNodes) {
	    	actionNodeNames.add(actionNode.name);
	    }
	    
	    for (cp_calm__ActionNode__c actionNode : actionNodes) {
    		if (actionNode.name == 'D' || actionNode.name == 'E') {
	    		system.assertEquals(1, actionNode.cp_calm__Count__c.intValue());
	    	}
	    	else {
	    		system.assertEquals(2, actionNode.cp_calm__Count__c.intValue());
	    	}
	    }
        system.assertEquals(4, actionNodes.size());
        system.assert(actionNodeNames.contains('B'));
        system.assert(actionNodeNames.contains('C'));        
        system.assert(actionNodeNames.contains('D'));        
        system.assert(actionNodeNames.contains('E'));        
	    actionNodeNames.clear();        
        
        /***************************
         * check the level 2 nodes *
         ***************************/
    	actionNodes = [SELECT name, cp_calm__Count__c 
        			   FROM cp_calm__ActionNode__c 
        			   WHERE level__c = 2];
	    
	    for (cp_calm__ActionNode__c actionNode : actionNodes) {
	    	actionNodeNames.add(actionNode.name);
	    }
	    
	    for (cp_calm__ActionNode__c actionNode : actionNodes) {
	    	if (actionNode.name == 'D' || actionNode.name == 'E') {
	    		system.assertEquals(1, actionNode.cp_calm__Count__c.intValue());
	    	}
	    	else {
	    		system.assertEquals(2, actionNode.cp_calm__Count__c.intValue());
	    	}
	    }
        system.assertEquals(3, actionNodes.size());
        system.assert(actionNodeNames.contains('C'));        
        system.assert(actionNodeNames.contains('D'));        
        system.assert(actionNodeNames.contains('E'));        
	    actionNodeNames.clear();        
        
        /***************************
         * check the level 3 nodes *
         ***************************/
    	actionNodes = [SELECT name, cp_calm__Count__c 
        			   FROM cp_calm__ActionNode__c 
        			   WHERE level__c = 3];
	    
	    for (cp_calm__ActionNode__c actionNode : actionNodes) {
	    	actionNodeNames.add(actionNode.name);
	    }
	    
	    for (cp_calm__ActionNode__c actionNode : actionNodes) {
	    	if (actionNode.name == 'D' || actionNode.name == 'E') {
	    		system.assertEquals(1, actionNode.cp_calm__Count__c.intValue());
	    	}
	    	else {
	    		system.assertEquals(2, actionNode.cp_calm__Count__c.intValue());
	    	}
	    }
        system.assertEquals(2, actionNodes.size());
        system.assert(actionNodeNames.contains('D'));        
        system.assert(actionNodeNames.contains('E'));        
	    actionNodeNames.clear();        
    }
    
    static testMethod void testTreeSessionWithRepeats() {
    	
    	cp_calm__MobileApplication__c app = new cp_calm__MobileApplication__c(name = 'unit-test', 
    																	      cp_calm__fl__c = 4, 
    																	      cp_calm__sl__c = 4);
        insert app;
    	
        List<cp_calm__Session__c> sessionStarts = new List<cp_calm__Session__c>();
        List<cp_calm__Session__c> sessionEnds = new List<cp_calm__Session__c>();
        List<cp_calm__Action__c> actions = new List<cp_calm__Action__c>();
        List<cp_calm__Event_Attribute__c> eventAttrs = new List<cp_calm__Event_Attribute__c>();
        
        // create one session
        sessionStarts.add(new cp_calm__Session__c(
	                            cp_calm__u__c = '1', 
	                            cp_calm__st__c = date.newinstance(2000, 1, 1), 
	                            cp_calm__au__c = app.Id, cp_calm__dov__c = '-1', 
	                            cp_calm__lv__c = '-1', cp_calm__av__c = '-1', 
	                            cp_calm__dlc__c = '-1', cp_calm__dma__c = '-1', 
	                            cp_calm__dmo__c = '-1', cp_calm__dll__c = '-1', 
	                            cp_calm__du__c = '-1', cp_calm__nca__c = '-1'));
                            
        // create actions that belong to the above session
        actions.add(new cp_calm__Action__c(
	                        cp_calm__n__c ='A', 
	                        cp_calm__ct__c =datetime.newinstanceGMT(2000,1,2,15,0,0),
	                        cp_calm__su__c = '1', 
	                        cp_calm__u__c = '1'));
                        
        actions.add(new cp_calm__Action__c(
	                        cp_calm__n__c ='B', 
	                        cp_calm__ct__c =datetime.newinstanceGMT(2000,1,2,15,1,0),
	                        cp_calm__su__c = '1', 
	                        cp_calm__u__c = '2'));
        
        actions.add(new cp_calm__Action__c(
	                        cp_calm__n__c ='C', 
	                        cp_calm__ct__c =datetime.newinstanceGMT(2000,1,2,15,2,0),
	                        cp_calm__su__c = '1', 
	                        cp_calm__u__c = '3'));
                        
        actions.add(new cp_calm__Action__c(
	                        cp_calm__n__c ='B', 
	                        cp_calm__ct__c =datetime.newinstanceGMT(2000,1,2,15,3,0),
	                        cp_calm__su__c = '1', 
	                        cp_calm__u__c = '4'));
                        
        // close the sessions
        sessionEnds.add(new cp_calm__Session__c(
	                            cp_calm__u__c = '1', 
	                            cp_calm__et__c = date.newinstance(2000, 2, 1), 
	                            cp_calm__au__c = app.Id, cp_calm__dov__c = '-1', 
	                            cp_calm__lv__c = '-1', cp_calm__av__c = '-1', 
	                            cp_calm__dlc__c = '-1', cp_calm__dma__c = '-1', 
	                            cp_calm__dmo__c = '-1', cp_calm__dll__c = '-1', 
	                            cp_calm__du__c = '-1', cp_calm__nca__c = '-1'));
                            
        Test.StartTest();
        UploadMetricsWebservice.insertMetrics(sessionStarts, sessionEnds, actions, eventAttrs);
        BatchTreeBuilder builder = new BatchTreeBuilder();
        ID batchprocessid = Database.executeBatch(builder);
        Test.StopTest();
        
        /* The tree should look like the following:
         * A(1) -> B(1) -> C(1) -> B(1)
         * B(2) -> C(1) -> B(1)
         * C(1) -> B(1)
         */
         
        Integer numNodes;
        numNodes = [SELECT COUNT() FROM cp_calm__ActionNode__c];
        system.assertEquals(9, numNodes);
        
        /***************************
         * check the level 0 nodes *
         ***************************/
        List<cp_calm__ActionNode__c> actionNodes = [SELECT name, cp_calm__Count__c 
        											FROM cp_calm__ActionNode__c 
        										    WHERE level__c = 0];
        										    
	    Set<String> actionNodeNames = new Set<String>();
	    for (cp_calm__ActionNode__c actionNode : actionNodes) {
	    	actionNodeNames.add(actionNode.name);
	    }
	    
	    for (cp_calm__ActionNode__c actionNode : actionNodes) {
	    	if (actionNode.name == 'B') {
	    		system.assertEquals(2, actionNode.cp_calm__Count__c.intValue());
	    	}
	    	else {
	    		system.assertEquals(1, actionNode.cp_calm__Count__c.intValue());
	    	}

	    }
        system.assertEquals(3, actionNodes.size());
        system.assert(actionNodeNames.contains('A'));
        system.assert(actionNodeNames.contains('B'));        
        system.assert(actionNodeNames.contains('C'));        
	    actionNodeNames.clear();
        
        /***************************
         * check the level 1 nodes *
         ***************************/
    	actionNodes = [SELECT name, cp_calm__Count__c, cp_calm__parent__c 
        			   FROM cp_calm__ActionNode__c 
        			   WHERE level__c = 1];
	    
        integer numBs = 0;
	    for (cp_calm__ActionNode__c actionNode : actionNodes) {
	    	actionNodeNames.add(actionNode.name);
	   		if (actionNode.name == 'B') {
	   			numBs++;
	   		}
	    }
	    
	    for (cp_calm__ActionNode__c actionNode : actionNodes) {
    		system.assertEquals(1, actionNode.cp_calm__Count__c.intValue());
	    }
        system.assertEquals(3, actionNodes.size());
        system.assert(actionNodeNames.contains('B'));
        system.assert(actionNodeNames.contains('C'));
        system.assertEquals(2, numBs);
	    actionNodeNames.clear();
        
        /***************************
         * check the level 2 nodes *
         ***************************/
    	actionNodes = [SELECT name, cp_calm__Count__c 
        			   FROM cp_calm__ActionNode__c 
        			   WHERE level__c = 2];
	    
	    for (cp_calm__ActionNode__c actionNode : actionNodes) {
	    	actionNodeNames.add(actionNode.name);
	    }
	    
	    for (cp_calm__ActionNode__c actionNode : actionNodes) {
    		system.assertEquals(1, actionNode.cp_calm__Count__c.intValue());
	    }
        system.assertEquals(2, actionNodes.size());
        system.assert(actionNodeNames.contains('B'));        
        system.assert(actionNodeNames.contains('C'));        
	    actionNodeNames.clear();        
        
        /***************************
         * check the level 3 nodes *
         ***************************/
    	actionNodes = [SELECT name, cp_calm__Count__c 
        			   FROM cp_calm__ActionNode__c 
        			   WHERE level__c = 3];
	    
	    for (cp_calm__ActionNode__c actionNode : actionNodes) {
	    	actionNodeNames.add(actionNode.name);
	    }
	    
	    for (cp_calm__ActionNode__c actionNode : actionNodes) {
    		system.assertEquals(1, actionNode.cp_calm__Count__c.intValue());
	    }
        system.assertEquals(1, actionNodes.size());
        system.assert(actionNodeNames.contains('B'));  
	    actionNodeNames.clear();
    }
    
    static testMethod void testTreeLongSessionWithRepeats() {
    	
		cp_calm__MobileApplication__c app = new cp_calm__MobileApplication__c(name = 'unit-test', 
    																	      cp_calm__fl__c = 4, 
    																	      cp_calm__sl__c = 4);
        insert app;
    	
        List<cp_calm__Session__c> sessionStarts = new List<cp_calm__Session__c>();
        List<cp_calm__Session__c> sessionEnds = new List<cp_calm__Session__c>();
        List<cp_calm__Action__c> actions = new List<cp_calm__Action__c>();
        List<cp_calm__Event_Attribute__c> eventAttrs = new List<cp_calm__Event_Attribute__c>();
        
        // create one session
        sessionStarts.add(new cp_calm__Session__c(
	                            cp_calm__u__c = '1', 
	                            cp_calm__st__c = date.newinstance(2000, 1, 1), 
	                            cp_calm__au__c = app.Id, cp_calm__dov__c = '-1', 
	                            cp_calm__lv__c = '-1', cp_calm__av__c = '-1', 
	                            cp_calm__dlc__c = '-1', cp_calm__dma__c = '-1', 
	                            cp_calm__dmo__c = '-1', cp_calm__dll__c = '-1', 
	                            cp_calm__du__c = '-1', cp_calm__nca__c = '-1'));
                            
        // create actions that belong to the above session
        actions.add(new cp_calm__Action__c(
	                        cp_calm__n__c ='A', 
	                        cp_calm__ct__c =datetime.newinstanceGMT(2000,1,2,15,0,0),
	                        cp_calm__su__c = '1', 
	                        cp_calm__u__c = '1'));
                        
        actions.add(new cp_calm__Action__c(
	                        cp_calm__n__c ='B', 
	                        cp_calm__ct__c =datetime.newinstanceGMT(2000,1,2,15,1,0),
	                        cp_calm__su__c = '1', 
	                        cp_calm__u__c = '2'));
        
        actions.add(new cp_calm__Action__c(
	                        cp_calm__n__c ='C', 
	                        cp_calm__ct__c =datetime.newinstanceGMT(2000,1,2,15,2,0),
	                        cp_calm__su__c = '1', 
	                        cp_calm__u__c = '3'));
                        
        actions.add(new cp_calm__Action__c(
	                        cp_calm__n__c ='B', 
	                        cp_calm__ct__c =datetime.newinstanceGMT(2000,1,2,15,3,0),
	                        cp_calm__su__c = '1', 
	                        cp_calm__u__c = '4'));
	                        
        actions.add(new cp_calm__Action__c(
	                        cp_calm__n__c ='C', 
	                        cp_calm__ct__c =datetime.newinstanceGMT(2000,1,2,15,4,0),
	                        cp_calm__su__c = '1', 
	                        cp_calm__u__c = '5'));
	                        
        actions.add(new cp_calm__Action__c(
	                        cp_calm__n__c ='A', 
	                        cp_calm__ct__c =datetime.newinstanceGMT(2000,1,2,15,5,0),
	                        cp_calm__su__c = '1', 
	                        cp_calm__u__c = '6'));
                        
        // close the sessions
        sessionEnds.add(new cp_calm__Session__c(
	                            cp_calm__u__c = '1', 
	                            cp_calm__et__c = date.newinstance(2000, 2, 1), 
	                            cp_calm__au__c = app.Id, cp_calm__dov__c = '-1', 
	                            cp_calm__lv__c = '-1', cp_calm__av__c = '-1', 
	                            cp_calm__dlc__c = '-1', cp_calm__dma__c = '-1', 
	                            cp_calm__dmo__c = '-1', cp_calm__dll__c = '-1', 
	                            cp_calm__du__c = '-1', cp_calm__nca__c = '-1'));
                            
		Test.StartTest();
        UploadMetricsWebservice.insertMetrics(sessionStarts, sessionEnds, actions, eventAttrs);
        BatchTreeBuilder builder = new BatchTreeBuilder();
        ID batchprocessid = Database.executeBatch(builder);
        Test.StopTest();
        
        /* The tree should look like the following:
         * A(2) -> B(1) -> C(1) -> B(1)
      	 * B(2) -> C(2) -> B(1) -> C(1)
         *             \-> A(1)
         * C(2) -> A(1)
         *	   \-> B(1) -> C(1) -> A(1)
         */
         
        Integer numNodes = [SELECT COUNT() FROM cp_calm__ActionNode__c];
        system.assertEquals(14, numNodes);
        
        /***************************
         * check the level 0 nodes *
         ***************************/
        List<cp_calm__ActionNode__c> actionNodes = [SELECT name, cp_calm__Count__c 
        											FROM cp_calm__ActionNode__c 
        										    WHERE level__c = 0];
        										    
	    Set<String> actionNodeNames = new Set<String>();
	    for (cp_calm__ActionNode__c actionNode : actionNodes) {
	    	actionNodeNames.add(actionNode.name);
	    }
	    
	    for (cp_calm__ActionNode__c actionNode : actionNodes) {
    		system.assertEquals(2, actionNode.cp_calm__Count__c.intValue());
	    }
        system.assertEquals(3, actionNodes.size());
        system.assert(actionNodeNames.contains('A'));
        system.assert(actionNodeNames.contains('B'));
        system.assert(actionNodeNames.contains('C'));        
	    actionNodeNames.clear();
        
        /***************************
         * check the level 1 nodes *
         ***************************/
    	actionNodes = [SELECT name, cp_calm__Count__c, cp_calm__parent__c 
        			   FROM cp_calm__ActionNode__c 
        			   WHERE level__c = 1];
	    
        integer numBs = 0;
	    for (cp_calm__ActionNode__c actionNode : actionNodes) {
	    	actionNodeNames.add(actionNode.name);
	   		if (actionNode.name == 'B') {
	   			numBs++;
	   		}
	    }
	    
	    for (cp_calm__ActionNode__c actionNode : actionNodes) {
	    	if (actionNode.name == 'C') {
	    		system.assertEquals(2, actionNode.cp_calm__Count__c.intValue());
	    	}
	    	else {
    			system.assertEquals(1, actionNode.cp_calm__Count__c.intValue());
	    	}
	    }
        system.assertEquals(4, actionNodes.size());
		system.assert(actionNodeNames.contains('A'));
        system.assert(actionNodeNames.contains('B'));
        system.assert(actionNodeNames.contains('C'));
        system.assertEquals(2, numBs);
	    actionNodeNames.clear();
        
        /***************************
         * check the level 2 nodes *
         ***************************/
    	actionNodes = [SELECT name, cp_calm__Count__c 
        			   FROM cp_calm__ActionNode__c 
        			   WHERE level__c = 2];
	    
	    integer numCs = 0;
	    for (cp_calm__ActionNode__c actionNode : actionNodes) {
	    	actionNodeNames.add(actionNode.name);
	    	if (actionNode.name == 'C') {
	    		numCs++;
	    	}
	    }
	    
	    for (cp_calm__ActionNode__c actionNode : actionNodes) {
			system.assertEquals(1, actionNode.cp_calm__Count__c.intValue());
	    }
        system.assertEquals(4, actionNodes.size());
        system.assert(actionNodeNames.contains('A'));
        system.assert(actionNodeNames.contains('B'));        
        system.assert(actionNodeNames.contains('C')); 
        system.assertEquals(2, numCs);       
	    actionNodeNames.clear();
        
        /***************************
         * check the level 3 nodes *
         ***************************/
    	actionNodes = [SELECT name, cp_calm__Count__c 
        			   FROM cp_calm__ActionNode__c 
        			   WHERE level__c = 3];
	    
	    for (cp_calm__ActionNode__c actionNode : actionNodes) {
	    	actionNodeNames.add(actionNode.name);
	    }
	    
	    for (cp_calm__ActionNode__c actionNode : actionNodes) {
    		system.assertEquals(1, actionNode.cp_calm__Count__c.intValue());
	    }
        system.assertEquals(3, actionNodes.size());
        system.assert(actionNodeNames.contains('A'));
        system.assert(actionNodeNames.contains('B'));
        system.assert(actionNodeNames.contains('C'));
	    actionNodeNames.clear();
    }
    
    /* This is essentially a "stress test" */
    static testMethod void testTreeManyLongSessionWithRepeats() {
    	
    	cp_calm__MobileApplication__c app = new cp_calm__MobileApplication__c(name = 'unit-test', 
    																	      cp_calm__fl__c = 4, 
    																	      cp_calm__sl__c = 4);
        insert app;
    	
        List<cp_calm__Session__c> sessionStarts = new List<cp_calm__Session__c>();
        List<cp_calm__Session__c> sessionEnds = new List<cp_calm__Session__c>();
        List<cp_calm__Action__c> actions = new List<cp_calm__Action__c>();
        List<cp_calm__Event_Attribute__c> eventAttrs = new List<cp_calm__Event_Attribute__c>();
        
        // create sessions
        sessionStarts.add(new cp_calm__Session__c(
	                            cp_calm__u__c = '1', 
	                            cp_calm__st__c = date.newinstance(2000, 1, 1), 
	                            cp_calm__au__c = app.Id, cp_calm__dov__c = '-1', 
	                            cp_calm__lv__c = '-1', cp_calm__av__c = '-1', 
	                            cp_calm__dlc__c = '-1', cp_calm__dma__c = '-1', 
	                            cp_calm__dmo__c = '-1', cp_calm__dll__c = '-1', 
	                            cp_calm__du__c = '-1', cp_calm__nca__c = '-1'));
                            
    	sessionStarts.add(new cp_calm__Session__c(
	                            cp_calm__u__c = '2', 
	                            cp_calm__st__c = date.newinstance(2000, 2, 1), 
	                            cp_calm__au__c = app.Id, cp_calm__dov__c = '-1', 
	                            cp_calm__lv__c = '-1', cp_calm__av__c = '-1', 
	                            cp_calm__dlc__c = '-1', cp_calm__dma__c = '-1', 
	                            cp_calm__dmo__c = '-1', cp_calm__dll__c = '-1', 
	                            cp_calm__du__c = '-1', cp_calm__nca__c = '-1'));        
    	
    	sessionStarts.add(new cp_calm__Session__c(
	                            cp_calm__u__c = '3', 
	                            cp_calm__st__c = date.newinstance(2000, 3, 1), 
	                            cp_calm__au__c = app.Id, cp_calm__dov__c = '-1', 
	                            cp_calm__lv__c = '-1', cp_calm__av__c = '-1', 
	                            cp_calm__dlc__c = '-1', cp_calm__dma__c = '-1', 
	                            cp_calm__dmo__c = '-1', cp_calm__dll__c = '-1', 
	                            cp_calm__du__c = '-1', cp_calm__nca__c = '-1'));
                                    
        sessionStarts.add(new cp_calm__Session__c(
	                            cp_calm__u__c = '4', 
	                            cp_calm__st__c = date.newinstance(2000, 4, 1), 
	                            cp_calm__au__c = app.Id, cp_calm__dov__c = '-1', 
	                            cp_calm__lv__c = '-1', cp_calm__av__c = '-1', 
	                            cp_calm__dlc__c = '-1', cp_calm__dma__c = '-1', 
	                            cp_calm__dmo__c = '-1', cp_calm__dll__c = '-1', 
	                            cp_calm__du__c = '-1', cp_calm__nca__c = '-1'));
                            
                            
        // create actions that belong to the above session
        // session 1
        actions.add(new cp_calm__Action__c(
	                        cp_calm__n__c ='A', 
	                        cp_calm__ct__c =datetime.newinstanceGMT(2000,1,2,15,0,0),
	                        cp_calm__su__c = '1', 
	                        cp_calm__u__c = '1'));
        actions.add(new cp_calm__Action__c(
	                        cp_calm__n__c ='B', 
	                        cp_calm__ct__c =datetime.newinstanceGMT(2000,1,2,15,1,0),
	                        cp_calm__su__c = '1', 
	                        cp_calm__u__c = '2'));
        actions.add(new cp_calm__Action__c(
	                        cp_calm__n__c ='C', 
	                        cp_calm__ct__c =datetime.newinstanceGMT(2000,1,2,15,2,0),
	                        cp_calm__su__c = '1', 
	                        cp_calm__u__c = '3'));
        actions.add(new cp_calm__Action__c(
	                        cp_calm__n__c ='D', 
	                        cp_calm__ct__c =datetime.newinstanceGMT(2000,1,2,15,3,0),
	                        cp_calm__su__c = '1', 
	                        cp_calm__u__c = '4'));
        actions.add(new cp_calm__Action__c(
	                        cp_calm__n__c ='C', 
	                        cp_calm__ct__c =datetime.newinstanceGMT(2000,1,2,15,4,0),
	                        cp_calm__su__c = '1', 
	                        cp_calm__u__c = '5'));
        actions.add(new cp_calm__Action__c(
	                        cp_calm__n__c ='A', 
	                        cp_calm__ct__c =datetime.newinstanceGMT(2000,1,2,15,5,0),
	                        cp_calm__su__c = '1', 
	                        cp_calm__u__c = '6'));
	                        
		// session 2
        actions.add(new cp_calm__Action__c(
	                        cp_calm__n__c ='B', 
	                        cp_calm__ct__c =datetime.newinstanceGMT(2000,2,2,15,0,0),
	                        cp_calm__su__c = '2', 
	                        cp_calm__u__c = '7'));
        actions.add(new cp_calm__Action__c(
	                        cp_calm__n__c ='B', 
	                        cp_calm__ct__c =datetime.newinstanceGMT(2000,2,2,15,1,0),
	                        cp_calm__su__c = '2', 
	                        cp_calm__u__c = '8'));
        actions.add(new cp_calm__Action__c(
	                        cp_calm__n__c ='C', 
	                        cp_calm__ct__c =datetime.newinstanceGMT(2000,2,2,15,2,0),
	                        cp_calm__su__c = '2', 
	                        cp_calm__u__c = '9'));
        actions.add(new cp_calm__Action__c(
	                        cp_calm__n__c ='A', 
	                        cp_calm__ct__c =datetime.newinstanceGMT(2000,2,2,15,3,0),
	                        cp_calm__su__c = '2', 
	                        cp_calm__u__c = '10'));
        actions.add(new cp_calm__Action__c(
	                        cp_calm__n__c ='D', 
	                        cp_calm__ct__c =datetime.newinstanceGMT(2000,2,2,15,4,0),
	                        cp_calm__su__c = '2', 
	                        cp_calm__u__c = '11'));
        actions.add(new cp_calm__Action__c(
	                        cp_calm__n__c ='A', 
	                        cp_calm__ct__c =datetime.newinstanceGMT(2000,2,2,15,5,0),
	                        cp_calm__su__c = '2', 
	                        cp_calm__u__c = '12'));
		// session 3
        actions.add(new cp_calm__Action__c(
	                        cp_calm__n__c ='E', 
	                        cp_calm__ct__c =datetime.newinstanceGMT(2000,3,2,15,0,0),
	                        cp_calm__su__c = '3', 
	                        cp_calm__u__c = '13'));
        actions.add(new cp_calm__Action__c(
	                        cp_calm__n__c ='F', 
	                        cp_calm__ct__c =datetime.newinstanceGMT(2000,3,2,15,1,0),
	                        cp_calm__su__c = '3', 
	                        cp_calm__u__c = '14'));
        actions.add(new cp_calm__Action__c(
	                        cp_calm__n__c ='D', 
	                        cp_calm__ct__c =datetime.newinstanceGMT(2000,3,2,15,2,0),
	                        cp_calm__su__c = '3', 
	                        cp_calm__u__c = '15'));
        actions.add(new cp_calm__Action__c(
	                        cp_calm__n__c ='C', 
	                        cp_calm__ct__c =datetime.newinstanceGMT(2000,3,2,15,3,0),
	                        cp_calm__su__c = '3', 
	                        cp_calm__u__c = '16'));
        actions.add(new cp_calm__Action__c(
	                        cp_calm__n__c ='A', 
	                        cp_calm__ct__c =datetime.newinstanceGMT(2000,3,2,15,4,0),
	                        cp_calm__su__c = '3', 
	                        cp_calm__u__c = '17'));
        actions.add(new cp_calm__Action__c(
	                        cp_calm__n__c ='B', 
	                        cp_calm__ct__c =datetime.newinstanceGMT(2000,3,2,15,5,0),
	                        cp_calm__su__c = '3', 
	                        cp_calm__u__c = '18'));
        actions.add(new cp_calm__Action__c(
	                        cp_calm__n__c ='F', 
	                        cp_calm__ct__c =datetime.newinstanceGMT(2000,3,2,15,6,0),
	                        cp_calm__su__c = '3', 
	                        cp_calm__u__c = '19'));
                        
        // session 4
        actions.add(new cp_calm__Action__c(
	                        cp_calm__n__c ='E', 
	                        cp_calm__ct__c =datetime.newinstanceGMT(2000,4,2,15,0,0),
	                        cp_calm__su__c = '4', 
	                        cp_calm__u__c = '20'));
        actions.add(new cp_calm__Action__c(
	                        cp_calm__n__c ='F', 
	                        cp_calm__ct__c =datetime.newinstanceGMT(2000,4,2,15,1,0),
	                        cp_calm__su__c = '4', 
	                        cp_calm__u__c = '21'));
        actions.add(new cp_calm__Action__c(
	                        cp_calm__n__c ='D', 
	                        cp_calm__ct__c =datetime.newinstanceGMT(2000,4,2,15,2,0),
	                        cp_calm__su__c = '4', 
	                        cp_calm__u__c = '22'));
        actions.add(new cp_calm__Action__c(
	                        cp_calm__n__c ='C', 
	                        cp_calm__ct__c =datetime.newinstanceGMT(2000,4,2,15,3,0),
	                        cp_calm__su__c = '4', 
	                        cp_calm__u__c = '23'));
        actions.add(new cp_calm__Action__c(
	                        cp_calm__n__c ='A', 
	                        cp_calm__ct__c =datetime.newinstanceGMT(2000,4,2,15,4,0),
	                        cp_calm__su__c = '4', 
	                        cp_calm__u__c = '24'));
        actions.add(new cp_calm__Action__c(
	                        cp_calm__n__c ='B', 
	                        cp_calm__ct__c =datetime.newinstanceGMT(2000,4,2,15,5,0),
	                        cp_calm__su__c = '4', 
	                        cp_calm__u__c = '25'));
        actions.add(new cp_calm__Action__c(
	                        cp_calm__n__c ='F', 
	                        cp_calm__ct__c =datetime.newinstanceGMT(2000,4,2,15,6,0),
	                        cp_calm__su__c = '4', 
	                        cp_calm__u__c = '26'));
	                        
        // close the sessions
        sessionEnds.add(new cp_calm__Session__c(
	                            cp_calm__u__c = '1', 
	                            cp_calm__et__c = date.newinstance(2000, 2, 1), 
	                            cp_calm__au__c = app.Id, cp_calm__dov__c = '-1', 
	                            cp_calm__lv__c = '-1', cp_calm__av__c = '-1', 
	                            cp_calm__dlc__c = '-1', cp_calm__dma__c = '-1', 
	                            cp_calm__dmo__c = '-1', cp_calm__dll__c = '-1', 
	                            cp_calm__du__c = '-1', cp_calm__nca__c = '-1'));        
        sessionEnds.add(new cp_calm__Session__c(
	                            cp_calm__u__c = '2', 
	                            cp_calm__et__c = date.newinstance(2000, 3, 1), 
	                            cp_calm__au__c = app.Id, cp_calm__dov__c = '-1', 
	                            cp_calm__lv__c = '-1', cp_calm__av__c = '-1', 
	                            cp_calm__dlc__c = '-1', cp_calm__dma__c = '-1', 
	                            cp_calm__dmo__c = '-1', cp_calm__dll__c = '-1', 
	                            cp_calm__du__c = '-1', cp_calm__nca__c = '-1'));
        sessionEnds.add(new cp_calm__Session__c(
	                            cp_calm__u__c = '3', 
	                            cp_calm__et__c = date.newinstance(2000, 4, 1), 
	                            cp_calm__au__c = app.Id, cp_calm__dov__c = '-1', 
	                            cp_calm__lv__c = '-1', cp_calm__av__c = '-1', 
	                            cp_calm__dlc__c = '-1', cp_calm__dma__c = '-1', 
	                            cp_calm__dmo__c = '-1', cp_calm__dll__c = '-1', 
	                            cp_calm__du__c = '-1', cp_calm__nca__c = '-1'));
        sessionEnds.add(new cp_calm__Session__c(
	                            cp_calm__u__c = '4', 
	                            cp_calm__et__c = date.newinstance(2000, 5, 1), 
	                            cp_calm__au__c = app.Id, cp_calm__dov__c = '-1', 
	                            cp_calm__lv__c = '-1', cp_calm__av__c = '-1', 
	                            cp_calm__dlc__c = '-1', cp_calm__dma__c = '-1', 
	                            cp_calm__dmo__c = '-1', cp_calm__dll__c = '-1', 
	                            cp_calm__du__c = '-1', cp_calm__nca__c = '-1'));	                            
                            
		Test.StartTest();
        UploadMetricsWebservice.insertMetrics(sessionStarts, sessionEnds, actions, eventAttrs);
        BatchTreeBuilder builder = new BatchTreeBuilder();
        ID batchprocessid = Database.executeBatch(builder);
        Test.StopTest();
		        
        /* The tree should look like the following:
         *
         *             /-> F(2)
         * A(6) -> B(3) -> C(1) -> D(1)
         *     \-> D(1) -> A(1)
         *     
         *	   /-> F(2)
         *    /        /-> A(1) -> D(1)
         * B(5) -> C(2) -> D(1) -> C(1)
         *     \-> B(1) -> C(1) -> A(1)
         *
         * C(5) -> D(1) -> C(1) -> A(1)
         *     \-> A(4) -> D(1) -> A(1)
         *             \-> B(2) -> F(2)
         *
         * D(4) -> C(3) -> A(3) -> B(2)
         *     \-> A(1)
         *
         * E(2) -> F(2) -> D(2) -> C(2)
         * 
         * F(4) -> D(2) -> C(2) -> A(2)
         */
         
        Integer numNodes = [SELECT COUNT() FROM cp_calm__ActionNode__c];
        system.assertEquals(39, numNodes);
        
        /***************************
         * check the level 0 nodes *
         ***************************/
        List<cp_calm__ActionNode__c> actionNodes = [SELECT name, cp_calm__Count__c 
        											FROM cp_calm__ActionNode__c 
        										    WHERE level__c = 0];
        										    
	    Set<String> actionNodeNames = new Set<String>();
	    for (cp_calm__ActionNode__c actionNode : actionNodes) {
	    	actionNodeNames.add(actionNode.name);
	    }
	    
	    for (cp_calm__ActionNode__c actionNode : actionNodes) {
	    	integer expectedCount;
	    	if (actionNode.name == 'A') {
	    		expectedCount = 6;
	    	}
	    	else if (actionNode.name == 'B') {
	    		expectedCount = 5;
	    	}
	    	else if (actionNode.name == 'C') {
	    		expectedCount = 5;
	    	}
	    	else if (actionNode.name == 'D') {
	    		expectedCount = 4;
	    	}
	    	else if (actionNode.name == 'E') {
	    		expectedCount = 2;
	    	}
	    	else if (actionNode.name == 'F') {
	    		expectedCount = 4;
	    	}
    		system.assertEquals(expectedCount, actionNode.cp_calm__Count__c.intValue());
	    }
        system.assertEquals(6, actionNodes.size());
        system.assert(actionNodeNames.contains('A'));
        system.assert(actionNodeNames.contains('B'));
        system.assert(actionNodeNames.contains('C'));
        system.assert(actionNodeNames.contains('D'));
        system.assert(actionNodeNames.contains('E'));
        system.assert(actionNodeNames.contains('F'));
	    actionNodeNames.clear();
        
        /* get root elements */
        cp_calm__ActionNode__c A = [SELECT Id FROM cp_calm__ActionNode__c WHERE name = 'A' AND level__c = 0];
		cp_calm__ActionNode__c B = [SELECT Id FROM cp_calm__ActionNode__c WHERE name = 'B' AND level__c = 0];
		cp_calm__ActionNode__c C = [SELECT Id FROM cp_calm__ActionNode__c WHERE name = 'C' AND level__c = 0];
		cp_calm__ActionNode__c D = [SELECT Id FROM cp_calm__ActionNode__c WHERE name = 'D' AND level__c = 0];
		cp_calm__ActionNode__c E = [SELECT Id FROM cp_calm__ActionNode__c WHERE name = 'E' AND level__c = 0];
		cp_calm__ActionNode__c F = [SELECT Id FROM cp_calm__ActionNode__c WHERE name = 'F' AND level__c = 0];
        
		/***************************
		 * check the level 1 nodes *
		 ***************************/
     	Integer numActionNodes = [SELECT COUNT()
			   					  FROM cp_calm__ActionNode__c 
			   					  WHERE level__c = 1];
		system.assertEquals(11, numActionNodes);
			   
		cp_calm__ActionNode__c AB = [SELECT name, cp_calm__count__c, cp_calm__parent__c
									 FROM cp_calm__ActionNode__c
									 WHERE cp_calm__parent__c =: A.Id 
									 AND name = 'B' AND level__c = 1];
		system.assertEquals(3, AB.cp_calm__Count__c);
		         				  
		cp_calm__ActionNode__c AD = [SELECT name, cp_calm__count__c, cp_calm__parent__c
									 FROM cp_calm__ActionNode__c
									 WHERE cp_calm__parent__c =: A.Id 
									 AND name = 'D' AND level__c = 1];
		system.assertEquals(1, AD.cp_calm__Count__c);
   		
   		cp_calm__ActionNode__c BF = [SELECT name, cp_calm__count__c, cp_calm__parent__c
									 FROM cp_calm__ActionNode__c
									 WHERE cp_calm__parent__c =: B.Id 
									 AND name = 'F' AND level__c = 1];
		system.assertEquals(2, BF.cp_calm__Count__c);
		
   		cp_calm__ActionNode__c BC = [SELECT name, cp_calm__count__c, cp_calm__parent__c
									 FROM cp_calm__ActionNode__c
									 WHERE cp_calm__parent__c =: B.Id 
									 AND name = 'C' AND level__c = 1];
		system.assertEquals(2, BC.cp_calm__Count__c);
		
   		cp_calm__ActionNode__c BB = [SELECT name, cp_calm__count__c, cp_calm__parent__c
									 FROM cp_calm__ActionNode__c
									 WHERE cp_calm__parent__c =: B.Id 
									 AND name = 'B' AND level__c = 1];
		system.assertEquals(1, BB.cp_calm__Count__c);
		
   		cp_calm__ActionNode__c CD = [SELECT name, cp_calm__count__c, cp_calm__parent__c
									 FROM cp_calm__ActionNode__c
									 WHERE cp_calm__parent__c =: C.Id 
									 AND name = 'D' AND level__c = 1];
		system.assertEquals(1, CD.cp_calm__Count__c);
		
   		cp_calm__ActionNode__c CA = [SELECT name, cp_calm__count__c, cp_calm__parent__c
									 FROM cp_calm__ActionNode__c
									 WHERE cp_calm__parent__c =: C.Id 
									 AND name = 'A' AND level__c = 1];
		system.assertEquals(4, CA.cp_calm__Count__c);
		
   		cp_calm__ActionNode__c DC = [SELECT name, cp_calm__count__c, cp_calm__parent__c
									 FROM cp_calm__ActionNode__c
									 WHERE cp_calm__parent__c =: D.Id 
									 AND name = 'C' AND level__c = 1];
		system.assertEquals(3, DC.cp_calm__Count__c);
		
   		cp_calm__ActionNode__c DA = [SELECT name, cp_calm__count__c, cp_calm__parent__c
									 FROM cp_calm__ActionNode__c
									 WHERE cp_calm__parent__c =: D.Id 
									 AND name = 'A' AND level__c = 1];
		system.assertEquals(1, DA.cp_calm__Count__c);
		
   		cp_calm__ActionNode__c EF = [SELECT name, cp_calm__count__c, cp_calm__parent__c
									 FROM cp_calm__ActionNode__c
									 WHERE cp_calm__parent__c =: E.Id 
									 AND name = 'F' AND level__c = 1];
		system.assertEquals(2, EF.cp_calm__Count__c);
		
   		cp_calm__ActionNode__c FD = [SELECT name, cp_calm__count__c, cp_calm__parent__c
									 FROM cp_calm__ActionNode__c
									 WHERE cp_calm__parent__c =: F.Id 
									 AND name = 'D' AND level__c = 1];
		system.assertEquals(2, FD.cp_calm__Count__c);
   				  
		/***************************
		 * check the level 2 nodes *
		 ***************************/
		numActionNodes = [SELECT COUNT()
			   			  FROM cp_calm__ActionNode__c 
			   		      WHERE level__c = 2];
		system.assertEquals(12, numActionNodes);
			   
		cp_calm__ActionNode__c ABC = [SELECT cp_calm__count__c
									  FROM cp_calm__ActionNode__c
									  WHERE cp_calm__parent__c =: AB.Id 
									  AND name = 'C' AND level__c = 2];
		system.assertEquals(1, ABC.cp_calm__Count__c);
		
		cp_calm__ActionNode__c ABF = [SELECT cp_calm__count__c
									  FROM cp_calm__ActionNode__c
									  WHERE cp_calm__parent__c =: AB.Id 
									  AND name = 'F' AND level__c = 2];
		system.assertEquals(2, ABF.cp_calm__Count__c);
		        				  
		cp_calm__ActionNode__c ADA = [SELECT cp_calm__count__c
									  FROM cp_calm__ActionNode__c
									  WHERE cp_calm__parent__c =: AD.Id 
									  AND name = 'A' AND level__c = 2];
		system.assertEquals(1, ADA.cp_calm__Count__c);

   		cp_calm__ActionNode__c BCA = [SELECT cp_calm__count__c
									  FROM cp_calm__ActionNode__c
									  WHERE cp_calm__parent__c =: BC.Id 
									  AND name = 'A' AND level__c = 2];
		system.assertEquals(1, BCA.cp_calm__Count__c);
		
   		cp_calm__ActionNode__c BCD = [SELECT cp_calm__count__c
									  FROM cp_calm__ActionNode__c
									  WHERE cp_calm__parent__c =: BC.Id 
									  AND name = 'D' AND level__c = 2];
		system.assertEquals(1, BCD.cp_calm__Count__c);
		
   		cp_calm__ActionNode__c BBC = [SELECT cp_calm__count__c
									  FROM cp_calm__ActionNode__c
									  WHERE cp_calm__parent__c =: BB.Id 
									  AND name = 'C' AND level__c = 2];
		system.assertEquals(1, BBC.cp_calm__Count__c);
		
   		cp_calm__ActionNode__c CDC = [SELECT cp_calm__count__c
									  FROM cp_calm__ActionNode__c
									  WHERE cp_calm__parent__c =: CD.Id 
									  AND name = 'C' AND level__c = 2];
		system.assertEquals(1, CDC.cp_calm__Count__c);
		
   		cp_calm__ActionNode__c CAD = [SELECT cp_calm__count__c
									  FROM cp_calm__ActionNode__c
									  WHERE cp_calm__parent__c =: CA.Id 
									  AND name = 'D' AND level__c = 2];
		system.assertEquals(1, CAD.cp_calm__Count__c);
		
   		cp_calm__ActionNode__c CAB = [SELECT cp_calm__count__c
									  FROM cp_calm__ActionNode__c
									  WHERE cp_calm__parent__c =: CA.Id 
									  AND name = 'B' AND level__c = 2];
		system.assertEquals(2, CAB.cp_calm__Count__c);
		
   		cp_calm__ActionNode__c DCA = [SELECT cp_calm__count__c
									  FROM cp_calm__ActionNode__c
									  WHERE cp_calm__parent__c =: DC.Id 
									  AND name = 'A' AND level__c = 2];
		system.assertEquals(3, DCA.cp_calm__Count__c);
		
   		cp_calm__ActionNode__c EFD = [SELECT cp_calm__count__c
									  FROM cp_calm__ActionNode__c
									  WHERE cp_calm__parent__c =: EF.Id 
									  AND name = 'D' AND level__c = 2];
		system.assertEquals(2, EFD.cp_calm__Count__c);
		
   		cp_calm__ActionNode__c FDC = [SELECT cp_calm__count__c
									  FROM cp_calm__ActionNode__c
									  WHERE cp_calm__parent__c =: FD.Id 
									  AND name = 'C' AND level__c = 2];
		system.assertEquals(2, FDC.cp_calm__Count__c);
		
		/***************************
		 * check the level 3 nodes *
		 ***************************/
		numActionNodes = [SELECT COUNT()
			   		      FROM cp_calm__ActionNode__c 
			   			  WHERE level__c = 3];
		system.assertEquals(10, numActionNodes);
			   
		cp_calm__ActionNode__c ABCD = [SELECT cp_calm__count__c
									   FROM cp_calm__ActionNode__c
									   WHERE cp_calm__parent__c =: ABC.Id 
									   AND name = 'D' AND level__c = 3];
		system.assertEquals(1, ABCD.cp_calm__Count__c);
		
   		cp_calm__ActionNode__c BCAD = [SELECT cp_calm__count__c
									   FROM cp_calm__ActionNode__c
									   WHERE cp_calm__parent__c =: BCA.Id 
									   AND name = 'D' AND level__c = 3];
		system.assertEquals(1, BCAD.cp_calm__Count__c);
		
   		cp_calm__ActionNode__c BCDC = [SELECT cp_calm__count__c
									   FROM cp_calm__ActionNode__c
									   WHERE cp_calm__parent__c =: BCD.Id 
									   AND name = 'c' AND level__c = 3];
		system.assertEquals(1, BCDC.cp_calm__Count__c);
		
   		cp_calm__ActionNode__c BBCA = [SELECT cp_calm__count__c
									   FROM cp_calm__ActionNode__c
									   WHERE cp_calm__parent__c =: BBC.Id 
									   AND name = 'A' AND level__c = 3];
		system.assertEquals(1, BBCA.cp_calm__Count__c);
		
   		cp_calm__ActionNode__c CDCA = [SELECT cp_calm__count__c
									   FROM cp_calm__ActionNode__c
									   WHERE cp_calm__parent__c =: CDC.Id 
									   AND name = 'A' AND level__c = 3];
		system.assertEquals(1, CDCA.cp_calm__Count__c);
		
   		cp_calm__ActionNode__c CADA = [SELECT cp_calm__count__c
									   FROM cp_calm__ActionNode__c
									   WHERE cp_calm__parent__c =: CAD.Id 
									   AND name = 'A' AND level__c = 3];
		system.assertEquals(1, CADA.cp_calm__Count__c);
		
   		cp_calm__ActionNode__c CABF = [SELECT cp_calm__count__c
									   FROM cp_calm__ActionNode__c
									   WHERE cp_calm__parent__c =: CAB.Id 
									   AND name = 'F' AND level__c = 3];
		system.assertEquals(2, CABF.cp_calm__Count__c);
		
   		cp_calm__ActionNode__c DCAB = [SELECT cp_calm__count__c
									   FROM cp_calm__ActionNode__c
									   WHERE cp_calm__parent__c =: DCA.Id 
									   AND name = 'B' AND level__c = 3];
		system.assertEquals(2, DCAB.cp_calm__Count__c);
		
   		cp_calm__ActionNode__c EFDC = [SELECT cp_calm__count__c
									   FROM cp_calm__ActionNode__c
									   WHERE cp_calm__parent__c =: EFD.Id 
									   AND name = 'C' AND level__c = 3];
		system.assertEquals(2, EFDC.cp_calm__Count__c);
		
   		cp_calm__ActionNode__c FDCA = [SELECT cp_calm__count__c
									   FROM cp_calm__ActionNode__c
									   WHERE cp_calm__parent__c =: FDC.Id 
									   AND name = 'A' AND level__c = 3];
		system.assertEquals(2, FDCA.cp_calm__Count__c);
    }

    static testMethod void testQueryList() {
	    
	    List<cp_calm__ActionNode__c> nodesToQuery = new List<cp_calm__ActionNode__c>();
	    
	    cp_calm__ActionNode__c A = new cp_calm__ActionNode__c(name = 'A', 
	    												   	  cp_calm__level__c = 0, 
	    												   	  cp_calm__dt__c = 'e', 
	    												   	  cp_calm__au__c = 'unit-test');
	    									
	   	cp_calm__ActionNode__c AB = new cp_calm__ActionNode__c(name = 'B', 
	    												   	  cp_calm__level__c = 1, 
	    												   	  cp_calm__dt__c = 'e', 
	    												   	  cp_calm__au__c = 'unit-test',
	    												   	  cp_calm__parent__c = A.id);	
	    												   	  
	   	cp_calm__ActionNode__c ABC = new cp_calm__ActionNode__c(name = 'C', 
	    												   	  cp_calm__level__c = 2, 
	    												   	  cp_calm__dt__c = 'e', 
	    												   	  cp_calm__au__c = 'unit-test',
	    												   	  cp_calm__parent__c = AB.id);
	    												   	  
	   	cp_calm__ActionNode__c ABCB = new cp_calm__ActionNode__c(name = 'B', 
	    												   	  cp_calm__level__c = 3, 
	    												   	  cp_calm__dt__c = 'e', 
	    												   	  cp_calm__au__c = 'unit-test',
	    												   	  cp_calm__parent__c = ABC.id);
	   
	    /* different branch */ 												   	  
	    cp_calm__ActionNode__c C = new cp_calm__ActionNode__c(name = 'C', 
	    												   	  cp_calm__level__c = 0, 
	    												   	  cp_calm__dt__c = 'e', 
	    												   	  cp_calm__au__c = 'unit-test');
	    												   	  
	   	cp_calm__ActionNode__c CA = new cp_calm__ActionNode__c(name = 'A', 
	    												   	  cp_calm__level__c = 1, 
	    												   	  cp_calm__dt__c = 'e', 
	    												   	  cp_calm__au__c = 'unit-test',
	    												   	  cp_calm__parent__c = C.id);	
	    									
	   	cp_calm__ActionNode__c CB = new cp_calm__ActionNode__c(name = 'B', 
	    												   	  cp_calm__level__c = 1, 
	    												   	  cp_calm__dt__c = 'e', 
	    												   	  cp_calm__au__c = 'unit-test',
	    												   	  cp_calm__parent__c = C.id);	
	    												   	  
	   	cp_calm__ActionNode__c CBC = new cp_calm__ActionNode__c(name = 'C', 
	    												   	  cp_calm__level__c = 2, 
	    												   	  cp_calm__dt__c = 'e', 
	    												   	  cp_calm__au__c = 'unit-test',
	    												   	  cp_calm__parent__c = CB.id);
	    												   	  
	   	cp_calm__ActionNode__c CBCA = new cp_calm__ActionNode__c(name = 'A', 
	    												   	  cp_calm__level__c = 3, 
	    												   	  cp_calm__dt__c = 'e', 
	    												   	  cp_calm__au__c = 'unit-test',
	    												   	  cp_calm__parent__c = CBC.id);
	    												   	  			   	  
	    nodesToQuery.add(A);
	    nodesToQuery.add(AB);
	    nodesToQuery.add(ABC);
	    nodesToQuery.add(ABCB);
	    nodesToQuery.add(C);
	    nodesToQuery.add(CA);
	    nodesToQuery.add(CB);
	    nodesToQuery.add(CBC);
	    nodesToQuery.add(CBCA);
	    
	    system.assertNotEquals(null, TreeBuilder.queryList(nodesToQuery, 'A', 0, 'e', null));
	    system.assertEquals(A, TreeBuilder.queryList(nodesToQuery, 'A', 0, 'e', null));
	    
	    system.assertNotEquals(null, TreeBuilder.queryList(nodesToQuery, 'B', 1, 'e', A));
	    system.assertEquals(AB, TreeBuilder.queryList(nodesToQuery, 'B', 1, 'e', A));
	    
	    system.assertNotEquals(null, TreeBuilder.queryList(nodesToQuery, 'C', 2, 'e', AB));
	    system.assertEquals(ABC, TreeBuilder.queryList(nodesToQuery, 'C', 2, 'e', AB));
	    
	    system.assertNotEquals(null, TreeBuilder.queryList(nodesToQuery, 'B', 3, 'e', ABC));
	    system.assertEquals(ABCB, TreeBuilder.queryList(nodesToQuery, 'B', 3, 'e', ABC));
	    
	    /* different branch */
	    system.assertNotEquals(null, TreeBuilder.queryList(nodesToQuery, 'C', 0, 'e', null));
	    system.assertEquals(C, TreeBuilder.queryList(nodesToQuery, 'C', 0, 'e', null));
	    
	    system.assertNotEquals(null, TreeBuilder.queryList(nodesToQuery, 'B', 1, 'e', C));
	    system.assertEquals(CB, TreeBuilder.queryList(nodesToQuery, 'B', 1, 'e', C));
	    
	    system.assertNotEquals(null, TreeBuilder.queryList(nodesToQuery, 'C', 2, 'e', CB));
	    system.assertEquals(CBC, TreeBuilder.queryList(nodesToQuery, 'C', 2, 'e', CB));
	    
	    system.assertNotEquals(null, TreeBuilder.queryList(nodesToQuery, 'A', 3, 'e', CBC));
	    system.assertEquals(CBCA, TreeBuilder.queryList(nodesToQuery, 'A', 3, 'e', CBC));
	    
	    system.assertNotEquals(null, TreeBuilder.queryList(nodesToQuery, 'A', 1, 'e', C));
	    system.assertEquals(CA, TreeBuilder.queryList(nodesToQuery, 'A', 1, 'e', C));
	    
    }
}