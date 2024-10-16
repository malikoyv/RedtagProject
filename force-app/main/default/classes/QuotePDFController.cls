public class QuotePDFController {
    private static Blob generatePDF(Id quoteId) {
        PageReference pdfPage = Page.QuotePDF;
        pdfPage.getParameters().put('id', quoteId);
        Blob pdfBlob = pdfPage.getContentAsPDF();
        return pdfBlob;
    }

    @InvocableMethod
    public static void sendEmailWithPDF(List<EmailParams> paramsList) {
        for (EmailParams params : paramsList) {
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            
            email.setToAddresses(new String[] { params.emailAddress });
            email.setSubject('Quote PDF');
            email.setPlainTextBody('Please find attached the Quote PDF.');

            Blob pdfBlob = generatePDF(params.quoteId);
            Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
            attachment.setFileName('Quote.pdf');
            attachment.setBody(pdfBlob);
            attachment.setContentType('application/pdf');
            email.setFileAttachments(new Messaging.EmailFileAttachment[] { attachment });

            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
        }
    }
    
    public class EmailParams {
        @InvocableVariable
        public String emailAddress;

        @InvocableVariable
        public Id quoteId;
    }
}
