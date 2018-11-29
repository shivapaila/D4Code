/* *******************************************************************************************************************
* Class Name   : PaymentControllerTest
* Description  : A test class for the Lightning Apex Controller PaymentController
*				
* Author       : Sriram (Perficient, Inc.)
* Created On   : 06/03/2018
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer                                   Date                   Modification ID      Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* 
**************************************************************************************************************************************/
@isTest
private class PaymentControllerTest
{
	@testSetup
	private static void setup(){

	 	TestDataFactory.prepareAPICustomSetting();
	}

	@isTest
	public static void testGetPaymentMethods(){
		User rsaUser = TestDataFactory.createRSAUser();
		insert rsaUser;
		System.runAs(rsaUser) {
			Account account = createAccount();
			Opportunity opportunity = prepareShoppingCart(account);
			createPaymentTransaction(opportunity);			
			Test.startTest();
			Test.setMock(HttpCalloutMock.class, new PaymentTerminalMock());		
			Map<String, List<PaymentMethodWrapper>> result = PaymentController.getPaymentMethods(account.Id);
			Test.stopTest();
			System.assertEquals(true, result.containsKey(PaymentController.CC_PMT_TYPE), ' Expecting payment type ' + PaymentController.CC_PMT_TYPE);
			System.assertEquals('127.67.89.100', result.get(PaymentController.CC_PMT_TYPE).get(0).paymentTerminals.get(0), ' Expecting payment terminal ' + '127.67.89.100');			
		}
	}
    
    @isTest
    public static void testClearOpptyFields(){
        User rsaUser = TestDataFactory.createRSAUser();
        insert rsaUser;
        System.runAs(rsaUser) {
            Account account = createAccount();
            Opportunity opportunity = prepareShoppingCart(account);
            createPaymentTransaction(opportunity);          
            Test.startTest();
            PaymentController.clearOpptyFields(account.Id);
            Test.stopTest();
            Opportunity opp = [SELECT Id, StageName FROM Opportunity WHERE Id=:opportunity.Id];
            System.assertEquals('Saved Shopping Cart', opp.StageName, ' Expecting opportunity stage name ' + 'Saved Shopping Cart');
        }
    } 

    @isTest
    public static void testPaymentTerminalWrapper(){
        PaymentTerminalWrapper ptw = new PaymentTerminalWrapper();
        ptw.VerifoneIP = '127';
        ptw.WorkstationIP = '128';
        ptw.ReceiptPrinter = 'test';
        ptw.UsingOPOS = 'true';  
        System.assertEquals(true, ptw!=null);              
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

    public class PaymentTerminalMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"VerifoneIP": "127.67.89.100", "WorkstationIP": "127.67.89.100", "ReceiptPrinter": "printer-1234", "UsingOPOS": "b073b150-e8fe-480b-aadb-4e0e7dc2a20a"}');
            res.setStatusCode(200);
            res.setStatus('OK');
            return res;
        }
    }	
}