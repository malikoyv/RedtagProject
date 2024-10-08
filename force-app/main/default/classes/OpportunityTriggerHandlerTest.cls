@isTest
private class OpportunityTriggerHandlerTest {
    @TestSetup
    static void setup(){
        
    }


    // create class testdatafactory
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
    static void testOnBeforeDelete() {
        EmailTemplate template = new EmailTemplate(
            Name = 'OpportunityDeletion',
            DeveloperName = 'OpportunityDeletion',
            TemplateType = 'text',
            FolderId = UserInfo.getUserId(),
            Subject = 'Opportunity Deleted: {!Opportunity.Name}',
            Body = 'The opportunity {!Opportunity.Name} has been deleted.'
        );
        insert template;

        List<Opportunity> oppsToDelete = new List<Opportunity>();
        for (Integer i = 0; i < 3; i++) {
            oppsToDelete.add(new Opportunity(
                Name = 'Test Opp ' + i,
                StageName = 'Prospecting',
                CloseDate = Date.today().addDays(30),
                AccountName__c = 'Account ' + i,
                ContactLastName__c = 'Contact ' + i
            ));
        }
        insert oppsToDelete;

        Test.startTest();
        delete oppsToDelete;
        Test.stopTest();

        Integer emailInvocations = Limits.getEmailInvocations();
        System.assertEquals(3, emailInvocations, 'Expected 3 emails to be sent');

        List<EmailMessage> sentEmails = [SELECT Subject, ToAddress FROM EmailMessage WHERE RelatedToId IN :oppsToDelete];
        System.assertEquals(3, sentEmails.size(), 'Expected 3 email messages to be created');
        for (EmailMessage email : sentEmails) {
            System.assert(email.Subject.startsWith('Opportunity Deleted:'));
        }
    }
    
    @isTest
    static void testUpdateOpportunityDetails() {
        OpportunityTriggerHandler handler = new OpportunityTriggerHandler();
        List<Opportunity> opps = new List<Opportunity>{
            new Opportunity(AccountName__c = 'Test Account'),
            new Opportunity() // tofix
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
        Opportunity opp = new Opportunity(
            Name = 'Test Opp',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30),
            AccountName__c = 'Old Account',
            ContactLastName__c = 'Old Contact'
        );
        insert opp;
        
        opp = [SELECT Id, AccountId, Contact__c, AccountName__c, ContactLastName__c FROM Opportunity WHERE Id = :opp.Id];
        
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
        
        System.assertEquals(2, updatedContacts.size());
        Assert.areEqual(2, updatedAccounts.size());
        
        Opportunity verifyOpp = [SELECT Id, AccountId, Contact__c, Account.Name, Contact__r.LastName 
                                FROM Opportunity WHERE Id = :updatedOpp.Id];
        System.assertEquals('Updated Account', verifyOpp.Account.Name);
        System.assertEquals('Updated Contact', verifyOpp.Contact__r.LastName);
    }
}