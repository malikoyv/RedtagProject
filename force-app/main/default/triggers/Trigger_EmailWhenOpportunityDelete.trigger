trigger Trigger_EmailWhenOpportunityDelete on Opportunity (after delete) {
    List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
    
    for (Opportunity opp : Trigger.old) {
        User owner = opp.Owner;
        
        if (owner != null && owner.Email != null) {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(new String[]{owner.Email});
            mail.setSubject('Opportunity record is deleted: ' + opp.Name);
            
            String emailBody = '<html><body>';
            emailBody += '<p>Hi ' + owner.Name + ',</p>';
            emailBody += '<p>Opportunity ' + opp.Name + ' was deleted:</p>';
            emailBody += '<ul>';
            emailBody += '<li>Opportunity Id: ' + opp.Id + '</li>';
            emailBody += '<li>Opportunity Name: ' + opp.Name + '</li>';
            emailBody += '<li>Amount: ' + (opp.Amount != null ? opp.Amount.format() : 'N/A') + '</li>';
            emailBody += '</ul>';
            
            emailBody += '</body></html>';
            
            mail.setHtmlBody(emailBody);
            mails.add(mail);
        }
    }
    
    if (!mails.isEmpty()) {
        // debug
        // List<Messaging.SendEmailResult> results = Messaging.sendEmail(mails);
        // System.debug(results);
        // use template
        Messaging.sendEmail(mails);

        // rewrite with Messaging.MassEmailMessage
    }
}