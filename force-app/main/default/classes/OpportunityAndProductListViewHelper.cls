public with sharing class OpportunityAndProductListViewHelper {
    @AuraEnabled(cacheable = true)
    public static List<Opportunity> searchOpportunity(String input){
        String searchQuery = '%' + input + '%';
        return [
            SELECT Id, Name, StageName, CloseDate, AccountName__c, ContactLastName__c, AccountId, ContactId,
                   (SELECT Id, OpportunityId, Product2.Name, Quantity, UnitPrice, Discount_Price__c
                    FROM OpportunityLineItems)
            FROM Opportunity 
            WHERE Name LIKE :searchQuery 
               OR AccountName__c LIKE :searchQuery 
               OR ContactLastName__c LIKE :searchQuery
        ];
    }
    
    @AuraEnabled
    public static Boolean deleteOpportunities(List<Id> ids){
        Boolean result = false;
        if (!ids.isEmpty()){
            delete [SELECT Id FROM Opportunity WHERE Id IN :ids];
            result = true;
        }
         
        return result;
    }
    
    @AuraEnabled
    public static Boolean deleteProducts(List<Id> ids){
        Boolean result = false;
        if (!ids.isEmpty()){
            delete [SELECT Id FROM OpportunityLineItem WHERE Id IN :ids];
            result = true;
        }
        
        return result;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<OpportunityLineItem> getOpportunityLineItems() {
        return [
            SELECT Id, Quantity, UnitPrice, Discount_Price__c, OpportunityId, Product2Id, Product2.Name, Opportunity.Name
            FROM OpportunityLineItem
        ];
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Opportunity> getOpportunitiesWithLineItems() {
        return [
            SELECT Id, Name, StageName, CloseDate, AccountName__c, ContactLastName__c, AccountId, ContactId,
                   (SELECT Id, OpportunityId, Product2.Name, Quantity, UnitPrice, Discount_Price__c
                    FROM OpportunityLineItems)
            FROM Opportunity
        ];
    }
}