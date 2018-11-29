/****** v1 | Description: Product List component controller | 12/12/2017 | JoJo Zhao */
public class ProductListCmpCtrl {
    /**
* @description <get product list of certain category>                                                        
* @param <categoryId: category Id>
* @return <A list of ProductWrapper>
**/
    @AuraEnabled
    public static List<ProductWrapper> getCategoryProductList(String categoryId) {
        ProductListAPIHelper productListAPIhelper = new ProductListAPIHelper();
        String sourceURL = productListAPIhelper.getAPIEndpoint(categoryId);
        System.debug('lst ' + sourceURL);
        String resJSON = productListAPIhelper.connectToAPIGetJSON(sourceURL);
        System.debug('lst1 ' + resJSON);
        CategoryProductListWrapper  categoryProductListWrapper =  productListAPIhelper.parseJSONToCategoryProductListWrapper(resJSON);
        if(categoryProductListWrapper==null){
           throw new AuraHandledException('Get Error when calling Product List API, please check the response for reason:'+resJSON);
                 
        }
        for(ProductWrapper p:categoryProductListWrapper.productList){
            p.largeImageUrl= p.imageUrl+'?$AFHS-Product-Grid-Large$';
        }
        return categoryProductListWrapper.productList;
    }    
    
      /**
* @description <get product list of certain category>                                                        
* @param <categoryId: category Id>
* @return <A list of ProductWrapper>
**/
    @AuraEnabled
    public static String getProductListFilter(String categoryId, Integer currentIndex, Integer rows, String filterStr) {
        ProductFilterAPIHelper productFilterAPIHelper = new ProductFilterAPIHelper();
        String sourceURL = ProductFilterAPIHelper.getAPIEndpoint(categoryId, currentIndex, rows, filterStr);
        String resJSON = ProductFilterAPIHelper.connectToAPIGetJSON(sourceURL);
		return resJSON;
    }    
    
     /**
* @description <get product list of certain searchKey>                                                        
* @param <searchKey: searchKey>
* @return <A list of ProductWrapper>
**/
    @AuraEnabled
    public static String getProductListSearch(String searchKey, Integer currentIndex, Integer rows, String filterStr) {
        ProductFilterAPIHelper productFilterAPIHelper = new ProductFilterAPIHelper();
        String sourceURL = ProductFilterAPIHelper.getSearchAPIEndpoint(searchKey, currentIndex, rows, filterStr);
        String resJSON = ProductFilterAPIHelper.connectToAPIGetJSON(sourceURL);
		return resJSON;
    }    
     @AuraEnabled
 	public static String getPriceZoneFacet() {
        StoreInfoWrapper si = StoreInfo.getStoreInfo();
        Price_Zone__c[] pz = [Select id, Price_Zone__c from Price_Zone__c where name=:si.storeZip];
        
        
        PriceZoneInfo__mdt pzmdt = [Select priceFilterFacet__c from PriceZoneInfo__mdt where DeveloperName=:'PZ'+pz[0].Price_Zone__c];
        return pzmdt.priceFilterFacet__c; 
    }
  
}