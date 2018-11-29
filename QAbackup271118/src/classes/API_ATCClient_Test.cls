@isTest
private class API_ATCClient_Test {
	
	@isTest 
	static void testATCCalloutSuccess() {
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
         // Create custom setting
        TestDataFactory.prepareAPICustomSetting();
	/*
		Integration_Settings__c sandboxSetting = new Integration_Settings__c(Name = API_ATCClient.INTEGRATION_SETTING_KEY_SANDBOX, API_Key__c = 'test key');
		Integration_Settings__c productionSetting = new Integration_Settings__c(Name = API_ATCClient.INTEGRATION_SETTING_KEY_PRODUCTION, API_Key__c = 'test key');
		insert new List<Integration_Settings__c>{sandboxSetting, productionSetting};
*/
		Test.startTest();

		Test.setMock(HttpCalloutMock.class, new MockCallout(200, 'OK', sampleResponse,new Map<String, String>()));	

		API_ATCClient.ATCPayload payLoad = new API_ATCClient.ATCPayload ();
		payLoad.city = 'Dallas';
		payLoad.country = 'US';
		payLoad.deliveryMode = 'Home';
		payLoad.postalCode = '75252';
		payLoad.region = 'TX';
		payLoad.products.add(new API_ATCClient.ProductWrapper('test sku', 1));

		API_ATCClient.ATCResponseWrapper response = API_ATCClient.getAvailableDeliveryWindows('1234', '1234', Date.Today(), Date.Today().addDays(30), payLoad);

		Test.stopTest();
		
		
		System.assert(response.isSuccess);
		System.assert(response.deliveryWindows.size() == 5);
	}
	@isTest 
	static void testATCCalloutFailure() {
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
         // Create custom setting
        TestDataFactory.prepareAPICustomSetting();
	/*
		Integration_Settings__c sandboxSetting = new Integration_Settings__c(Name = API_ATCClient.INTEGRATION_SETTING_KEY_SANDBOX, API_Key__c = 'test key');
		Integration_Settings__c productionSetting = new Integration_Settings__c(Name = API_ATCClient.INTEGRATION_SETTING_KEY_PRODUCTION, API_Key__c = 'test key');
		insert new List<Integration_Settings__c>{sandboxSetting, productionSetting};
*/
		Test.startTest();

		Test.setMock(HttpCalloutMock.class, new MockCallout(500, 'internal server error', sampleResponse,new Map<String, String>()));	

		API_ATCClient.ATCPayload payLoad = new API_ATCClient.ATCPayload ();
		payLoad.city = 'Dallas';
		payLoad.country = 'US';
		payLoad.deliveryMode = 'Home';
		payLoad.postalCode = '75252';
		payLoad.region = 'TX';
		payLoad.products.add(new API_ATCClient.ProductWrapper('test sku', 1));

		API_ATCClient.ATCResponseWrapper response = API_ATCClient.getAvailableDeliveryWindows('1234', '1234', Date.Today(), Date.Today().addDays(30), payLoad);

		Test.stopTest();
		
		
		System.assert(response.isSuccess == false);
		
	}
}