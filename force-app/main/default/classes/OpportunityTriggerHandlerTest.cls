@isTest
private class OpportunityTriggerHandlerTest {
    @TestSetup
    static void setup() {
        Account acc = TestDataFactory.createAccount();
        // Create test data
        Opportunity opp = TestDataFactory.createOpportunity(acc.Id);
        insert opp;
    }

    @isTest
    static void testOnBeforeInsert() {
        Opportunity opp = [SELECT Id, Name, StageName, CloseDate, AccountName__c FROM Opportunity LIMIT 1];
        
        Test.startTest();
        OpportunityTriggerHandler handler = new OpportunityTriggerHandler();
        handler.OnBeforeInsert(new List<Opportunity>{opp});
        Test.stopTest();
        Assert.isTrue(opp.Name.startsWith('Test Account'));
        Assert.areEqual('Prospecting', opp.StageName);
        Assert.areEqual(Date.today().addDays(90), opp.CloseDate);
    }

    @isTest
    static void testOnAfterInsert() {
        List<Opportunity> opps = [SELECT Id, AccountId, Contact__c, AccountName__c, ContactLastName__c FROM Opportunity];
        
        for (Opportunity opp : opps) {
            opp.AccountId = null;
            opp.Contact__c = null;
        }
        update opps;

        Test.startTest();
        OpportunityTriggerHandler handler = new OpportunityTriggerHandler();
        handler.OnAfterInsert(opps);
        Test.stopTest();
        
        opps = [SELECT Id, AccountId, Contact__c, AccountName__c, ContactLastName__c FROM Opportunity];
        
        // without loop but to zero elements
        for (Opportunity opp : opps) {
            Assert.areNotEqual(null, opp.AccountId, 'Opportunity should be linked to an Account');
            Assert.areNotEqual(null, opp.Contact__c, 'Opportunity should be linked to a Contact');
            
            Account relatedAccount = [SELECT Id, Name FROM Account WHERE Id = :opp.AccountId];
            Contact relatedContact = [SELECT Id, LastName FROM Contact WHERE Id = :opp.Contact__c];
            
            Assert.areEqual(opp.AccountName__c, relatedAccount.Name, 'Account name should match');
            Assert.areEqual(opp.ContactLastName__c, relatedContact.LastName, 'Contact last name should match');
        }
    }

    @isTest
    static void testOnBeforeUpdate() {
        Opportunity opp = [SELECT Id, AccountId, Contact__c, Name, AccountName__c, ContactLastName__c FROM Opportunity LIMIT 1];
        
        opp.AccountName__c = 'New Account';
        opp.ContactLastName__c = 'New Contact';
        
        Test.startTest();
        OpportunityTriggerHandler handler = new OpportunityTriggerHandler();
        Map<Id, Opportunity> oldMap = new Map<Id, Opportunity>{opp.Id => opp.clone(true, true, false, false)};
        handler.OnBeforeUpdate(new List<Opportunity>{opp}, new List<Opportunity>{opp}, oldMap);
        update opp;
        Test.stopTest();
        
        opp = [SELECT Id, AccountId, Contact__c, Name FROM Opportunity WHERE Id = :opp.Id];
        Account newAccount = [SELECT Id FROM Account WHERE Name = 'New Account'];
        Contact newContact = [SELECT Id FROM Contact WHERE LastName = 'New Contact'];
        
        Assert.isTrue(opp.Name.startsWith('New Account'));
        Assert.areEqual(newAccount.Id, opp.AccountId);
        Assert.areEqual(newContact.Id, opp.Contact__c);
    }

    @isTest
    static void testUpdateOpportunityDetails() {
        Opportunity opp = [SELECT Id, Name, StageName, CloseDate, AccountName__c FROM Opportunity LIMIT 1];
        
        Test.startTest();
        OpportunityTriggerHandler handler = new OpportunityTriggerHandler();
        handler.OnBeforeInsert(new List<Opportunity>{opp});
        Test.stopTest();
        
        Assert.areEqual('Prospecting', opp.StageName);
        Assert.areEqual(Date.today().addDays(90), opp.CloseDate);
    }

    @isTest
    static void testInsertAccountsAndContacts() {
        Opportunity opp = [SELECT Id, AccountId, Contact__c, AccountName__c, ContactLastName__c FROM Opportunity LIMIT 1];

        Test.startTest();
        OpportunityTriggerHandler handler = new OpportunityTriggerHandler();
        handler.OnAfterInsert(new List<Opportunity>{opp});
        Test.stopTest();
        
        List<Account> insertedAccounts = [SELECT Id, Name FROM Account];
        List<Contact> insertedContacts = [SELECT Id, LastName FROM Contact];
        
        Assert.areEqual(2, insertedAccounts.size());
        Assert.areEqual(2, insertedContacts.size());
        
        opp = [SELECT Id, AccountId, Contact__c FROM Opportunity WHERE Id = :opp.Id];
        Assert.areNotEqual(null, opp.AccountId, 'Opportunity should be linked to an Account');
        Assert.areNotEqual(null, opp.Contact__c, 'Opportunity should be linked to a Contact');
    }

    @isTest
    static void testUpdateAccountsAndContacts() {
        Opportunity opp = [SELECT Id, AccountId, Contact__c, AccountName__c, ContactLastName__c FROM Opportunity LIMIT 1];

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
        
        Assert.areEqual(2, updatedAccounts.size());
        Assert.areEqual(2, updatedContacts.size());
        
        Opportunity verifyOpp = [SELECT Id, AccountId, Contact__c, Account.Name, Contact__r.LastName 
                                FROM Opportunity WHERE Id = :updatedOpp.Id];
        Assert.areEqual('Updated Account', verifyOpp.Account.Name);
        Assert.areEqual('Updated Contact', verifyOpp.Contact__r.LastName);
    }
}