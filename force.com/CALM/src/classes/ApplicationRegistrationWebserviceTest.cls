@isTest
global with sharing class ApplicationRegistrationWebserviceTest {
    
    static testMethod void testAddApp()
    {
        String result1, result2, result3;
        
        result1 = ApplicationRegistrationWebservice.post('unit-test app name 1');
        result2 = ApplicationRegistrationWebservice.remoteAddApp('unit-test app name 2');
        result3 = ApplicationRegistrationWebservice.remoteAddApp('unit-test app name 2');

        system.assertNotEquals(result1, result2);     // different Ids
        system.assertNotEquals('', result1);
        system.assertNotEquals('', result2);
        system.assertEquals(result2, result3);        // existing Id
    }
    
    static testMethod void testGetApps()
    {
        List<cp_calm__MobileApplication__c> result;
        cp_calm__MobileApplication__c newApp1 = new cp_calm__MobileApplication__c(Name = 'unit-test app name 1');
        cp_calm__MobileApplication__c newApp2 = new cp_calm__MobileApplication__c(Name = 'unit-test app name 2');
        
        insert newApp1;
        insert newApp2;
        
        result = ApplicationRegistrationWebservice.remoteGetApps();

        system.assertEquals(2, result.size());
        system.assertEquals('unit-test app name 1', result.get(0).Name);
        system.assertEquals('unit-test app name 2', result.get(1).Name);
        system.assertNotEquals(result.get(0).Id, result.get(1).Id);
    }
    
    static testMethod void testEditApp() {
    	Id idOne = ApplicationRegistrationWebservice.remoteAddApp('unit-test app name 1');
    	Id idTwo = ApplicationRegistrationWebservice.remoteAddApp('unit-test app name 2');
    	
    	ApplicationRegistrationWebservice.remoteEditApp(idOne, 'unit-test app name 1', 4, 3);
    	
    	cp_calm__MobileApplication__c appOne = [SELECT cp_calm__sl__c, cp_calm__fl__c 
    										    FROM cp_calm__MobileApplication__c
    										    WHERE id =: idOne];
    										    
    	cp_calm__MobileApplication__c appTwo = [SELECT cp_calm__sl__c, cp_calm__fl__c 
    										    FROM cp_calm__MobileApplication__c
    										    WHERE id =: idTwo];
    										    
	    system.assertEquals(4, appOne.cp_calm__sl__c);
	    system.assertEquals(3, appOne.cp_calm__fl__c);
	    system.assertEquals(0, appTwo.cp_calm__sl__c);
	    system.assertEquals(0, appTwo.cp_calm__fl__c);
    }
    
    static testMethod void testDeleteApp() {
    	Id idOne = ApplicationRegistrationWebservice.remoteAddApp('unit-test app name 1');
    	Id idTwo = ApplicationRegistrationWebservice.remoteAddApp('unit-test app name 2');
    	
    	ApplicationRegistrationWebservice.remoteDeleteApp('unit-test app name 1', idOne);
    	
    	try {
    		cp_calm__MobileApplication__c appOne = [SELECT cp_calm__sl__c, cp_calm__fl__c 
    											    FROM cp_calm__MobileApplication__c
    											    WHERE id =: idOne];
   			system.assert(false);
    	}
    	catch(QueryException e) {
    		if (e.getMessage() != 'List has no rows for assignment to SObject') {
				system.assert(false);
    		}
    	}
    
    	try {							    
    		cp_calm__MobileApplication__c appTwo = [SELECT cp_calm__sl__c, cp_calm__fl__c 
    											    FROM cp_calm__MobileApplication__c
    											    WHERE id =: idTwo];
    		system.assert(true);
    	}
    	catch(QueryException e) {
    		if (e.getMessage() == 'List has no rows for assignment to SObject') {
				system.assert(false);
    		}
    	}
    										    
    }
}