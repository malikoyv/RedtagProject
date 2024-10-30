@isTest
private class OpportunityManagementControllerTest {
    @TestSetup
    static void makeData() {
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        update standardPricebook;
        
        List<Product2> products = new List<Product2>();
        List<PricebookEntry> pricebookEntries = new List<PricebookEntry>();
        
        for (Integer i = 0; i < 5; i++) {
            Product2 product = TestDataFactory.createProduct('Test Product ' + i);
            products.add(product);
            
            PricebookEntry standardEntry = new PricebookEntry(
                Pricebook2Id = standardPricebook.Id,
                Product2Id = product.Id,
                UnitPrice = 100,
                IsActive = true
            );
            pricebookEntries.add(standardEntry);
        }
        
        insert pricebookEntries;
    }
    
    @isTest
    static void testGetAllProducts_Success() {
        Test.startTest();
        List<Map<String, String>> products = OpportunityManagementController.getAllProducts();
        Test.stopTest();
        
        Assert.areEqual(5, products.size(), 'Should return 5 products');
        for (Map<String, String> product : products) {
            Assert.isTrue(product.containsKey('value'), 'Product should contain value key');
            Assert.isTrue(product.containsKey('label'), 'Product should contain label key');
        }
    }
    
    @isTest
    static void testCreateOpportunityWithRelatedRecords_Success() {
        String accountName = 'Unique Account Name';
        Account acc = new Account(Name = accountName);
        Contact con = new Contact(LastName = 'Test Contact');
        Opportunity opp = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30),
            AccountName__c = accountName,
            ContactLastName__c = 'Test Contact'
        );
        
        Product2 product = [SELECT Id FROM Product2 LIMIT 1];
        PricebookEntry pbe = [SELECT Id FROM PricebookEntry WHERE Product2Id = :product.Id LIMIT 1];
        
        OpportunityLineItem oli = new OpportunityLineItem(
            Quantity = 1,
            UnitPrice = 100,
            PricebookEntryId = pbe.Id
        );
        
        Test.startTest();
        OpportunityManagementController.createOpportunityWithRelatedRecords(
            opp, acc, con, new List<OpportunityLineItem>{oli}
        );
        Test.stopTest();
        
        List<Account> accounts = [SELECT Id FROM Account WHERE Name = :accountName];
        Assert.areEqual(2, accounts.size(), 'Account should be created');
        
        List<Contact> contacts = [SELECT Id FROM Contact WHERE LastName = 'Test Contact'];
        Assert.areEqual(2, contacts.size(), 'Contact should be created');
        
        List<Opportunity> opportunities = [
            SELECT Id, AccountId, Contact__c 
            FROM Opportunity 
            WHERE AccountName__c = :accountName
        ];
        Assert.areEqual(1, opportunities.size(), 'Opportunity should be created');
        Assert.areEqual(accounts[0].Id, opportunities[0].AccountId, 'Opportunity should be linked to Account');
        Assert.areEqual(contacts[0].Id, opportunities[0].Contact__c, 'Opportunity should be linked to Contact');
        
        List<OpportunityLineItem> olis = [
            SELECT Id 
            FROM OpportunityLineItem 
            WHERE OpportunityId = :opportunities[0].Id
        ];
        Assert.areEqual(1, olis.size(), 'OpportunityLineItem should be created');
    }
    
    @isTest
    static void testCreateOpportunityWithRelatedRecords_DuplicateAccountName() {
        String existingAccountName = 'Existing Account';
        Account existingAcc = new Account(Name = existingAccountName);
        insert existingAcc;
        
        Opportunity opp = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30),
            AccountName__c = existingAccountName,
            ContactLastName__c = 'Test Contact'
        );
        
        Test.startTest();
        try {
            OpportunityManagementController.createOpportunityWithRelatedRecords(
                opp, new Account(Name = existingAccountName), new Contact(), new List<OpportunityLineItem>()
            );
            Assert.isTrue(false, 'Should have thrown an exception');
        } catch (Exception e) {
            Assert.isTrue(e.getMessage().contains('Account Name should be unique.'), 
                         'Error message should indicate duplicate account name');
        }
        Test.stopTest();
    }
}