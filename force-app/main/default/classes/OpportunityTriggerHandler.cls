public with sharing class OpportunityTriggerHandler {

    public void OnBeforeInsert(List<Opportunity> newOpps) {
        List<Opportunity> opportunities = updateOpportunityDetails(newOpps);
    }

    public void OnAfterInsert(List<Opportunity> newOpps) {
        List<Account> accounts = insertAccounts(newOpps);
        List<Contact> contacts =  insertContacts(newOpps);

        insert accounts;
        insert contacts;

        List<Opportunity> opportunities = updateOpportunityAccountAndContactIds(newOpps);
        update opportunities;
    }

    public void OnAfterUpdate(List<Opportunity> oldOpps){

    }

    public void OnAfterDelete(List<Opportunity> oldOpps){

    }

    public void OnBeforeUpdate(List<Opportunity> oldOpps, List<Opportunity> newOpps, Map<Id, Opportunity> oldOppMap) {
        List<Opportunity> opportunities = updateOpportunityDetails(newOpps);
        List<Account> accounts = updateAccounts(oldOpps, newOpps, oldOppMap);
        List<Contact> contacts = updateContacts(oldOpps, newOpps, oldOppMap);
    }

    public void OnBeforeDelete(List<Opportunity> deletedOpps) {
        EmailService.sendEmail(deletedOpps, 'OpportunityDeletion');
    }

    private List<Opportunity> updateOpportunityDetails(List<Opportunity> newOppList) {
        for (Opportunity opp : newOppList) {
            if (opp.AccountName__c != null) {
                opp.Name = opp.AccountName__c + ' ' + Datetime.now().format('yyyy-MM-dd');
            } else {
                opp.Name = 'No Account ' + Datetime.now().format('yyyy-MM-dd');
            }
            
            opp.StageName = 'Prospecting';
            opp.CloseDate = Date.today().addDays(90);
        }

        return newOppList;
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

    private List<Opportunity> updateRelatedRecords(
        List<Opportunity> newOpps,
        Map<Id, Opportunity> oldOppMap,
        Map<String, SObject> relatedRecordMap,
        String relatedRecordFieldName,
        String relatedNameField
    ) {
        for (Opportunity newOpp : newOpps) {
            Opportunity oldOpp = oldOppMap.get(newOpp.Id);
            if (newOpp.get(relatedNameField) != oldOpp.get(relatedNameField)) {
                SObject relatedRecord = relatedRecordMap.get((String) newOpp.get(relatedNameField));
                newOpp.put(relatedRecordFieldName, relatedRecord.get('Id'));
            }
        }

        return newOpps;
    }

    public List<Account> updateAccounts(List<Opportunity> oldOpps, List<Opportunity> newOpps, Map<Id, Opportunity> oldOppMap) {
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

        updateRelatedRecords(newOpps, oldOppMap, accountNameToAccount, 'AccountId', 'AccountName__c');

        return accountsToUpsert;
    }

    private List<Contact> updateContacts(List<Opportunity> oldOpps, List<Opportunity> newOpps, Map<Id, Opportunity> oldOppMap) {
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

        updateRelatedRecords(newOpps, oldOppMap, lastNameToContact, 'Contact__c', 'ContactLastName__c');

        return contactsToUpsert;
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