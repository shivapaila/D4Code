public class ShoppingCartWrapper {
    @AuraEnabled
    public List<SalesOrderLineWrapper> SalesOrderLineList{get;set;}
    
    @AuraEnabled
    public ShoppingCartDeliveryWrapper Delivery{get;set;}
}