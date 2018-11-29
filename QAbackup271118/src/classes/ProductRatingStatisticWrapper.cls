public class ProductRatingStatisticWrapper {
    @AuraEnabled
    public Double averageOverallRating{get;set;}
    @AuraEnabled
    public Integer totalReviewCount{get;set;}
    @AuraEnabled
    public Integer overalRatingRange{get;set;}
}