/****** v1 | Description: Test methods for financing api controller class | 2/9/2018 | L OMeara */
@isTest
public class FinanceApiHelper_Test {
    /* test a call to process financing without config */
    @isTest
    static void testProcessFinancingNoConfig() {
        try {
	        FinanceApiHelper fh = new FinanceApiHelper(); 
        }catch(Exception ex){
			system.debug('ex is : ' + ex.getMessage());
        }
    }

    /* test a call to process financing without config */
    @isTest
    static void testProcessFinancing() {
        String sampleResponse = '{"authorizationId":"SYF-PAY-1U9Y9","fundingInstrumentId":"SYF-PLC-NNWK0842G","amount":561.8,"currencyCode":"USD","providerTransactionCode":"028652","providerResultCode":"028652","referenceNumber":"55087007"}';
        Integration_Settings__c finSettings = new Integration_Settings__c();
        finSettings.Name = FinanceApiHelper.PAYMENT_API_SETTING_NAME;
        finSettings.End_Point_URL__c = 'https://ashley-preprod-qa.apigee.net/authorizationgateway/authorizations';
        finSettings.API_Key__c = 'apigeeapikey1234';
        insert finSettings;
        
        Test.setMock(HttpCalloutMock.class, new MockCallout(200, 'OK', sampleResponse,new Map<String, String>()));
        FinanceApiHelper fh = new FinanceApiHelper();
        
        // create a payment object
        PaymentMethodWrapper pmt = new PaymentMethodWrapper();
        pmt.paymentTrans = new Cart_Payment_Transaction__c();
        pmt.FINnum = '6019193000801125';
        pmt.FINterms = 'SYNC003';
        pmt.paymentTrans.Payment_Amount__c = 1000.00;
        //pmt.paymentTrans.Opportunity__c  = ;
        pmt.paymentTrans.Payment_Type__c = 'Financing'; 
        
        Test.startTest();
		
        PaymentMethodWrapper result = fh.processFinancing(pmt);

        Test.stopTest();
    }    
}