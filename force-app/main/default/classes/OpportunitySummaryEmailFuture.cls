public class OpportunitySummaryEmailFuture {
    @future
    public static void sendEmailWithSummary(Id summaryId) {
        Messaging.SingleEmailMessage sentEmail = EmailService.sendStatisticsEmail(summaryId);
    }
}
