/****** v1 | Description: Categories information | 12/6/2017 | JoJo Zhao */
global class ProductCategoryAPIHelper extends ProductAPIBaseHelper {
      
    /**
* @description <get Ashley Retail - NavigableCategory API Endpoint>                                                        
* @return <returns String value> 
**/
    public Override String getAPIEndpoint(String parentCategoryId){      
        //https://ashley-preprod-qa.apigee.net/productinformation/retail/navigablecategories?apikey=bGna5ABiJwsJyqV9DDtQmTBEH2Kpz713
        //https://ashley-preprod-qa.apigee.net/productinformation/retail/navigablecategories/AFHS-0225?apikey=bGna5ABiJwsJyqV9DDtQmTBEH2Kpz713
       
       String paramId='';
        if(parentCategoryId!=null){
            paramId ='/'+parentCategoryId;
        }
        String path ='';
        if(apiPathConf!=null){
            if(apiPathConf.Product_API_NavigatableCategory_Path__c!=null){                
                   path = apiPathConf.Product_API_NavigatableCategory_Path__c;
            }
        }

       	return getBaseUrlAPIEndpoint() + String.format(path, new List<String>{paramId,getAPIKey()});
    }
    
      /**
* @description <get Ashley Retail - Category API Endpoint>                                                        
* @return <returns String value> 
**/
    public  String getXMLAPIEndpoint(String parentCategoryId){      
        //https://ashley-preprod-qa.apigee.net/productinformation/retail/categories?apikey=bGna5ABiJwsJyqV9DDtQmTBEH2Kpz713
        //https://ashley-preprod-qa.apigee.net/productinformation/retail/categories/AFHS-0225?apikey=bGna5ABiJwsJyqV9DDtQmTBEH2Kpz713
       
       String paramId='';
        if(parentCategoryId!=null){
            paramId ='/'+parentCategoryId;
        }
        String path ='';
        if(apiPathConf!=null){
            if(apiPathConf.Product_API_Category_Path__c!=null){                
                   path = apiPathConf.Product_API_Category_Path__c;
            }
        }

       	return getBaseUrlAPIEndpoint() + String.format(path, new List<String>{paramId,getAPIKey()});
    }
    
    /**
*   @description <Method to parse JSON string to ProductCategoryWrapper>
*   @return <returns ProductCategoryWrapper>
*/
    public ProductCategoryWrapper parseJSONToCategoryWrapper(String resJSON){
        if(resJSON!=null){
            ProductCategoryWrapper catgoryAll = new ProductCategoryWrapper();
            try{
                catgoryAll = (ProductCategoryWrapper)JSON.deserialize(resJSON, ProductCategoryWrapper.class);
                return catgoryAll;
            }catch(JSONException ex){
                System.debug(LoggingLevel.ERROR, 'JSON parse Exception:' + ex.getMessage()+';resJSON: '+resJSON );
                new ErrorLogController().createLog(
                    new ErrorLogController.Log(
                        'ProductCategoryAPIHelper', 'parseJSONToCategoryWrapper',
                        'JSON Parse Exception: ' + ex.getMessage() +';resJSON: '+resJSON+
                        ' Stack Trace: ' + ex.getStackTraceString()
                    )
                );   
            }
        }
        
        return null;
    }
}