/**************************************************************************************************
* Name       : ConciergeTaskNewControllerTest
* Purpose    : Test Class for ConciergeTaskNewController
***************************************************************************************************
* Author            | Version    | Created Date    | Description
***************************************************************************************************
*Perficient         | 1.0        | 2/20/2018      | Initial Draft
**************************************************************************************************/

@isTest
private class ConciergeTaskNewControllerTest 
{
	@isTest
	static void testCreateRecords()
	{
		Test.startTest();
		// positive scenarios
		ConciergeTaskNewController.ResultWrapper response = 
				ConciergeTaskNewController.createEvent(new Event(Subject = 'From Test Class', Type = 'Phone', StartDateTime = System.now(), EndDateTime = System.now().addHours(1)));
		System.assertEquals('200', response.resultCode);
		response = ConciergeTaskNewController.createTask(new Task(Subject = 'From Test Class', Type = 'Phone', ActivityDate = System.Today()));
		System.assertEquals('200', response.resultCode);

		// negative scenarios
		response = ConciergeTaskNewController.createEvent(null);
		System.assertEquals('400', response.resultCode);
		response = ConciergeTaskNewController.createTask(null);
		System.assertEquals('400', response.resultCode);

		Test.stopTest();
	}
	
	@isTest
	static void testGetCustomer(){
	    Test.startTest();
	    List<Account> testAccounts = TestDataFactory.initializeAccounts(1);
        insert testAccounts;
        ConciergeTaskNewController.getCustomer(testAccounts[0].Id);
	    Test.stopTest();
	}
}