public class ProductCategoryWrapper {
	@AuraEnabled
    public string categoryId{get;set;}
    
	@AuraEnabled
    public string name{get;set;}

    @AuraEnabled
    public List<ProductCategoryWrapper> categories{get;set;}
    
     @AuraEnabled
    public List<ProductCategoryWrapper> categoriesWithImage{get;set;}
    
    @AuraEnabled
    public string path{get;set;}
    
    @AuraEnabled
    public string parentCategoryId{get;set;}
    
    @AuraEnabled
    public string categoryImagePath{get;set;}
        
}