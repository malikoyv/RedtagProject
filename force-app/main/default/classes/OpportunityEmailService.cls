public with sharing class OpportunityEmailService {
    public static void sendEmailOnDelete(List<Opportunity> deletedOpps) {
        EmailTemplate template = [SELECT Id, Subject, Body FROM EmailTemplate WHERE Name = 'OpportunityDeletion' LIMIT 1];
        
        if (template == null) {
            System.debug('Email template not found');
            return;
        }
        
        List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();
        
        for (Opportunity opp : deletedOpps) {
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            // email.setTemplateId(template.Id);
            email.setTargetObjectId(opp.OwnerId);
            email.setSaveAsActivity(false);
            email.setWhatId(opp.Id);
            email.setPlainTextBody(template.Body);
            emailsToSend.add(email);
        }
        
        List<Messaging.SendEmailResult> result = Messaging.sendEmail(emailsToSend);

    }
}