@isTest
private class API_UpdateSalesOrderClient_Test {
	@testSetup
	static void setupTestData(){
		// Create custom setting
        TestDataFactory.prepareAPICustomSetting();
    }

	@isTest 
	static void testUpdateShippingAddressSuccess() {
		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new MockCallout(200, 'order updated', 'sampleResponse',new Map<String, String>()));	
		API_BaseResponse response = API_UpdateSalesOrderClient.updateShippingAddress('testfullfilledbyid', '00000001', 44, 'Test Customer',
		'123 test street', 'Apt 100', 'Atlanata', 'GA', '30067');
		Test.stopTest();

		System.assert(response.isSuccess);

	}

	@isTest 
	static void testUpdateShippingAddressError() {
		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new MockCallout(400, 'error', 'sampleResponse',new Map<String, String>()));	
		API_BaseResponse response = API_UpdateSalesOrderClient.updateShippingAddress('testfullfilledbyid', '00000001', 44, 'Test Customer',
		'123 test street', 'Apt 100', 'Atlanata', 'GA', '30067');
		Test.stopTest();

		System.assert(response.isSuccess == false);

	}
	
	@isTest 
	static void testUpdateHotStatusSuccess() {
		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new MockCallout(200, 'order updated', 'sampleResponse',new Map<String, String>()));	
		API_BaseResponse response = API_UpdateSalesOrderClient.updateSalesOrderHotStatus('testfullfilledbyid', '00000001',true,'9','10', Date.today(),44);
		Test.stopTest();

		System.assert(response.isSuccess);

	}
    	//public static API_BaseResponse updateSalesOrderHotStatus(string fullfilledById, string orderNumber, boolean hotStatus, Date deliveryDate){
	@isTest 
	static void testUpdateHotStatusError() {
		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new MockCallout(500, 'error', 'sampleResponse',new Map<String, String>()));	
		API_BaseResponse response = API_UpdateSalesOrderClient.updateSalesOrderHotStatus('testfullfilledbyid', '00000001',true,'9','10', Date.today(),44);
		Test.stopTest();

		System.assert(response.isSuccess == false);

	}

	@isTest 
	static void testUpdateDeliveryDateSuccess() {
		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new MockCallout(200, 'order updated', 'sampleResponse',new Map<String, String>()));	
		API_BaseResponse response = API_UpdateSalesOrderClient.updateSalesOrderDeliveryDate('testfullfilledbyid', '00000001',true, 55,  Date.newInstance(2018, 1, 1), 'home x', 'reasoncode');
		Test.stopTest();

		System.assert(response.isSuccess);

	}

	@isTest 
	static void testUpdateDeliveryDateError() {
		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new MockCallout(400, 'error', 'sampleResponse',new Map<String, String>()));	
		API_BaseResponse response = API_UpdateSalesOrderClient.updateSalesOrderDeliveryDate('testfullfilledbyid', '00000001',true, 55,  Date.newInstance(2018, 1, 1), 'home x', 'reasoncode');
		Test.stopTest();

		System.assert(response.isSuccess == false);

	}

/*	@isTest 
	static void testUpdateDeliveryDateWithNullDeliveryDate() {
		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new MockCallout(200, 'order updated', 'sampleResponse',new Map<String, String>()));	
		API_BaseResponse response = API_UpdateSalesOrderClient.updateSalesOrderDeliveryDate('testfullfilledbyid', '00000001',true, 55,  Date.newInstance(2018, 1, 1), 'home x', 'reasoncode');
		Test.stopTest();

		System.assert(response.isSuccess == false);

	}
*/
	@isTest 
	static void testUpdateDeliveryCommentsSuccess() {
		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new MockCallout(200, 'order updated', 'sampleResponse',new Map<String, String>()));	
		API_BaseResponse response = API_UpdateSalesOrderClient.updateSalesOrderDeliveryComments('testfullfilledbyid', 'some comments', 'ordernumber',  Date.newInstance(2018, 1, 1), 'Homex');
		Test.stopTest();

		System.assert(response.isSuccess);

	}
	@isTest 
	static void testUpdateDeliveryCommentError() {
		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new MockCallout(500, 'some error', 'sampleResponse',new Map<String, String>()));	
		API_BaseResponse response = API_UpdateSalesOrderClient.updateSalesOrderDeliveryComments('testfullfilledbyid', 'some comments', 'ordernumber',  Date.newInstance(2018, 1, 1), 'Homex');
		Test.stopTest();

		System.assert(response.isSuccess == false);

	}

	@isTest 
	static void testUpdateOrderCommentsSuccess() {
		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new MockCallout(200, 'order updated', 'sampleResponse',new Map<String, String>()));	
		API_BaseResponse response = API_UpdateSalesOrderClient.updateSalesOrderComments('testfullfilledbyid', 'some order notes', 'ordernumber', 44);
		Test.stopTest();

		System.assert(response.isSuccess);

	}

	@isTest 
	static void testUpdateOrderCommentsError() {
		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new MockCallout(500, 'some errors', 'sampleResponse',new Map<String, String>()));	
		API_BaseResponse response = API_UpdateSalesOrderClient.updateSalesOrderComments('testfullfilledbyid', 'some order notes', 'ordernumber', 44);
		Test.stopTest();

		System.assert(response.isSuccess == false);

	}
    @isTest 
	static void testUpdateVIPLIBStatusSuccess() {
		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new MockCallout(200, 'order updated', 'sampleResponse',new Map<String, String>()));	
		API_BaseResponse response = API_UpdateSalesOrderClient.updateSalesOrderVIPLIBStatus('testfullfilledbyid', 'some order notes', true,true,false,false);
		Test.stopTest();

		System.assert(response.isSuccess);

	}
    @isTest 
	static void testUpdateVIPLIBStatusError() {
		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new MockCallout(500, 'some errors', 'sampleResponse',new Map<String, String>()));	
		API_BaseResponse response = API_UpdateSalesOrderClient.updateSalesOrderVIPLIBStatus('testfullfilledbyid', 'some order notes', true,true,false,false);
		Test.stopTest();

		System.assert(response.isSuccess == false);

	}
}