@isTest
private class API_UpdateStrikeCounter_Test {
	@testSetup
	static void setUpData(){
		List<Account> testPersonAccounts = TestDataFactory.initializePersonAccounts(5);
		for(Integer i=0; i < testPersonAccounts.size();i++){
			testPersonAccounts[i].Strike_Counter__pc = i + 1;
		}
		insert testPersonAccounts;
	}
	@isTest 
	static void testStrikeCountUpdate() {
		//add test contacts to list
		List<Account> testAccounts = [Select Id, Strike_Counter__pc from Account];		
		List<Id> testAccountIds = new List<Id>();
		for(Account a: testAccounts){
			testAccountIds.add(a.Id);

		}

		//add invalid contact id to list
		testAccountIds.add('001000000000000000');

		Test.startTest();
		List<API_BaseResponse> response = API_UpdateStrikeCounter.doPatch(testAccountIds);
		Test.stopTest();

		Integer successCount = 0;
		Integer errorCount = 0;
		Integer strikeCounterSum = 0;

		for(API_BaseResponse r: response){
			if(r.isSuccess){
				successCount++;
			}
			else{
				errorCount++;
			}
		}

		System.assert(successCount == 5, 'Should have 5 successful responses');
		System.assert(errorCount == 1, 'Should have 1 error response');

		//check if strike counter is just updated by one
		testAccounts = [Select Id, Strike_Counter__pc from Account];
		for(Account a: testAccounts){
			strikeCounterSum += Integer.valueOf(a.Strike_Counter__pc);
		}
		System.assert(strikeCounterSum == 20, 'Strike counter was not incremented by one in one or more of the contacts');
	}
	
}