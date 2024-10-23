public with sharing class OpportunityAndProductListViewHelper {
    @AuraEnabled(cacheable = True)
    public static List<Opportunity> getOpportunities(){
        return [SELECT Id, Name, AccountId, AccountName__c, ContactLastName__c, ContactId, StageName, CloseDate FROM Opportunity LIMIT 200];
    }

    @AuraEnabled(cacheable = True)
    public static List<Opportunity> searchOpportunity(String input){
        List<List<Opportunity>> opportunities = [FIND :input IN ALL FIELDS RETURNING Opportunity(Name, AccountName__c, ContactLastName__c, StageName, CloseDate)];
        return opportunities[0];
    }

    @AuraEnabled
    public static void deleteOpportunities(List<Id> ids){
        if (ids.size() > 0){
            delete [SELECT Id FROM Opportunity WHERE Id IN: ids];
        }
    }
}