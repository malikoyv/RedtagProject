global class OpportunitySummaryBatch implements Database.Batchable<SObject>, Database.Stateful {

    private Statistic__c summarySObject;

    global Database.QueryLocator start(Database.BatchableContext BC) {
        summarySObject = new Statistic__c(Closed_Won_Opportunities__c = 0, Closed_Lost_Opportunities__c = 0, Total_Opportunities__c = 0);

        Date currentDate = Date.today();
        Integer currentMonth = currentDate.month();

        Integer quarterStartMonth = ((currentMonth - 1) / 3) * 3 + 1;
        Date quarterStartDate = Date.newInstance(currentDate.year(), quarterStartMonth, 1);
        Date quarterEndDate = quarterStartDate.addMonths(3).addDays(-1);

        Database.QueryLocator result = Database.getQueryLocator([
            SELECT Id, StageName, CloseDate
            FROM Opportunity
            WHERE CloseDate >= :quarterStartDate AND CloseDate <= :quarterEndDate
        ]);

        return result;
    }

    global void execute(Database.BatchableContext BC, List<Opportunity> scope) {

        for (Opportunity opp : scope) {
            if (opp.StageName == 'Closed Won') {
                summarySObject.Closed_Won_Opportunities__c++;
            } else if (opp.StageName == 'Closed Lost') {
                summarySObject.Closed_Lost_Opportunities__c++;
            }
            summarySObject.Total_Opportunities__c++;
            System.debug('Opportunity Stage: ' + opp.StageName);
            System.debug('Closed Won Count: ' + summarySObject.Closed_Won_Opportunities__c);
            System.debug('Closed Lost Count: ' + summarySObject.Closed_Lost_Opportunities__c);

        }
        
    }

    global void finish(Database.BatchableContext BC) {
        summarySObject.Last_Processing_Date__c = Date.today();
        System.debug('Closed Won Count: ' + summarySObject.Closed_Won_Opportunities__c);
        System.debug('Closed Lost Count: ' + summarySObject.Closed_Lost_Opportunities__c);
        insert summarySObject;

        OpportunitySummaryQueueable queueableJob = new OpportunitySummaryQueueable(summarySObject);
        System.enqueueJob(queueableJob);
    }
}
