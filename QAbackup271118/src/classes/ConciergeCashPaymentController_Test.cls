@isTest
public class ConciergeCashPaymentController_Test {
    
    @testsetup
    public static void testCreateOpporutinty(){
        TestDataFactory.prepareAPICustomSetting();
        String recordTypeId  = [select Id from RecordType where (Name='Customer') and (SobjectType='Account')].Id;
        Account acc= new Account(
            RecordTypeID=recordTypeId ,
            FirstName='Test FName',
            LastName='Test LName',
            PersonMailingStreet='teststreet1',
            PersonMailingPostalCode='12345',
            PersonMailingCity='SFO',
            PersonEmail='test@yahoo.com',
            PersonMobilePhone='1234567897',
            Phone ='(404) 643-3751',
            Phone_2__pc ='(404) 643-3752',
            Phone_3__pc ='(404) 643-3753'
        );
        insert acc;
        
        Opportunity opp = new Opportunity();
        opp.stageName ='Saved Shopping Cart';
        opp.accountId = acc.Id;
        opp.closeDate = Date.newInstance(System.now().year(), System.now().month(), System.now().day())+7;
        opp.name = 'Test Opportunity Name';
        insert opp;
    }
    
    @isTest
    static void addpayment_Test_happy(){
        Account acc = [SELECT id FROM Account][0];
        Opportunity oppt = CreateSalesOrderHelper.getOpportunity(acc.Id);
        String payment ='{"Object":"PaymentMethodWrapper","paymentTrans":{"SObjectType":"Cart_Payment_Transaction__c","Payment_Type__c":"Cash","Payment_Amount__c":200}}';
        List<Cart_Payment_Transaction__c> lstCart = new List<Cart_Payment_Transaction__c>();
        Test.setMock(HttpCalloutMock.class, new Mock());
        Test.startTest();
        try{
            ConciergeCashPaymentController.addPayment(acc.Id,payment);
            lstCart = [Select id FROM Cart_Payment_Transaction__c WHERE ReferenceNumber__c =: 'Cash' AND isVoid__c = false];
            system.debug(lstCart);
            System.assertEquals(lstCart.size(),1);
            
            payment ='{"CCexp":"null","paymentTrans":{"Name":"TRNS-324","Transaction_Number__c":"Cash","Payment_Type__c":"Cash","Payment_Amount__c":200,"isVoid__c":false,"ReferenceNumber__c":"Cash","Id":"'+lstCart[0].Id+'"}}';
            ConciergeCashPaymentController.removePayment(acc.Id,payment);
        }catch(Exception e){
            system.debug(e.getStackTraceString());
        }
        Test.stopTest();
        lstCart = [Select id FROM Cart_Payment_Transaction__c WHERE ReferenceNumber__c =: 'Cash' AND isVoid__c = true];
        system.debug(lstCart);
        System.assertEquals(lstCart.size(),1);
    }
    
    public class Mock implements HTTPCalloutMock {
        public Mock() {
        }
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setBody('[{"TermsCode":"CSH","TermsCodeDescription":"CASH","TermsPlanNumber":"          ","ExpirationDays":"0"}]');            
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            res.setStatus('OK');
            return res;
        }
    }
}