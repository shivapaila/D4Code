trigger EventTrigger on Event (before insert, before update) {
	if(trigger.isBefore && trigger.isInsert){
		EventTriggerHandler.handleBeforeInsert(Trigger.new);
	}	
	else if(trigger.isBefore && trigger.isUpdate){
		EventTriggerHandler.handleBeforeUpdate(Trigger.newMap, Trigger.oldMap);
	}
}