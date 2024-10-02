public with sharing class OpportunityTriggerHandler {

    public void insertAccountAndContact(List<Opportunity> newOppList){
        List<Account> accountsToAdd = new List<Account>();
        List<Contact> contactsToAdd = new List<Contact>();
    
        Map<Id, Account> oppAccountMap = new Map<Id, Account>();
        Map<Id, Contact> oppContactMap = new Map<Id, Contact>();
    
        List<Opportunity> oppToUpdate = new List<Opportunity>();
    
        for (Opportunity op : newOppList) {
            Account newAccount = new Account(Name = op.AccountName__c);
            accountsToAdd.add(newAccount);
    
            Contact newContact = new Contact(LastName = op.ContactLastName__c);
            contactsToAdd.add(newContact);
    
            oppAccountMap.put(op.Id, newAccount);
            oppContactMap.put(op.Id, newContact);
        }
    
        if (!accountsToAdd.isEmpty()) {
            insert accountsToAdd;
        }
        if (!contactsToAdd.isEmpty()) {
            insert contactsToAdd;
        }

        for (Opportunity opp : newOppList) {
            Opportunity oppTemp = new Opportunity(Id = opp.Id); // because record is readonly
            if (oppAccountMap.containsKey(opp.Id)) {
                oppTemp.AccountId = oppAccountMap.get(opp.Id).Id;
            }
            if (oppContactMap.containsKey(opp.Id)){
                oppTemp.Contact__c = oppContactMap.get(opp.Id).Id;
            }
            oppToUpdate.add(oppTemp);
        }
    
        if (!oppToUpdate.isEmpty()) {
            update oppToUpdate;
        }
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

    public void updateOpportunityAccountAndContact(List<Opportunity> oldOppList, List<Opportunity> newOppList) {
        Map<Id, Opportunity> oldOppMap = new Map<Id, Opportunity>(oldOppList);
        List<Account> accountsToUpsert = new List<Account>();
        List<Contact> contactsToUpsert = new List<Contact>();
        
        Map<Id, Id> oppToNewAccountMap = new Map<Id, Id>();
        Map<Id, Id> oppToNewContactMap = new Map<Id, Id>();

        for (Opportunity newOp : newOppList) {
            Opportunity oldOp = oldOppMap.get(newOp.Id);
            
            if (newOp.AccountName__c != oldOp.AccountName__c) {
                Account acc;
                if (newOp.AccountId != null) {
                    acc = new Account(Id = newOp.AccountId, Name = newOp.AccountName__c);
                } else {
                    acc = new Account(Name = newOp.AccountName__c);
                }
                accountsToUpsert.add(acc);
                oppToNewAccountMap.put(newOp.Id, acc.Id);
            }
            
            if (newOp.ContactLastName__c != oldOp.ContactLastName__c) {
                Contact con;
                if (newOp.Contact__c != null) {
                    con = new Contact(Id = newOp.Contact__c, LastName = newOp.ContactLastName__c);
                } else {
                    con = new Contact(LastName = newOp.ContactLastName__c);
                }
                contactsToUpsert.add(con);
                oppToNewContactMap.put(newOp.Id, con.Id);
            }
        }

        if (!accountsToUpsert.isEmpty()) {
            upsert accountsToUpsert;
        }
        if (!contactsToUpsert.isEmpty()) {
            upsert contactsToUpsert;
        }

        for (Opportunity newOp : newOppList) {
            if (oppToNewAccountMap.containsKey(newOp.Id)) {
                newOp.AccountId = oppToNewAccountMap.get(newOp.Id);
            }
            if (oppToNewContactMap.containsKey(newOp.Id)) {
                newOp.Contact__c = oppToNewContactMap.get(newOp.Id);
            }
        }
    }

    public void sendEmailAfterDelete(List<Opportunity> deletedOpps) {
        List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();
        Set<Id> ownerIds = new Set<Id>();
        for (Opportunity opp : deletedOpps) {
            ownerIds.add(opp.OwnerId);
        }
        Map<Id, User> ownerMap = new Map<Id, User>([SELECT Email FROM User WHERE Id IN :ownerIds]);

        
        EmailTemplate template = [SELECT Id, Subject, Body FROM EmailTemplate WHERE Name = 'OpportunityDeletion' LIMIT 1];
        
        for (Opportunity opp : deletedOpps) {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            
            mail.setTemplateId(template.Id);
            
            mail.setWhatId(opp.Id);
            mail.setToAddresses(new List<String>{ownerMap.get(opp.OwnerId).Email});
            
            emailsToSend.add(mail);
        }
        
        List<Messaging.SendEmailResult> results = Messaging.sendEmail(emailsToSend);
        System.debug(results);
    }
}