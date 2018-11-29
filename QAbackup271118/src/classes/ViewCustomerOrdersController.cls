/****** v1 | Description: Methods for querying customer order information | 12/18/2017 | L OMeara */
public class ViewCustomerOrdersController {
    /* method used by view customer order history lightning component query order history */
    @AuraEnabled
    public static List<SalesOrder__x> getCustomerOrderHistory(ID contactId) 
    {
        try {
            List<SalesOrder__x> results = [SELECT ID, ExternalId, phhSalesOrderDate__c, phhSaleType__c, 
                                           phhSalesOrder__c, phhPurchaseValue__c 
                                           FROM SalesOrder__x 
                                           WHERE phhGuestId__c=:contactId 
                                           LIMIT 10];
            
            return results;
        }catch(Exception ex){ 
            system.debug(ex.getMessage());
        }
        return null;
    }
        
    /* method used by view customer order  lightning component query order details */
    @AuraEnabled
    public static List<SalesOrderItem__x> getOrder(String orderId) 
    {
          return SalesOrderDAO.getOrderLineItemsByOrderExternalId(orderId);
    }    

    @AuraEnabled
    public static ProductWrapper getProductDetail(String productSKUId) {  
        return ProductDetailCmpCtrl.getProductDetail(productSKUId);
    }
    
}