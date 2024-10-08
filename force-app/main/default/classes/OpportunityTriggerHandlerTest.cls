@isTest
private class OpportunityTriggerHandlerTest {

    @TestSetup
    static void setup() {
        Opportunity opp = TestDataFactory.createOpportunity();
        insert opp;
    }

    @isTest
    static void testOnBeforeInsert() {
        Opportunity opp = TestDataFactory.createOpportunity();
        
        Test.startTest();
        insert opp;
        Test.stopTest();
        
        Opportunity insertedOpp = [SELECT Id, Name, StageName, CloseDate FROM Opportunity WHERE Id = :opp.Id];
        System.assert(insertedOpp.Name.startsWith('Test Account'));
        System.assertEquals('Prospecting', insertedOpp.StageName);
        System.assertEquals(Date.today().addDays(90), insertedOpp.CloseDate);
    }

    @isTest
    static void testOnAfterInsert() {
        Opportunity opp = TestDataFactory.createOpportunity();
        
        Test.startTest();
        insert opp;
        Test.stopTest();
        
        Opportunity insertedOpp = [SELECT Id, AccountId, Contact__c FROM Opportunity WHERE Id = :opp.Id];
        Account insertedAccount = [SELECT Id, Name FROM Account WHERE Name = 'Test Account'];
        Contact insertedContact = [SELECT Id, LastName FROM Contact WHERE LastName = 'Test Contact'];
        
        System.assertNotEquals(null, insertedOpp.AccountId);
        System.assertNotEquals(null, insertedOpp.Contact__c);
        System.assertEquals(insertedAccount.Id, insertedOpp.AccountId);
        System.assertEquals(insertedContact.Id, insertedOpp.Contact__c);
    }

    @isTest
    static void testOnBeforeUpdate() {
        Opportunity opp = TestDataFactory.createOpportunity();
        insert opp;
        
        opp.AccountName__c = 'New Account';
        opp.ContactLastName__c = 'New Contact';
        
        Test.startTest();
        update opp;
        Test.stopTest();
        
        Opportunity updatedOpp = [SELECT Id, AccountId, Contact__c, Name FROM Opportunity WHERE Id = :opp.Id];
        Account newAccount = [SELECT Id FROM Account WHERE Name = 'New Account'];
        Contact newContact = [SELECT Id FROM Contact WHERE LastName = 'New Contact'];
        
        System.assert(updatedOpp.Name.startsWith('New Account'));
        System.assertEquals(newAccount.Id, updatedOpp.AccountId);
        System.assertEquals(newContact.Id, updatedOpp.Contact__c);
    }

    @isTest
    static void testOnBeforeDelete() {
        List<Opportunity> oppsToDelete = [SELECT Id FROM Opportunity];
        
        Test.startTest();
        delete oppsToDelete;
        Test.stopTest();
        
        Integer emailInvocations = Limits.getEmailInvocations();
        System.assertEquals(1, emailInvocations, 'Expected 1 email to be sent');
    }

    @isTest
    static void testUpdateOpportunityDetails() {
        OpportunityTriggerHandler handler = new OpportunityTriggerHandler();
        List<Opportunity> opps = [SELECT Id, Name, StageName, CloseDate FROM Opportunity];

        Test.startTest();
        handler.OnBeforeInsert(opps);
        Test.stopTest();
        
        for (Opportunity opp : opps) {
            System.assertEquals('Prospecting', opp.StageName);
            System.assertEquals(Date.today().addDays(90), opp.CloseDate);
        }
    }

    @isTest
    static void testInsertAccountsAndContacts() {
        Opportunity opp = TestDataFactory.createOpportunity();
        insert opp;

        Test.startTest();
        OpportunityTriggerHandler handler = new OpportunityTriggerHandler();
        handler.OnAfterInsert(new List<Opportunity>{opp});
        Test.stopTest();
        
        List<Account> insertedAccounts = [SELECT Id, Name FROM Account];
        List<Contact> insertedContacts = [SELECT Id, LastName FROM Contact];
        
        System.assertEquals(1, insertedAccounts.size());
        System.assertEquals(1, insertedContacts.size());
        
        Opportunity updatedOpp = [SELECT Id, AccountId, Contact__c FROM Opportunity WHERE Id = :opp.Id];
        System.assertNotEquals(null, updatedOpp.AccountId, 'Opportunity should be linked to an Account');
        System.assertNotEquals(null, updatedOpp.Contact__c, 'Opportunity should be linked to a Contact');
    }

    @isTest
    static void testUpdateAccountsAndContacts() {
        Opportunity opp = TestDataFactory.createOpportunity();
        insert opp;

        Opportunity updatedOpp = opp.clone(true, true, false, false);
        updatedOpp.AccountName__c = 'Updated Account';
        updatedOpp.ContactLastName__c = 'Updated Contact';
        
        OpportunityTriggerHandler handler = new OpportunityTriggerHandler();
        Map<Id, Opportunity> oldMap = new Map<Id, Opportunity>{opp.Id => opp};
        
        Test.startTest();
        handler.OnBeforeUpdate(new List<Opportunity>{opp}, new List<Opportunity>{updatedOpp}, oldMap);
        update updatedOpp;
        Test.stopTest();
        
        List<Account> updatedAccounts = [SELECT Id, Name FROM Account WHERE Name = 'Updated Account'];
        List<Contact> updatedContacts = [SELECT Id, LastName FROM Contact WHERE LastName = 'Updated Contact'];
        
        System.assertEquals(1, updatedAccounts.size());
        System.assertEquals(1, updatedContacts.size());
        
        Opportunity verifyOpp = [SELECT Id, AccountId, Contact__c, Account.Name, Contact__r.LastName 
                                FROM Opportunity WHERE Id = :updatedOpp.Id];
        System.assertEquals('Updated Account', verifyOpp.Account.Name);
        System.assertEquals('Updated Contact', verifyOpp.Contact__r.LastName);
    }
}