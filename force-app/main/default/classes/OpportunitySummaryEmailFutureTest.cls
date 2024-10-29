@isTest
private class OpportunitySummaryEmailFutureTest {
    @isTest
    static void testSendStatisticsEmail() {
        Statistic__c summary = new Statistic__c(
            Closed_Won_Opportunities__c = 5,
            Closed_Lost_Opportunities__c = 3,
            Total_Opportunities__c = 8,
            Last_Processing_Date__c = Date.today()
        );
        insert summary;

        Test.startTest();
        Messaging.SingleEmailMessage email = EmailService.sendStatisticsEmail(summary.Id);
        Test.stopTest();

        System.assertEquals('Opportunity Summary for Current Quarter', email.getSubject());
        System.assertEquals('test@example.com', email.getToAddresses()[0]);
    }
}
