public class ProductRatingsWrapper {
	@AuraEnabled
    public Integer totalResults{get;set;}
    @AuraEnabled
    public List<ProductStatisticsWrapper> results{get;set;}
}