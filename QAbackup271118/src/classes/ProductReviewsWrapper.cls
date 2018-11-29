public class ProductReviewsWrapper {
    @AuraEnabled
    public Integer totalResults{get;set;}
    @AuraEnabled
    public List<ProductReviewWrapper> results{get;set;}
}