public class CrossSellWrapper {
    @AuraEnabled
    public string sku{get;set;}

    @AuraEnabled
    public string name{get;set;}

    @AuraEnabled
    public string imageUrl{get;set;}
}