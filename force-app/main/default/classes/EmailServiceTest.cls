@isTest
private class EmailServiceTest {
    @TestSetup
    static void setup(){
        EmailTemplate emailTemplate = TestDataFactory.createEmailTemplate();
        insert emailTemplate;
    }

    @isTest
    static void sendEmailOnOpportunity() {
        Opportunity opp = TestDataFactory.createOpportunity();
        insert opp;
        
        Test.startTest();
        EmailService.sendEmail(new List<Opportunity>{opp}, 'OpportunityDeletion12');
        Test.stopTest();

        Integer emailInvocations = Limits.getEmailInvocations();
        System.assertEquals(1, emailInvocations, 'Expected 1 email to be sent');
    }
}