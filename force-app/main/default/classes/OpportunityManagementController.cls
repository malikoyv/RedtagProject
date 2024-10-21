public with sharing class OpportunityManagementController {
    
    @AuraEnabled
    public static List<Map<String, String>> getAllProducts() {
        List<Map<String, String>> options = new List<Map<String, String>>();
        for (Product2 product : [SELECT Id, Name FROM Product2]) {
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

        if (String.isNotBlank(acc.Name)) {
            insert acc;
            opp.AccountId = acc.Id;
        }

        if (String.isNotBlank(con.LastName)) {
            insert con;
            opp.Contact__c = con.Id;
        }

        insert opp;

        Pricebook2 standardPricebook;
        try {
            standardPricebook = [SELECT Id FROM Pricebook2 WHERE IsActive = true LIMIT 1];
        } catch (Exception e) {
            throw new AuraHandledException('Standard Pricebook not found.');
        }

        if (standardPricebook == null) {
            throw new AuraHandledException('Standard Pricebook is required but not found.');
        }

        Set<Id> productIds = new Set<Id>();
        for (OpportunityLineItem oli : oppProducts) {
            if (oli.Product2Id != null) {
                productIds.add(oli.Product2Id);
            } else {
                throw new AuraHandledException('Product is required for all Opportunity Line Items.');
            }
        }

        Map<Id, PricebookEntry> pricebookEntries = new Map<Id, PricebookEntry>(
            [SELECT Id, Product2Id FROM PricebookEntry WHERE Pricebook2Id = :standardPricebook.Id AND Product2Id IN :productIds]
        );

        List<PricebookEntry> newEntriesToInsert = new List<PricebookEntry>();
        for (OpportunityLineItem oli : oppProducts) {
            oli.OpportunityId = opp.Id;
            if (pricebookEntries.containsKey(oli.Product2Id)) {
                oli.PricebookEntryId = pricebookEntries.get(oli.Product2Id).Id;
            } else {
                PricebookEntry newEntry = new PricebookEntry(
                    Pricebook2Id = standardPricebook.Id,
                    Product2Id = oli.Product2Id,
                    UnitPrice = 0,
                    IsActive = true
                );
                newEntriesToInsert.add(newEntry);
            }
        }

        if (!newEntriesToInsert.isEmpty()) {
            insert newEntriesToInsert;
            pricebookEntries = new Map<Id, PricebookEntry>(
                [SELECT Id, Product2Id FROM PricebookEntry WHERE Pricebook2Id = :standardPricebook.Id AND Product2Id IN :productIds]
            );
        }

        for (OpportunityLineItem oli : oppProducts) {
            if (oli.PricebookEntryId == null && pricebookEntries.containsKey(oli.Product2Id)) {
                oli.PricebookEntryId = pricebookEntries.get(oli.Product2Id).Id;
            } else if (oli.PricebookEntryId == null) {
                throw new AuraHandledException('No Pricebook Entry found for product: ' + oli.Product2Id);
            }
        }

        insert oppProducts;
    }
}
