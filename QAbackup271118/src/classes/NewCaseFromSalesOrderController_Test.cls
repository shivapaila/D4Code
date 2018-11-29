@isTest
private class NewCaseFromSalesOrderController_Test {
	
	@isTest 
	static void test_method_one() {
		// create a person account
		List<Account> accounts = TestDataFactory.initializePersonAccounts(1);
		insert accounts;

		//mock sales order
		List<SalesOrder__x> orders = TestDataFactory.initializeSalesOrders(1);
		orders[0].phhGuestID__c = accounts[0].Id;
		SalesOrderDAO.mockedSalesOrders.add(orders[0]);

		//call controller method
		Schema.DescribeSObjectResult describeResult = SalesOrder__x.SobjectType.getDescribe();
		string salesOrderIdPrefix = describeResult.getKeyPrefix();
		string smapleSalesOrderId = salesOrderIdPrefix + '2F0000004eetAAA';

		NewCaseFromSalesOrderController.NewCaseInfo response = NewCaseFromSalesOrderController.getOrderData(smapleSalesOrderId);
		System.assert(response.isSuccess);
		System.assert(response.accountId == accounts[0].Id);
		System.assert(response.orderExternalId == orders[0].ExternalId);
	}
	
}