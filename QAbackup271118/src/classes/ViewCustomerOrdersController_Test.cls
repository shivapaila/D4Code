/****** v1 | Description: Test methods for view customer orders controller class | 12/28/2017 | L OMeara */
@isTest
public class ViewCustomerOrdersController_Test {
    @testSetup 
    static void setup() {
        TestDataFactory.prepareAPICustomSetting();
        
    }
    // NOTE this and ManageRelatedNotesController_Test.cls need to move to test utility
    static final String ACCOUNT_TYPE_CUSTOMER = 'Customer';
    static final Id AccountTypeCustomer = Schema.SObjectType.Account.getRecordTypeInfosByName().get(ACCOUNT_TYPE_CUSTOMER).getRecordTypeId();
    
    /* test query for customer order list */
    @isTest
    static void testGetCustomerOrderHistory() {
        Account account = new Account(
            RecordtypeId = AccountTypeCustomer,
            FirstName = 'TestCoverage',
            LastName = 'CoveragePerson',
            PersonEmail = 'tc@example.com',
            Phone = '615-555-1212',
            Primary_Language__pc = 'English'
        );
        insert account;

        List<SalesOrder__x> result = ViewCustomerOrdersController.getCustomerOrderHistory(account.id);
        System.assert(result.size() == 0);
    }
    /* test query for order details */
    @isTest
    static void testGetOrder() {
        Schema.DescribeSObjectResult describeResult = SalesOrder__x.SobjectType.getDescribe();
        string salesOrderIdPrefix = describeResult.getKeyPrefix();
        string testSalesOrderId = salesOrderIdPrefix + '2F0000004eetAAA';
        List<SalesOrderItem__x> result = ViewCustomerOrdersController.getOrder(testSalesOrderId);
        System.assert(result.size() == 0);
    }  
    
    @isTest
    static void testgetProductDetail(){
        String fetchType = 'other';
        String productSkuId = 'W669-88';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new ProductDetailCallOutMock(fetchType));
        
        ProductWrapper pw = ViewCustomerOrdersController.getProductDetail(productSkuId);
        System.assertEquals('W669-88 Title name', pw.productTitle);
        
        Test.stopTest();
    }
}