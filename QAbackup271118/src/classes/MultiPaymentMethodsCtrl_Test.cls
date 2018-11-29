/****** v1 | Description: Test methods for multi payment controller class | 2/19/2018 | L OMeara */
@isTest
global class MultiPaymentMethodsCtrl_Test {
    public static final String FINANCE_PMT_TYPE = 'Financing';
    public static final String CC_PMT_TYPE = 'Credit/Debit Card';

    @testSetup
    public static void initsetup(){

        TestDataFactory.prepareAPICustomSetting();

     }    

    /* test add credit card payment */
    @isTest
    static void testAddPayment() {
        /* set up data */
        User user =  ShoppingCartLineItemCmpCtrl_Test.prepareRSAUser('U1');
        System.runAs(user){
            Account acc =  ShoppingCartLineItemCmpCtrl_Test.prepareCustomerInfo();
            Opportunity opp =  ShoppingCartLineItemCmpCtrl_Test.prepareShoppingCart(acc);
            List<Shopping_cart_line_item__c> cartItems = ShoppingCartLineItemCmpCtrl_Test.prepareShoppingCartLineItems(opp);   
            Cart_Payment_Transaction__c cartPayment = new Cart_Payment_Transaction__c(
                Opportunity__c = opp.Id,
                Payment_Amount__c = 100.00,
                Payment_Type__c = CC_PMT_TYPE,
                TenderCode__c = '1234',
                ReferenceNumber__c = '1234',
                Isvoid__c = false
            ); 
            //insert cartPayment;  

            Payment_Type__c paymentType = new Payment_Type__c(
                    TenderCodeDescription__c = 'Desc'
                    , TenderCode__c = '1234'
                    , DocumentNumber__c = '1'
                    , Last_Updated_PaymentTypes_Info__c = System.now()
                );
            insert paymentType;
            
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new Mock());

            PaymentMethodWrapper pmtInfo = new PaymentMethodWrapper();
            pmtInfo.paymentTrans = cartPayment;
            
            PaymentMethodWrapper result = MultiPaymentMethodsCtrl.addPayment(acc.id, JSON.serialize(pmtInfo));
            Test.stopTest();
            pmtInfo.paymentTrans.Payment_Type__c='Check';
            PaymentMethodWrapper resultCheck = MultiPaymentMethodsCtrl.addPayment(acc.id, JSON.serialize(pmtInfo));
            
            try{
                pmtInfo.paymentTrans.Payment_Type__c='Financing';
            	PaymentMethodWrapper resultfinancing = MultiPaymentMethodsCtrl.addPayment(acc.id, JSON.serialize(pmtInfo));
            }catch(Exception e){}
            
        } 
    } 
	
    @isTest
    public static void testupdatepayment(){
        Account acc =  ShoppingCartLineItemCmpCtrl_Test.prepareCustomerInfo();
            Opportunity opp =  ShoppingCartLineItemCmpCtrl_Test.prepareShoppingCart(acc);
            List<Shopping_cart_line_item__c> cartItems = ShoppingCartLineItemCmpCtrl_Test.prepareShoppingCartLineItems(opp);   
            Cart_Payment_Transaction__c cartPayment = new Cart_Payment_Transaction__c(
                Opportunity__c = opp.Id,
                Payment_Amount__c = 500.00,
                Payment_Type__c = CC_PMT_TYPE,
                TenderCode__c = '1234',
                ReferenceNumber__c = '1234',
                Isvoid__c = false
            );
        	insert cartPayment;
			Test.startTest();
			PaymentMethodWrapper pmtInfo = new PaymentMethodWrapper();
            pmtInfo.paymentTrans = cartPayment;
            MultiPaymentMethodsCtrl.updatePayment(JSON.serialize(pmtInfo));
            cartPayment = [SELECT Id, Payment_Amount__c FROM Cart_Payment_Transaction__c];
            System.assertEquals(cartPayment.Payment_Amount__c,500);
            Test.stopTest();
        	try{
                MultiPaymentMethodsCtrl.getPaymentOptions();
            }catch(Exception e){}
    }
    /* test get terms with exception */
    @isTest
    static void testGetPaymentTermsException() {
        string sampleResponse = '[{"Code":"SYNC003",' + 
            '"CardType":"Synchrony",' + 
            '"Description":"6 Months Promotional Financing"}]';       
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockCallout(200, 'OK', sampleResponse,new Map<String, String>()));
        try{
            PaymentMethodWrapper pmtInfo = new PaymentMethodWrapper();
            FinanceTermsWrapper[] terms = MultiPaymentMethodsCtrl.getPaymentTerms(JSON.serialize(pmtInfo));
        }catch(Exception ex){
        }
        Test.stopTest();
    } 

    /* test get terms */
    @isTest
    static void testGetPaymentTerms() {
        Finance_Terms_Info__c  keys = new Finance_Terms_Info__c ();
        keys.Name = FinanceApiHelper.FINANCE_TERMS_INFO_SETTINGS_NAME;
        //FIXME - doesn't work with fake values
        keys.Salt__c  = 'S6xRCXyDw4e65XSN';
        keys.Key__c  = '4r7MemB7fQEHPqve4kjKEUe2hFXfBUn9';
        insert keys;
         
        string sampleResponse = '[{"Code":"SYNC003",' + 
            '"CardType":"Synchrony",' + 
            '"Description":"6 Months Promotional Financing"}]';       
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockCallout(200, 'OK', sampleResponse,new Map<String, String>()));
        PaymentMethodWrapper pmtInfo = new PaymentMethodWrapper();
        pmtInfo.FINnum = '6019193000801125';
        pmtInfo.paymentTrans = new Cart_Payment_Transaction__c(
            Payment_Amount__c = 100.00,
            Payment_Type__c = FINANCE_PMT_TYPE
        );
        
        FinanceTermsWrapper[] terms = MultiPaymentMethodsCtrl.getPaymentTerms(JSON.serialize(pmtInfo));
        Test.stopTest();
    }

    public class Mock implements HttpCalloutMock {

        private String productAPIResponse = '{"authorizationId":"SYF-PAY-1U9Y9",' + 
            '"fundingInstrumentId":"SYF-PLC-NNWK0842G","amount":561.8,' +
            '"currencyCode":"USD","providerTransactionCode":"028652",' + 
            '"providerResultCode":"028652","referenceNumber":"55087007",' +
            '"CartGuid": "1234", "SalesGrandTotal": 1000 }';  

        private String paymentAPIResponse = '[{"TenderCodeDescription":"Desc","TenderCode":"1234","DocumentNumber":"1"}]';

        private String ccPaymentResponse = '[{"TransactionTime":null,"TransactionStatus":null,"TransactionDate":null,"TransactionAmount":100,"TermsCode":null,"SignatureFilePath":null,"SalesOrderNumber":1234,"RequestDate":null,"ReferenceNumber":"1234","ReasonDescription":null,"ReasonCode":null,"IsVoidSale":null,"ExpirationDate":null,"CustomerID":null,"CardType":null,"AuthorizationNumber":null,"AccountNumber":null}]';
        private String ccVoidPaymentResponse = '{"TransactionTime":null,"TransactionDate":null,"TermsCodeDescription":null,"TermsCode":null,"TenderCode":null,"Status":null,"SalesGuid":null,"ReferenceNumber":null,"Receipt":null,"PaymentReceived":null,"FinanceTerms":null,"ExpirationDays":null,"DocumentNumber":null,"CashGroup":null,"AuthorizationNumber":null,"Amount":null,"AccountNumber":null,"AccountLookUpRequestID":null}';


        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json');
            if (req.getEndPoint().contains('cc-sales/1234')){
                res.setBody(ccPaymentResponse);            
            }             
            else if (req.getEndPoint().contains('cc-sales')){
                res.setBody(ccVoidPaymentResponse);            
            } else if (req.getEndPoint().contains('payment-types')){
                res.setBody(paymentAPIResponse);
            } else {
                res.setBody(productAPIResponse);               
            }               
            res.setStatusCode(200);
            res.setStatus('OK');
            return res;
        }
    }
}