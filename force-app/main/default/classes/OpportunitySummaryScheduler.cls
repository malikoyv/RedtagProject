global class OpportunitySummaryScheduler implements Schedulable {

    global void execute(SchedulableContext sc) {
        OpportunitySummaryBatch batchJob = new OpportunitySummaryBatch();
        Database.executeBatch(batchJob);
    }
}
