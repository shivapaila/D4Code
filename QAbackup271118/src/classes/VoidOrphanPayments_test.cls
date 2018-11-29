/**************************************************************************************************
* Name       : VoidOrphanPayments_test
* Purpose    : Test class for VoidOrphanPayments
***************************************************************************************************
* Author            | Version    | Created Date    | Description
***************************************************************************************************
*Sridhar            | 1.0        | 3/8/2018        | Initial Draft
*Sridhar            | 1.1        | 3/14/2018       | Final Draft
**************************************************************************************************/
@isTest
public class VoidOrphanPayments_test {

	@testSetup
    public static void initsetup(){
		
        // Create custom setting
        TestDataFactory.prepareAPICustomSetting();
    }
    
    @isTest
    public static void positivePath(){
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
        opp.stageName ='Closed Won';
        opp.accountId = acc.Id;
        opp.closeDate = Date.newInstance(System.now().year(), System.now().month(), System.now().day())+7;
        opp.name = 'Test Opportunity Name';
        insert opp;

        Shopping_cart_line_item__c lineItem = new Shopping_cart_line_item__c();
        lineItem.Product_SKU__c = 'M80421';
        lineItem.Discount__c=0;
        lineItem.DiscountType__c = 'Percent';
        lineItem.Flat_Discounted_Amount__c = 0;
        lineItem.List_Price__c = 284;
        lineItem.Average_Cost__c = 146.49;
        lineItem.Quantity__c = 2;
        lineItem.Opportunity__c = opp.Id;
        lineItem.Delivery_Mode__c ='HD';
        lineItem.Discount_Status__c = 'Not Applicable';
        lineItem.Estimated_Tax__c = 39.76;
        lineItem.Extended_Price__c = 568;
        lineItem.ItemType__c = 0;

        insert lineItem;

        Address__c add = new Address__c();
        add.AccountId__c = acc.Id;
        add.Address_Line_1__c = '55 Trinity Avenue';
        add.City__c = 'Atlanta';
        add.State__c = 'GA';
        add.Country__c = 'US';
        add.Zip_Code__c = '30303';
        insert add;

        List<Cart_Payment_Transaction__c> lstinputCart = new List<Cart_Payment_Transaction__c>();
        for(Integer i=0; i<25;i++){
            Cart_Payment_Transaction__c payment = new Cart_Payment_Transaction__c();
            payment.Transaction_Number__c = 'EFB-PAY-19HHVG';
            payment.Payment_Type__c = 'Cash';
            payment.Payment_Amount__c = 568;
            payment.Opportunity__c = opp.Id;
            lstinputCart.add(payment);
		}
        insert lstinputCart;

        Test.setMock(HttpCalloutMock.class, new Mock());
        Test.startTest();
        VoidOrphanPayments VoidOrphanPayment = new VoidOrphanPayments(lstinputCart.get(0).id);
        Database.BatchableContext     bc;
        System.runAs(new User(Id=UserInfo.getUserId())){
            VoidOrphanPayment.start(bc);
            VoidOrphanPayment.execute(bc,lstinputCart);
            VoidOrphanPayment.finish(bc);
        }
        Test.stopTest();
        List<Cart_Payment_Transaction__c> lstCart = [SELECT Id, isVoid__c FROM Cart_Payment_Transaction__c WHERE Transaction_Number__c != null AND Opportunity__r.StageName != 'Closed Won' AND OrderNumber__c = null];
        for(Cart_Payment_Transaction__c cart_payment : lstCart){
            System.assertEquals(true, cart_payment.isVoid__c);
        }
	}

    @isTest
    public static void negativePath(){
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
        opp.stageName ='Closed Won';
        opp.accountId = acc.Id;
        opp.closeDate = Date.newInstance(System.now().year(), System.now().month(), System.now().day())+7;
        opp.name = 'Test Opportunity Name';
        insert opp;

        Shopping_cart_line_item__c lineItem = new Shopping_cart_line_item__c();
        lineItem.Product_SKU__c = 'M80421';
        lineItem.Discount__c=0;
        lineItem.DiscountType__c = 'Percent';
        lineItem.Flat_Discounted_Amount__c = 0;
        lineItem.List_Price__c = 284;
        lineItem.Average_Cost__c = 146.49;
        lineItem.Quantity__c = 2;
        lineItem.Opportunity__c = opp.Id;
        lineItem.Delivery_Mode__c ='HD';
        lineItem.Discount_Status__c = 'Not Applicable';
        lineItem.Estimated_Tax__c = 39.76;
        lineItem.Extended_Price__c = 568;
        lineItem.ItemType__c = 0;

        insert lineItem;

        Address__c add = new Address__c();
        add.AccountId__c = acc.Id;
        add.Address_Line_1__c = '55 Trinity Avenue';
        add.City__c = 'Atlanta';
        add.State__c = 'GA';
        add.Country__c = 'US';
        add.Zip_Code__c = '30303';
        insert add;

        List<Cart_Payment_Transaction__c> lstinputCart = new List<Cart_Payment_Transaction__c>();
        for(Integer i=0; i<25;i++){
            Cart_Payment_Transaction__c payment = new Cart_Payment_Transaction__c();
            payment.Transaction_Number__c = 'EFB-PAY-19HHVG';
            payment.Payment_Type__c = 'Cash';
            payment.Payment_Amount__c = 568;
            payment.Opportunity__c = opp.Id;
            lstinputCart.add(payment);
		}
        insert lstinputCart;

        Test.setMock(HttpCalloutMock.class, new NonMock());
        Test.startTest();
        VoidOrphanPayments VoidOrphanPayment = new VoidOrphanPayments(lstinputCart.get(0).id);
        Database.BatchableContext     bc;
        System.runAs(new User(Id=UserInfo.getUserId())){
            VoidOrphanPayment.start(bc);
            VoidOrphanPayment.execute(bc,lstinputCart);
            VoidOrphanPayment.finish(bc);
        }
        Test.stopTest();
        List<Cart_Payment_Transaction__c> lstCart = [SELECT Id, isVoid__c FROM Cart_Payment_Transaction__c WHERE Transaction_Number__c != null AND Opportunity__r.StageName != 'Closed Won' AND OrderNumber__c = null];
        for(Cart_Payment_Transaction__c cart_payment : lstCart){
            System.assertNotEquals(true, cart_payment.isVoid__c);
        }
	}
    
	private class Mock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{  "voidId": null,  "authorizationId": "EFB-PAY-G2ZYJEP",  "amount": 100,  "currencyCode": null,  "providerTransactionCode": "55094966",  "providerResultCode": "0000"}');
            res.setStatusCode(200);         
            res.setStatus('OK');
            return res;
        }
    }
    
    private class NonMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{ }');
            res.setStatusCode(404);         
            res.setStatus('Not Found');
            return res;
        }
    }
}