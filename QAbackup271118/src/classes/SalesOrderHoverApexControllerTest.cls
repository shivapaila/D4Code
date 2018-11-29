@isTest
public class SalesOrderHoverApexControllerTest {
 static testMethod void testsoRoutingData() {
 
     
       SalesOrder__x salesOrder = new SalesOrder__x(fulfillerID__c = '8888300-164',
                                                         ExternalId = '17331400:001q000000raDkvAAE',  
                                                         phhProfitcenter__c = 1234567,
                                                         Phhcustomerid__c = '784584585',
                                                         phhSalesOrder__c = '88845758',
                                                         phhStoreID__c = '133',
                                                         phhGuestID__c = '001q000000raI3DAAU'
                                                         );
        system.debug('order------' + salesOrder);
        SalesOrderDAO.mockedSalesOrders.add(salesOrder);
        system.debug('order--2----' + salesOrder.Id);
          SalesOrder__x salesOrderObj = SalesOrderDAO.getOrderById(salesOrder.Id);
          SalesOrderItem__x salesOrderItem = new SalesOrderItem__x(ExternalId = '17331400:001q000000raDkvAAE', 
                                                                  phdShipZip__c = '30548');
         SalesOrderDAO.mockedSalesOrderLineItems.add(salesOrderItem);
          SalesOrderItem__x salesOrderItemObj = SalesOrderDAO.getOrderLineItemByExternalId(salesOrderItem.ExternalId);
       
       
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        SalesOrder__x testSalesOrder = TestDataFactory.initializeSalesOrders(1)[0];
        mock.setStaticResource('soRoutingDatamockResponse');

        mock.setStatusCode(200);

        mock.setHeader('Content-Type', 'application/json');
          
         
         Test.startTest();
             // Set the mock callout mode
             Test.setMock(HttpCalloutMock.class, mock);
            SalesOrderHoverApexController.getAccounts(salesOrder.phhGuestID__c);
            SalesOrderHoverApexController.getSalesOrderLineItem(salesOrder.Id); 


        Test.stopTest(); 
   }
   

}