public with sharing class EmailService {

    // Method to send emails for deleted opportunities using an email template
    public static List<Messaging.SendEmailResult> sendEmail(List<Opportunity> opps, String templateName) {
        List<Messaging.SendEmailResult> results = new List<Messaging.SendEmailResult>();
        
        EmailTemplate template = [SELECT Id, Subject, Body FROM EmailTemplate WHERE DeveloperName = :templateName LIMIT 1];

        List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();

        for (Opportunity opp : opps) {
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

        return results;
    }

    // Method to send emails with Quote PDFs attached
    public static List<Messaging.SendEmailResult> sendEmailWithPDF(Id recordId, String toAddress, String subject, String body, String attachmentName, String pageName) {
        List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();

        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        
        email.setToAddresses(new String[] { toAddress });
        email.setSubject(subject);
        email.setPlainTextBody(body);

        Blob attachmentBlob = generatePDF(recordId, pageName);

        Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
        attachment.setFileName(attachmentName);
        attachment.setBody(attachmentBlob);
        attachment.setContentType('application/pdf');
        email.setFileAttachments(new Messaging.EmailFileAttachment[] { attachment });

        emailsToSend.add(email);
        List<Messaging.SendEmailResult> result = Messaging.sendEmail(emailsToSend); 

        return result;
   }

    // Private helper method to generate PDF based on a Record
    @TestVisible
    private static Blob generatePDF(Id recordId, String pageName) {
        if (Test.isRunningTest()) {
            return Blob.valueOf('Test PDF Content');
        } else {
            PageReference pdfPage = new PageReference('/apex/' + pageName);
            pdfPage.setRedirect(false);
            pdfPage.getParameters().put('id', recordId);
            return pdfPage.getContentAsPDF();
        }
    }
}
