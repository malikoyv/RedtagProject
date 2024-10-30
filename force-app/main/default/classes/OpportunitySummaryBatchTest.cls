@isTest
private class OpportunitySummaryBatchTest {
    @isTest
    static void testOpportunitySummaryBatch() {
        List<Opportunity> opportunities = new List<Opportunity>{
            new Opportunity(Name = 'Opp 1', StageName = 'Closed Won', CloseDate = Date.today()),
            new Opportunity(Name = 'Opp 2', StageName = 'Closed Lost', CloseDate = Date.today()),
            new Opportunity(Name = 'Opp 3', StageName = 'Closed Won', CloseDate = Date.today())
        };
        insert opportunities;

        Test.startTest();
        OpportunitySummaryBatch batchJob = new OpportunitySummaryBatch();
        Database.executeBatch(batchJob);
        Test.stopTest();

        List<Statistic__c> statistics = [SELECT Closed_Won_Opportunities__c, Closed_Lost_Opportunities__c, Total_Opportunities__c
                                          FROM Statistic__c];
        Assert.areEqual(1, statistics.size(), 'One Statistic record should be created.');
        Statistic__c stat = statistics[0];

        Assert.areEqual(2, stat.Closed_Won_Opportunities__c, 'Should count 2 Closed Won opportunities.');
        Assert.areEqual(1, stat.Closed_Lost_Opportunities__c, 'Should count 1 Closed Lost opportunity.');
        Assert.areEqual(3, stat.Total_Opportunities__c, 'Total opportunities should be 3.');
    }
}
