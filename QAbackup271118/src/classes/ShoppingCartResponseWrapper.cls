public class ShoppingCartResponseWrapper {
    @AuraEnabled
    public List<SalesOrderLineWrapper> SalesOrderLineList{get;set;}
    
    @AuraEnabled
    public ShoppingCartDeliveryWrapper Delivery{get;set;}
    
    @AuraEnabled
    public Decimal SalesGrandTotal{get;set;}
    @AuraEnabled
    public Decimal TotalCost{get;set;}
    @AuraEnabled
    public Decimal TotalDiscountAmount{get;set;}
    @AuraEnabled
    public PairValueObj[] WarrantyItemAmount{get;set;}
    @AuraEnabled
    public Decimal TotalTaxAmount{get;set;}
    @AuraEnabled
    public Decimal TotalNextDayCharge{get;set;}
    @AuraEnabled
    public Decimal TotalWarrantyAmount{get;set;}
    @AuraEnabled
    public Decimal TotalRecycleAmount{get;set;}
    @AuraEnabled
    public Decimal TotalDeliveryAmount{get;set;}
    @AuraEnabled
    public Decimal TotalProductLastAmount{get;set;}

    public class PairValueObj {
        @AuraEnabled
        public Decimal value{get;set;}
        @AuraEnabled
        public String key{get;set;}
        
        public PairValueObj(String name,Decimal price){            
            this.key=name;
            this.value=price;
        }
    }
   
}