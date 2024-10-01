@isTest
private class Test_EmailWhenOpportunityDeleted {

    @isTest
    static void emailOnOpp() {
        Id id = new Id();
        String email = 'email@gmail.com';
        User owner = new User(Id = id, Email = email);
        Account acc = new Account(Id = id);
        Contact con = new Contact(Id = id);
        Opportunity opp = new Opportunity(
            Owner = owner,
            AccountId = acc,
            Contact__c = con
        );

        
    }
}