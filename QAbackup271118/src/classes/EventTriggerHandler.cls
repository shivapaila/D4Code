/* This is a handler class for EventTrigger that will be called when Events are Creataed/Modified in the system.*/
public with sharing class EventTriggerHandler {
	/* Method populates the Account__c lookup on Event Object when an event is created with the Realted to 
	 * Object if the Event is related to an Account.
	 */
	public static void handleBeforeInsert(List<Event> newEvents){
		for(Event e: newEvents){
			if(e.WhatId != null && e.WhatId.getSobjectType() == Account.SobjectType){
				e.Account__c = e.whatId;
			}          
		}
	}

	/* Method populates the Account__c lookup on Event Object when an event's Relataed to is updated provided  
	 * the Event is related to an Account.
	 */
	public static void handleBeforeUpdate(Map<Id, Event> newMap, Map<Id, Event> oldMap){
		for(Event e: newMap.values()){
			Event oldVersion = oldMap.get(e.Id);
			if(e.whatId != null && e.whatId.getSobjectType() == Account.SobjectType && e.whatId != oldVersion.whatId){
				e.Account__c = e.whatId;
			}
		}
	}
}