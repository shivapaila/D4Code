public class ProductWrapper {
    @AuraEnabled
    public string categoryId{get;set;}
    @AuraEnabled
    public string primaryImageId{get;set;}
    @AuraEnabled
    public string categoryName{get;set;}
    @AuraEnabled
    public string sku{get;set;}
    @AuraEnabled
    public string productTitle{get;set;}
    @AuraEnabled
    public string imageUrl{get;set;}
    /* @AuraEnabled
    public string[] swatchesimageUrl{get;set;}*/
    @AuraEnabled
    public List<SwatchesWrapper> swatches{get;set;}
    @AuraEnabled
    public string path{get;set;}
    
    @AuraEnabled
    public string detailedDescription{get;set;}
    
    @AuraEnabled
    public string eCommLargeImage{get;set;}
    @AuraEnabled
    public string ecommSmallImage{get;set;}
    @AuraEnabled
    public string ecommRolloverImage{get;set;}
  	@AuraEnabled
    public string largeImageUrl{get;set;}
    @AuraEnabled
    public string smallImageUrl{get;set;}
    @AuraEnabled
    public string rolloverImageUrl{get;set;}

    @AuraEnabled
    public string imageSetId{get;set;}
    @AuraEnabled
    public string imageUrls{get;set;}
    @AuraEnabled
    public string imageSize{get;set;}
    @AuraEnabled
    public string lifestyle{get;set;}
    @AuraEnabled
    public string itemColor{get;set;}
    /*
    @AuraEnabled
    public String[] itemColorArr{get;set;}*/
    @AuraEnabled
    public string genericColors{get;set;}
   /* @AuraEnabled
    public String[] genericColorsArr{get{
        return this.genericColors.split('/');
        
    }
                                     set;}*/
    @AuraEnabled
    public Boolean isDirectShipOnly{get;set;}
    @AuraEnabled
    public List<FabricWrapper>  fabricdetails{get;set;}
    
    @AuraEnabled
    public List<ProductVariantWrapper> variants{get;set;}
    
    @AuraEnabled
    public String  dimensionDescription{get;set;}  //"dimensionDescription": "54\"W x 74\"D x 8.5\"H", 
    @AuraEnabled
    public Decimal  standardDepth{get;set;}    //"standardDepth": "74.0000000000000000", 
    @AuraEnabled
    public Decimal  standardHeight{get;set;}   // "standardHeight": "8.5000000000000000", 
    @AuraEnabled
    public Decimal  standardWidth{get;set;}    // "standardWidth": "54.0000000000000000", 
    @AuraEnabled
    public List<MediaWrapper> media{get;set;}
    @AuraEnabled
    public ProductCategoryWrapper[] categories{get;set;}
    @AuraEnabled
    public CrossSellWrapper[] crossSells{get;set;}
    @AuraEnabled
    public CrossSellWrapper[] completeYourCollection{get;set;}
    
    @AuraEnabled
    public ProductPriceWrapper priceInfo{get;set;}
     @AuraEnabled
    public ProductRatingStatisticWrapper ratingInfo{get;set;}
}