/* *******************************************************************************************************************
* Class Name   : ConciergeServiceControllerTest
* Description  : A test class for the Lightning Apex Controller ConciergeServiceController
*				
* Author       : Sriram (Perficient, Inc.)
* Created On   : 07/21/2018
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer                                   Date                   Modification ID      Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* 
**************************************************************************************************************************************/
@isTest
private class ConciergeServiceControllerTest {

	@testSetup 
	static void setup() {
  		TestDataFactory.prepareAPICustomSetting();
	}

	@isTest
	static void testGetRSAAccountInfo()	{
        StoreInfoMock fakeResponse = new StoreInfoMock(200, 'Complete',
                                                       '{"oneSourceID":"14444","LocationID":"2667","OneSourceName":"Alpharetta, GA","LocationName":"Alpharetta, GA","LegacyStoreID":"133","ProfitCenter":"34","AccountNo":"8888300","Shipto":"298","ZIP":"30022","RDCNUM":"164","FulfillerID":"8888300-164"}',
                                                       null);
		Test.setMock(HttpCalloutMock.class, fakeResponse);		
		User rsaUser = TestDataFactory.createRSAUser();
		insert rsaUser;
		System.runAs(rsaUser) {
			RSAAccountInfoWrapper rsaAccountInfo = null;
			Test.startTest();
			rsaAccountInfo = ConciergeServiceController.getRSAAccountInfo();
			Test.stopTest();
			System.assertEquals(true, rsaAccountInfo!=null, 'Expecting the RSA Account Information for the RSA User');
		}
	}

	@isTest
	public static void testIsPaymentStage(){
		User rsaUser = TestDataFactory.createRSAUser();
		insert rsaUser;
		System.runAs(rsaUser) {
			Account account = createAccount();
			Opportunity opportunity = prepareShoppingCart(account);
			PaymentController.setPaymentStageOnOpportunity(account.Id);
			createPaymentTransaction(opportunity);
			Test.startTest();
			System.assertEquals(true, ConciergeServiceController.isPaymentStage(account.Id), 'Expecting the opportunity to be in Payment Stage');
			Test.stopTest();
		}
	}	

    private static Account createAccount(){
        RecordType customerAccRT = [Select Id from recordType where SObjectType='Account' and Name='Customer'];
        Account acc =  new Account();
        acc.FirstName = 'testAccF';
        acc.LastName = 'testAccL';
        acc.RecordTypeId = customerAccRT.Id;
        acc.Phone ='(0)888-998-766';
        insert acc;
        return acc;
    }

    private static Opportunity prepareShoppingCart(Account acc){
        Opportunity opp =  new Opportunity();
        opp.AccountId = acc.Id;
        opp.Name=acc.Name+'-'+system.today().format();
        opp.StageName='Saved Shopping Cart';
        opp.CloseDate=Date.Today().addDays(30);
        
        insert opp;
        
        List<Shopping_cart_line_item__c> lineItems = new  List<Shopping_cart_line_item__c>();
        Shopping_cart_line_item__c line = new Shopping_cart_line_item__c();
        line.Product_SKU__c ='1200014';
        line.Quantity__c =1;
        line.Delivery_Mode__c='HD';
        line.List_Price__c = 288.99;
        line.Average_Cost__c = 188.99;
        line.Opportunity__c = opp.Id;
        lineItems.add(line);
        
        Shopping_cart_line_item__c line2 = new Shopping_cart_line_item__c();
        line2.Product_SKU__c ='M80221';
        line2.Quantity__c =1;
        line2.List_Price__c = 284;
        line.Average_Cost__c = 184.99;
        line2.Opportunity__c = opp.Id;
        lineItems.add(line2);
        
        Shopping_cart_line_item__c line3 = new Shopping_cart_line_item__c();
        line3.Product_SKU__c ='*KSADJPR5YNT';
        line3.Quantity__c =1;
        line3.List_Price__c = 249.99;
        line.Average_Cost__c = 149.99;
        line3.Opportunity__c = opp.Id;
        lineItems.add(line3);
        insert lineItems;
        return opp;
    }

    private static void createPaymentTransaction(Opportunity opportunity){
        Cart_Payment_Transaction__c payment = new Cart_Payment_Transaction__c();
        payment.Transaction_Number__c = 'EFB-PAY-19HHVG';
        payment.Payment_Type__c = 'Cash';
        payment.Payment_Amount__c = 568;
        payment.Opportunity__c = opportunity.Id;
        insert payment;    	
    }    	
}