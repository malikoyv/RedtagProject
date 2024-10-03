public with sharing class OpportunityTriggerHandler {
    public void OnAfterInsert(List<Opportunity> newOppList){
        createAccount(newOppList);
        createContact(newOppList);
    }

    public void OnBeforeUpdate(List<Opportunity> oldOppList, List<Opportunity> newOppList){
        updateOpportunityDetails(newOppList);
        updateOpportunityAccount(oldOppList, newOppList);
        updateOpportunityContact(OldOppList, newOppList);
    }

    public void createAccount(List<Opportunity> newOppList){
        System.debug('Entering createAccount method');
        List<Account> accountsToAdd = new List<Account>();
        Map<Id, Account> oppAccountMap = new Map<Id, Account>();
        List<Opportunity> oppToUpdate = new List<Opportunity>();
    
        for (Opportunity op : newOppList) {
            if (String.isNotBlank(op.AccountName__c)) {
                System.debug('Creating account for Opportunity: ' + op.Id + ' with AccountName: ' + op.AccountName__c);
                Account newAccount = new Account(Name = op.AccountName__c);
                accountsToAdd.add(newAccount);
                oppAccountMap.put(op.Id, newAccount);
            } else {
                System.debug('AccountName__c is blank for Opportunity: ' + op.Id);
            }
        }
    
        if (!accountsToAdd.isEmpty()) {
            try {
                insert accountsToAdd;
                System.debug('Inserted ' + accountsToAdd.size() + ' accounts');
                
                List<Opportunity> oppsToUpdate = new List<Opportunity>();
                for (Id oppId : oppAccountMap.keySet()) {
                    oppsToUpdate.add(new Opportunity(
                        Id = oppId,
                        AccountId = oppAccountMap.get(oppId).Id
                    ));
                }
                
                if (!oppsToUpdate.isEmpty()) {
                    updateOpportunitiesAsync(JSON.serialize(oppsToUpdate));
                    System.debug('Called updateOpportunitiesAsync with ' + oppsToUpdate.size() + ' opportunities');
                }
            } catch (Exception e) {
                System.debug('Error in createAccount method: ' + e.getMessage());
            }
        } else {
            System.debug('No accounts to add');
        }
    }

    public void createContact(List<Opportunity> newOppList){
        List<Contact> contactsToAdd = new List<Contact>();
    
        Map<Id, Contact> oppContactMap = new Map<Id, Contact>();
    
        List<Opportunity> oppToUpdate = new List<Opportunity>();
    
        for (Opportunity op : newOppList) {
            Contact newContact = new Contact(LastName = op.ContactLastName__c);
            contactsToAdd.add(newContact);
            oppContactMap.put(op.Id, newContact);
        }
    
        if (!contactsToAdd.isEmpty()) {
            insert contactsToAdd;
            
            List<Opportunity> oppsToUpdate = new List<Opportunity>();
            for (Id oppId : oppContactMap.keySet()) {
                oppsToUpdate.add(new Opportunity(
                    Id = oppId,
                    Contact__c = oppContactMap.get(oppId).Id
                ));
            }
            
            if (!oppsToUpdate.isEmpty()) {
                updateOpportunitiesAsync(JSON.serialize(oppsToUpdate));
            }
        }
    }

    @future
    public static void updateOpportunitiesAsync(String serializedOpps) {
        List<Opportunity> oppsToUpdate = (List<Opportunity>) JSON.deserialize(serializedOpps, List<Opportunity>.class);
        update oppsToUpdate;
    }

    public void updateOpportunityDetails(List<Opportunity> newOppList){
        for (Opportunity opp : newOppList) {
            if (opp.AccountName__c != null) {
                opp.Name = opp.AccountName__c + ' ' + Datetime.now().format('yyyy-MM-dd');
            } else {
                opp.Name = 'No Account ' + Datetime.now().format('yyyy-MM-dd');
            }
            
            opp.StageName = 'Prospecting';
            
            opp.CloseDate = Date.today().addDays(90);
        }
    }

    public void updateOpportunityAccount(List<Opportunity> oldOppList, List<Opportunity> newOppList) {
        Map<Id, Opportunity> oldOppMap = new Map<Id, Opportunity>(oldOppList);
        List<Account> accountsToUpdate = new List<Account>();
        List<Account> accountsToInsert = new List<Account>();

        for (Opportunity newOp : newOppList) {
            Opportunity oldOp = oldOppMap.get(newOp.Id);
            Account acc;
            if (!newOp.AccountName__c.contains(oldOp.AccountName__c) || !oldOp.AccountName__c.contains(newOp.AccountName__c)) {
                acc = new Account(Name = newOp.AccountName__c);
                accountsToInsert.add(acc);
                newOp.AccountId = acc.Id;
            } else {
                acc = new Account(Id = newOp.AccountId, Name = newOp.AccountName__c);
                accountsToUpdate.add(acc);
                newOp.AccountId = acc.Id;
            }
        }

        if (!accountsToInsert.isEmpty()){
            insert accountsToInsert;
        }
        if (!accountsToUpdate.isEmpty()){
            update accountsToUpdate;
        }
    }

    public void updateOpportunityContact(List<Opportunity> oldOppList, List<Opportunity> newOppList) {
        Map<Id, Opportunity> oldOppMap = new Map<Id, Opportunity>(oldOppList);
        List<Contact> contactsToUpdate = new List<Contact>();
        List<Contact> contactsToInsert = new List<Contact>();
        
        Map<Id, Id> oppToNewContactMap = new Map<Id, Id>();

        for (Opportunity newOp : newOppList) {
            Opportunity oldOp = oldOppMap.get(newOp.Id);
            Contact con;
            if (!newOp.ContactLastName__c.contains(oldOp.ContactLastName__c) || !oldOp.ContactLastName__c.contains(newOp.ContactLastName__c)) {
                con = new Contact(LastName = newOp.ContactLastName__c);
                contactsToInsert.add(con);
                newOp.Contact__c = con.Id;
            } else {
                con = new Contact(Id = newOp.Contact__c, LastName = newOp.ContactLastName__c);
                contactsToUpdate.add(con);
                newOp.Contact__c = con.Id;
            }
        }

        if (!contactsToInsert.isEmpty()){
            insert contactsToInsert;
        }
        if (!contactsToUpdate.isEmpty()){
            update contactsToUpdate;
        }

        // for (Opportunity newOp : newOppList) {
        //     if (oppToNewContactMap.containsKey(newOp.Id)) {
        //         newOp.Contact__c = oppToNewContactMap.get(newOp.Id);
        //     }
        // }
    }

    public void sendEmailAfterDelete(List<Opportunity> deletedOpps) {
        // List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();
        // Set<Id> ownerIds = new Set<Id>();
        // for (Opportunity opp : deletedOpps) {
        //     ownerIds.add(opp.OwnerId);
        // }
        // Map<Id, User> ownerMap = new Map<Id, User>([SELECT Email FROM User WHERE Id IN :ownerIds]);

        // EmailTemplate template = [SELECT Id, Subject, Body FROM EmailTemplate WHERE Name = 'OpportunityDeletion' LIMIT 1];
        
        // for (Opportunity opp : deletedOpps) {
        //     Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            
        //     mail.setTemplateId(template.Id);
            
        //     mail.setWhatId(opp.Id);
        //     mail.setTargetObjectId(ownerMap.get(opp.OwnerId).Id);
            
        //     emailsToSend.add(mail);
        // }
        
        // List<Messaging.SendEmailResult> results = Messaging.sendEmail(emailsToSend);
        // System.debug(results);




        Set<Id> ownerIds = new Set<Id>();
        Set<Id> accountIds = new Set<Id>();
        Set<Id> contactIds = new Set<Id>();
        
        for (Opportunity opp : deletedOpps) {
            ownerIds.add(opp.OwnerId);
            if (opp.AccountId != null) accountIds.add(opp.AccountId);
            if (opp.ContactId != null) contactIds.add(opp.ContactId);
        }
        
        Map<Id, User> owners = new Map<Id, User>([SELECT Name, Email FROM User WHERE Id IN :ownerIds]);
        Map<Id, Account> accounts = new Map<Id, Account>([SELECT Name FROM Account WHERE Id IN :accountIds]);
        Map<Id, Contact> contacts = new Map<Id, Contact>([SELECT LastName FROM Contact WHERE Id IN :contactIds]);
        
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        
        for (Opportunity opp : deletedOpps) {
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
        
        List<Messaging.SendEmailResult> results = Messaging.sendEmail(mails);
        System.debug(results);
    }
}