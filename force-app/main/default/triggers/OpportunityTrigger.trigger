trigger OpportunityTrigger on Opportunity (before insert, after insert, before update, after update, after delete) {
    OpportunityTriggerHandler handler = new OpportunityTriggerHandler();

    if (Trigger.isAfter && Trigger.isInsert){
        handler.OnAfterInsert(Trigger.new);
    }

    if (Trigger.isBefore && Trigger.isUpdate){
        handler.OnBeforeUpdate(Trigger.old, Trigger.new);
    }
}