/**************************************************************************************************
* Name       : PaymentTypeHelper_Test
* Purpose    : Test class for PaymentTypeHelper
***************************************************************************************************
* Author            | Version    | Created Date    | Description
***************************************************************************************************
*Sridhar            | 1.0        | 3/2/2018       | Initial Draft
**************************************************************************************************/
@isTest
public class PaymentTypeHelper_Test {

	@testSetup
	public static void initsetup(){

		TestDataFactory.prepareAPICustomSetting();
	}

	@isTest
	public static void PositiveWay(){
		Test.setMock(HttpCalloutMock.class, new Mock(true));
		Test.startTest();
		Map<String, Payment_Type__c> pMap = PaymentTypeHelper.getPaymentTypeMapping();
        PaymentTypeHelper.maintainPaymentTypeMapping();
        PaymentTypeHelper.updatePaymentTypeFromAPI();
		Test.stopTest();
        System.assert(pMap !=null);
	}
    
    @isTest
	public static void NegativeWay(){
		Test.setMock(HttpCalloutMock.class, new Mock(false));
		Test.startTest();
		Map<String, Payment_Type__c> pMap = PaymentTypeHelper.getPaymentTypeMapping();
		Test.stopTest();
        System.assert(pMap !=null);
	}

    private class Mock implements HttpCalloutMock {
		boolean isValid;
		public Mock(boolean isValid){
			this.isValid = isValid;
		}
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json');
            if (req.getEndpoint().startsWith('https://ashley-preprod-dev.apigee.net') && isValid) {
                res.setBody('[{"TenderCodeDescription":"Desc","TenderCode":"code","DocumentNumber":"1"}]');
                res.setStatusCode(200);
            } else {
                res.setBody('{"salesOrderResult":[{"SalesOrderNumber":0,"DeliveryViaCode":"HD","SalesOrderReferenceId":"b073b150-e8fe-480b-aadb-4e0e7dc2a20a"}],"customerId":"4046433752A"}');
                res.setStatusCode(201);
            }
            res.setStatus('OK');
            return res;
        }
    }

}