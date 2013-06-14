public with sharing class TreeBuilder {
	    
	/**
     * Returns a view of the portion of this list between the specified fromIndex, 
     * inclusive, and toIndex, exclusive. (If fromIndex and toIndex are equal, 
     * the returned list is empty.)
     * TODO: Throw exception if index is out of bounds.
     */
    private static List<cp_calm__Action__c> subList(List<cp_calm__Action__c> actions, Integer fromIndex, Integer toIndex) {
        List<cp_calm__Action__c> subList = new List<cp_calm__Action__c>();
        for (Integer index = fromIndex; index < actions.size() && index < toIndex; index++) {
            subList.add(actions.get(index));
        }
        return subList;
    }
      
    /**
     * Inserts a session (sequence of actions) into the funnels tree.
     * @param actions the full sequence of actions for a single session.
     * @param appKey
     * @param type the type of the tree to build. 'f' for funnel, 's' for screen.
     * @pre if type == 's', every Action__c in actions has dt__c == 's'
     */
    public static void insertSessionIntoTree(List<cp_calm__Action__c> actions, String appKey, String type) {
        
        Integer treeDepthLimit = 0;
        cp_calm__MobileApplication__c app;
        
        // get the funnel or screen depth limit
        if (type == 'f') {
        	app = [SELECT cp_calm__fl__c FROM cp_calm__MobileApplication__c WHERE Id =: appKey];
        	treeDepthLimit = app.cp_calm__fl__c.intValue();
        }
        else if (type == 's') {
        	app = [SELECT cp_calm__sl__c FROM cp_calm__MobileApplication__c WHERE Id =: appKey];
        	treeDepthLimit = app.cp_calm__sl__c.intValue();
        }
        
        /* A List of all the action nodes that have had their counts changed during insertion of the entire session
         * This list will be modified by the insertSubSessionIntoTree method as it comes across nodes that need to be updated */
        List<cp_calm__ActionNode__c> nodesToUpdate = new List<cp_calm__ActionNode__c>();
        
        for (Integer index = 0; index < actions.size(); index++) {
            if (actions.size() - index > treeDepthLimit) {
                insertSubSessionIntoTree(subList(actions, index, index + treeDepthLimit), appKey, nodesToUpdate, type);
            }
            else {
                insertSubSessionIntoTree(subList(actions, index, actions.size()), appKey, nodesToUpdate, type);
            }
        }
        update(nodesToUpdate);
    }
    
    /**
     * Inserts or updates a branch in the tree that is less than or equal to the tree depth limit.
     * @pre actions.size() <= treeDepthLimit
     */
    private static void insertSubSessionIntoTree(List<cp_calm__Action__c> actions, String appKey, List<cp_calm__ActionNode__c> nodesToUpdate, String type) {
        
        cp_calm__ActionNode__c prevNode;
        cp_calm__ActionNode__c root = queryList(nodesToUpdate, actions.get(0).cp_calm__n__c, 0, actions.get(0).cp_calm__dt__c, null);
        
        // if the root wasn't in the nodesToUpdate list
        if (root == null) {
            try {
                root = [SELECT cp_calm__level__c, name, cp_calm__dt__c, cp_calm__Count__c, cp_calm__nt__c
                        FROM cp_calm__ActionNode__c 
                        WHERE cp_calm__level__c =: 0 
                        AND name =: actions.get(0).cp_calm__n__c 
                        AND cp_calm__dt__c =: actions.get(0).cp_calm__dt__c 
                        AND cp_calm__au__c =: appKey
                        AND cp_calm__nt__c =: type];
                        
                        nodesToUpdate.add(root);
            }
            catch(System.QueryException e) {
                if (e.getMessage() == 'List has no rows for assignment to SObject') {
                    root = null;
                }
                else {
                    throw e;
                }
            }
        }
        // if the root wasn't in the database either
        if (root == null) {
            createTree(null, actions, appKey, type);
        }
        else {
            root.cp_calm__Count__c++;
            prevNode = root;
            
            for (Integer index = 1; index < actions.size(); index++) {
                cp_calm__ActionNode__c curNode = queryList(nodesToUpdate, actions.get(index).cp_calm__n__c, index, actions.get(index).cp_calm__dt__c, prevNode);
                
                // if the node wasn't in the list of nodes to update
                if (curNode == null) {
                    try {
                        curNode = [SELECT cp_calm__count__c, cp_calm__level__c, name, cp_calm__dt__c, cp_calm__parent__c, cp_calm__nt__c
                                   FROM cp_calm__ActionNode__c 
                                   WHERE cp_calm__level__c =: index 
                                   AND cp_calm__au__c =: appKey
                                   AND name =: actions.get(index).cp_calm__n__c 
                                   AND cp_calm__dt__c =: actions.get(index).cp_calm__dt__c 
                                   AND cp_calm__parent__c =: prevNode.id
                                   ANd cp_calm__nt__c = : type];
                                   
                        nodesToUpdate.add(curNode);
                    }
                    catch(System.QueryException e) {
                        if (e.getMessage() == 'List has no rows for assignment to SObject') {
                            curNode = null;
                        }
                        else {
                            throw e;
                        }
                    }
                }
                // if the node also wasn't in the database
                if (curNode == null) {
                    createTree(prevNode, subList(actions, index, actions.size()), appKey, type);
                    break;
                }         
                else {
                    curNode.cp_calm__count__c++;
                    prevNode = curNode;
                }
            }
        }
    }
    
    /**
     * Creates new branches in the tree if they didn't exist before.
     */
    private static void createTree(cp_calm__ActionNode__c prevNode, List<cp_calm__Action__c> actions, String appKey, String type) {
        cp_calm__ActionNode__c prevCreatedNode = prevNode;
        if (prevNode == null) {
            cp_calm__ActionNode__c root = new cp_calm__ActionNode__c(
                                                  cp_calm__au__c = appKey,
                                                  name = actions.get(0).cp_calm__n__c, 
                                                  cp_calm__dt__c = actions.get(0).cp_calm__dt__c, 
                                                  cp_calm__level__c = 0,
                                                  cp_calm__nt__c = type);
            prevCreatedNode = root;
            insert root;
            actions.remove(0);
        }
        for (Integer index = 0; index < actions.size(); index++) {
            
            cp_calm__ActionNode__c newNode = new cp_calm__ActionNode__c(
                                                      cp_calm__au__c = appKey,
                                                      name = actions.get(index).cp_calm__n__c, 
                                                      cp_calm__dt__c = actions.get(index).cp_calm__dt__c, 
                                                      cp_calm__level__c = prevCreatedNode.cp_calm__level__c + 1, 
                                                      cp_calm__parent__c = prevCreatedNode.Id,
                                                      cp_calm__nt__c = type);
            insert newNode;
            prevCreatedNode = newNode;
        }
    }
    
    public static cp_calm__ActionNode__c queryList(List<cp_calm__ActionNode__c> nodes, String name, Integer level, String dt, cp_calm__ActionNode__c parent) {
        for (cp_calm__ActionNode__c node : nodes) {
            // one of the root nodes
            if (parent == null) {
                if (node.name == name && node.cp_calm__level__c == level && node.cp_calm__dt__c == dt) {
                    return node;
                }
            }
            else {
                if (node.name == name && node.level__c == level && node.cp_calm__parent__c == parent.Id && node.cp_calm__dt__c == dt) {
                    return node;
                }
            }

        }
        return null;
    }
}