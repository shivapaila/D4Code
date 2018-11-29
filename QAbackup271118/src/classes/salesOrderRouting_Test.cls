@isTest

public class salesOrderRouting_Test{


 static testMethod void testsoRoutingData() {
 
     
       SalesOrder__x salesOrder = new SalesOrder__x(fulfillerID__c = '8888300-164',
                                                         ExternalId = '17331400:001q000000raDkvAAE',  
                                                         phhProfitcenter__c = 1234567,
                                                         Phhcustomerid__c = '784584585',
                                                         phhSalesOrder__c = '88845758',
                                                         phhStoreID__c = '133'
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
            salesOrderRouting.soRoutingData(salesOrder.ExternalId );
            salesOrderRouting.soRoutingHistoryData(salesOrder.ExternalId );
            salesOrderRouting.soLineItemsData(salesOrder.ExternalId );
            salesOrderRouting.soLineItemHistoryData(salesOrder.ExternalId );
            
            String jSRout = '[{"StoreID": 133,"SalesOrderNumber": "200442750","TransportationOrderID": "01330000862365","IsConfirmed": false,"BegunTime": "09:55","CompletedTime": "10:18","UserName": "ASHLEY","RoutingPass": 1,"TimeChanged": 0,"ProfitCenter": 23,"DeliverDate": "2018-06-26","CustomerWindowOpen": "09:45","CustomerWindowClose": "13:45","TruckID": "G01","SFPersonAccountID": "001q000000raIJLAA2","UniqueID": "17331388","ConfirmationDateTime": null,"AccountShipTo": "8888300-164","SOLineItems": [{"SKU": "*090949C","ItemDescription": "Must Take Delivery Within 90 Days.","Quantity": 0},{"SKU": "*ANNIVERSARY","ItemDescription": "1 year anniversary","Quantity": 0},{"SKU": "*AS IS","ItemDescription": "No Refunds, No Svc, No Exchanges","Quantity": 0},{"SKU": "*DELIV-TAX","ItemDescription": "Delivery Fees","Quantity": 0},{"SKU": "B213-21","ItemDescription": "Dresser","Quantity": 1}]}]';
            
            salesOrderRouting.soConfirmData(jSRout,1);
            salesOrderRouting.convertDatetimeToLocal(System.now());
        Test.stopTest(); 
   }


}