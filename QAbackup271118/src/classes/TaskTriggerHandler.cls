/* This is a handler class for EventTrigger that will be called when Events are Creataed/Modified in the system.*/
public with sharing class TaskTriggerHandler {
	/* Method populates the Account__c lookup on Task Object when a Task is created with the Realted to 
	 * Object if the Task is related to an Account.
	 */
	public static void handleBeforeInsert(List<Task> newTasks){
		for(Task t: newTasks){
			if(t.WhatId != null && t.WhatId.getSobjectType() == Account.SobjectType){
				t.Account__c = t.whatId;
			}
          
		}
	}

	/* Method populates the Account__c lookup on Task Object when a Task's Relataed to is updated provided  
	 * the Task is related to an Account.
	 */
	public static void handleBeforeUpdate(Map<Id, Task> newMap, Map<Id, Task> oldMap){
		for(Task t: newMap.values()){
			Task oldVersion = oldMap.get(t.Id);
			if(t.whatId != null && t.whatId.getSobjectType() == Account.SobjectType && t.whatId != oldVersion.whatId){
				t.Account__c = t.whatId;
			}
		}
	}
}