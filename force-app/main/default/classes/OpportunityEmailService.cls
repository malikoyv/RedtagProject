public with sharing class OpportunityEmailService {
    public static void sendEmailOnDelete(List<Opportunity> deletedOpps) {
        EmailTemplate template = [SELECT Id, Subject, Body FROM EmailTemplate WHERE Name = 'OpportunityDeletion' LIMIT 1];
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
}