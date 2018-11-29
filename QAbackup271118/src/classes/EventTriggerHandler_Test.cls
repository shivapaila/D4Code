@isTest
private class EventTriggerHandler_Test {
	@isTest 
	static void testEventCreation() {
		//create test person account
		List<Account> testAccounLIst = TestDataFactory.initializePersonAccounts(1);
		insert testAccounLIst;

		//create an Event
		List<Event> testEvents = TestDataFactory.initializeEvents(testAccounLIst[0].Id, null, 200);
		insert testEvents;

		//make sure account id is copied to Event custom Account Lookup
		testEvents = [Select Account__c from Event where Id in: testEvents];
		for(Event e: testEvents){
			System.assert(e.Account__c == testAccounLIst[0].Id);
		}
	}
	@isTest 
	static void testEventUpdate() {
		//create test person account
		List<Account> testAccounLIst = TestDataFactory.initializePersonAccounts(2);
		insert testAccounLIst;

		//create an Event
		List<Event> testEvents = TestDataFactory.initializeEvents(testAccounLIst[0].Id, null, 200);
		insert testEvents;

		//update event to a new Account
		for(Event e: testEvents){
			e.WhatId = testAccounLIst[1].Id;
		}
		update testEvents;

		//make sure account id is copied to Event custom Account Lookup
		testEvents = [Select Account__c from Event where Id in: testEvents];
		for(Event e: testEvents){
			System.assert(e.Account__c == testAccounLIst[1].Id);
		}
	}	
}