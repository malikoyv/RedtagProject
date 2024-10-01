trigger Trigger_EmailWhenOpportunityDelete on Opportunity (after delete) {
    Set<Id> ownerIds = new Set<Id>();
    Set<Id> accountIds = new Set<Id>();
    Set<Id> contactIds = new Set<Id>();
    
    for (Opportunity opp : Trigger.old) {
        ownerIds.add(opp.OwnerId);
        if (opp.AccountId != null) accountIds.add(opp.AccountId);
        if (opp.ContactId != null) contactIds.add(opp.ContactId);
    }
    
    Map<Id, User> owners = new Map<Id, User>([SELECT Name, Email FROM User WHERE Id IN :ownerIds]);
    Map<Id, Account> accounts = new Map<Id, Account>([SELECT Name FROM Account WHERE Id IN :accountIds]);
    Map<Id, Contact> contacts = new Map<Id, Contact>([SELECT LastName FROM Contact WHERE Id IN :contactIds]);
    
    List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
    
    for (Opportunity opp : Trigger.old) {
        User owner = owners.get(opp.OwnerId);
        Account acc = accounts.get(opp.AccountId);
        Contact con = contacts.get(opp.ContactId);
        
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
            
            if (con != null) emailBody += '<p>Contact: ' + con.LastName + '</p>';
            if (acc != null) emailBody += '<p>Account: ' + acc.Name + '</p>';
            
            emailBody += '</body></html>';
            
            mail.setHtmlBody(emailBody);
            mails.add(mail);
        }
    }
    
    if (!mails.isEmpty()) {
        Messaging.sendEmail(mails);
    }
}