/****** v1 | Description: Product Filter information | 01/14/2017 | JoJo Zhao */
public class ProductFilterAPIHelper extends ProductAPIBaseHelper {
    
    /**
* @description <get unbxdapi - Product Search API Endpoint>                                                        
* @return <returns String value> 
**/
    public String getAPIEndpoint(String parentCategoryId, Integer currentIndex, Integer rows, String filterStr){      
        //Unbxd filter is case senstive, for example: AND   
        //filterStr has category_ids info
      // http://search.unbxdapi.com/7e84d34e5d696f6eaac042a422b5e9f9/dev_ashleyfurniture_com-u1492545066797/search?q=*&format=json&rows=96&filter=(category_ids:%22AFHS-0226%22%20AND%20color_fq:%22Pebble%22%20AND%20material_fq:%22Fabric%22)
        String path ='';
        if(apiPathConf!=null){
            if(apiPathConf.Product_Filter_API_Path__c!=null){                
                   path = apiPathConf.Product_Filter_API_Path__c;
            }
        }
        String searchFilter = 'q=*&format=json&start='+currentIndex+'&rows='+rows;
        
        if(filterStr!=null && !String.isEmpty(filterStr)){
            searchFilter = searchFilter +'&filter='+filterStr; 
        }
        return getBaseUrlAPIEndpoint() + String.format(path, new List<String>{getAPIKey(),searchFilter});
    }
    
        /**
* @description <get unbxdapi - Product Search API Endpoint>                                                        
* @return <returns String value> 
**/
    public String getSearchAPIEndpoint(String searchKey, Integer currentIndex, Integer rows, String filterStr){      
      // http://search.unbxdapi.com/7e84d34e5d696f6eaac042a422b5e9f9/dev_ashleyfurniture_com-u1492545066797/search?q=Kids%20Rugs&format=json&rows=16&filter=(color_fq:"green"%20AND%20material_fq:Fabric)
       
        String path ='';
        if(apiPathConf!=null){
            if(apiPathConf.Product_Filter_API_Path__c!=null){                
                   path = apiPathConf.Product_Filter_API_Path__c;
            }
        }
        String searchFilter = 'q='+searchKey+'&format=json&start='+currentIndex+'&rows='+rows;
        if(filterStr!=null && !String.isEmpty(filterStr)){
            searchFilter = searchFilter +'&filter='+filterStr;
        }
        return getBaseUrlAPIEndpoint() + String.format(path, new List<String>{getAPIKey(),searchFilter});
    }
    /**
* @description <get APIKey>                                                        
* @return <returns String value>
**/
    public override String getAPIKey(){
        if(apiProductFilterConf!=null){
            return apiProductFilterConf.API_Key__c; 
        }else{
            return '';
        }
    }
    
      
    /**
* @description <get base url of Ashley Retail API>                                                        
* @return <returns String value>
**/
    public override String getBaseUrlAPIEndpoint(){      
        if(apiProductFilterConf!=null){
            return apiProductFilterConf.End_Point_URL__c; 
        }else{
            return '';
        }
    }
    

}