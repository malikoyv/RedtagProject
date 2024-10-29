@isTest
private class OpportunitySummarySchedulerTest {
    @isTest
    static void testOpportunitySummaryScheduler() {
        OpportunitySummaryScheduler scheduler = new OpportunitySummaryScheduler();
        String jobId = System.schedule('Test Scheduler', '0 0 0 ? * MON-FRI', scheduler);

        Test.startTest();
        System.abortJob(jobId);
        Test.stopTest();

        List<Statistic__c> statistics = [SELECT Id FROM Statistic__c];
        System.assertEquals(0, statistics.size(), 'No Statistic record should be created without opportunities.');
    }
}
