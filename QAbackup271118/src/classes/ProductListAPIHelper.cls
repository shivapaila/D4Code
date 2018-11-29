/****** v1 | Description: Product List of one category information | 12/20/2017 | JoJo Zhao */
global class ProductListAPIHelper extends ProductAPIBaseHelper{
     /**
* @description <get Ashley Retail - productabstracts API Endpoint>                                                        
* @return <returns String value>
**/
    public override String getAPIEndpoint(String categoryId){      
        //  https://ashley-preprod-qa.apigee.net/productinformation/retail/categories/AFHS-0146/productabstracts?apikey=bGna5ABiJwsJyqV9DDtQmTBEH2Kpz713
        //return getBaseUrlAPIEndpoint() + '/productinformation/retail/categories/'+categoryId+'/productabstracts?apikey='+getAPIKey(); 
        String[] paramList = new List<String>{categoryId,getAPIKey()};
            
        String path='';
        if(apiPathConf!=null){
            if(apiPathConf.Product_API_ProdList_Path__c!=null){                
                path = apiPathConf.Product_API_ProdList_Path__c;
            }
        }
        return getBaseUrlAPIEndpoint() + String.format(path, paramList);
    }
    
    /**
*   @description <Method to parse JSON string to CategoryProductListWrapper>
*   @return <returns CategoryProductListWrapper>
*/
    public CategoryProductListWrapper parseJSONToCategoryProductListWrapper(String resJSON){
        if(resJSON!=null){
            CategoryProductListWrapper catgoryProductsAll = new CategoryProductListWrapper();
            try{
                catgoryProductsAll = (CategoryProductListWrapper)JSON.deserialize(resJSON, CategoryProductListWrapper.class);
                return catgoryProductsAll;
            }catch(JSONException ex){
                System.debug(LoggingLevel.ERROR, 'JSON parse Exception:' + ex.getMessage()+';resJSON: '+resJSON );
                 new ErrorLogController().createLog(
                     new ErrorLogController.Log(
                         'ProductListAPIHelper', 'parseJSONToCategoryProductListWrapper',
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