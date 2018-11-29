public class ProductDetailCmpCtrl {
    /**
* @description <get one product detail>                                                        
* @param <productSKUId : product sku value>
* @return <ProductWrapper>
**/
    @AuraEnabled
    public static ProductWrapper getProductDetail(String productSKUId) {  
        ProductDetailAPIHelper prodDetailAPIHelper = new ProductDetailAPIHelper();
        String sourceURL = prodDetailAPIHelper.getAPIEndpoint(productSKUId);
        System.debug('source url is ' + sourceURL);
        String resJSON = prodDetailAPIHelper.connectToAPIGetJSON(sourceURL);
        System.debug('resJSON' + resJSON);
        ProductWrapper productDetail =  prodDetailAPIHelper.parseJSONToProductWrapper(resJSON);
       // if(productDetail==null){
          //  throw new AuraHandledException('Get Error when calling Product Detail API for Product Sku \''+productSKUId 
                                       //    +'\', please check the response for reason:'+resJSON);
            
      //  }
       	if(productDetail!=null){
            
        	productDetail.swatches.sort();
        }

        return productDetail;
    }
    
    /**
* @description <get product list of certain searchKey>                                                        
* @param <searchKey: searchKey>
* @return <A list of ProductWrapper>
**/
    @AuraEnabled
    public static String getProductListSearch(String searchKey, Integer currentIndex, Integer rows, String filterStr) {
        return ProductListCmpCtrl.getProductListSearch(searchKey, currentIndex, rows, filterStr);
    }    
}