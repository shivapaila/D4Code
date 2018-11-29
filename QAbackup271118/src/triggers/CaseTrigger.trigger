trigger CaseTrigger on Case (before insert, after insert, before update, after update) {
	if(trigger.isBefore && trigger.isInsert){
		CaseTriggerHandler.handleBeforeInsert(Trigger.new);
	}
	else if(trigger.isAfter && trigger.isInsert){
		CaseTriggerHandler.handleAfterInsert(Trigger.newMap);
	}
	else if(trigger.isBefore && trigger.isUpdate){
		CaseTriggerHandler.handleBeforeUpdate(Trigger.newMap, Trigger.oldMap);
	}
	else if(trigger.isAfter && trigger.isUpdate){
		CaseTriggerHandler.handleAfterUpdate(Trigger.newMap, Trigger.oldMap);
	}
}