trigger OpportunityTrigger on Opportunity (before insert, after insert, before update, after update, after delete) {
    OpportunityTriggerHandler handler = new OpportunityTriggerHandler();

    if (Trigger.isAfter && Trigger.isInsert){
        handler.OnAfterInsert(Trigger.new);
    }

    if (Trigger.isBefore && Trigger.isUpdate){
<<<<<<< HEAD
        handler.OnBeforeUpdate(Trigger.old, Trigger.new);
=======
        handler.updateOpportunityDetails(Trigger.new);
        handler.updateOpportunityAccountAndContact(Trigger.old, Trigger.new);
>>>>>>> parent of aad946d (add email sending to trigger handler)
    }
}