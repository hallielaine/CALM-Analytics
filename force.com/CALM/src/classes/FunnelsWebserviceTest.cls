@isTest
public with sharing class FunnelsWebserviceTest {

    static testMethod void testFunnelsRetrieve()
    {
        List<FunnelsWebservice.StepDetail> result;
        
        List<FunnelsWebservice.StepDetail> steps = new List<FunnelsWebservice.StepDetail>();
        steps.add(new FunnelsWebservice.StepDetail('A', 'e', 0));
        
        result = FunnelsWebservice.post(steps, '1');
        
        system.assertEquals('A',result.get(0).n);
        system.assertEquals('e',result.get(0).dt);
        system.assertEquals(0,result.get(0).c);
        
        cp_calm__ActionNode__c aNode0 = new cp_calm__ActionNode__c(cp_calm__Count__c = 3,cp_calm__Level__c = 0, cp_calm__au__c = '1', cp_calm__dt__c = 'e', cp_calm__nt__c = 'f', Name = 'A');
        insert aNode0;
        
        
        result = FunnelsWebservice.remoteGetFunnel(steps, '1');
        
        system.assertEquals('A',result.get(0).n);
        system.assertEquals('e',result.get(0).dt);
        system.assertEquals(3,result.get(0).c);
        
        cp_calm__ActionNode__c bNode1 = new cp_calm__ActionNode__c(cp_calm__Count__c = 2,cp_calm__Level__c = 1, cp_calm__au__c = '1', cp_calm__dt__c = 'e', cp_calm__nt__c = 'f', Name = 'B', cp_calm__Parent__c = aNode0.Id);
        insert bNode1;
        
        steps.add(new FunnelsWebservice.StepDetail('B', 'e', 0));
        
        result = FunnelsWebservice.remoteGetFunnel(steps, '1');
        
        system.assertEquals('A',result.get(0).n);
        system.assertEquals('e',result.get(0).dt);
        system.assertEquals(3,result.get(0).c);
        system.assertEquals('B',result.get(1).n);
        system.assertEquals('e',result.get(1).dt);
        system.assertEquals(2,result.get(1).c);
        
        cp_calm__ActionNode__c bNode0 = new cp_calm__ActionNode__c(cp_calm__Count__c = 4,cp_calm__Level__c = 0, cp_calm__au__c = '1', cp_calm__dt__c = 'e', cp_calm__nt__c = 'f', Name = 'B');
        insert bNode0;
        cp_calm__ActionNode__c aNode2 = new cp_calm__ActionNode__c(cp_calm__Count__c = 1,cp_calm__Level__c = 2, cp_calm__au__c = '1', cp_calm__dt__c = 'e', cp_calm__nt__c = 'f', Name = 'A', cp_calm__Parent__c = bNode1.Id);
        insert aNode2;
        
        steps.add(new FunnelsWebservice.StepDetail('A', 'e', 0));
        
        result = FunnelsWebservice.remoteGetFunnel(steps, '1');
        
        system.assertEquals('A',result.get(0).n);
        system.assertEquals('e',result.get(0).dt);
        system.assertEquals(3,result.get(0).c);
        system.assertEquals('B',result.get(1).n);
        system.assertEquals('e',result.get(1).dt);
        system.assertEquals(2,result.get(1).c);
        system.assertEquals('A',result.get(2).n);
        system.assertEquals('e',result.get(2).dt);
        system.assertEquals(1,result.get(2).c);
        
        cp_calm__ActionNode__c bNode2 = new cp_calm__ActionNode__c(cp_calm__Count__c = 1,cp_calm__Level__c = 2, cp_calm__au__c = '1', cp_calm__dt__c = 'e', cp_calm__nt__c = 'f', Name = 'B', cp_calm__Parent__c = bNode1.Id);
        insert bNode2;
        
        result = FunnelsWebservice.remoteGetFunnel(steps, '1');
        
        system.assertEquals('A',result.get(0).n);
        system.assertEquals('e',result.get(0).dt);
        system.assertEquals(3,result.get(0).c);
        system.assertEquals('B',result.get(1).n);
        system.assertEquals('e',result.get(1).dt);
        system.assertEquals(2,result.get(1).c);
        system.assertEquals('A',result.get(2).n);
        system.assertEquals('e',result.get(2).dt);
        system.assertEquals(1,result.get(2).c);
        
        steps.remove(2);
        steps.add(new FunnelsWebservice.StepDetail('B', 'e', 0));
        
        result = FunnelsWebservice.remoteGetFunnel(steps, '1');
        
        system.assertEquals('A',result.get(0).n);
        system.assertEquals('e',result.get(0).dt);
        system.assertEquals(3,result.get(0).c);
        system.assertEquals('B',result.get(1).n);
        system.assertEquals('e',result.get(1).dt);
        system.assertEquals(2,result.get(1).c);
        system.assertEquals('B',result.get(2).n);
        system.assertEquals('e',result.get(2).dt);
        system.assertEquals(1,result.get(2).c);
        
    }
    
    static testMethod void testFunnelDepthRetrieve()
    {
        cp_calm__MobileApplication__c app = new cp_calm__MobileApplication__c(cp_calm__fl__c = 2, cp_calm__sl__c = 3);
        insert app;
        
        Integer depth = FunnelsWebservice.remoteGetFunnelDepth(app.Id);
        
        system.assertEquals(2, depth);
    }
    
    static testMethod void testActionNameRetrieve()
    {
        insert new cp_calm__ActionNode__c(cp_calm__Count__c = 3,cp_calm__Level__c = 0, cp_calm__au__c = '1', cp_calm__dt__c = 'e', cp_calm__nt__c = 'f', Name = 'Eaction');
        insert new cp_calm__ActionNode__c(cp_calm__Count__c = 3,cp_calm__Level__c = 0, cp_calm__au__c = '1', cp_calm__dt__c = 's', cp_calm__nt__c = 'f', Name = 'Saction1');
        insert new cp_calm__ActionNode__c(cp_calm__Count__c = 3,cp_calm__Level__c = 0, cp_calm__au__c = '1', cp_calm__dt__c = 's', cp_calm__nt__c = 'f', Name = 'Saction2');
        
        Map<String, List<String>> names = FunnelsWebservice.remoteGetActionNames('1');
        
        system.assertEquals(1, names.get('events').size());
        system.assertEquals(2, names.get('screens').size());
        
        system.assertEquals(1, FunnelsWebservice.remoteGetEventNames('1').size());
        system.assertEquals(2, FunnelsWebservice.remoteGetScreenNames('1').size());
        
    }
    
    static testMethod void testRemoveSavedFunnel()
    {
        List<FunnelsWebservice.StepDetail> steps = new List<FunnelsWebservice.StepDetail>();
        steps.add(new FunnelsWebservice.StepDetail('test', 'e', 0)); 
        FunnelsWebservice.FunnelDetail fd = new FunnelsWebservice.FunnelDetail('testFunnel', steps);
 
        
        FunnelsWebservice.remoteSaveFunnel(fd, '1');
        
        List<Id> Id_list = FunnelsWebservice.remoteGetSavedFunnelIds('1');
        
    }
    
}