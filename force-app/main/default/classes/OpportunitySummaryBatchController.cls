public with sharing class OpportunitySummaryBatchController {
    
    public static void runBatch() {
        OpportunitySummaryBatch batchJob = new OpportunitySummaryBatch();
        Database.executeBatch(batchJob);
    }
}
