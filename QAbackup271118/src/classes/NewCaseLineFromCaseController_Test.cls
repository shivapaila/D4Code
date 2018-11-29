@isTest
private class NewCaseLineFromCaseController_Test {
	
	@isTest 
	static void test_method_one() {
		//create test person account		
		List<Account> testPersonAccounts = TestDataFactory.initializePersonAccounts(1);
		insert testPersonAccounts;
		Id personContactId = [Select PersonContactId from Account where Id =:testPersonAccounts[0].Id].PersonContactId;

		//get id prefix for sales orders
		Schema.DescribeSObjectResult describeResult = SalesOrder__x.SobjectType.getDescribe();
		string salesOrderIdPrefix = describeResult.getKeyPrefix();
		string smapleSalesOrderId = salesOrderIdPrefix + '2F0000004eetAAA';

		SalesOrder__x sampleOrder = new SalesOrder__x(Id = smapleSalesOrderId, 
                                                      ExternalId = 'test000000000000000000000', 
                                                      phhProfitcenter__c = 3,
                                                      phhStoreLocation__c = 'Shadow Mountain', 
                                                      phhStoreID__c = '943',
                                                      fulfillerID__c = '8888000-570',
                                                      phhSalesOrder__c = '00001');
		SalesOrderDAO.mockedSalesOrders.add(sampleOrder);

        Id serviceRequestRecordTypeId = Utilities_SalesAndService.getRecordTypeId(Case.SobjectType, CaseTriggerHandler.CASE_RECORD_TYPE_SERVICE_REQUEST_DEVELOPER_NAME);
		List<Case> testCases = TestDataFactory.initializeCases(testPersonAccounts[0].Id, personContactId, 1);
		for(Case c: testCases){
			c.RecordTypeId = serviceRequestRecordTypeId;
			c.Sales_Order__c = 'test000000000000000000000';
		}

		Test.startTest();
		insert testCases;
		NewCaseLineFromCaseController.InitializationDataResponse response = NewCaseLineFromCaseController.getInitializationData(testCases[0].Id);
		Test.stopTest();

		System.assert(response.isSuccess);
		System.assert(response.salesOrderNumber == '00001');
	}
	
}