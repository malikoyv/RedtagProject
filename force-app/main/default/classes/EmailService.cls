public with sharing class EmailService {

    // Method to send emails for deleted opportunities using an email template
    public static void sendEmail(List<Opportunity> deletedOpps, String templateName) {
        EmailTemplate template = [SELECT Id, Subject, Body FROM EmailTemplate WHERE DeveloperName = :templateName LIMIT 1];
        if (template == null) {
            System.debug('Email template not found');
            return;
        }
        
        List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();
        
        for (Opportunity opp : deletedOpps) {
            Messaging.SingleEmailMessage email = Messaging.renderStoredEmailTemplate(template.Id, opp.OwnerId, opp.Id);
            email.setSaveAsActivity(false);
            emailsToSend.add(email);
        }
        
        if (!emailsToSend.isEmpty()) {
            List<Messaging.SendEmailResult> results = Messaging.sendEmail(emailsToSend);
            for (Messaging.SendEmailResult result : results) {
                if (!result.isSuccess()) {
                    System.debug('Email sending failed: ' + result.getErrors()[0].getMessage());
                }
            }
        }
    }

    // Method to send emails with Quote PDFs attached
    public static void sendQuoteEmailWithPDF(List<QuotePDFController.EmailParams> paramsList) {
        List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();

        for (QuotePDFController.EmailParams params : paramsList) {
            Quote quote = [SELECT Id, Name FROM Quote WHERE Id = :params.quoteId LIMIT 1];

            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();

            email.setToAddresses(new String[] { params.emailAddress });
            email.setSubject('Quote PDF: ' + quote.Name);
            email.setPlainTextBody('Please find attached the Quote PDF for ' + quote.Name + '.'); 

            Blob pdfBlob = generatePDF(params.quoteId);

            Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
            attachment.setFileName(quote.Name + '.pdf');
            attachment.setBody(pdfBlob);
            attachment.setContentType('application/pdf');
            email.setFileAttachments(new Messaging.EmailFileAttachment[] { attachment });

            emailsToSend.add(email);
        }

        if (!emailsToSend.isEmpty()) {
            List<Messaging.SendEmailResult> results = Messaging.sendEmail(emailsToSend);
            for (Messaging.SendEmailResult result : results) {
                if (!result.isSuccess()) {
                    System.debug('Email sending failed: ' + result.getErrors()[0].getMessage());
                }
            }
        }
    }

    private static Blob generatePDF(Id quoteId) {
        PageReference pdfPage = Page.QuotePDF;
        pdfPage.getParameters().put('id', quoteId);
        Blob pdfBlob = pdfPage.getContentAsPDF();
        return pdfBlob;
    }
}
