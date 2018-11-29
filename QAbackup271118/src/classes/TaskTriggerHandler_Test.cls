@isTest
private class TaskTriggerHandler_Test {
	
	@isTest 
	static void testTaskCreation() {
		//create test person account
		List<Account> testAccounLIst = TestDataFactory.initializePersonAccounts(1);
		insert testAccounLIst;

		//create a task
		List<Task> testTasks = TestDataFactory.initializeTasks(testAccounLIst[0].Id, null, 200);
		insert testTasks;

		//make sure account id is copied to Task custom Account Lookup
		testTasks = [Select Account__c from Task where Id in: testTasks];
		for(Task t: testTasks){
			System.assert(t.Account__c == testAccounLIst[0].Id);
		}
	}	
	@isTest 
	static void testTaskUpdate() {
		//create test person account
		List<Account> testAccounLIst = TestDataFactory.initializePersonAccounts(2);
		insert testAccounLIst;

		//create a task
		List<Task> testTasks = TestDataFactory.initializeTasks(testAccounLIst[0].Id, null, 200);
		insert testTasks;

		//update tasks to a new Account
		for(Task t: testTasks){
			t.WhatId = testAccounLIst[1].Id;
		}
		update testTasks;

		//make sure account id is copied to Task custom Account Lookup
		testTasks = [Select Account__c from Task where Id in: testTasks];
		for(Task t: testTasks){
			System.assert(t.Account__c == testAccounLIst[1].Id);
		}
	}
}