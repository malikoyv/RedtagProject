trigger Trigger_OppAccountAndContactCreated on Opportunity (after insert) {
    List<Account> accountsToAdd = new List<Account>();
    List<Contact> contactsToAdd = new List<Contact>();
    Map<Id, Account> oppAccountMap = new Map<Id, Account>();
    Map<Id, Contact> oppContactMap = new Map<Id, Contact>();
    List<Opportunity> oppToUpdate = new List<Opportunity>();

    for (Opportunity op : Trigger.new) {
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

    for (Opportunity op : Trigger.new) {
        Opportunity opp = new Opportunity(Id = op.Id);
        if (oppAccountMap.containsKey(op.Id)) {
            opp.AccountId = oppAccountMap.get(op.Id).Id;
        }
        if (oppContactMap.containsKey(op.Id)){
            opp.Contact__c = oppContactMap.get(op.Id).Id;
        }
        oppToUpdate.add(opp);
    }

    if (!oppToUpdate.isEmpty()) {
        update oppToUpdate;
    }
}