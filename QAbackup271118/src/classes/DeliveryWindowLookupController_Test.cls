@isTest
private class DeliveryWindowLookupController_Test {
    
    @testSetup
    public static void prepareAPICustomSetting(){
        TestDataFactory.prepareAPICustomSetting();
                
    }
	
	@isTest 
	static void testWithOutAPIMock() {
		//set some test data
		SalesOrder__x testSalesOrder = TestDataFactory.initializeSalesOrders(1)[0];
		SalesOrderItem__x testLineItem = TestDataFactory.initializeSalesOrderLineItems(1)[0];

		SalesOrderDAO.mockedSalesOrders.add(testSalesOrder);
		SalesOrderDAO.mockedSalesOrderLineItems.add(testLineItem);

		DeliveryWindowLookupController.DeliveryCalendarResponse response = DeliveryWindowLookupController.getDeliveryCalendarDays('2017-01-01', 'ord-001', 'ordline-001', '00154', '118');
		System.assert(response.isSuccess == false);
	}

	@isTest 
	static void testWithAPIMockAndAvailableDates() {
		//set some test data
		SalesOrder__x testSalesOrder = TestDataFactory.initializeSalesOrders(1)[0];
		SalesOrderItem__x testLineItem = TestDataFactory.initializeSalesOrderLineItems(1)[0];

		SalesOrderDAO.mockedSalesOrders.add(testSalesOrder);
		SalesOrderDAO.mockedSalesOrderLineItems.add(testLineItem);

		String sampleResponse = '{"deliveryWindows": [';
		for(Integer i=0; i < 5; i++){
			sampleResponse += '{';
			sampleResponse += '"start": "' + API_ATCClient.formatDateToISO8601(Date.today().addDays(i)) + '",';
			sampleResponse += '"end": "' + API_ATCClient.formatDateToISO8601(Date.today().addDays(i)) + '",';
			sampleResponse += '"sortIndex": ' + String.valueOf(i);
			sampleResponse += '}';
			if(i != 4){
				sampleResponse += ',';
			}
		}        
		sampleResponse += ']}';
        
		Test.startTest();

		Test.setMock(HttpCalloutMock.class, new MockCallout(200, 'OK', sampleResponse,new Map<String, String>()));
		DeliveryWindowLookupController.DeliveryCalendarResponse response = DeliveryWindowLookupController.getDeliveryCalendarDays('2017-01-01', 'ord-001', 'ordline-001', '00154', '118');
		Test.stopTest();
		
		System.assert(response.isSuccess == true);
		System.assert(response.calendar != null, 'A calendar should have been returned');
	}	

	@isTest 
	static void testWithAPIMockAndNoAvailableDates() {
		//set some test data
		SalesOrder__x testSalesOrder = TestDataFactory.initializeSalesOrders(1)[0];
		SalesOrderItem__x testLineItem = TestDataFactory.initializeSalesOrderLineItems(1)[0];

		SalesOrderDAO.mockedSalesOrders.add(testSalesOrder);
		SalesOrderDAO.mockedSalesOrderLineItems.add(testLineItem);

		String sampleResponse = '{"deliveryWindows": [';  
		sampleResponse += ']}';

		Test.startTest();

		Test.setMock(HttpCalloutMock.class, new MockCallout(200, 'OK', sampleResponse,new Map<String, String>()));
		DeliveryWindowLookupController.DeliveryCalendarResponse response = DeliveryWindowLookupController.getDeliveryCalendarDays('2017-01-01', 'ord-001', 'ordline-001', '00154', '118');
		Test.stopTest();
		
		System.assert(response.isSuccess == true);
		//System.assert(response.calendar == null);
		System.assert(response.message == 'No Delivery Dates available');
	}
	
    @isTest 
	static void testWithAPIMockAndAvailableDeliveryDates() {
		//set some test data
		SalesOrder__x testSalesOrder = TestDataFactory.initializeSalesOrders(1)[0];
		SalesOrderItem__x testLineItem = TestDataFactory.initializeSalesOrderLineItems(1)[0];

		SalesOrderDAO.mockedSalesOrders.add(testSalesOrder);
		SalesOrderDAO.mockedSalesOrderLineItems.add(testLineItem);

		String sampleResponse = '{"deliveryWindows": [';
		for(Integer i=0; i < 5; i++){
			sampleResponse += '{';
			sampleResponse += '"start": "' + API_ATCClient.formatDateToISO8601(Date.today().addDays(i)) + '",';
			sampleResponse += '"end": "' + API_ATCClient.formatDateToISO8601(Date.today().addDays(i)) + '",';
			sampleResponse += '"sortIndex": ' + String.valueOf(i);
			sampleResponse += '}';
			if(i != 4){
				sampleResponse += ',';
			}
		}        
		sampleResponse += ']}';

		Test.startTest();

        Test.setMock(HttpCalloutMock.class, new MockCallout(200, 'OK', sampleResponse,new Map<String, String>()));
        Account acc =  prepareCustomerInfo();
        Opportunity opp =  TestDataFactory.prepareShoppingCart(acc);
        List<Shopping_cart_line_item__c> lineItems = TestDataFactory.prepareShoppingCartLineItems(opp, true);
        Address__c addr = new Address__c();
        addr.AccountId__c = acc.Id;
        addr.Address_Line_1__c = 'Sample address 1';
        addr.Address_Line_2__c = 'Sample address 2';
        addr.City__c = 'Sample city';
        addr.State__c = 'Sample state';
        addr.Country__c = 'Sample country';
        addr.Zip_Code__c = '123456';
        insert addr;
		DeliveryWindowLookupController.DeliveryCalendarResponse response = DeliveryWindowLookupController.getDeliveryCalendarDays('2017-01-01', null, lineItems[0].Id, '00154', '118',addr.Id);
		Test.stopTest();
		System.assert(response != null);
	}	
    
     public static Account prepareCustomerInfo(){
        
        RecordType customerAccRT = [Select Id from recordType where SObjectType='Account' and Name='Customer'];
        Account acc =  new Account();
        acc.FirstName = 'testAccF';
        acc.LastName = 'testAccL';
        acc.RecordTypeId = customerAccRT.Id;
        acc.Phone ='(0)888-998-766';
        insert acc;
        
        return acc;
    }
    
   
}