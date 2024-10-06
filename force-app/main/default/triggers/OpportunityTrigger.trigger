trigger OpportunityTrigger on Opportunity (before insert, after insert, before update, after update, after delete, before delete) {
    OpportunityTriggerHandler handler = new OpportunityTriggerHandler();

    if (Trigger.isInsert){
        if (Trigger.isAfter){
            handler.OnAfterInsert(Trigger.new);
        }
        else if (Trigger.isBefore){
            handler.OnBeforeInsert(Trigger.new);
        }
    } else if (Trigger.isUpdate){
        if (Trigger.isBefore){
            handler.OnBeforeUpdate(Trigger.old, Trigger.new, Trigger.oldMap);

        }
    } else if (Trigger.isDelete){
        if (Trigger.isBefore){
            handler.OnBeforeDelete(Trigger.old);
        }
    }

}