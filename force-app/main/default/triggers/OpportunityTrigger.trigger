trigger OpportunityTrigger on Opportunity (before insert, after insert, before update, after update, after delete) {
    OpportunityTriggerHandler handler = new OpportunityTriggerHandler();

    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            handler.OnBeforeInsert(Trigger.new);
        } else if (Trigger.isUpdate) {
            handler.OnBeforeUpdate(Trigger.old, Trigger.new, Trigger.oldMap);
        }
    } else if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            handler.OnAfterInsert(Trigger.new);
        } else if (Trigger.isDelete) {
            handler.OnAfterDelete(Trigger.old);
        }
    }
}