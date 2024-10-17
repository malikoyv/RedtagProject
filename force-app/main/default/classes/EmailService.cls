public with sharing class EmailService {

    // Method to send emails for deleted opportunities using an email template
    public static List<Messaging.SendEmailResult> sendEmail(List<Opportunity> deletedOpps, String templateName) {
        List<Messaging.SendEmailResult> results = new List<Messaging.SendEmailResult>();
        
        try {
            EmailTemplate template = [SELECT Id, Subject, Body FROM EmailTemplate WHERE DeveloperName = :templateName LIMIT 1];

            List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();

            for (Opportunity opp : deletedOpps) {
                Messaging.SingleEmailMessage email = Messaging.renderStoredEmailTemplate(template.Id, opp.OwnerId, opp.Id);
                email.setSaveAsActivity(false);
                emailsToSend.add(email);
            }

            if (!emailsToSend.isEmpty()) {
                results = Messaging.sendEmail(emailsToSend);

                for (Messaging.SendEmailResult result : results) {
                    if (!result.isSuccess()) {
                        System.debug('Email sending failed: ' + result.getErrors()[0].getMessage());
                    }
                }
            }
        } catch (Exception e) {
            System.debug('Exception occurred: ' + e.getMessage());
        }

        return results;
    }

    public class EmailParams {
        @InvocableVariable(required=true)
        public String toAddress;
        
        @InvocableVariable(required=true)
        public String subject;
        
        @InvocableVariable(required=true)
        public String body;
        
        @InvocableVariable(required=true)
        public String attachmentName;
        
        @InvocableVariable(required=true)
        public Id recordId;
    }

    // Method to send emails with Quote PDFs attached
   public static List<Boolean> sendEmailWithPDF(List<EmailParams> paramsList) {
       List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();
       List<Boolean> emailResults = new List<Boolean>();

       for (EmailParams params : paramsList) {
           try {
               Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
               
               email.setToAddresses(new String[] { params.toAddress });
               email.setSubject(params.subject);
               email.setPlainTextBody(params.body);

               Blob attachmentBlob = generatePDF(params.recordId);

               Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
               attachment.setFileName(params.attachmentName);
               attachment.setBody(attachmentBlob);
               attachment.setContentType('application/pdf');
               email.setFileAttachments(new Messaging.EmailFileAttachment[] { attachment });

               emailsToSend.add(email);
           } catch (Exception e) {
               emailResults.add(false);
               System.debug('Error while preparing email: ' + e.getMessage());
           }
       }

       if (!emailsToSend.isEmpty()) {
           List<Messaging.SendEmailResult> results = Messaging.sendEmail(emailsToSend);
           
           for (Integer i = 0; i < results.size(); i++) {
               Messaging.SendEmailResult result = results[i];
               if (result.isSuccess()) {
                   emailResults.add(true);
               } else {
                   emailResults.add(false);
               }
           }
       }

       return emailResults;
   }

    // Private helper method to generate PDF based on a Quote
    private static Blob generatePDF(Id quoteId) {
        PageReference pdfPage = Page.QuotePDF;
        pdfPage.getParameters().put('id', quoteId);
        Blob pdfBlob = pdfPage.getContentAsPDF();
        return pdfBlob;
    }
}