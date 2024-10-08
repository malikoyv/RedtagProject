@isTest
private class OpportunityTriggerHandlerTest {
    @isTest
    static void testOnBeforeInsert() {
        Opportunity opp = TestDataFactory.createOpportunity();
        
        Test.startTest();
        insert opp;
        Test.stopTest();
        
        Opportunity insertedOpp = [SELECT Id, Name, StageName, CloseDate FROM Opportunity WHERE Id = :opp.Id];
        Assert.isTrue(insertedOpp.Name.startsWith('Test Account'));
        Assert.areEqual('Prospecting', insertedOpp.StageName);
        Assert.areEqual(Date.today().addDays(90), insertedOpp.CloseDate);
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
        
        Assert.areNotEqual(null, insertedOpp.AccountId);
        Assert.areNotEqual(null, insertedOpp.Contact__c);
        Assert.areEqual(insertedAccount.Id, insertedOpp.AccountId);
        Assert.areEqual(insertedContact.Id, insertedOpp.Contact__c);
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
        
        Assert.isTrue(updatedOpp.Name.startsWith('New Account'));
        Assert.areEqual(newAccount.Id, updatedOpp.AccountId);
        Assert.areEqual(newContact.Id, updatedOpp.Contact__c);
    }

    @isTest
    static void testUpdateOpportunityDetails() {
        OpportunityTriggerHandler handler = new OpportunityTriggerHandler();
        List<Opportunity> opps = [SELECT Id, Name, StageName, CloseDate FROM Opportunity];

        Test.startTest();
        handler.OnBeforeInsert(opps);
        Test.stopTest();
        
        for (Opportunity opp : opps) {
            Assert.areEqual('Prospecting', opp.StageName);
            Assert.areEqual(Date.today().addDays(90), opp.CloseDate);
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
        
        Assert.areEqual(2, insertedAccounts.size());
        Assert.areEqual(2, insertedContacts.size());
        
        Opportunity updatedOpp = [SELECT Id, AccountId, Contact__c FROM Opportunity WHERE Id = :opp.Id];
        Assert.areNotEqual(null, updatedOpp.AccountId, 'Opportunity should be linked to an Account');
        Assert.areNotEqual(null, updatedOpp.Contact__c, 'Opportunity should be linked to a Contact');
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
        
        Assert.areEqual(2, updatedAccounts.size());
        Assert.areEqual(2, updatedContacts.size());
        
        Opportunity verifyOpp = [SELECT Id, AccountId, Contact__c, Account.Name, Contact__r.LastName 
                                FROM Opportunity WHERE Id = :updatedOpp.Id];
        Assert.areEqual('Updated Account', verifyOpp.Account.Name);
        Assert.areEqual('Updated Contact', verifyOpp.Contact__r.LastName);
    }
}
