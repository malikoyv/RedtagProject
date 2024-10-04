@isTest
private class OpportunityTriggerHandlerTest {

    @isTest
    static void testOnBeforeInsert() {
        Opportunity opp = new Opportunity(
            AccountName__c = 'Test Account',
            Name = 'opp',
            ContactLastName__c = 'Test Contact',
            CloseDate = Date.today().addDays(2),
            StageName = 'Qualification'
            );
        
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
        Opportunity opp = new Opportunity(AccountName__c = 'Test Account', ContactLastName__c = 'Test Contact');
        
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
        Opportunity opp = new Opportunity(AccountName__c = 'Old Account', ContactLastName__c = 'Old Contact');
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
    static void testOnAfterDelete() {
        //todo
    }
    
    @isTest
    static void testUpdateOpportunityDetails() {
        OpportunityTriggerHandler handler = new OpportunityTriggerHandler();
        List<Opportunity> opps = new List<Opportunity>{
            new Opportunity(AccountName__c = 'Test Account'),
            new Opportunity()
        };
        
        Test.startTest();
        handler.OnBeforeInsert(opps);
        Test.stopTest();
        
        System.assert(opps[0].Name.startsWith('Test Account'));
        System.assert(opps[1].Name.startsWith('No Account'));
        for (Opportunity opp : opps) {
            System.assertEquals('Prospecting', opp.StageName);
            System.assertEquals(Date.today().addDays(90), opp.CloseDate);
        }
    }
    
    @isTest
    static void testInsertAccountsAndContacts() {
        List<Opportunity> opps = new List<Opportunity>{
            new Opportunity(AccountName__c = 'Test Account 1', ContactLastName__c = 'Test Contact 1')
        };
        insert opps;

        Test.startTest();
        OpportunityTriggerHandler handler = new OpportunityTriggerHandler();
        handler.OnAfterInsert(opps);
        Test.stopTest();
        
        List<Account> insertedAccounts = [SELECT Id, Name FROM Account];
        List<Contact> insertedContacts = [SELECT Id, LastName FROM Contact];
        List<Opportunity> updatedOpps = [SELECT Id, AccountId, Contact__c FROM Opportunity WHERE Id IN :opps];
        
        System.assertEquals(2, insertedAccounts.size(), 'Two accounts should have been inserted');
        System.assertEquals(2, insertedContacts.size(), 'Two contacts should have been inserted');
        
        for (Opportunity opp : updatedOpps) {
            System.assertNotEquals(null, opp.AccountId, 'Opportunity should be linked to an Account');
            System.assertNotEquals(null, opp.Contact__c, 'Opportunity should be linked to a Contact');
        }
    }
    
    @isTest
    static void testUpdateAccountsAndContacts() {
        Opportunity opp = new Opportunity(AccountName__c = 'Old Account', ContactLastName__c = 'Old Contact');
        insert opp;
        
        opp.AccountName__c = 'Updated Account';
        opp.ContactLastName__c = 'Updated Contact';
        
        OpportunityTriggerHandler handler = new OpportunityTriggerHandler();
        Map<Id, Opportunity> oldMap = new Map<Id, Opportunity>{opp.Id => opp.clone(true, true, false, false)};
        
        Test.startTest();
        handler.OnBeforeUpdate(new List<Opportunity>{opp.clone(true, true, false, false)}, new List<Opportunity>{opp}, oldMap);
        Test.stopTest();
        
        Account updatedAccount = [SELECT Id, Name FROM Account WHERE Name = 'Updated Account'];
        Contact updatedContact = [SELECT Id, LastName FROM Contact WHERE LastName = 'Updated Contact'];
        
        System.assertNotEquals(null, updatedAccount, 'Account should have been updated');
        System.assertNotEquals(null, updatedContact, 'Contact should have been updated');
    }
}