/* This is a controller clas for SalesOrderLineItemRelatedList lightning component. The Component is used to display all line items 
associated to a given order. */
public with sharing class SalesOrderLineItemRelatedListController {
    @AuraEnabled
    public static List<SalesOrderItem__x> getLineItems(Id salesforceOrderId) {
        List<SalesOrderItem__x> lineItems = new List<SalesOrderItem__x>();
        system.debug('salesforceOrderId------'+salesforceOrderId);
        SalesOrder__x order = SalesorderDAO.getOrderById(salesforceOrderId);
        List<SalesOrderItem__x> finallineItems = new List<SalesOrderItem__x>();
        system.debug('order------'+order);
        if(order != null){
            lineItems = SalesOrderDAO.getOrderLineItemsByOrderExternalId(order.ExternalId);
        }
        String orderId = order.Id;
        for(SalesOrderItem__x oli: lineItems){
            system.debug('oli---1---'+oli.phdSaleType__c+'-----'+order.phhSaleType__c);
            if(order.phhSaleType__c == oli.phdSaleType__c)//Added by Venkat on 10292018
            {
                system.debug('oli---1---'+oli);
                //if(!oli.phdItemSKU__c.startsWith('*')){
                    finallineItems.add(oli);
                //}
            }
        }
        system.debug('finallineItems---> ' +finallineItems);
        return lineItems;
    }
    @AuraEnabled
    public static List<SalesOrderItem__x> getSalesOrderLineItem (id salesOrderItemId, id salesOrderId){
        system.debug('salesOrderItemId value is '+salesOrderItemId);
        system.debug('salesOrderId value is '+salesOrderId);
        List < SalesOrderItem__x > lstOfSalesOrdLineItem = new List < SalesOrderItem__x >();
        lstOfSalesOrdLineItem = [SELECT Id,phdShipAddress1__c,phdShipAddress2__c,phdShipCity__c,phdShipState__c,phdShipZip__c,phdSalesOrder__c From SalesOrderItem__x where id =: salesOrderItemId];
        system.debug('lstOfSalesOrdLineItem value is '+lstOfSalesOrdLineItem);
        List < SalesOrderItem__x > SOLAddrsList = new List < SalesOrderItem__x >();
        if(lstOfSalesOrdLineItem.size()>0){
            for(SalesOrderItem__x soi:lstOfSalesOrdLineItem){
                if(soi.id == salesOrderItemId){
                    SOLAddrsList.add(soi);
                    break;
                }
            }
        }
        system.debug('SOLAddrsList value is '+SOLAddrsList);
        return SOLAddrsList;
        
    }

    @AuraEnabled
    public static List<String> getval(Id salesforceOrderId) {
        List<SalesOrderItem__x> lineItems = new List<SalesOrderItem__x>();
        List<String> EstArrival = new List<String>();
        List<SalesOrderItem__x> finallineItems = new List<SalesOrderItem__x>();
        system.debug('salesforceOrderId------'+salesforceOrderId);
        SalesOrder__x order = SalesorderDAO.getOrderById(salesforceOrderId);
        system.debug('order------'+order);
        if(order != null){
            lineItems = SalesOrderDAO.getOrderLineItemsByOrderExternalId(order.ExternalId);
        }
        for(SalesOrderItem__x oli: lineItems){
            //if(order.phhSaleType__c == oli.phdSaleType__c)//Added by Venkat on 10292018
            //{
                if(!oli.phdItemSKU__c.startsWith('*')){
                    finallineItems.add(oli);
                }
            //}
        }
        system.debug('finallineItems---> ' +finallineItems);
        
        String orderId = order.Id;
        if(!(lineItems.isEmpty())){
            for(integer i=0; i < lineItems.size(); i++)
            {
                String String1;
                  if(!lineItems[i].phdItemSKU__c.startsWith('*')){ 
                        String1 = String.valueOf(lineItems[i].phdDeliveryDueDate__c);
                        String String2 = lineItems[i].phdLOC_PO__c;
                        system.debug('EST. Arrival Date ' + String1);
                        system.debug('LOC/PO ' + String2);
                        if(String.isBlank(String1)){
                            system.debug('LOC/PO---->' + String2);
                            String1 = String2;   
                        }
                    } else {
                        String1 = '';
                    }
                EstArrival.add(String1);
            }
        }
        System.debug('lineItems.size-->'+lineItems.size());
        return EstArrival;
    }
}