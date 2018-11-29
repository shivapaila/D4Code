/****** v1 | Description: Product Review and Rating component controller | 12/18/2017 | JoJo Zhao */
public class ProductReviewAndRatingCmpCtrl {
    
    /**
* @description: get rating information for a list of product                                                       
* @param: String[] productSKUIds - a list of product sku value
* @return: Map<String, ProductRatingStatisticWrapper>
**/
    @AuraEnabled
    public static Map<String, ProductRatingStatisticWrapper>  getProductRatingList(String[] productIdList) {
        Set<String> productIdSet = new Set<String>();
        productIdSet.addAll(productIdList);
        ProductReviewAndRatingAPIHelper reviewsAPIHelper = new ProductReviewAndRatingAPIHelper();
        String sourceURL = reviewsAPIHelper.getProductRatingAPIEndpoint(productIdSet);
        String resJSON = reviewsAPIHelper.connectToAPIGetJSON(sourceURL);
        
        Map<String, ProductRatingStatisticWrapper> productRatingMap =  reviewsAPIHelper.parseJSONToProductRatingWrapper(resJSON);
        if(productRatingMap==null){
            throw new AuraHandledException('Get Error when calling Product Review and Rating API, please check the response for reason:'+resJSON);
            
        }
        return productRatingMap;
    }   
    
    /**
* @description: get reviews information for a list of product                                                       
* @param: String[] productSKUIds - a list of product sku value
* @return: Map<String,  List<ProductReviewWrapper>>
**/
    @AuraEnabled
    public static  Map<String, List<ProductReviewWrapper>> getProductReviewList(String[] productIdList) {
        Set<String> productIdSet = new Set<String>();
        productIdSet.addAll(productIdList);
        ProductReviewAndRatingAPIHelper reviewsAPIHelper = new ProductReviewAndRatingAPIHelper();
      
        String sourceURL = reviewsAPIHelper.getProductReviewsAPIEndpoint(productIdSet);
        String resJSON = reviewsAPIHelper.connectToAPIGetJSON(sourceURL);
        
        Map<String, List<ProductReviewWrapper>> productReviewsMap =  reviewsAPIHelper.parseJSONToProductReviewWrapper(resJSON);
          if(productReviewsMap==null){
            throw new AuraHandledException('Get Error when calling Product Review and Rating API, please check the response for reason:'+resJSON);
            
        }
        return productReviewsMap;
    }
    
}