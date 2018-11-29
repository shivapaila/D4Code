public class ProductStatisticWrapper {
     @AuraEnabled
	public String productId{get;set;}
     @AuraEnabled
    public ProductRatingStatisticWrapper reviewStatistics{get;set;}
}