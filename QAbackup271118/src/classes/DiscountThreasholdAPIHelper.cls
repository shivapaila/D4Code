/****** v1 | Description: Discount Threashold information | 6/13/2018 | JoJo Zhao */
public class DiscountThreasholdAPIHelper extends ProductAPIBaseHelper {

    
    /**
*   @description <Method to connect Ashely API by using http call out, receive JSON type response>
*   @param <sourceURL sample:  https://ashley-preprod-sandbox.apigee.net/homestores/<AccountNo>-<Shipto>/salesorders/sales-orders/settings/DISCOUNT_MANAGER_OVERRIDE_THRESHOLD?profitCenter=<profitCenter> >
*   @return <returns String value, it is a JSON string>
**/
    public String connectAPIGetJSON(String sourceURL) {
           return super.connectToAPIGetJSON(sourceURL,new Map<String, String> {'apiKey'=>getAPIKey()});
    }
    
    /**
    * @description: Method takes a sku, and pulls users store info, to query for price and use parseJSONToProductPriceWrapperto parse response 
    * when sku=1, using POST way to post multiple CartItem info.  and use parseJSONToProductPriceWrapperList to parse response                                                 
    * @return: Returns price and availability information for that product at that location
    **/
    public String getAPIEndpoint(){
        //  https://ashley-preprod-sandbox.apigee.net/homestores/<AccountNo>-<Shipto>/salesorders/sales-orders/settings/DISCOUNT_MANAGER_OVERRIDE_THRESHOLD?profitCenter=<profitCenter>
        StoreInfoWrapper si= StoreInfo.getStoreInfo();
       
        if(si!=null){
            
        	String path ='';
            String[] paramList = new List<String>{si.fulfillerId,si.profitCtr};
                
                if(apiPathConf!=null){
                    if(apiPathConf.Discount_Threshhold_API__c!=null){                
                        path = apiPathConf.Discount_Threshhold_API__c;
                    }
                }
            
			return getBaseUrlAPIEndpoint() + String.format(path, paramList); 
        }
        return null;
    }
}