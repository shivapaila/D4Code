@IsTest
public class API_ATCClientUpdateDeliveryDate_Test {
@IsTest 
	 static void testATCCalloutSuccess() {
         API_ATCClientUpdateDeliveryDate.DeliveryWindow dewi = new API_ATCClientUpdateDeliveryDate.DeliveryWindow();
         String sampleResponse = '[{"DeliverDate": "Sunday, November 25, 2018","DeliverDateTime": "2018-11-25T00:00:00","ResourceGroup": "","ResourceGroupType": "Deliver","AllowableOverage": "2%","Capacity": 0,"AllowbalePromisedCapacity": 0,"Promised": 3,"PromisedActual": "0%","PromisedAllowable": "0%","Confirmed": 0,"ConfirmedActual": "0%","BackColor": "DarkGray","ServiceLevel": "Premium Delivery"}]';
		
		/*	sampleResponse += '{';
			sampleResponse += '"DeliverDateTime": "' + dewi.DeliverDateTime + '",';
			sampleResponse += '"Capacity": "' + dewi.Capacity + '",';
			sampleResponse += '"AllowbalePromisedCapacity": ' + dewi.AllowbalePromisedCapacity + '",';
            sampleResponse += '"BackColor"' + dewi.BackColor;
			sampleResponse += '}';
			
		        
		sampleResponse += ']';*/
         // Create custom setting
        TestDataFactory.prepareAPICustomSetting();
	/*
		Integration_Settings__c sandboxSetting = new Integration_Settings__c(Name = API_ATCClient.INTEGRATION_SETTING_KEY_SANDBOX, API_Key__c = 'test key');
		Integration_Settings__c productionSetting = new Integration_Settings__c(Name = API_ATCClient.INTEGRATION_SETTING_KEY_PRODUCTION, API_Key__c = 'test key');
		insert new List<Integration_Settings__c>{sandboxSetting, productionSetting};
*/
		Test.startTest();

		Test.setMock(HttpCalloutMock.class, new MockCallout(200, 'OK', sampleResponse,new Map<String, String>()));	

		API_ATCClientUpdateDeliveryDate.ATCPayload payLoad = new API_ATCClientUpdateDeliveryDate.ATCPayload ();
		payLoad.city = 'Dallas';
		payLoad.country = 'US';
		payLoad.deliveryMode = 'Home';
		payLoad.postalCode = '75252';
		payLoad.region = 'TX';
		payLoad.products.add(new API_ATCClientUpdateDeliveryDate.ProductWrapper('test sku', 1));

		API_ATCClientUpdateDeliveryDate.ATCResponseWrapper response = API_ATCClientUpdateDeliveryDate.getAvailableDeliveryWindows('1234', '1234', Date.Today(), Date.Today().addDays(30), payLoad,'200453330', 23, '2049-12-01');
			
         API_ATCClientUpdateDeliveryDate.DeliveryWindow dw = new API_ATCClientUpdateDeliveryDate.DeliveryWindow();
		 dw.DeliverDate = 'Sunday, November 25, 2018'; 
		 dw.DeliverDateTime = '2018-11-25T00:00:00';
         dw.ResourceGroup = '';
         dw.ResourceGroupType = 'Deliver';
         dw.AllowableOverage = '2%';
         dw.Capacity = 0;
         dw.AllowbalePromisedCapacity = 0;
         dw.Promised = 3;
         dw.PromisedActual = '0%';
         dw.PromisedAllowable = '0%';
         dw.Confirmed = 0;
         dw.ConfirmedActual = '0%';
         dw.BackColor = 'DarkGrey';
         dw.ServiceLevel = 'Premium Delivery';
         date sd = dw.getStartDate();
         sd = Date.valueof(dw.DeliverDateTime.left(10));
         
         Test.stopTest();
		
		
		System.assert(response.isSuccess);
		//System.assert(response.deliveryWindows.size() == 5);
	}
	@IsTest 
	 static void testATCCalloutFailure() {
          API_ATCClientUpdateDeliveryDate.DeliveryWindow dewil = new API_ATCClientUpdateDeliveryDate.DeliveryWindow();
         String sampleResponse = '[{"DeliverDate": "Sunday, November 25, 2018","DeliverDateTime": "2018-11-25T00:00:00","ResourceGroup": "","ResourceGroupType": "Deliver","AllowableOverage": "2%","Capacity": 0,"AllowbalePromisedCapacity": 0,"Promised": 3,"PromisedActual": "0%","PromisedAllowable": "0%","Confirmed": 0,"ConfirmedActual": "0%","BackColor": "DarkGray","ServiceLevel": "Premium Delivery"}]';
		
		/*String sampleResponse = '{"deliveryWindows": [';
		for(Integer i=0; i < 5; i++){
			sampleResponse += '{';
			sampleResponse += '"start": "' + API_ATCClientUpdateDeliveryDate.formatDateToISO8601(Date.today().addDays(i)) + '",';
			sampleResponse += '"end": "' + API_ATCClientUpdateDeliveryDate.formatDateToISO8601(Date.today().addDays(i)) + '",';
			sampleResponse += '"sortIndex": ' + String.valueOf(i);
			sampleResponse += '}';
			if(i != 4){
				sampleResponse += ',';
			}
		}        
		sampleResponse += ']}';*/
         // Create custom setting
        TestDataFactory.prepareAPICustomSetting();
	/*
		Integration_Settings__c sandboxSetting = new Integration_Settings__c(Name = API_ATCClient.INTEGRATION_SETTING_KEY_SANDBOX, API_Key__c = 'test key');
		Integration_Settings__c productionSetting = new Integration_Settings__c(Name = API_ATCClient.INTEGRATION_SETTING_KEY_PRODUCTION, API_Key__c = 'test key');
		insert new List<Integration_Settings__c>{sandboxSetting, productionSetting};
*/
		Test.startTest();

		Test.setMock(HttpCalloutMock.class, new MockCallout(500, 'internal server error', sampleResponse,new Map<String, String>()));	

		API_ATCClientUpdateDeliveryDate.ATCPayload payLoad = new API_ATCClientUpdateDeliveryDate.ATCPayload ();
		payLoad.city = 'Dallas';
		payLoad.country = 'US';
		payLoad.deliveryMode = 'Home';
		payLoad.postalCode = '75252';
		payLoad.region = 'TX';
		payLoad.products.add(new API_ATCClientUpdateDeliveryDate.ProductWrapper('test sku', 1));

		API_ATCClientUpdateDeliveryDate.ATCResponseWrapper response = API_ATCClientUpdateDeliveryDate.getAvailableDeliveryWindows('1234', '1234', Date.Today(), Date.Today().addDays(30), payLoad, '200453330', 23, '2049-12-01');
			
         for(object dewi : response.deliveryWindows){
             API_ATCClientUpdateDeliveryDate.DeliveryWindow dw = new API_ATCClientUpdateDeliveryDate.DeliveryWindow();
         
         dw.DeliverDate = 'Sunday, November 25, 2018'; 
		 dw.DeliverDateTime = '2018-11-25T00:00:00';
         dw.ResourceGroup = '';
         dw.ResourceGroupType = 'Deliver';
         dw.AllowableOverage = '2%';
         dw.Capacity = 0;
         dw.AllowbalePromisedCapacity = 0;
         dw.Promised = 3;
         dw.PromisedActual = '0%';
         dw.PromisedAllowable = '0%';
         dw.Confirmed = 0;
         dw.ConfirmedActual = '0%';
         dw.BackColor = 'DarkGrey';
         dw.ServiceLevel = 'Premium Delivery';
         date sd = dw.getStartDate();
         sd = Date.valueof(dw.DeliverDateTime.left(10));
         
         }
		Test.stopTest();System.assert(response.isSuccess == false);
		
	}
}