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
    
    @IsTest
    static void testSendEmailWithPDF() {
        Account testAccount = TestDataFactory.createAccount();
        Contact testContact = TestDataFactory.createContact(testAccount.Id);
        Opportunity testOpportunity = TestDataFactory.createOpportunity(testAccount.Id);
        Quote testQuote = TestDataFactory.createQuote(testAccount.Id, testContact.Id);

        List<EmailService.EmailParams> paramsList = new List<EmailService.EmailParams>{
            TestDataFactory.createEmailParams(testQuote.Id)
        };
        
        Test.startTest();
        List<Boolean> results = EmailService.sendEmailWithPDF(paramsList);
        Test.stopTest();
        
        System.assertEquals(1, results.size());
        System.assert(results[0]);
    }
}