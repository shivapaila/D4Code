@isTest
public class TestNewCaseorderassociation {
  @testSetup
     static void setup() {
         
         List<Account> accList = new List<Account>();
         accList = TestDataFactory.initializeAccounts(1);
         insert accList;
         
         List<Contact> contList = new List<Contact>();
         contList = TestDataFactory.initializeContacts(accList[0].Id, 1);
         insert contList;
         
         // Insert Sales Order
         Test.startTest();
         SalesOrder__x salesOrder = new SalesOrder__x(fulfillerID__c = '8888300-164',
                                                         ExternalId = '0012900000GRGzzAAH:004049148813:133:300442390:8888300-164:D',	
                                                         phhProfitcenter__c = 1234567,
                                                         Phhcustomerid__c = '784584585',
                                                         phhSalesOrder__c = '88845758',
                                                       phhGuestID__c = accList[0].Id
                                                     		);
   
         ExternalRequestModel.mockedSalesOrders.add(salesOrder);
         SalesOrder__x salesOrderObj = ExternalRequestModel.findById(salesOrder.Id);
         
         // Insert Sales Order Item
         SalesOrderItem__x salesOrderItem = new SalesOrderItem__x(ExternalId = '0012900000GRGzzAAH:004049148813:133:300442390:8888300-164:D', 
                                                                  phdShipZip__c = '30548');
         ExternalRequestModel.mockedSalesOrderItems.add(salesOrderItem);
         SalesOrderItem__x salesOrderItemObj = ExternalRequestModel.findByOrderItemId(salesOrderItem.Id);
         System.assertEquals('0012900000GRGzzAAH:004049148813:133:300442390:8888300-164:D', salesOrderObj.ExternalId);
         
         // Insert Case
         Case caseObj = new Case(Sales_Order__c = '0012900000GRGzzAAH:004049148813:133:300442390:8888300-164:D', Status = 'New', Origin = 'Phone', 
                                 Type = 'Open Order Inquiry', Subject = 'Test',
                                 Description = 'Test', ContactId = contList[0].Id );
         insert caseObj;
         
         Test.stopTest(); 
    }
    private static testMethod void testCaseWithSalesOrder(){
       Case caseObj = [Select Id,Sales_Order__c from Case Where Sales_Order__c = '0012900000GRGzzAAH:004049148813:133:300442390:8888300-164:D'];
            Test.startTest();
            SalesOrder__x salesOrder = new SalesOrder__x(fulfillerID__c = '8888300-164',
                                                         ExternalId = '0012900000GRGzzAAH:004049148813:133:300442390:8888300-164:D',
                                                         phhProfitcenter__c = 1234567,
                                                         Phhcustomerid__c = '784584585',
                                                         phhSalesOrder__c = '88845758'
                                                        
                                                     		);
        ExternalRequestModel.mockedSalesOrders.add(salesOrder);
         SalesOrder__x salesOrderObj = ExternalRequestModel.findById(salesOrder.Id);
        SalesOrderListfromCase.getSalesOrders(caseObj.Id);
 		 Test.stopTest();
    }
}