# OpportunityTriggerHandler Documentation

## Overview

The `OpportunityTriggerHandler` class is designed to handle trigger events related to Salesforce `Opportunity` objects. It manages the automation of key business processes, such as updating opportunity details, creating related `Account` and `Contact` records, and sending email notifications upon record deletion. The class implements several methods for handling different trigger events (`before insert`, `after insert`, `before update`, `after update`, `before delete`, `after delete`).

This documentation provides a detailed explanation of each method, its purpose, and its functionality, along with associated helper methods.

---

## Class Structure

- **Visibility**: `public with sharing`
- **Purpose**: This class is meant to be used as a handler for Salesforce `Opportunity` trigger events. It ensures that appropriate actions are taken when opportunities are created, updated, or deleted.

---

## Trigger Methods

### OnBeforeInsert
```apex
public void OnBeforeInsert(List<Opportunity> newOpps)
```

**Description**: This method is invoked before new `Opportunity` records are inserted. It calls the `updateOpportunityDetails` helper method to set default values for each opportunity, such as the name format, stage, and close date.

- **Input**: List of new `Opportunity` records (`newOpps`).
- **Operation**: Prepares each opportunity by setting a meaningful name (using the account name and current date), setting the stage to `Prospecting`, and the close date to 90 days from today.

---

### OnAfterInsert
```apex
public void OnAfterInsert(List<Opportunity> newOpps)
```

**Description**: This method is invoked after new `Opportunity` records are inserted. It performs the following tasks:
1. Inserts related `Account` records based on the opportunities.
2. Inserts related `Contact` records based on the opportunities.
3. Updates each opportunity with the corresponding `AccountId` and `ContactId`.

- **Input**: List of new `Opportunity` records (`newOpps`).
- **Operation**: Manages the creation of related objects (`Account` and `Contact`) and associates them with the newly created opportunities.

---

### OnBeforeUpdate
```apex
public void OnBeforeUpdate(List<Opportunity> oldOpps, List<Opportunity> newOpps, Map<Id, Opportunity> oldOppMap)
```

**Description**: This method is invoked before existing `Opportunity` records are updated. It does the following:
1. Calls `updateOpportunityDetails` to update any modified opportunity details.
2. Calls `updateAccounts` and `updateContacts` to ensure that any changes in the related `Account` or `Contact` are correctly reflected.

- **Input**: 
   - List of old `Opportunity` records (`oldOpps`).
   - List of new `Opportunity` records (`newOpps`).
   - Map of old `Opportunity` records (`oldOppMap`).

---

### OnBeforeDelete
```apex
public void OnBeforeDelete(List<Opportunity> deletedOpps)
```

**Description**: This method is triggered before the deletion of `Opportunity` records. It sends an email notification using the `EmailService` class, notifying relevant stakeholders about the deletion.

- **Input**: List of deleted `Opportunity` records (`deletedOpps`).
- **Operation**: Sends an email alert for each deleted opportunity using the `EmailService.sendEmail()` method.

---

## Helper Methods

### updateOpportunityDetails
```apex
private void updateOpportunityDetails(List<Opportunity> newOppList)
```

**Description**: Updates the basic details of each opportunity. If the `AccountName__c` field is populated, the opportunity's name is set to `[AccountName] yyyy-MM-dd`. Otherwise, the name defaults to "No Account yyyy-MM-dd". Additionally, this method sets the opportunity's stage to `Prospecting` and the close date to 90 days from today.

- **Operation**: Customizes opportunity details based on business logic.

---

### insertAccounts
```apex
private List<Account> insertAccounts(List<Opportunity> newOppList)
```

**Description**: This method creates new `Account` records for each opportunity that has an associated `AccountName__c`.

- **Returns**: A list of `Account` records to be inserted.
- **Operation**: Generates a list of new accounts based on the opportunity data.

---

### insertContacts
```apex
private List<Contact> insertContacts(List<Opportunity> newOppList)
```

**Description**: Creates new `Contact` records for each opportunity that has an associated `ContactLastName__c`.

- **Returns**: A list of `Contact` records to be inserted.
- **Operation**: Generates new contacts based on the opportunity data.

---

### updateOpportunityAccountAndContactIds
```apex
private List<Opportunity> updateOpportunityAccountAndContactIds(List<Opportunity> newOppList)
```

**Description**: Updates the `AccountId` and `ContactId` fields of each opportunity after the related accounts and contacts have been inserted. It fetches the `Account` and `Contact` records by name and associates their IDs with the appropriate opportunities.

- **Returns**: A list of `Opportunity` records that need to be updated.

---

### updateAccounts
```apex
public void updateAccounts(List<Opportunity> oldOpps, List<Opportunity> newOpps, Map<Id, Opportunity> oldOppMap)
```

**Description**: Updates or inserts `Account` records when an opportunity’s associated account changes. It uses the opportunity's new and old account names to determine if a new account needs to be created or an existing one updated.

---

### updateContacts
```apex
private void updateContacts(List<Opportunity> oldOpps, List<Opportunity> newOpps, Map<Id, Opportunity> oldOppMap)
```

**Description**: Similar to `updateAccounts`, this method updates or inserts `Contact` records when an opportunity’s associated contact changes.

---

## EmailService Class

### sendEmail
```apex
public static void sendEmail(List<Opportunity> deletedOpps, String templateName)
```

**Description**: This method sends an email notification for each deleted opportunity. It uses the `EmailTemplate` associated with the given `templateName`.

- **Input**: 
  - List of deleted opportunities (`deletedOpps`).
  - Email template name (`templateName`).
- **Operation**: Sends emails using the `Messaging.SingleEmailMessage` class and logs any errors that occur during the process.

---

## Considerations and Limitations

- **Governor Limits**: Be mindful of Salesforce governor limits (DML statements, SOQL queries) during bulk operations.
- **Error Handling**: Ensure proper error handling (e.g., for email sending failures) is in place, especially during the execution of bulk processes.
- **Email Template**: Ensure that the appropriate email templates are set up in the system, as this will impact the email functionality during opportunity deletion.
