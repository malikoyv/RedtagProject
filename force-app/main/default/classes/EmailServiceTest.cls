@isTest
private class EmailServiceTest {
    @TestSetup
    static void setup(){
        Opportunity opp = TestDataFactory.createOpportunity();
        insert opp;

        System.runAs(new User(Id=UserInfo.getUserId())) {
            EmailTemplate emailTemplate = TestDataFactory.createEmailTemplate();
            insert emailTemplate;
        }
    }

    @isTest
    static void sendEmailOnOpportunity() {
        Opportunity opp = [SELECT Id, OwnerId FROM Opportunity LIMIT 1];
        
        Test.startTest();
        EmailService.sendEmail(new List<Opportunity>{opp}, 'OpportunityDeletion12');
        Test.stopTest();

        Integer emailInvocations = Limits.getEmailInvocations();
        System.assertEquals(1, emailInvocations, 'Expected 1 email to be sent');
    }
}