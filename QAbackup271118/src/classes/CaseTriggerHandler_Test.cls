@isTest
private class CaseTriggerHandler_Test {
	
	@isTest 
	static void testCaseCreation() {
		//create test person account		
		List<Account> testPersonAccounts = TestDataFactory.initializePersonAccounts(1);
		insert testPersonAccounts;
		Id personContactId = [Select PersonContactId from Account where Id =:testPersonAccounts[0].Id].PersonContactId;

        Id serviceRequestRecordTypeId = Utilities_SalesAndService.getRecordTypeId(Case.SobjectType, CaseTriggerHandler.CASE_RECORD_TYPE_SERVICE_REQUEST_DEVELOPER_NAME);
		List<Case> testCases = TestDataFactory.initializeCases(testPersonAccounts[0].Id, personContactId, 200);
		for(Case c: testCases){
			c.RecordTypeId = serviceRequestRecordTypeId;
		}
		Test.startTest();
			insert testCases;
		Test.stopTest();

		//assert counters are updated
		System.assert([Select Strike__c from Case limit 1].Strike__c == 1, 'Strike Count should have been incremented');
		System.assert([Select Strike_Counter__pc from Account limit 1].Strike_Counter__pc == 200, 'Strike Count should have been incremented as a result of all the cases created');

	}

	@isTest 
	static void testCaseUpdate() {
		//create test person account		
		List<Account> testPersonAccounts = TestDataFactory.initializePersonAccounts(1);
		insert testPersonAccounts;
		Id personContactId = [Select PersonContactId from Account where Id =:testPersonAccounts[0].Id].PersonContactId;

        Id serviceRequestRecordTypeId = Utilities_SalesAndService.getRecordTypeId(Case.SobjectType, CaseTriggerHandler.CASE_RECORD_TYPE_SERVICE_REQUEST_DEVELOPER_NAME);
		List<Case> testCases = TestDataFactory.initializeCases(testPersonAccounts[0].Id, personContactId, 200);
		for(Case c: testCases){
			c.RecordTypeId = serviceRequestRecordTypeId;
		}
		insert testCases;

		//update case with another sub type 
		Test.startTest();
			for(Case c: testCases){
				c.Sub_Type__c = null;
			}
			update testCases;

			for(Case c: testCases){
				c.Sub_Type__c = CaseTriggerHandler.CASE_SUB_TYPE_DAMAGE;
			}
			update testCases;
		Test.stopTest();

		//assert counters are updated
		System.assert([Select Strike__c from Case limit 1].Strike__c == 2, 'Strike Count should have been incremented');
		System.assert([Select Strike_Counter__c from Contact limit 1].Strike_Counter__c == 400, 'Strike Count should have been incremented');

	}
	@isTest 
	static void testSalesOrderUpdateOnCaseInsert() {
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
                                                      fulfillerID__c = '8888000-570');
		SalesOrderDAO.mockedSalesOrders.add(sampleOrder);

        Id serviceRequestRecordTypeId = Utilities_SalesAndService.getRecordTypeId(Case.SobjectType, CaseTriggerHandler.CASE_RECORD_TYPE_SERVICE_REQUEST_DEVELOPER_NAME);
		List<Case> testCases = TestDataFactory.initializeCases(testPersonAccounts[0].Id, personContactId, 50);
		for(Case c: testCases){
			c.RecordTypeId = serviceRequestRecordTypeId;
			c.Sales_Order__c = smapleSalesOrderId;
		}
		//set the first case with temp sales order field populated (this happens when a case is creted from an Order screen)
		testCases[0].Temp_Sales_Order__c = 'test000000000000000000000';

		Test.startTest();
		insert testCases;
		Test.stopTest();

		for(Case savedCopy : [Select Sales_Order__c from Case where Id in: testCases]){
			System.assert(savedCopy.Sales_Order__c == 'test000000000000000000000', 'External id of the sales order should have been populated');
		}
	}	
}