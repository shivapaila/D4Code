/**
 * This is a Data Access class that provides methods to access Sales Orders and Sales Order Line Items by Ids and External Ids. 
 * External Objects can't be created in test context and the class provides a way to mock data that will be returned if the call is
 * in test context. All methods in this class will identify the context of the call and return mocked results in test context or results
 * from actual queries outside test context.
 */
 public with sharing class SalesOrderDAO {
    @TestVisible 
    private static List<SalesOrder__x> mockedSalesOrders = new List<SalesOrder__x>();

    @TestVisible 
    private static List<SalesOrderItem__x> mockedSalesOrderLineItems = new List<SalesOrderItem__x>();

    public static List<SalesOrder__x> getOrdersByIds(List<Id> orderSalesforceIds) {
        if(Test.isRunningTest()) {
            return mockedSalesOrders;
        }

        List<SalesOrder__x> orders = [Select Id, ExternalId, phhHot__c,phhOrder_Notes__c, phhDesiredDate__c, fulfillerID__c, 
                                    phhStoreID__c, phhDeliveryType__c , phhProfitcenter__c, phhSaleType__c, phhSalesOrder__c,
                                    phhCustomerName__c, phhStoreLocation__c, phhReasonCode__c, phhGuestID__c, phhDatePromised__c,phhWindowBegin__c,phhWindowEnd__c,phhASAP__c                        
                                    from SalesOrder__x  
                                    where Id in: orderSalesforceIds];

        return orders;
    }
    public static SalesOrder__x getOrderById(Id orderSalesforceId) {
        if(Test.isRunningTest()) {
            return (mockedSalesOrders.size() > 0) ? mockedSalesOrders[0] : null;
        }

        List<SalesOrder__x> orders = [Select Id, ExternalId, phhHot__c,phhOrder_Notes__c, phhDesiredDate__c, fulfillerID__c, 
                                    phhStoreID__c, phhDeliveryType__c , phhProfitcenter__c, phhSaleType__c, phhSalesOrder__c,
                                    phhCustomerName__c, phhStoreLocation__c, phhReasonCode__c, phhGuestID__c, phhDatePromised__c,phhWindowBegin__c,phhWindowEnd__c,phhASAP__c,phhServiceLevel__c,
                                    VIPFlag__c,LIBFlag__c
                                    from SalesOrder__x  
                                    where Id=: orderSalesforceId];

        return (orders.size() > 0) ? orders[0] : null;
    }

    public static SalesOrder__x getOrderByExternalId(string externalId) {
        if(Test.isRunningTest()) {
            return (mockedSalesOrders.size() > 0) ? mockedSalesOrders[0] : null;
        }

        List<SalesOrder__x> orders = [Select Id, ExternalId, phhHot__c,phhOrder_Notes__c, phhDesiredDate__c, fulfillerID__c, 
                                    phhStoreID__c, phhDeliveryType__c , phhProfitcenter__c, phhSaleType__c, phhSalesOrder__c,
                                    phhCustomerName__c, phhStoreLocation__c, phhReasonCode__c, phhGuestID__c, phhDatePromised__c,phhWindowBegin__c ,phhWindowEnd__c,phhASAP__c                   
                                    from SalesOrder__x  
                                    where ExternalId=: externalId];

        return (orders.size() > 0) ? orders[0] : null;
    }

    public static List<SalesOrderItem__x> getOrderLineItemsByOrderExternalId(string orderExternalId) {
        if(Test.isRunningTest()) {
            return mockedSalesOrderLineItems;
        }

        List<SalesOrderItem__x> lineItems = [Select Id, ExternalId, phdItemSKU__c, phdItemDesc__c, phdQuantity__c, phdReturnedReason__c, 
                                            phdDeliveryDueDate__c, phdSalesOrder__c, phdIsFPP__c, phdItemStatus__c, phdWarrantyExpiredOn__c, 
                                            phdShipAddress1__c, phdShipAddress2__c, phdShipCity__c, phdShipState__c, phdShipZip__c,
                                            phdLOC_PO__c, phdInStoreQty__c, phdInWarehouseQty__c, phdWarrantyDaysLeft__c, phdDeliveryType__c,
                                            phdDeliveryTypeDesc__c, phdAckNo__c, phdSaleType__c, phdItemSeq__c, phdOrderType__c,
                                            phdPurchaseDate__c, phdPaymentType__c, phdInvoiceNo__c, phdRSA__c, phdCustomerPo__c,
                                            phdDiscountReasonCode__c,phdAmount__c,dtea__c,Ship_Customer_Name__c
                                            from SalesOrderItem__x 
                                            where phdSalesOrder__r.ExternalId =: orderExternalId];
        system.debug('lineItems'+lineItems);
        return lineItems;
    }

    public static SalesOrderItem__x getOrderLineItemByExternalId(string externalId) {
        if(Test.isRunningTest()) {
            return (mockedSalesOrderLineItems.size() > 0) ? mockedSalesOrderLineItems[0]: null;
        }

        List<SalesOrderItem__x> lineItems = [Select Id, ExternalId, phdItemSKU__c, phdItemDesc__c, phdQuantity__c, phdReturnedReason__c, 
                                            phdDeliveryDueDate__c, phdSalesOrder__c, phdIsFPP__c, phdItemStatus__c, phdWarrantyExpiredOn__c, 
                                            phdShipAddress1__c, phdShipAddress2__c, phdShipCity__c, phdShipState__c, phdShipZip__c,
                                            phdLOC_PO__c, phdInStoreQty__c, phdInWarehouseQty__c, phdWarrantyDaysLeft__c, phdDeliveryType__c,
                                            phdDeliveryTypeDesc__c, phdAckNo__c, phdSaleType__c, phdItemSeq__c, phdOrderType__c,
                                            phdPurchaseDate__c, phdPaymentType__c, phdInvoiceNo__c, phdRSA__c, phdCustomerPo__c,
                                            phdDiscountReasonCode__c,phdAmount__c,Ship_Customer_Name__c
                                            from SalesOrderItem__x 
                                            where ExternalId =: externalId];
        List<SalesOrderItem__x> filteredLineItems = new List<SalesOrderItem__x>();
        for(SalesOrderItem__x lineItem: lineItems){
            if(lineItem.ExternalId == externalId){
                filteredLineItems.add(lineItem);
                break;
            }
        }

        return (filteredLineItems.size() > 0) ? filteredLineItems[0] : null;
    }

}