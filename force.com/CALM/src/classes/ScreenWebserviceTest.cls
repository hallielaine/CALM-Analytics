/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class ScreenWebserviceTest {

    private static String APP_KEY = '1';
    private static String SCREEN_A = 'screen a';
    private static String SCREEN_B = 'screen b';
    private static String SCREEN_C = 'screen c';
    
    static testMethod void testGetScreens() {
    	
    	cp_calm__ActionNode__c A = new cp_calm__ActionNode__c(Name=SCREEN_A, 
    													  	  cp_calm__au__c = APP_KEY, 
    													  	  cp_calm__count__c = 3, 
    													  	  cp_calm__level__c = 0,
    													  	  cp_calm__dt__c = 's',
    													  	  cp_calm__nt__c = 's');
    													
    	cp_calm__ActionNode__c B = new cp_calm__ActionNode__c(Name=SCREEN_B, 
    												 	  	  cp_calm__au__c = APP_KEY, 
    												 	  	  cp_calm__count__c = 2, 
    													  	  cp_calm__level__c = 0,
    													  	  cp_calm__dt__c = 's',
    													  	  cp_calm__nt__c = 's');
    													
    	cp_calm__ActionNode__c C = new cp_calm__ActionNode__c(Name=SCREEN_C, 
    													  	  cp_calm__au__c = APP_KEY, 
    													  	  cp_calm__count__c = 1, 
    													  	  cp_calm__level__c = 0,
    													  	  cp_calm__dt__c = 's',
    													  	  cp_calm__nt__c = 's');
    													
    	insert A;
        insert B;
        insert C;
    													
    	cp_calm__ActionNode__c AB = new cp_calm__ActionNode__c(Name=SCREEN_B, 
    													   	   cp_calm__au__c = APP_KEY, 
    													   	   cp_calm__count__c = 1, 
    													   	   cp_calm__level__c = 1,
    													   	   cp_calm__parent__c = A.Id,
    													  	   cp_calm__dt__c = 's',
    													  	   cp_calm__nt__c = 's');
    													   
    	cp_calm__ActionNode__c AC = new cp_calm__ActionNode__c(Name=SCREEN_C, 
    													   	   cp_calm__au__c = APP_KEY, 
    													   	   cp_calm__count__c = 1, 
    													   	   cp_calm__level__c = 1,
    													  	   cp_calm__parent__c = A.Id,
    													  	   cp_calm__dt__c = 's',
    													  	   cp_calm__nt__c = 's');
    													   
    	cp_calm__ActionNode__c BC = new cp_calm__ActionNode__c(Name=SCREEN_C, 
    													  	   cp_calm__au__c = APP_KEY, 
    													   	   cp_calm__count__c = 1, 
    													   	   cp_calm__level__c = 1,
    													   	   cp_calm__parent__c = B.Id,
    													  	   cp_calm__dt__c = 's',
    													  	   cp_calm__nt__c = 's');
    													  	   
        insert AB;
        insert AC;
        insert BC;
    													
    	cp_calm__ActionNode__c ABC = new cp_calm__ActionNode__c(Name=SCREEN_C, 
    													   	   cp_calm__au__c = APP_KEY, 
    													   	   cp_calm__count__c = 1, 
    													   	   cp_calm__level__c = 2,
    													   	   cp_calm__parent__c = AB.Id,
    													  	   cp_calm__dt__c = 's',
    													  	   cp_calm__nt__c = 's');
    													   
    	cp_calm__ActionNode__c ACB = new cp_calm__ActionNode__c(Name=SCREEN_B, 
    													   	   cp_calm__au__c = APP_KEY, 
    													   	   cp_calm__count__c = 1, 
    													   	   cp_calm__level__c = 2,
    													  	   cp_calm__parent__c = AC.Id,
    													  	   cp_calm__dt__c = 's',
    													  	   cp_calm__nt__c = 's');
    													   
    	cp_calm__ActionNode__c BCA = new cp_calm__ActionNode__c(Name=SCREEN_A, 
    													  	   cp_calm__au__c = APP_KEY, 
    													   	   cp_calm__count__c = 1, 
    													   	   cp_calm__level__c = 2,
    													   	   cp_calm__parent__c = BC.Id,
    													  	   cp_calm__dt__c = 's',
    													  	   cp_calm__nt__c = 's');
    													  	   
    	insert ABC;
        insert ACB;
        insert BCA;
    	
    	List<ScreenWebservice.ScreenDetail> screens = ScreenWebservice.remoteGetScreens(null, APP_KEY);
    	
    	system.assertEquals(3, screens.size());
    	system.assertEquals(SCREEN_A, screens.get(0).n);
    	system.assertEquals(3, screens.get(0).c);
    	system.assertEquals(SCREEN_B, screens.get(1).n);
    	system.assertEquals(2, screens.get(1).c);
    	system.assertEquals(SCREEN_C, screens.get(2).n);
    	system.assertEquals(1, screens.get(2).c);
    	
    	
    	List<String> sequence = new List<String>();
    	sequence.add(SCREEN_A);
    	sequence.add(SCREEN_C);
    	screens = ScreenWebservice.remoteGetScreens(sequence, APP_KEY);
    	
    	system.assertEquals(1, screens.size());
    	system.assertEquals(SCREEN_B, screens.get(0).n);
    	system.assertEquals(1, screens.get(0).c);
    	
    	sequence.add(SCREEN_A);
    	try {
    		screens = ScreenWebservice.post(sequence, APP_KEY);
    		system.assert(false);
    	}
    	catch (System.QueryException e) {
    		if (e.getMessage() != 'List has no rows for assignment to SObject') {
    			system.assert(false);
    		}
    	}
    	
        sequence.add(0, 'fake screen');
    	try {
    		screens = ScreenWebservice.post(sequence, APP_KEY);
    		system.assert(false);
    	}
    	catch (System.QueryException e) {
    		if (e.getMessage() != 'List has no rows for assignment to SObject') {
    			system.assert(false);
    		}
    	}
    }
    
    static testMethod void testGetScreenDepth()
    {
        cp_calm__MobileApplication__c app = new cp_calm__MobileApplication__c(cp_calm__fl__c = 2, cp_calm__sl__c = 3);
        insert app;
        
        Integer depth = ScreenWebservice.remoteGetScreenDepth(app.Id);
        
        system.assertEquals(3, depth);
    }

}