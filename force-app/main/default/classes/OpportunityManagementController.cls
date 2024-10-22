public with sharing class OpportunityManagementController {
    
    @AuraEnabled
    public static List<Map<String, String>> getAllProducts() {
        List<Map<String, String>> options = new List<Map<String, String>>();
        List<Product2> productsWithPricebooks = [SELECT Id, Name FROM Product2 WHERE Id IN (SELECT Product2Id FROM PricebookEntry WHERE Pricebook2.IsStandard = true)];
        for (Product2 product : productsWithPricebooks) {
            Map<String, String> option = new Map<String, String>();
            option.put('value', product.Id);
            option.put('label', product.Name);
            options.add(option);
        }

        return options;
    }

    @AuraEnabled
    public static void createOpportunityWithRelatedRecords(Opportunity opp, Account acc, Contact con, List<OpportunityLineItem> oppProducts) {
        if (String.isBlank(opp.AccountName__c)) {
            throw new AuraHandledException('Account Name is required.');
        }
        if (String.isBlank(opp.ContactLastName__c)) {
            throw new AuraHandledException('Contact Last Name is required.');
        }

        List<Account> account = [SELECT Name FROM Account];
        for (Account accTemp : account) {
            if (accTemp.Name.equals(opp.AccountName__c)) {
                throw new AuraHandledException('Account Name should be unique.');
            }
        }

        if (String.isNotBlank(acc.Name)) {
            insert acc;
            opp.AccountId = acc.Id;
        }

        if (String.isNotBlank(con.LastName)) {
            insert con;
            opp.Contact__c = con.Id;
        }

        insert opp;

        for (OpportunityLineItem oppProduct : oppProducts) {
            oppProduct.OpportunityId = opp.Id;
        }

        insert oppProducts;
    }
}
