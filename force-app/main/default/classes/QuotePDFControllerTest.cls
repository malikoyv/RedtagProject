@IsTest
public class QuotePDFControllerTest {
    @TestSetup
    static void makeData(){
        
    }
    
    @IsTest
    static void testSendEmailWithAttachment() {
        Account testAccount = TestDataFactory.createAccount();
        Contact testContact = TestDataFactory.createContact(testAccount.Id);
        Opportunity testOpportunity = TestDataFactory.createOpportunity(testAccount.Id);
        Quote testQuote = TestDataFactory.createQuote(testAccount.Id, testContact.Id);

        List<EmailService.EmailParams> paramsList = new List<EmailService.EmailParams>{
            TestDataFactory.createEmailParams(testQuote.Id)
        };
        
        Test.startTest();
        List<Boolean> results = QuotePDFController.sendEmailWithAttachment(paramsList);
        Test.stopTest();
        
        System.assertEquals(1, results.size());
        System.assert(results[0]);
    }
}
