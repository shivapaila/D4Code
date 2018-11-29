public class ProductListFilterWrapper {
	@AuraEnabled
    public string id{get;set;}
    
    @AuraEnabled
    public string sku{get{
        return this.id;
    }set;}
   
    
    @AuraEnabled
    public string name{get;set;}

     @AuraEnabled
    public string productTitle{get{
        return this.name;
    }set;}
    
    @AuraEnabled
    public string imageUrl{get;set;}

    @AuraEnabled
    public string largeImageUrl{get;set;}
    
    @AuraEnabled
    public String[] swatchesimageUrl{get;set;}
    
     @AuraEnabled
    public String[] swatchesname{get;set;}
}