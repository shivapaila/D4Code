/****** v1 | Description: Product Price information | 12/15/2017 | JoJo Zhao */
public class ProductPriceAPIHelper extends ProductAPIBaseHelper {

    
    /**
*   @description <Method to connect Ashely API by using http call out, receive JSON type response>
*   @param <sourceURL sample:  https://ashley-preprod-sandbox.apigee.net/homestores/<AccountNo>-<Shipto>/price-and-availability/products/<sku>?profitCenter=<profitCenter> >
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
    public override String getAPIEndpoint(String sku){
        //  https://ashley-preprod-sandbox.apigee.net/homestores/<AccountNo>-<Shipto>/price-and-availability/products/<sku>?profitCenter=<profitCenter>
        StoreInfoWrapper si;
        try {
            if(Test.isRunningTest()){
                si = new StoreInfoWrapper('8888300-164-23-SWF');
                si.fulfillerId = '8888300-164';
            }else{            
                si = StoreInfo.getStoreInfo();
            }       
        } catch (Exception ex) {
            System.debug(LoggingLevel.ERROR, 'Store Information Exception:' + ex.getMessage() );
            new ErrorLogController().createLog(
                new ErrorLogController.Log(
                    'ProductPriceAPIHelper',
                    'getAPIEndpoint',
                    'Store Information Exception: ' + ex.getMessage() +
                    ' Stack Trace: ' + ex.getStackTraceString()
                )
            );                              
           throw new AuraHandledException('Get Error in getAPIEndpoint when calling Product Price API for Product Sku \''+sku +'\', Store Information Exception::'+ex.getMessage());
                       
        }
        if(si!=null){
            
        	String path ='';
            String[] paramList = new List<String>{si.fulfillerId,sku,si.profitCtr};
                
                if(apiPathConf!=null){
                    if(apiPathConf.Product_API_Price_Path__c!=null){                
                        path = apiPathConf.Product_API_Price_Path__c;
                    }
                }
            
			return getBaseUrlAPIEndpoint() + String.format(path, paramList); 
        }
        return null;
    }

    public String getPriceZone() {
        StoreInfoWrapper si = StoreInfo.getStoreInfo();
        Price_Zone__c[] pz = [Select id, Price_Zone__c from Price_Zone__c where name=:si.storeZip];
        return pz[0].Price_Zone__c; 
    }

    /**
    * @description: Method takes a sku, and pulls users store info, to query for ecomm price  
    * @return: Returns ecomm price information for that product at that location
    **/
    public ProductEcommWrapper getEcommPrice(String sku){
        try {
            String priceZone = getPriceZone();

            String sourceURL = this.apiEcommPricingConf.End_Point_URL__c + 
                '/productinformation/retail/prices/' + priceZone + 
                '/products/' + sku;
            String resJSON = super.connectToAPIGetJSON(sourceURL,new Map<String, String> {'apiKey'=>this.apiEcommPricingConf.API_Key__c});
            system.debug('ecomm json response ' + resJSON);
            ProductEcommWrapper ecommObj = (ProductEcommWrapper)JSON.deserialize(resJSON, ProductEcommWrapper.class);
            system.debug('parsed response ' + ecommObj);
            return ecommObj;
        } catch (Exception ex) {
            System.debug(LoggingLevel.ERROR, 'Store Information Exception:' + ex.getMessage() );
            new ErrorLogController().createLog(
                new ErrorLogController.Log(
                    'ProductPriceAPIHelper',
                    'getEcomAPIEndpoint',
                    'Store Information Exception: ' + ex.getMessage() +
                    ' Stack Trace: ' + ex.getStackTraceString()
                )
            );                              
            return null;            
        }
    }    
    
    /**
    *   @description: Method to parse JSON string to ProductPriceWrapper
    *   @return: ProductPriceWrapper
    */
    public ProductPriceWrapper parseJSONToProductPriceWrapper(String resJSON){
        if(resJSON!=null){
             ProductPriceWrapper productPriceInfo;
            try{
                productPriceInfo = (ProductPriceWrapper)JSON.deserialize(resJSON, ProductPriceWrapper.class);
                return productPriceInfo;
            }catch(JSONException ex){
                System.debug(LoggingLevel.ERROR, 'JSON parse Exception:' + ex.getMessage()+';resJSON: '+resJSON );
                new ErrorLogController().createLog(
                    new ErrorLogController.Log(
                        'ProductPriceAPIHelper',
                        'parseJSONToProductPriceWrapper',
                        'JSON Parse Exception: ' + ex.getMessage() +
                        ' Stack Trace: ' + ex.getStackTraceString()
                    )
                );         
                return null;
            }
        }
        
        return null;
    }   
}