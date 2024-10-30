@IsTest
private class QuotePDFControllerTest {
    @TestSetup
    static void setup(){
        Account testAccount = TestDataFactory.createAccount();
        Contact testContact = TestDataFactory.createContact(testAccount.Id);
        Opportunity testOpp = TestDataFactory.createOpportunity(testAccount.Id);
        TestDataFactory.createQuote(testOpp.Id, testContact.Id);
    }

    @IsTest
    static void testSendEmailWithAttachment() {
        Quote testQuote = [SELECT Id FROM Quote LIMIT 1];
        QuotePDFController.EmailParams emailParams = TestDataFactory.createEmailParams(testQuote.Id);
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new EmailServiceMock());
        
        List<QuotePDFController.Results> results = QuotePDFController.sendEmailWithAttachment(new List<QuotePDFController.EmailParams>{emailParams});
        
        Test.stopTest();
        
        Assert.areEqual(1, results.size());
        Assert.isTrue(results[0].isSuccess);
    }
    
    // Mock class for EmailService
    private class EmailServiceMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setBody('{"success": true}');
            res.setStatusCode(200);
            return res;
        }
    }
}