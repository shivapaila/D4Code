/* *******************************************************************************************************************
* Class Name   : Case_SalesOrderDetails_Controller_Test
* Description  : Test class for the Controller class Case_SalesOrderDetails_Controller.     
* Author       : Venkat (Perficient, Inc.)
* Created On   : 22/12/2017
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer                                   Date                   Modification ID      Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
*
**************************************************************************************************************************************/

@isTest
public class Case_SalesOrderDetails_Controller_Test{

    @testSetup static void methodName() {
        Integration_Settings__c is = new Integration_Settings__c(Name = 'Cara_Order_Odata_Dev',
                                  End_Point_URL__c = 'http://cara-api-dev-slot-dev.azurewebsites.net/odata/');
        insert is;
     }
    //Case without Associated SalesOrder
    private static testMethod void testCaseWithoutSalesOrder(){
        
        //Creating Account
        TestDataFactory.initializeAccounts(1);
        
        //Creating Account
        List<Account> testAccount = TestDataFactory.initializeAccounts(1);
        insert testAccount;
        
        //Creating Contact
        List<Contact> testContact = TestDataFactory.initializeContacts(testAccount[0].Id,1);
        insert testContact;
        
        //Creating Case
        List<Case> testCase = TestDataFactory.initializeCases(testAccount[0].Id,testContact[0].Id,1);  
        insert testCase;
        
        //Calling the Controller Method
        SalesOrder__x result = Case_SalesOrderDetails_Controller.getDetails(testCase[0].Id);  
        //As it is not associated to SalesOrder the result will be null
        System.assert(result==null);                
    }
    
    //Case with Associated SalesOrder    
    private static testMethod void testCaseWithSalesOrder(){
        //Creating Account
        TestDataFactory.initializeAccounts(1);
        
        //Creating Account
        List<Account> testAccount = TestDataFactory.initializeAccounts(1);
        insert testAccount;
        
        //Creating Contact
        List<Contact> testContact = TestDataFactory.initializeContacts(testAccount[0].Id,1);
        insert testContact;
        
        //Creating Sales Order Object
        String sOMockReq = '{"@odata.context":"http://cara-api-dev-slot-dev.azurewebsites.net/odata/$metadata#SalesOrderHeaders","value":' +
                '[ ' + 
                    '{"phhContactID":"'+testContact[0].Id+'","phhStoreID":133,"phhProfitcenter":24,"phhCustomerID":"009048870576","phhCustomerName":"HANSON, DARRELL","phhSalesOrder":"300493250","phhSalesOrderDate":"2015-12-15T06:00:00Z","phhOrderType":"S","phhOrderSubType":"Enterprise","phhPurchaseDate":"2015-12-15T06:00:00Z","phhItemCount":9,"phhPaymentType":"VM","phhInvoiceNo":"300493250","phhPurchaseValue":2214.00,"phhHighDollarSale":false,"phhBalanceDue":-118.44,"phhDesiredDate":"2015-12-26T06:00:00Z","phhRSA":"079","phhHot":false,"phhDeliveryType":"G16","phhOrderNotes":"please schedule the delivery back to home on Dec 26,2015","phhRescheduledReason":"","phhDeliveryAttempts":0,"phhOrderStatus":"","phhStoreLocation":"ATLANTA","phhBillAddress1":"1314 HORNAGE ROAD","phhBillAddress2":null,"phhBillCity":"BALL GROUND","phhBillState":"GA","phhBillZip":"30107","phhShipAddress1":"1314 HORNAGE ROAD","phhShipAddress2":null,"phhShipCity":"BALL GROUND","phhShipState":"GA","phhShipZip":"30107","npsScore":0,"npsSurveyStatus":"Completed","npsComment1":"Customer at work-unable to answer survey","npsComment2":null,"npsPreventiveAction":"No contact","npsCorrectiveAction":"No contact","phhSaleType":"D","fulfillerID":"8888300-164"},' + 
                    '{"phhContactID":"'+testContact[0].Id+'","phhStoreID":133,"phhProfitcenter":24,"phhCustomerID":"009048870576","phhCustomerName":"HANSON, DARRELL","phhSalesOrder":"300493260","phhSalesOrderDate":"2015-12-22T06:00:00Z","phhOrderType":"S","phhOrderSubType":"Enterprise","phhPurchaseDate":"2015-12-22T06:00:00Z","phhItemCount":3,"phhPaymentType":"VM","phhInvoiceNo":"300493260","phhPurchaseValue":480.00,"phhHighDollarSale":false,"phhBalanceDue":-33.60,"phhDesiredDate":"2015-12-26T06:00:00Z","phhRSA":"079","phhHot":false,"phhDeliveryType":"G15","phhOrderNotes":"please schedule the delivery back to home on Dec 26,2015","phhRescheduledReason":"","phhDeliveryAttempts":0,"phhOrderStatus":"","phhStoreLocation":"ATLANTA","phhBillAddress1":"1314 HORNAGE ROAD","phhBillAddress2":null,"phhBillCity":"BALL GROUND","phhBillState":"GA","phhBillZip":"30107","phhShipAddress1":"1314 HORNAGE ROAD","phhShipAddress2":null,"phhShipCity":"BALL GROUND","phhShipState":"GA","phhShipZip":"30107","npsScore":0,"npsSurveyStatus":"Completed","npsComment1":"Customer at work-unable to answer survey","npsComment2":null,"npsPreventiveAction":"No contact","npsCorrectiveAction":"No contact","phhSaleType":"D","fulfillerID":"8888300-164"}' + 
                  ']' + 
                '}';
        HttpCalloutMockForRESTCallouts soCallOut = new HttpCalloutMockForRESTCallouts(200,'OK',sOMockReq,new Map<String, String>());    
        Test.setMock(HttpCalloutMock.class, soCallOut);     
        
        SalesOrder__x testSalesOrder = TestDataFactory.initializeSalesOrders(1)[0];
        testSalesOrder.phhGuestID__c= testAccount[0].Id;
        system.debug('testSalesOrder -------'+testSalesOrder+'-----'+testSalesOrder.Id);
        
                
        //Creating Case
        List<Case> testCase = TestDataFactory.initializeCases(testAccount[0].Id,testContact[0].Id,1);  
        insert testCase;
        //Now associating Sales Order
        testCase[0].Sales_Order__c = testContact[0].Id+':009048870576:133:300493250:8888300-164';
        //testCase[0].Sales_Order__c = testSalesOrder.Id;
        update testCase;        
        system.debug('testCase----'+testCase);
        //Calling the Controller Method
        SalesOrder__x result = Case_SalesOrderDetails_Controller.getDetails(testCase[0].Id);  
        SalesOrderListfromCase.getSalesOrders(testCase[0].Id);
        SalesOrderListfromCase.updateSalesOrderRecord(testCase[0].Sales_Order__c,testCase[0].Id);
        SalesOrderListfromCase.soWrapper sw = new SalesOrderListfromCase.soWrapper();
        
        sw.Salesorder = '300493250';
        sw.customerId  = '009048870576';
        sw.salesType = 'D';
        sw.DeliveryDate = Date.ValueOf('2015-12-22T06:00:00Z');
        sw.externId = '204258:0012900000GRH2LAAX';
    }    
}