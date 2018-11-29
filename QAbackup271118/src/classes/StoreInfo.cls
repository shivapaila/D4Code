/****** v1 | Description: Library for obtaining store info from user record| 01/25/2018 | Lauren OMeara */
public class StoreInfo {
    /* one source custom setting */
    public static final String ONE_SOURCE_API_CONFIG_NAME = 'OneSourceConfig';
    /* market custom setting */
    //public static final String MARKET_CONFIG_NAME = 'Default';

	/* custom exception for getting store info */
	public class StoreInfoException extends Exception {}
    
    /**
    * @description: method obtains account number, ship to, and profit center from current user                                                  
    * @return: store information object
    **/
    static public StoreInfoWrapper getStoreInfo(){
        Integration_Settings__c setting;
        OneSourceSettings__c osSettings;
        MarketSettings__c marketSettings;
        Datetime currentTimestamp = system.now();
        Boolean doUpdate = false;
        String apiKey; 
        String baseOneSourceURL;
        Integer maxMinutes;
        String marketCode; 
        StoreInfoWrapper storeInfoObj;
        try {
            osSettings = OneSourceSettings__c.getInstance(ONE_SOURCE_API_CONFIG_NAME);

            if ((osSettings!=null)) {
                apiKey = osSettings.One_Source_API_Key__c ; 
                baseOneSourceURL = osSettings.One_Source_API_Path__c;
                maxMinutes = Integer.valueOf(osSettings.One_Source_API_Refresh_Minutes__c);
              
            } else {
                throw new StoreInfoException('Store information is not configured in custom settings. Look at ' +
                                             ONE_SOURCE_API_CONFIG_NAME + ' setting in OneSourceSettings__c.');
            }
            //REQ-455 - Text Opt In Modified the SOQL to query additional custom field LegalEntityName__c  
            User usr = [SELECT Id, Name, Last_Checked_Store_Info__c, One_Source_ID__c,  AcctNo_ShipTo_ProfitCtr__c,                      
                        Store_Zip__c, RDC__c, FulfillerID__c,LegacyStoreID__c, LegalEntityName__c
                        FROM User WHERE Id = :UserInfo.getUserId()][0];
            
            if(Usr.One_Source_ID__c!=null){
                
            
                // check date last checked
                if (usr.Last_Checked_Store_Info__c == null) {
                    doUpdate = true;
                } else {
                    Integer minutesSinceLastCheck = Integer.valueOf((currentTimestamp.getTime() - usr.Last_Checked_Store_Info__c.getTime())/(60*1000));
                    if (minutesSinceLastCheck > maxMinutes) {
                        doUpdate = true;
                    }
                }
            }
            // if user's oneSourceId has value and there is no last checked date or last date checked is past limit, query for updated store info
            // NOTE - do not put a test check around this, use a mock. see StoreInfo_Test and StoreInfoMock
            
            if (doUpdate) {
                // get current info
                ProductPriceAPIHelper helper = new ProductPriceAPIHelper();
                
                String onesourceEndpoint = baseOneSourceURL + usr.One_Source_ID__c + '?apikey=' + apiKey;
                String resJSON = helper.connectToAPIJSON(onesourceEndpoint,null,'GET',null); 
                System.debug(resJSON);
                Map<String,Object> storeMap = (Map<String, Object>) JSON.deserializeUntyped(resJSON);
                
               
                usr.Last_Checked_Store_Info__c = currentTimestamp; 
                usr.Store_Zip__c  = (String)storeMap.get('ZIP'); 
                usr.FulfillerID__c = (String)storeMap.get('FulfillerID'); 
                marketSettings = MarketSettings__c.getInstance(usr.FulfillerID__c);
                if ((marketSettings!=null)) {
                    
                    marketCode = marketSettings.Market_Code__c;
                } else {
                    throw new StoreInfoException('Store information is not configured in custom settings. Look at ' +
                                                 usr.FulfillerID__c+ ' setting in MarketSettings__c.');
                }
                 // build info string 
                usr.AcctNo_ShipTo_ProfitCtr__c = storeMap.get('AccountNo') + '-' + 
                    storeMap.get('Shipto') + '-' + 
                    storeMap.get('ProfitCenter') + '-' + 
                    // NOTE - this is set in custom settings for initial release but will be replaced 
                    marketCode;
                usr.Last_Checked_Store_Info__c = currentTimestamp; 
                usr.Store_Zip__c  = (String)storeMap.get('ZIP'); 
                usr.FulfillerID__c = (String)storeMap.get('FulfillerID'); 
                
                usr.RDC__c = (String)storeMap.get('RDCNUM'); 
                usr.LegacyStoreID__c = (String)storeMap.get('LegacyStoreID'); 
                //REQ-455 - Text Opt In
                usr.LegalEntityName__c = (String)storeMap.get('LegalEntityName');
                UpdateUser(usr);
            }else{
                marketSettings = MarketSettings__c.getInstance(usr.FulfillerID__c);
                if ((marketSettings!=null)) {
                    
                    marketCode = marketSettings.Market_Code__c;
                } else {
                    throw new StoreInfoException('Store information is not configured in custom settings. Look at ' +
                                                 usr.FulfillerID__c+ ' setting in MarketSettings__c.');
                }
            }
            storeInfoObj = new StoreInfoWrapper(usr.AcctNo_ShipTo_ProfitCtr__c);
            storeInfoObj.storeZip = usr.Store_Zip__c; 
            storeInfoObj.fulfillerId = usr.FulfillerID__c; 
            storeInfoObj.RDC = usr.RDC__c; 
            storeInfoObj.legacyStoreID = usr.LegacyStoreID__c;
            //REQ-455 - Text Opt In
            storeInfoObj.legalEntityName = usr.LegalEntityName__c;
          	storeInfoObj.marketCode = marketCode;
            storeInfoObj.OneSourceID = usr.One_Source_ID__c;
            return storeInfoObj;
        } catch (Exception e) {
            system.debug('store info exception ' + e.getMessage());
            new ErrorLogController().createLog(
                new ErrorLogController.Log(
                    'StoreInfo', 'getStoreInfo',
                    'Update User Store Info Exception: ' + e.getMessage() +
                    ' Stack Trace: ' + e.getStackTraceString()
                )
            );
            throw new StoreInfoException('Store information is unavailable for this user Please contact system administrator.',e);
        }
    }
    
    /* getting session id from a visual force page because the aura supplied session id is 
     * not accepted in the call out */
    static public String getSessionIdFromVFPage(){
        PageReference visualforcePage = Page.GetSessionId;
        String content = '{ "sessionId": "123" }';
        if (!Test.IsRunningTest())
        {
            content = visualforcePage.getContent().toString();
        }
        Map<String,Object> sessionInfo = (Map<String, Object>) JSON.deserializeUntyped(content);
        
        return (String)sessionInfo.get('sessionId'); 
    }
    
    static public void UpdateUser(User userToUpdate) {
        String restAPIURL = 'callout:Ashley_Salesforce/services/apexrest/User/StoreInformation/';
        HttpRequest httpRequest = new HttpRequest(); 
        httpRequest.setMethod('POST'); 
        httpRequest.setHeader('Content-Type', 'application/json; charset=utf-8');
        httpRequest.setEndpoint(restAPIURL);  
        httpRequest.setBody(JSON.serialize(userToUpdate));
        String response = '';
        Http http = new Http();   
        HttpResponse httpResponse = http.send(httpRequest);  
        if (httpResponse.getStatusCode() != 200 ) {  
            System.debug(' httpResponse ' + httpResponse.getBody() );  
            throw new CalloutException( httpResponse.getBody() );  
        }
    }
    
}