public class OpportunitySummaryQueueable implements Queueable, Database.AllowsCallouts {
    private Id summaryId;

    public OpportunitySummaryQueueable(Statistic__c summarySObject) {
        this.summaryId = summarySObject.Id;
    }

    public void execute(QueueableContext context) {
        OpportunitySummaryEmailFuture.sendEmailWithSummary(summaryId);
    }
}
