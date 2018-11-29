/******Description: Test methods for SalesOrderResponseWrapper class*/
@isTest
public class SalesOrderResponseWrapper_Test {
    @testSetup 
    static void setup() {
        TestDataFactory.prepareAPICustomSetting();
    }
    
    @isTest
    static void testSalesOrderResponseWrapper(){
        Test.startTest();
        SalesOrderResponseWrapper sorw = new SalesOrderResponseWrapper();
        List<SalesOrderResultWrapper> lstSorw = new List<SalesOrderResultWrapper>();
        sorw.salesOrderResult = lstSorw;
        sorw.customerId = 'testStr';
        sorw.eReceiptBlobStorageUri = 'testStr';
        Test.stopTest();
    }
    
}