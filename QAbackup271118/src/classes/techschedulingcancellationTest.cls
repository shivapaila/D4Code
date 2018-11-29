@isTest
public class techschedulingcancellationTest {

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
                                                 ExternalId = '17331400:001q000000raDkvAAE',
                                                 phhProfitcenter__c = 1234567,
                                                 Phhcustomerid__c = '784584585',
                                                 phhSalesOrder__c = '88845758'
                                                );
        system.debug('order' + salesOrder);
        SalesOrderDAO.mockedSalesOrders.add(salesOrder);
        SalesOrder__x salesOrderObj = SalesOrderDAO.getOrderById(salesOrder.Id);
        SalesOrderItem__x salesOrderItem = new SalesOrderItem__x(ExternalId = '17331400:001q000000raDkvAAE',
                                                             phdShipZip__c = '30548');
        SalesOrderDAO.mockedSalesOrderLineItems.add(salesOrderItem);
        SalesOrderItem__x salesOrderItemObj = SalesOrderDAO.getOrderLineItemByExternalId(salesOrderItem.ExternalId);
        system.debug('orderitem' + salesOrderItemObj);

        // Insert Case
        Case caseObj = new Case(Sales_Order__c = '17331400:001q000000raDkvAAE', Status = 'New', Origin = 'Phone',
                            Type = 'Open Order Inquiry', Subject = 'Test', Technician_ServiceReqId__c = '91506',
                            Description = 'Test', ContactId = contList[0].Id );
        insert caseObj;
        Test.stopTest();
    }

    @isTest static void lineitemcase() {
        Case caseObj = [Select Id,Sales_Order__c from Case Where Sales_Order__c = '17331400:001q000000raDkvAAE'];
        Test.startTest();
        techschedulingcancellation.getRelatedServiceRequestsforcancelling(caseObj.Id);
        Test.stopTest();
    }

    @isTest static void getApiResponse () {
        Case caseObj = [Select Id,Sales_Order__c from Case Where Sales_Order__c = '17331400:001q000000raDkvAAE'];
        SalesOrderItem__x salesOrderItem = new SalesOrderItem__x(ExternalId = '17331400:001q000000raDkvAAE', 
                                                             phdShipZip__c = '30548');
        ExternalRequestModel.mockedSalesOrderItems.add(salesOrderItem);
        SalesOrderItem__x salesOrderItemObj = ExternalRequestModel.findByOrderItemId(salesOrderItem.Id);

        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('TechSchedulePost');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');

        Test.startTest();
        // Set the mock callout mode
        Test.setMock(HttpCalloutMock.class, mock);
        // Call the method that performs the callout
        techschedulingcancellation.getApiResponse(caseObj.Id);
        Test.stopTest();
    }
}