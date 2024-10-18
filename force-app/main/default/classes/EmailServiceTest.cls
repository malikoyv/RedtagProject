@IsTest
private class EmailServiceTest {
    @TestSetup
    static void setup() {
        // Create test data

        Account testAccount = TestDataFactory.createAccount();
        Opportunity testOpp = TestDataFactory.createOpportunity(testAccount.Id);
                
    }
    
    @IsTest
    static void testSendEmail() {
        // Create email template
        EmailTemplate testTemplate = TestDataFactory.createEmailTemplate();

        Opportunity testOpp = [SELECT Id, OwnerId FROM Opportunity WHERE AccountName__c = 'test account' LIMIT 1];
        
        Test.startTest();
        List<Messaging.SendEmailResult> results = EmailService.sendEmail(new List<Opportunity>{testOpp}, 'OpportunityDeletion12');
        Test.stopTest();
        
        System.assertEquals(1, results.size());
        System.assert(results[0].isSuccess());
    }
    
    @IsTest
    static void testSendEmailWithPDF() {
        Opportunity testOpp = [SELECT Id FROM Opportunity WHERE AccountName__c = 'test account' LIMIT 1];
        
        Test.startTest();
        Test.setCurrentPage(Page.QuotePDF);
        
        List<Messaging.SendEmailResult> results = EmailService.sendEmailWithPDF(
            testOpp.Id,
            'test@example.com',
            'Test Subject',
            'Test Body',
            'TestQuote.pdf',
            'QuotePDF'
        );
        Test.stopTest();
        
        System.assertEquals(1, results.size());
        System.assert(results[0].isSuccess());
    }
    
    @IsTest
    static void testGeneratePDF() {
        Opportunity testOpp = [SELECT Id FROM Opportunity WHERE AccountName__c = 'test account' LIMIT 1];
        
        Test.startTest();
        Test.setCurrentPage(Page.QuotePDF);
        Blob pdfBlob = EmailService.generatePDF(testOpp.Id, 'QuotePDF');
        Test.stopTest();
        
        System.assertNotEquals(null, pdfBlob);
        System.assert(pdfBlob.size() > 0);
    }
}