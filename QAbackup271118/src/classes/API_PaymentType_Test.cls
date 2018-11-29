/**************************************************************************************************
* Name       : API_PaymentType_Test
* Purpose    : Test class for API_PaymentType
***************************************************************************************************
* Author            | Version    | Created Date    | Description
***************************************************************************************************
*Sridhar            | 1.0        | 3/2/2018       | Initial Draft
**************************************************************************************************/
@isTest
public class API_PaymentType_Test {

	@testSetup
	public static void initsetup(){
		// Create custom setting
        TestDataFactory.prepareAPICustomSetting();
	}
	@isTest
	public static void PositiveTest(){

		API_PaymentType.PaymentTypeWrapper pWrap = new API_PaymentType.PaymentTypeWrapper();
		API_PaymentType.PaymentTypesWrapper psWrap = new API_PaymentType.PaymentTypesWrapper();

		Test.setMock(HttpCalloutMock.class, new Mock(true));
		Test.startTest();
		List<API_PaymentType.PaymentTypeWrapper> result = API_PaymentType.getAllPaymentTypes();
		System.assert(result !=null);
		Test.stopTest();

	}

	@isTest
	public static void NegativeTest(){

		Test.setMock(HttpCalloutMock.class, new Mock(false));
		Test.startTest();
		List<API_PaymentType.PaymentTypeWrapper> result = API_PaymentType.getAllPaymentTypes();
		System.assert(result ==null);
		Test.stopTest();
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