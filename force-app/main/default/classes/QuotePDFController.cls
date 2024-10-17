public class QuotePDFController {
    
    @InvocableMethod
    public static void sendEmailWithPDF(List<EmailParams> paramsList) {
        EmailService.sendQuoteEmailWithPDF(paramsList);
    }

    public class EmailParams {
        @InvocableVariable
        public String emailAddress;

        @InvocableVariable
        public Id quoteId;
    }
}
