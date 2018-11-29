public with sharing class ExternalRequestModel {

    @TestVisible private static List<SalesOrder__x> mockedSalesOrders = new List<SalesOrder__x>();

    public static SalesOrder__x findById(Id requestId) {
        if(Test.isRunningTest()) {
            return (mockedSalesOrders.size() > 0) ? mockedSalesOrders[0] : null;
        }

        List<SalesOrder__x> requests = [
            SELECT  Id, fulfillerID__c, ExternalId
            FROM SalesOrder__x
            WHERE Id =: requestId
        ];

        return (requests.size() > 0) ? requests[0] : null;
    }
    
    @TestVisible private static List<SalesOrderItem__x> mockedSalesOrderItems = new List<SalesOrderItem__x>();

    public static SalesOrderItem__x findByOrderItemId(Id requestId) {
        List<SalesOrderItem__x> requests = (!mockedSalesOrderItems.isEmpty()) ? mockedSalesOrderItems : [
            SELECT  Id, phdShipZip__c, ExternalId
            FROM SalesOrderItem__x
            WHERE Id =: requestId
        ];

        return (requests.size() > 0) ? requests[0] : null;
    }
}