public with sharing class OpportunityTriggerHandler {

    public void OnBeforeInsert(List<Opportunity> newOpps) {
        updateOpportunityDetails(newOpps);
    }

    public void OnAfterInsert(List<Opportunity> newOpps) {
        insert insertAccounts(newOpps);
        insert insertContacts(newOpps);
        update updateOpportunityAccountAndContactIds(newOpps);
    }

    public void OnAfterUpdate(List<Opportunity> oldOpps){

    }

    public void OnAfterDelete(List<Opportunity> oldOpps){

    }

    public void OnBeforeUpdate(List<Opportunity> oldOpps, List<Opportunity> newOpps, Map<Id, Opportunity> oldOppMap) {
        updateAccounts(oldOpps, newOpps, oldOppMap);
        updateContacts(oldOpps, newOpps, oldOppMap);
    }

    public void OnBeforeDelete(List<Opportunity> deletedOpps) {
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

    private List<Account> insertAccounts(List<Opportunity> newOppList) {
        List<Account> accountsToAdd = new List<Account>();
        for (Opportunity opp : newOppList) {
            accountsToAdd.add(new Account(Name = opp.AccountName__c));
        }
        return accountsToAdd;
    }

    private List<Contact> insertContacts(List<Opportunity> newOppList) {
        List<Contact> contactsToAdd = new List<Contact>();
        for (Opportunity opp : newOppList) {
            contactsToAdd.add(new Contact(LastName = opp.ContactLastName__c));
        }
        return contactsToAdd;
    }

    private List<Opportunity> updateOpportunityAccountAndContactIds(List<Opportunity> newOppList) {
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

        return oppsToUpdate;
    }

    public void updateAccounts(List<Opportunity> oldOpps, List<Opportunity> newOpps, Map<Id, Opportunity> oldOppMap) {
        Map<String, Account> accountNameToAccount = new Map<String, Account>();
        Set<Id> existingAccountIds = new Set<Id>();
        List<Account> accountsToUpsert = new List<Account>();
    
        for (Opportunity newOpp : newOpps) {
            Opportunity oldOpp = oldOppMap.get(newOpp.Id);
            if (newOpp.AccountName__c != oldOpp.AccountName__c) {
                if (!accountNameToAccount.containsKey(newOpp.AccountName__c)) {
                    Account acc;
                    if (newOpp.AccountName__c.contains(oldOpp.AccountName__c) || oldOpp.AccountName__c.contains(newOpp.AccountName__c)) {
                        acc = new Account(Id = newOpp.AccountId, Name = newOpp.AccountName__c);
                        existingAccountIds.add(newOpp.AccountId);
                    } else {
                        acc = new Account(Name = newOpp.AccountName__c);
                    }
                    accountNameToAccount.put(newOpp.AccountName__c, acc);
                    accountsToUpsert.add(acc);
                }
            }
        }
    
        if (!accountsToUpsert.isEmpty()) {
            upsert accountsToUpsert;
        }
    
        for (Opportunity newOpp : newOpps) {
            Opportunity oldOpp = oldOppMap.get(newOpp.Id);
            if (newOpp.AccountName__c != oldOpp.AccountName__c) {
                Account acc = accountNameToAccount.get(newOpp.AccountName__c);
                newOpp.AccountId = acc.Id;
            }
        }
    }

    private void updateContacts(List<Opportunity> oldOpps, List<Opportunity> newOpps, Map<Id, Opportunity> oldOppMap) {
        Map<String, Contact> lastNameToContact = new Map<String, Contact>();
        Set<Id> existingContactIds = new Set<Id>();
        List<Contact> contactsToUpsert = new List<Contact>();
    
        for (Opportunity newOpp : newOpps) {
            Opportunity oldOpp = oldOppMap.get(newOpp.Id);
            if (newOpp.ContactLastName__c != oldOpp.ContactLastName__c) {
                if (!lastNameToContact.containsKey(newOpp.ContactLastName__c)) {
                    Contact con;
                    if (newOpp.ContactLastName__c.contains(oldOpp.ContactLastName__c) || oldOpp.ContactLastName__c.contains(newOpp.ContactLastName__c)) {
                        con = new Contact(Id = newOpp.Contact__c, LastName = newOpp.ContactLastName__c);
                        existingContactIds.add(newOpp.Contact__c);
                    } else {
                        con = new Contact(LastName = newOpp.ContactLastName__c);
                    }
                    lastNameToContact.put(newOpp.ContactLastName__c, con);
                    contactsToUpsert.add(con);
                }
            }
        }
    
        if (!contactsToUpsert.isEmpty()) {
            upsert contactsToUpsert;
        }
    
        for (Opportunity newOpp : newOpps) {
            Opportunity oldOpp = oldOppMap.get(newOpp.Id);
            if (newOpp.ContactLastName__c != oldOpp.ContactLastName__c) {
                Contact con = lastNameToContact.get(newOpp.ContactLastName__c);
                newOpp.Contact__c = con.Id;
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