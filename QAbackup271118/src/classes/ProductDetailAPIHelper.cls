/****** v1 | Description: Product Detail information | 12/20/2017 | JoJo Zhao */
global class ProductDetailAPIHelper extends ProductAPIBaseHelper{
     /**
* @description <>                                                        
* @return <returns String value>
**/
    public override String getAPIEndpoint(String productSKUId){      
    //https://ashley-preprod-qa.apigee.net/productinformation/retail/products?skus=0966340B,D746-01&apikey=bGna5ABiJwsJyqV9DDtQmTBEH2Kpz713
      //  return getBaseUrlAPIEndpoint() + '/products?sku='+productSKUId+'&apikey='+getAPIKey(); 
         String[] paramList = new List<String>{productSKUId,getAPIKey()};
              String path='';
        if(apiPathConf!=null){
            if(apiPathConf.Product_API_ProdDetail_Path__c!=null){                
                path = apiPathConf.Product_API_ProdDetail_Path__c;
            }
        }
        return getBaseUrlAPIEndpoint() + String.format(path, paramList);
    }
       
    
     /**
*   @description <Method to parse JSON string to Concierge_CategoryProductListWrapper>
*   @return <returns Concierge_CategoryProductListWrapper>
*/
    public ProductWrapper parseJSONToProductWrapper(String resJSON){
        if(resJSON!=null){
            ProductDetailWrapper productDetail = new ProductDetailWrapper();
            try{
                productDetail = (ProductDetailWrapper)JSON.deserialize(resJSON, ProductDetailWrapper.class);
                return productDetail.product;
            }catch(JSONException ex){
                System.debug(LoggingLevel.ERROR, 'JSON parse Exception:' + ex.getMessage()+';resJSON: '+resJSON );
                new ErrorLogController().createLog(
                     new ErrorLogController.Log(
                         'ProductDetailAPIHelper', 'parseJSONToProductWrapper',
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