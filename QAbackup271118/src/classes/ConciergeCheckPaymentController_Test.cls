@isTest
public class ConciergeCheckPaymentController_Test {
    
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
        String payment ='{"Object":"PaymentMethodWrapper","paymentTrans":{"SObjectType":"Cart_Payment_Transaction__c","Payment_Type__c":"Check","TenderCode__c":"AMEX","Check_DocumentNumber__c":123234,"Payment_Amount__c":200},"paymentTerminalSelected":"10.151.19.26"}';
        Test.setMock(HttpCalloutMock.class, new Mock());
        Test.startTest();
        ConciergeCheckPaymentController.addPayment(acc.Id,payment);
        List<Cart_Payment_Transaction__c> lstCart = [Select id FROM Cart_Payment_Transaction__c WHERE ReferenceNumber__c =: 'Check' AND isVoid__c = false];
        System.assertEquals(lstCart.size(),1);
        
        try{
            payment ='{"CCexp":"null","paymentTrans":{"Name":"TRNS-324","Transaction_Number__c":"Check","Payment_Type__c":"Check","Payment_Amount__c":200,"isVoid__c":false,"TenderCode__c":"AMEX","ReferenceNumber__c":"Check","Check_DocumentNumber__c":123234,"Id":"'+lstCart[0].Id+'"}}';
            ConciergeCheckPaymentController.removePayment(acc.Id,payment);
        }catch(Exception e){
            system.debug(e.getStackTraceString());
        }
        Test.stopTest();
        lstCart = [Select id FROM Cart_Payment_Transaction__c WHERE ReferenceNumber__c =: 'Check' AND isVoid__c = true];
        System.assertEquals(lstCart.size(),1);
    }
    
    @isTest
    static void addpayment_Test_sad(){
        Account acc = [SELECT id FROM Account][0];
        Opportunity oppt = CreateSalesOrderHelper.getOpportunity(acc.Id);
        String payment ='{"CCexp":"null","paymentTrans":{"Name":"TRNS-324","Transaction_Number__c":"Check","Payment_Type__c":"Check","Payment_Amount__c":200,"isVoid__c":false,"TenderCode__c":"AMEX","ReferenceNumber__c":"Check","Check_DocumentNumber__c":123234,"Id":"a0d2F00000McbKuQAJ"}}';
        Test.setMock(HttpCalloutMock.class, new Mock());
        Test.startTest();
        try{
            ConciergeCheckPaymentController.addPayment(acc.Id,payment);
            payment ='{"Object":"PaymentMethodWrapper","paymentTrans":{"SObjectType":"Cart_Payment_Transaction__c","Payment_Type__c":"Check","TenderCode__c":"AMEX","Check_DocumentNumber__c":123234,"Payment_Amount__c":200},"paymentTerminalSelected":"10.151.19.26"}';
            ConciergeCheckPaymentController.removePayment(acc.Id,payment);
        }catch(Exception e){
        }
        Test.stopTest();
        List<Cart_Payment_Transaction__c> lstCart = [Select id FROM Cart_Payment_Transaction__c WHERE ReferenceNumber__c =: 'Check' AND isVoid__c = false];
        System.assertEquals(lstCart.size(),0);
        
    }
    
    public class Mock implements HTTPCalloutMock {
        public Mock() {
        }
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setBody('[{"TermsCode":"CK ","TermsCodeDescription":"CHK-Check","TermsPlanNumber":"          ","ExpirationDays":"0"}]');            
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            res.setStatus('OK');
            return res;
        }
    }
}