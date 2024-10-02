public with sharing class OpportunityTriggerHandler {
    List<Opportunity> newOppList = Trigger.new;
    List<Opportunity> oldOppList = Trigger.old;

    public void insertAccountAndContact(){
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
    
        for (Opportunity op : newOppList) {
            Opportunity oppTemp = new Opportunity(Id = op.Id); // because record is readonly
            if (oppAccountMap.containsKey(op.Id)) {
                oppTemp.AccountId = oppAccountMap.get(op.Id).Id;
            }
            if (oppContactMap.containsKey(op.Id)){
                oppTemp.Contact__c = oppContactMap.get(op.Id).Id;
            }
            oppToUpdate.add(oppTemp);
        }
    
        if (!oppToUpdate.isEmpty()) {
            update oppToUpdate;
        }
    }

    public void updateOpportunityDetails(){
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

    public void updateOpportunityAccountAndContact(){
        List<Account> accountsToUpdate = new List<Account>();
        List<Account> accountsToInsert = new List<Account>();
    
        List<Contact> contactsToUpdate = new List<Contact>();
        List<Contact> contactsToInsert = new List<Contact>();
    
        Map<Id, String> oldContactNamesMap = new Map<Id, String>();
        Map<Id, String> oldAccountNamesMap = new Map<Id, String>();
    
        for (Opportunity oldOp : oldOppList) {
                oldAccountNamesMap.put(oldOp.AccountId, oldOp.AccountName__c);
                oldContactNamesMap.put(oldOp.ContactId, oldOp.ContactLastName__c);
        }

        for (Opportunity newOp : newOppList) {
            if (newOp.AccountId != null) {
                String oldName = oldAccountNamesMap.get(newOp.AccountId);
                String newName = newOp.AccountName__c;
                
                if (oldName != null && newName != null) {
                    if (oldName.contains(newName) || newName.contains(oldName)) {
                        Account accToUpdate = new Account(Id = newOp.AccountId, Name = newName);
                        accountsToUpdate.add(accToUpdate);
                    } else {
                        Account accToInsert = new Account(Name = newName);
                        accountsToInsert.add(accToInsert);
                    }
                }
            }

            if (newOp.ContactId != null){
                String oldName = oldContactNamesMap.get(newOp.ContactId);
                String newName = newOp.ContactLastName__c;

                if (oldName != null && newName != null){
                    if (oldName.contains(newName) || newName.contains(oldName)){
                        Contact contactToUpdate = new Contact(Id = newOp.ContactId, LastName = newName);
                        contactsToUpdate.add(contactToUpdate);
                    }
                    else {
                        Contact con = new Contact(LastName = newName);
                        contactsToInsert.add(con);
                    }
                }
            }
        }
    
        if (!accountsToInsert.isEmpty()) {
            insert accountsToInsert;
        }
        if (!accountsToUpdate.isEmpty()) {
            update accountsToUpdate;
        }
        if (!contactsToInsert.isEmpty()){
            insert contactsToInsert;
        }
        if (!contactsToUpdate.isEmpty()){
            update contactsToUpdate;
        }
    }

}