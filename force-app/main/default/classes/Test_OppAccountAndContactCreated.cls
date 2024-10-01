@isTest
private class Test_OppAccountAndContactCreated {

    @isTest
    static void testOpportunityCreated() {
        Opportunity opp = new Opportunity(
            Name = 'Opp',
            StageName = 'Closed Won',
            CloseDate = Date.today(),
            AccountName__c = 'AccountName',
            ContactLastName__c = 'ContactLastName'
        );

        Test.startTest();
        insert opp;
        Test.stopTest();

        Opportunity updatedOpp = [SELECT Name, AccountId, Contact__c, StageName, CloseDate FROM Opportunity WHERE Id = :opp.Id];
        Account account = [SELECT Name FROM Account WHERE Id = :updatedOpp.AccountId LIMIT 1];
        Contact contact = [SELECT LastName FROM Contact WHERE LastName = :opp.ContactLastName__c LIMIT 1];

        System.assertEquals('AccountName', account.Name);
        System.assertEquals('ContactLastName', contact.LastName);

        System.assertEquals(updatedOpp.AccountId, account.Id);
        System.assertEquals(updatedOpp.Contact__c, contact.Id);

        System.assertEquals('AccountName ' + String.valueOf(Date.today().month()) + '/' + 
        String.valueOf(Date.today().day()) + '/' + 
        String.valueOf(Date.today().year()), updatedOpp.Name);

        System.assertEquals('Prospecting', updatedOpp.StageName);
        System.assertEquals(Date.today().addDays(90), updatedOpp.CloseDate);
    }
}