/****** v1 | Description: Test methods for customer controller class | 12/1/2017 | L OMeara */
/****** v2 | Update: updated for person accounts | 2/1/2018 | L OMeara */
@isTest
public class AddCustomerController_Test {
    /* test create customer with exception - no information provided, will produce database exception */
    @isTest
    static void testCreateCustomerRecordsException() {
        Account testCustomer = new Account();
        Address__c testShipping = new Address__c();
        try {
            Id retVal = AddCustomerController.createCustomerRecords(
                testCustomer, testShipping, null, '');
        } catch (AuraHandledException e) {
            system.debug('got exception ' + e);
		}
    }
    
    /* test create customer with proper inputs */
    @isTest
    static void testCreateCustomerRecordsGoodInputs() {
        Account testCustomer = new Account(
            FirstName ='TestCoverage',
            LastName = 'CoveragePerson', 
            PersonEmail = 'tc@example.com', 
            Phone = '615-555-1212', 
            Primary_Language__pc = 'English'
		);
        Address__c testShipping = new Address__c(
            Address_Line_1__c = '123 Test Coverage St', 
			City__c = 'Franklin', 
			State__c = 'TN'
        );
        Address__c testBilling = new Address__c(
            Address_Line_1__c = '123 Other Test Coverage St', 
			City__c = 'Franklin', 
			State__c = 'TN'
        );
        Id retVal = AddCustomerController.createCustomerRecords(
            testCustomer, testShipping, testBilling, 
            '{"title": "test note", "body": "test body"}'
        );
        testCustomer.id=retVal;
        testCustomer.FirstName = 'New Name';
        retVal = AddCustomerController.updateCustomerRecords(
            testCustomer, '{"title": "new test note", "body": "new test body"}'
        );
        Account checkCustomer = [SELECT id,firstname FROM Account WHERE ID=:retVal];
    }
    
    /* test create several customers from a list */
    @isTest
    static void testCreateAllCustomers() {
        List<CustomerWrapper> customers = new List<CustomerWrapper>();
        for (Integer i = 0; i < 10; i++) {
            CustomerWrapper test = new CustomerWrapper();
            test.globalID = 'gid'+i;
            test.firstName = 'first'+i;
            test.lastName = 'last'+i; 
            test.email = 'test1'+i+'@example.com';
            test.email2 ='test2'+i+'@example.com'; 
            test.phone ='615-555-121'+i;
            test.phone2 = '615-555-123'+i;
            test.phone3 = '615-555-432'+i;
            test.primaryLanguage = 'English';
            test.taxExempt = false;
            test.seeManagement = false;
            test.twitterId = 'test'+i;
            test.instagramId = 'test'+i;
            test.facebookId = 'test'+i;
            test.snapchatId = 'test'+i;
            test.youTubeId = 'test'+i;
            test.pinterestId = 'test'+i;
            test.addressLine1 = i+' BillTest St';
            test.addressLine2 = 'Apt C'+i;
            test.city = 'Franklin';
            test.state = 'TN'; 
            test.zip = '37067';

        	customers.add(test);
        }
        List<CustomerResponseWrapper.CustomerIdStruct> createdCustIds = AddCustomerController.createAllCustomerRecords(customers);
    }    
    
    /* test update several customers from a list */
    @isTest
    static void testUpdateAllCustomers() {
        List<CustomerWrapper> customers = new List<CustomerWrapper>();
        for (Integer i = 0; i < 10; i++) {
            CustomerWrapper test = new CustomerWrapper();
            test.globalID = 'gid'+i;
            test.firstName = 'first'+i;
            test.lastName = 'last'+i; 
            test.email = 'test1'+i+'@example.com';
            test.email2 ='test2'+i+'@example.com'; 
            test.phone ='615-555-121'+i;
            test.phone2 = '615-555-123'+i;
            test.phone3 = '615-555-432'+i;
            test.primaryLanguage = 'English';
            test.taxExempt = false;
            test.seeManagement = false;
            test.twitterId = 'test'+i;
            test.instagramId = 'test'+i;
            test.facebookId = 'test'+i;
            test.snapchatId = 'test'+i;
            test.youTubeId = 'test'+i;
            test.pinterestId = 'test'+i;
            test.addressLine1 = i+' BillTest St';
            test.addressLine2 = 'Apt C'+i;
            test.city = 'Franklin';
            test.state = 'TN'; 
            test.zip = '37067';

        	customers.add(test);
        }
        List<CustomerResponseWrapper.CustomerIdStruct> createdCustIds = AddCustomerController.createAllCustomerRecords(customers);
       
        Integer j= 0;
        for (CustomerWrapper upCust : customers) {
            upCust.customerID = createdCustIds[j].sfId;
            upCust.addressLine1 = j+ ' Updated Bill St';
            upCust.firstName = 'updated first ' + j;
            j++;
        }

        List<CustomerResponseWrapper.CustomerIdStruct> updatedCustIds = AddCustomerController.updateAllCustomerRecords(customers);
    }        
    
    // FIXME - the code in MyCustomerController needs to be updated for person accounts and this test should pass
    /*
    @isTest
    public static void addToCartTest(){
        Account acc=AddCustomerController_Test.createCustomers();
        String prod='{"primaryImageId":"10116150M","productTitle":"Tempur Flex Supreme Queen Mattress","sku":"10116150M","standardDepth":"80.0000000000000000","standardHeight":"11.7500000000000000","standardWidth":"60.0000000000000000"}';
        String prodPrice='{"ImagePath":"https://www.ashleydirect.com/graphics/AD_Images/na.jpg","ItemDescription":"FLX SUP HY MED QN MATTRESS","ItemSku":"10116150M","NailedDamagedQty":0,"OnHandAvailableQty":0,"OriginalPrice":2699}';
        AddCustomerController.addToCart(acc.Id, prod, prodPrice, 2);
        List<Opportunity> oppLst=[Select id,name,Contact__c 
                                  From Opportunity 
                                  Where AccountId=:acc.Id];
        system.assert(!oppLst.isEmpty());
        if(!oppLst.isEmpty()){
            
            
            List<Shopping_cart_line_item__c > lineItemLst=[Select Id,Name,Opportunity__c,Product_SKU__c,List_Price__c,quantity__c 
                                                           From Shopping_cart_line_item__c 
                                                           where Opportunity__c=:oppLst[0].Id];
            system.assert(!lineItemLst.isEmpty());
            
            
        }
    }
*/
    
    public static Account createCustomers() 
    {
        Account acc =new Account();
        acc.firstname='Test';
        acc.lastname='Person';
        String rtypeId=[Select id From RecordType Where name='Customer'].id;
        acc.RecordTypeId=rtypeId;
        acc.FirstName='Test';
        acc.LastName='Test';
        acc.Phone='9090909090';
        acc.OwnerId=UserInfo.getUserId();
        insert acc;
        return acc;
        
    }
}