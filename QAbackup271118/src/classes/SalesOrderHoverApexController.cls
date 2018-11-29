public class SalesOrderHoverApexController {
@AuraEnabled
 
     public static List<SalesOrder__x> getAccounts(Id salesforceOrderId){
        
       List < SalesOrder__x > lstOfAccount = [SELECT Id, ExternalId,phhOrderType__c,phhDatePromised__c,phhSalesOrder__c,phhSaleType__c,phhPurchaseValue__c, phhCustomerName__c,phhSalesOrderDate__c,phhHot__c,phhWindowBegin__c,phhWindowEnd__c From SalesOrder__x where phhGuestID__r.id =: salesforceOrderId ];
        system.debug('lstOfAccount value is'+lstOfAccount);
        return lstOfAccount;
        
    }

  @AuraEnabled
    
    public static List<SalesOrderItem__x> getSalesOrderLineItem (id salesOrderId){
       
    List < SalesOrderItem__x > lstOfSalesOrdLineItem = [SELECT Id, phdItemSKU__c,phdItemDesc__c,phdQuantity__c,phdDeliveryType__c From SalesOrderItem__x where phdSalesOrder__r.id =: salesOrderId];
         system.debug('lstOfSalesOrdLineItem value is '+lstOfSalesOrdLineItem);
       
        return lstOfSalesOrdLineItem;
        
    }
}