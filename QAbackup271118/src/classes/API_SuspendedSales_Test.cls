@isTest
public class API_SuspendedSales_Test{
	final static String NAME = 'API_SuspendedSales_Test';
	@TestSetup
	static void setup(){
		// Create custom setting
        TestDataFactory.prepareAPICustomSetting();
        
		Account acct = createCustomer();
		Opportunity opp = new Opportunity(AccountId = acct.Id,Name=NAME,StageName='Saved Shopping Cart',CloseDate=System.today().addDays(10));
		insert opp;
		Shopping_cart_line_item__c item = new Shopping_cart_line_item__c(Opportunity__c=opp.Id, Product_SKU__c='Test',Quantity__c=1);
		insert item;
	}

	@isTest
	static void test_sendData(){
		String responseString = '{"CartId" : "1919"}';
		Account acct = [SELECT Id FROM Account WHERE LastName=:NAME];
		API_SuspendedSales.AddressWrapper billingAddress = createAddress();
		Test.startTest();
		Test.setMock(HttpCalloutMock.class,new MockCallout(200,'OK',responseString,new Map<String, String>()));
		API_SuspendedSales.ResponseWrapper res = API_SuspendedSales.sendData(acct.Id, billingAddress);
		Test.stopTest();
		List<ErrorLog__c> logs = [SELECT ApexClass__c, Method__c, Message__c FROM ErrorLog__c];
		for(ErrorLog__c log : logs){
			System.debug(log.ApexClass__c + ', ' + log.Method__c + ', ' + log.Message__c);
		}
	}

	@isTest
	static void test_sendDataWithAddressString(){
		String responseString = '{"CartId" : "1919"}';
		Account acct = [SELECT Id FROM Account WHERE LastName=:NAME];
		API_SuspendedSales.AddressWrapper billingAddress = createAddress();
		Test.startTest();
		Test.setMock(HttpCalloutMock.class,new MockCallout(200,'OK',responseString,new Map<String, String>()));
		API_SuspendedSales.ResponseWrapper res = API_SuspendedSales.sendDataWithAddressString(acct.Id, '200 Test Street, Dublin, CA 94568','1234567890');
		Test.stopTest();
		List<ErrorLog__c> logs = [SELECT ApexClass__c, Method__c, Message__c FROM ErrorLog__c];
		for(ErrorLog__c log : logs){
			System.debug(log.ApexClass__c + ', ' + log.Method__c + ', ' + log.Message__c);
		}
	}

	@isTest
	static void test_splitAddress(){
		API_SuspendedSales.AddressWrapper addrWrapper = API_SuspendedSales.splitAddress('200 Test Street, Dublin, CA 94568');
		API_SuspendedSales.AddressWrapper addrWrapper2 = API_SuspendedSales.splitAddress('200 Test Street, address2, Dublin, CA 94568');
		System.assertEquals('200 Test Street', addrWrapper.Address1);
		System.assertEquals('200 Test Street', addrWrapper2.Address1);
		System.assertEquals('Dublin', addrWrapper.City);
		System.assertEquals('Dublin', addrWrapper2.City);
		System.assertEquals('CA', addrWrapper.State);
		System.assertEquals('CA', addrWrapper2.State);
		System.assertEquals('94568', addrWrapper.ZipCode);
		System.assertEquals('94568', addrWrapper2.ZipCode);
	}

	public static Account createCustomer() {
        Account acct =new Account();
        acct.FirstName='Test';
        acct.LastName=NAME;
        Id rtypeId=[Select id From RecordType Where DeveloperName='Customer' AND SobjectType='Account'].id;
        acct.RecordTypeId=rtypeId;
        acct.Phone='8080909090';
        insert acct;
        return acct;        
    }

    public static API_SuspendedSales.AddressWrapper createAddress(){
    	API_SuspendedSales.AddressWrapper addr = new API_SuspendedSales.AddressWrapper();
    	addr.Address1 = 'Test Street';
    	addr.City = 'Test';
    	addr.State = 'CA';
    	return addr;
    }
}