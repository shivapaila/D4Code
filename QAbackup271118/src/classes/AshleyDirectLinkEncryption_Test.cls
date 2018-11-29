@isTest
public class   AshleyDirectLinkEncryption_Test
{
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
        
        //Creating Case
        List<Case> testCase = TestDataFactory.initializeCases(testAccount[0].Id,testContact[0].Id,1);  
        insert testCase;
        //Now associating Sales Order
        testCase[0].Sales_Order__c = testContact[0].Id+':009048870576:133:300493250:8888300-164';
        update testCase;  
        
        Case_Line_Item__c cli = new Case_Line_Item__c();
            cli.Sales_Order_Number__c = testCase[0].Sales_Order__c;
            cli.Case__c = testCase[0].Id;
            cli.Item_SKU__c = '*DELIV-TAX';
            cli.Fulfiller_ID__c = '8888300-164';
            cli.Address_1__c = '1 California St';
            cli.Address_2__c = 'STE 100';
            cli.City__c = 'San Francisco';
            cli.State__c = 'CA';
            cli.Zip__c = '94104';
            
        insert cli;   
        
        //Calling the Controller Method
        //SalesOrder__x result = Case_SalesOrderDetails_Controller.getDetails(testCase[0].Id);
        
        ApexPages.standardController scon = new ApexPages.standardController(cli);  
        AshleyDirectLinkEncryption adE = new AshleyDirectLinkEncryption(scon);
        
        adE.cliId = cli.Id;
        adE.objCLI = cli;
        
        //adE.MY_KEY = 'abcdefghijabcdef'; 
        //adE.MY_IV = '1234567890123456'; 
        
        Encrypt_Data__c settings = Encrypt_Data__c.getOrgDefaults();
        settings.crypto__c = 'VkYp3s6v8yB2E4H5asdgd5yhA23N2HzJ7r5hp21ht92';
        settings.cryptoIV__c = 'Ii7oSjjWuhp6J6/hj/wmivqx1h3N2HzJ2ByJOy1n89E=';
        settings.AlgorthemType__c = 'AES256';
        upsert settings Encrypt_Data__c.Id;
        adE.openAD();
    }    
}