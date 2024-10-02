trigger OpportunityTrigger on Opportunity (before insert, after insert, before update, after update, after delete) {
    OpportunityTriggerHandler handler = new OpportunityTriggerHandler();

    if (Trigger.isAfter && Trigger.isInsert){
        handler.insertAccountAndContact(Trigger.new);
    }

    if (Trigger.isBefore && Trigger.isUpdate){
        handler.updateOpportunityDetails(Trigger.new);
        handler.updateOpportunityAccountAndContact(Trigger.old, Trigger.new);
    }

    if (Trigger.isDelete && Trigger.isAfter){
        handler.sendEmailAfterDelete(Trigger.old);
    }
}