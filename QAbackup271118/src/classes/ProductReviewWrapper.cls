public class ProductReviewWrapper {
    @AuraEnabled
    public String Id{get;set;}
    @AuraEnabled
    public String ProductId{get;set;}
    @AuraEnabled
    public String AuthorId{get;set;}
    @AuraEnabled
    public Integer Rating{get;set;}
    @AuraEnabled
    public String ReviewText{get;set;}
    @AuraEnabled
    public String UserNickname{get;set;}
    
    @AuraEnabled
    public Datetime SubmissionTime{get;set;}
    @AuraEnabled
    public Boolean IsRecommended{get;set;}
    @AuraEnabled
    public String  ModerationStatus {get;set;}
}