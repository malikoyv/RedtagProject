@isTest
private class OpportunitySummaryQueueableTest {
    @isTest
    static void testOpportunitySummaryQueueable() {
        Statistic__c summary = new Statistic__c(
            Closed_Won_Opportunities__c = 2,
            Closed_Lost_Opportunities__c = 1,
            Total_Opportunities__c = 3,
            Last_Processing_Date__c = Date.today()
        );
        insert summary;

        Test.startTest();
        OpportunitySummaryQueueable queueableJob = new OpportunitySummaryQueueable(summary);
        System.enqueueJob(queueableJob);
        Test.stopTest();

        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        Test.setMock(HttpCalloutMock.class, new EmailMock(emails));

        Assert.areEqual(1, emails.size(), 'An email should be sent.');
        Assert.areEqual('Opportunity Summary for Current Quarter', emails[0].getSubject());
        Assert.areEqual(UserInfo.getUserEmail(), emails[0].getToAddresses()[0]);
    }

    private class EmailMock implements HttpCalloutMock {
        List<Messaging.SingleEmailMessage> emails;

        EmailMock(List<Messaging.SingleEmailMessage> emails) {
            this.emails = emails;
        }

        public HTTPResponse respond(HTTPRequest req) {
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(new String[] { 'test@example.com' });
            email.setSubject('Opportunity Summary for Current Quarter');
            email.setPlainTextBody('Test email body');

            emails.add(email);
            return new HTTPResponse();
        }
    }
}
