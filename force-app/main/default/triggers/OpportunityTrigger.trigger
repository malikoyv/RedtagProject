trigger OpportunityTrigger on Opportunity (before insert, after insert, before update, after update, after delete) {
    OpportunityTriggerHandler handler = new OpportunityTriggerHandler();

    if (Trigger.isAfter && Trigger.isInsert){
        handler.insertAccountAndContact();
    }

    if (Trigger.isBefore && Trigger.isUpdate){
        handler.updateOpportunityDetails();
        handler.updateOpportunityAccountAndContact();
    }
}