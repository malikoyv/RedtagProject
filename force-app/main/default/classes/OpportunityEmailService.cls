public with sharing class OpportunityEmailService {
    public static void sendEmailOnDelete(List<Opportunity> deletedOpps) {
        try {
            List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();
            Set<Id> ownerIds = new Set<Id>();
            for (Opportunity opp : deletedOpps) {
                ownerIds.add(opp.OwnerId);
            }

            Map<Id, User> ownerMap = new Map<Id, User>([SELECT Email FROM User WHERE Id IN :ownerIds]);
            System.debug('Owner Map: ' + ownerMap);

            List<EmailTemplate> templates = [SELECT Id, Subject, Body FROM EmailTemplate WHERE Name = 'OpportunityDeletion' LIMIT 1];
            if (templates.isEmpty()) {
                System.debug('Error: EmailTemplate "OpportunityDeletion" not found');
                return;
            }
            EmailTemplate template = templates[0];
            System.debug('Template found: ' + template.Id);

            for (Opportunity opp : deletedOpps) {
                if (ownerMap.containsKey(opp.OwnerId)) {
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.setTemplateId(template.Id);
                    mail.setTargetObjectId(opp.OwnerId);
                    mail.setSaveAsActivity(false);
                    mail.setToAddresses(new List<String>{opp.OwnerId});
                    emailsToSend.add(mail);
                }
            }

            System.debug('Emails to send: ' + emailsToSend.size());
            if (!emailsToSend.isEmpty()) {
                List<Messaging.SendEmailResult> results = Messaging.sendEmail(emailsToSend);
            }
        } catch (Exception e) {
            System.debug('Error in sendEmailOnDelete: ' + e.getMessage() + ' Stack trace: ' + e.getStackTraceString());
        }
    }
}
