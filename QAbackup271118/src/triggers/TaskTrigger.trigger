trigger TaskTrigger on Task (before insert, before update) {
    if(trigger.isBefore && trigger.isInsert){
        TaskTriggerHandler.handleBeforeInsert(Trigger.new);
    }   
    else if(trigger.isBefore && trigger.isUpdate){
        TaskTriggerHandler.handleBeforeUpdate(Trigger.newMap, Trigger.oldMap);
    }
}