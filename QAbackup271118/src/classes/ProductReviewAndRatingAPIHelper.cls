/****** v1 | Description: Product Review and Rating information | 12/19/2017 | JoJo Zhao */
public class ProductReviewAndRatingAPIHelper extends ProductAPIBaseHelper {
    
       /**
* @description <use parseJSONToProductReviewWrapper method to parse this endpoint's return result>                                                        
* @return <returns String value>
**/
    public String getProductReviewsAPIEndpoint(Set<String> productSkuIds){      
    	//http://api.bazaarvoice.com/data/reviews.json?passkey=m57st9ziosgngrm00m7foltdu&apiVersion=5.5&stats=reviews&filter=productid:B136-53   
  		String[] paramList = new List<String>{getAPIVersion(),getAPIKey(),String.join(new List<String>(productSkuIds), ',')};
        String path ='';
        if(apiPathConf!=null){
            if(apiPathConf.Product_Reviews_API_Reviews_Path__c!=null){                
                   path = apiPathConf.Product_Reviews_API_Reviews_Path__c;
            }
        }
        return getBaseUrlAPIEndpoint() + String.format(path, paramList);
    }
    
         /**
* @description <use parseJSONToProductRatingWrapper method to parse this endpoint's return result>                                                        
* @return <returns String value>
**/
    public String getProductRatingAPIEndpoint(Set<String> productSkuIds){
      
        //http://api.bazaarvoice.com/data/statistics.json?passkey=m57st9ziosgngrm00m7foltdu&apiVersion=5.5&stats=reviews&filter=productid:B136-53   
        String[] paramList = new List<String>{getAPIVersion(),getAPIKey(),String.join(new List<String>(productSkuIds), ',')};
         String path ='';
        if(apiPathConf!=null){
            if(apiPathConf.Product_Reviews_API_Statistics_Path__c!=null){                
                   path = apiPathConf.Product_Reviews_API_Statistics_Path__c;
            }
        }
        return getBaseUrlAPIEndpoint() + String.format(path, paramList);
    }
    
    /**
* @description <get APIVersion>                                                        
* @return <returns String value>
**/
    public override String getAPIVersion(){
        if(apiPathConf!=null){
            return apiPathConf.Product_Reviews_API_Version__c;
        }else{
            return '';
        }
    }
       /**
* @description <get APIKey>                                                        
* @return <returns String value>
**/
    public override String getAPIKey(){
        if(apiReviewsConf!=null){
            return apiReviewsConf.API_Key__c;
        }else{
            return '';
        }
    }
  
    
    /**
* @description <get base url of Ashley Retail API>                                                        
* @return <returns String value>
**/
    public override String getBaseUrlAPIEndpoint(){ 
        if(apiReviewsConf!=null){
            return apiReviewsConf.End_Point_URL__c;
        }else{
            return '';
        }     
    }
      /**
*   @description <Method to parse JSON string to ProductRatingStatisticWrapper>
*   @return <returns Map{productId => ProductRatingStatisticWrapper} >
*/
    public Map<String, ProductRatingStatisticWrapper> parseJSONToProductRatingWrapper(String resJSON){
        if(resJSON!=null){
            Map<String, ProductRatingStatisticWrapper> productRatingMap = new Map<String, ProductRatingStatisticWrapper>();
            ProductRatingsWrapper productRatings = new ProductRatingsWrapper();
            try{
                productRatings = (ProductRatingsWrapper)JSON.deserialize(resJSON, ProductRatingsWrapper.class);
                for(ProductStatisticsWrapper pr: productRatings.results){
                    productRatingMap.put(pr.ProductStatistics.productId, pr.ProductStatistics.reviewStatistics);
                }
                return productRatingMap;
            }catch(JSONException ex){
                System.debug(LoggingLevel.ERROR, 'JSON parse Exception:' + ex.getMessage()+';resJSON: '+resJSON );
                new ErrorLogController().createLog(
                    new ErrorLogController.Log(
                        'ProductReviewAndRatingAPIHelper', 'parseJSONToProductRatingWrapper',
                        'JSON parse Exception: ' + ex.getMessage() +';resJSON: '+resJSON+
                        ' Stack Trace: ' + ex.getStackTraceString()
                    )
                );   
				return null;                
            }
        }
        
        return null;
    }
        /**
*   @description <Method to parse JSON string to a list ProductReviewsWrapper for every product>
*   @return <<returns Map{productId =>  List<ProductReviewWrapper>}>
*/
    public Map<String, List<ProductReviewWrapper>> parseJSONToProductReviewWrapper(String resJSON){
        if(resJSON!=null){
             Map<String, List<ProductReviewWrapper>> productReviewsMap = new Map<String, List<ProductReviewWrapper>>();
      
            ProductReviewsWrapper productReviews = new ProductReviewsWrapper();
            try{
                productReviews = (ProductReviewsWrapper)JSON.deserialize(resJSON, ProductReviewsWrapper.class);
                for(ProductReviewWrapper prw:productReviews.results){
                    if(productReviewsMap.get(prw.productId)!=null){
                        productReviewsMap.get(prw.productId).add(prw);
                    }else{
                        productReviewsMap.put(prw.productId, new List<ProductReviewWrapper>{prw});
                    }
                    
                }
                return productReviewsMap;
            }catch(JSONException ex){
                System.debug(LoggingLevel.ERROR, 'JSON parse Exception:' + ex.getMessage()+';resJSON: '+resJSON );
                new ErrorLogController().createLog(
                    new ErrorLogController.Log(
                        'ProductReviewAndRatingAPIHelper', 'parseJSONToProductReviewWrapper',
                        'JSON parse Exception: ' + ex.getMessage() +';resJSON: '+resJSON+
                        ' Stack Trace: ' + ex.getStackTraceString()
                    )
                );   
				return null;                
            }
        }
        
        return null;
    }
    
  
}