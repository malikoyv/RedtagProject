public with sharing class OpportunityTriggerHandler {

    public void OnBeforeInsert(List<Opportunity> newOpps) {
        updateOpportunityDetails(newOpps);
    }

    public void OnAfterInsert(List<Opportunity> newOpps) {
        insertAccounts(newOpps);
        insertContacts(newOpps);
        updateOpportunityAccountAndContactIds(newOpps);
    }

    public void OnBeforeUpdate(List<Opportunity> oldOpps, List<Opportunity> newOpps, Map<Id, Opportunity> oldOppMap) {
        updateOpportunityDetails(newOpps);
        updateAccounts(oldOpps, newOpps, oldOppMap);
        updateContacts(oldOpps, newOpps, oldOppMap);
    }

    public void OnAfterDelete(List<Opportunity> deletedOpps) {
        OpportunityEmailService.sendEmailOnDelete(deletedOpps);
    }

    private void updateOpportunityDetails(List<Opportunity> newOppList) {
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

    private void insertAccounts(List<Opportunity> newOppList) {
        List<Account> accountsToAdd = new List<Account>();
        for (Opportunity op : newOppList) {
            accountsToAdd.add(new Account(Name = op.AccountName__c));
        }
        insert accountsToAdd;
    }

    private void insertContacts(List<Opportunity> newOppList) {
        List<Contact> contactsToAdd = new List<Contact>();
        for (Opportunity op : newOppList) {
            contactsToAdd.add(new Contact(LastName = op.ContactLastName__c));
        }
        insert contactsToAdd;
    }

    private void updateOpportunityAccountAndContactIds(List<Opportunity> newOppList) {
        Map<String, Id> accountNameToIdMap = new Map<String, Id>();
        Map<String, Id> contactLastNameToIdMap = new Map<String, Id>();

        for (Account acc : [SELECT Id, Name FROM Account WHERE Name IN :getAccountNames(newOppList)]) {
            accountNameToIdMap.put(acc.Name, acc.Id);
        }

        for (Contact con : [SELECT Id, LastName FROM Contact WHERE LastName IN :getContactLastNames(newOppList)]) {
            contactLastNameToIdMap.put(con.LastName, con.Id);
        }

        List<Opportunity> oppsToUpdate = new List<Opportunity>();
        for (Opportunity opp : newOppList) {
            Opportunity oppToUpdate = new Opportunity(Id = opp.Id);
            if (accountNameToIdMap.containsKey(opp.AccountName__c)) {
                oppToUpdate.AccountId = accountNameToIdMap.get(opp.AccountName__c);
            }
            if (contactLastNameToIdMap.containsKey(opp.ContactLastName__c)) {
                oppToUpdate.Contact__c = contactLastNameToIdMap.get(opp.ContactLastName__c);
            }
            oppsToUpdate.add(oppToUpdate);
        }

        if (!oppsToUpdate.isEmpty()) {
            update oppsToUpdate;
        }
    }

    public void updateAccounts(List<Opportunity> oldOpps, List<Opportunity> newOpps, Map<Id, Opportunity> oldOppMap) {
        Map<String, Account> accountNameToAccount = new Map<String, Account>();
        Set<Id> existingAccountIds = new Set<Id>();
        List<Account> accountsToUpsert = new List<Account>();
    
        for (Opportunity newOp : newOpps) {
            Opportunity oldOp = oldOppMap.get(newOp.Id);
            if (newOp.AccountName__c != oldOp.AccountName__c) {
                if (!accountNameToAccount.containsKey(newOp.AccountName__c)) {
                    Account acc;
                    if (newOp.AccountName__c.contains(oldOp.AccountName__c) || oldOp.AccountName__c.contains(newOp.AccountName__c)) {
                        acc = new Account(Id = newOp.AccountId, Name = newOp.AccountName__c);
                        existingAccountIds.add(newOp.AccountId);
                    } else {
                        acc = new Account(Name = newOp.AccountName__c);
                    }
                    accountNameToAccount.put(newOp.AccountName__c, acc);
                    accountsToUpsert.add(acc);
                }
            }
        }
    
        if (!accountsToUpsert.isEmpty()) {
            upsert accountsToUpsert;
        }
    
        for (Opportunity newOp : newOpps) {
            Opportunity oldOp = oldOppMap.get(newOp.Id);
            if (newOp.AccountName__c != oldOp.AccountName__c) {
                Account acc = accountNameToAccount.get(newOp.AccountName__c);
                newOp.AccountId = acc.Id;
            }
        }
    }

    private void updateContacts(List<Opportunity> oldOpps, List<Opportunity> newOpps, Map<Id, Opportunity> oldOppMap) {
        Map<String, Contact> lastNameToContact = new Map<String, Contact>();
        Set<Id> existingContactIds = new Set<Id>();
        List<Contact> contactsToUpsert = new List<Contact>();
    
        for (Opportunity newOp : newOpps) {
            Opportunity oldOp = oldOppMap.get(newOp.Id);
            if (newOp.ContactLastName__c != oldOp.ContactLastName__c) {
                if (!lastNameToContact.containsKey(newOp.ContactLastName__c)) {
                    Contact con;
                    if (newOp.ContactLastName__c.contains(oldOp.ContactLastName__c) || oldOp.ContactLastName__c.contains(newOp.ContactLastName__c)) {
                        con = new Contact(Id = newOp.Contact__c, LastName = newOp.ContactLastName__c);
                        existingContactIds.add(newOp.Contact__c);
                    } else {
                        con = new Contact(LastName = newOp.ContactLastName__c);
                    }
                    lastNameToContact.put(newOp.ContactLastName__c, con);
                    contactsToUpsert.add(con);
                }
            }
        }
    
        if (!contactsToUpsert.isEmpty()) {
            upsert contactsToUpsert;
        }
    
        for (Opportunity newOp : newOpps) {
            Opportunity oldOp = oldOppMap.get(newOp.Id);
            if (newOp.ContactLastName__c != oldOp.ContactLastName__c) {
                Contact con = lastNameToContact.get(newOp.ContactLastName__c);
                newOp.Contact__c = con.Id;
            }
        }
    }

    private Set<String> getAccountNames(List<Opportunity> opps) {
        Set<String> accountNames = new Set<String>();
        for (Opportunity opp : opps) {
            if (String.isNotBlank(opp.AccountName__c)) {
                accountNames.add(opp.AccountName__c);
            }
        }
        return accountNames;
    }

    private Set<String> getContactLastNames(List<Opportunity> opps) {
        Set<String> contactLastNames = new Set<String>();
        for (Opportunity opp : opps) {
            if (String.isNotBlank(opp.ContactLastName__c)) {
                contactLastNames.add(opp.ContactLastName__c);
            }
        }
        return contactLastNames;
    }
}