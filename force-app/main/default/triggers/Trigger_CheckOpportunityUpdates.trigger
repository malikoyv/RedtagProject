trigger Trigger_CheckOpportunityUpdates on Opportunity (after update) {
    List<Account> accountsToUpsert = new List<Account>();
    List<Contact> contactsToUpsert = new List<Contact>();
    List<Opportunity> oppsToUpdate = new List<Opportunity>();

    Map<Id, Account> existingAccounts = new Map<Id, Account>([SELECT Id, Name FROM Account WHERE Id IN (SELECT AccountId FROM Opportunity WHERE Id IN :Trigger.newMap.keySet())]);
    Map<Id, Contact> existingContacts = new Map<Id, Contact>([SELECT Id, LastName FROM Contact WHERE Id IN (SELECT Contact__c FROM Opportunity WHERE Id IN :Trigger.newMap.keySet())]);

    for (Opportunity newOpp : Trigger.new) {
        Opportunity oldOpp = Trigger.oldMap.get(newOpp.Id);
        Boolean updateOpportunity = false;

        if (newOpp.AccountName__c != oldOpp.AccountName__c) {
            Account existingAccount = existingAccounts.get(newOpp.AccountId);
            if (existingAccount != null && (existingAccount.Name.contains(newOpp.AccountName__c) || newOpp.AccountName__c.contains(existingAccount.Name))) {
                existingAccount.Name = newOpp.AccountName__c;
                accountsToUpsert.add(existingAccount);
            } else {
                Account newAccount = new Account(Name = newOpp.AccountName__c);
                accountsToUpsert.add(newAccount);
                newOpp.AccountId = null;
                updateOpportunity = true;
            }
        }

        if (newOpp.ContactLastName__c != oldOpp.ContactLastName__c) {
            Contact existingContact = existingContacts.get(newOpp.Contact__c);
            if (existingContact != null && (existingContact.LastName.contains(newOpp.ContactLastName__c) || newOpp.ContactLastName__c.contains(existingContact.LastName))) {
                existingContact.LastName = newOpp.ContactLastName__c;
                contactsToUpsert.add(existingContact);
            } else {
                Contact newContact = new Contact(LastName = newOpp.ContactLastName__c);
                contactsToUpsert.add(newContact);
                newOpp.Contact__c = null;
                updateOpportunity = true;
            }
        }

        if (updateOpportunity) {
            oppsToUpdate.add(newOpp);
        }
    }

    if (!accountsToUpsert.isEmpty()) {
        upsert accountsToUpsert;
    }
    if (!contactsToUpsert.isEmpty()) {
        upsert contactsToUpsert;
    }

    for (Opportunity opp : oppsToUpdate) {
        if (opp.AccountId == null) {
            for (Account acc : accountsToUpsert) {
                if (acc.Name == opp.AccountName__c) {
                    opp.AccountId = acc.Id;
                    break;
                }
            }
        }
        if (opp.Contact__c == null) {
            for (Contact con : contactsToUpsert) {
                if (con.LastName == opp.ContactLastName__c) {
                    opp.Contact__c = con.Id;
                    break;
                }
            }
        }
    }

    if (!oppsToUpdate.isEmpty()) {
        update oppsToUpdate;
    }
}