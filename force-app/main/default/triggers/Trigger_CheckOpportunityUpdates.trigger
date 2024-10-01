trigger Trigger_CheckOpportunityUpdates on Opportunity (before update) {
    List<Account> accountsToUpdate = new List<Account>();
    List<Account> accountsToInsert = new List<Account>();

    List<Contact> contactsToUpdate = new List<Contact>();
    List<Contact> contactsToInsert = new List<Contact>();

    Map<Id, String> oldContactNamesMap = new Map<Id, String>();
    Map<Id, String> oldAccountNamesMap = new Map<Id, String>();

    if (Trigger.isBefore && Trigger.isUpdate) {
        for (Opportunity oldOp : Trigger.old) {
                oldAccountNamesMap.put(oldOp.AccountId, oldOp.AccountName__c);
                oldContactNamesMap.put(oldOp.ContactId, oldOp.ContactLastName__c);
        }

        for (Opportunity newOp : Trigger.new) {
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