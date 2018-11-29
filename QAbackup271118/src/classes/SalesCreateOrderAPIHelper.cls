/****** v1 | Description: Create Order From SF to Home information | 01/24/2018 | JoJo Zhao */
public class SalesCreateOrderAPIHelper extends ProductAPIBaseHelper {
	/**
*   @description <Method to connect Ashely API by using http call out, receive JSON type response>
*   @param <sourceURL sample: callout:Cara_Order_Odata_Sandbox/cara/sales-orders?sfGuestId=0012F00000Ce7x8QAB&storeID=133 >
*   @return <returns String value, it is a JSON string>
**/
    public String connectAPIPostJSON(String sourceURL, String rawPost) {
        String res =connectToAPIPostJSON(sourceURL,null, rawPost);
        return res;
    }
    
    /**
    * @description: Method takes a sku, and pulls users store info, to combine sales-orders endpoint                                           
    * @return: Returns sales-orders url
    **/
    public Override String getAPIEndpoint(String accountId){
        //Example: 'callout:Cara_Order_Odata_Sandbox/cara/sales-orders?sfGuestId=0012F00000Ce7x8QAB&storeId=133'

        try {
            StoreInfoWrapper si;
            if(Test.isRunningTest()){
                si = new StoreInfoWrapper('8888300-164-23-SWF');   
                si.fulfillerId = '8888300-164';
				si.legacyStoreID = '133';
            }else{            
                si = StoreInfo.getStoreInfo();
            }   
            String[] paramList = new List<String>{accountId, si.legacyStoreID};
            String path ='';
            if(apiPathConf!=null){
                if(apiPathConf.Product_API_SalesOrders_Path__c!=null){                
                       path = apiPathConf.Product_API_SalesOrders_Path__c;
                }
            }
            return String.format(path, paramList);            
        } catch (Exception ex) {
            System.debug(LoggingLevel.ERROR, 'Store Information Exception:' + ex.getMessage() );
            new ErrorLogController().createLog(
                new ErrorLogController.Log(
                    'SalesCreateOrderAPIHelper',
                    'getAPIEndpoint',
                    'Store Information Exception: ' + ex.getMessage() +
                    ' Stack Trace: ' + ex.getStackTraceString()
                )
            );                              
            return null;            
        }
    }
    
      /**
    *   @description: Method to parse JSON string to a list of ShoppingCartWrapper
    *   @return: ShoppingCartWrapper
    */
    public SalesOrderResponseWrapper parseJSONToSalesOrderResponseWrapper(String resJSON){
        
        if(resJSON!=null){
            try{
                 System.debug('json:'+resJSON);
                SalesOrderResponseWrapper res = (SalesOrderResponseWrapper)JSON.deserialize(resJSON, SalesOrderResponseWrapper.class);
               
                return res;
            }catch(JSONException ex){
                System.debug(LoggingLevel.ERROR, 'JSON parse Exception:' + ex.getMessage()+';resJSON: '+resJSON );
                new ErrorLogController().createLog(
                    new ErrorLogController.Log(
                        'SalesCreateOrderAPIHelper',
                        'parseJSONToSalesOrderResponseWrapper',
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