/****** v1 | Description: Product API virtual helper, read API conf from custom setting and provide connect method | 12/20/2017 | JoJo Zhao */
public virtual class ProductAPIBaseHelper {
    
    public static final String PRODUCT_API_SETTING_NAME = 'ProductAPISetting';
    public static final String ITEM_DETAIL_API_ENDPOINT_SETTING_NAME = 'SuspendedSalesAPI';
    public static final String PRODUCT_API_ENDPOINT_SETTING_NAME = 'RetailAPIs';
    
    public static final String PRODUCT_REVIEWS_API_ENDPOINT_SETTING_NAME = 'ProductReviewsAPI';
    public static final String PRODUCT_FILTER_API_ENDPOINT_SETTING_NAME = 'ProductFilterAPI';
    public static final String ECOMM_PRICING_API_ENDPOINT_SETTING_NAME = 'EcommPricingAPI';
    
    public ConciergeProductAPISetting__c apiPathConf;
    public Integration_Settings__c apiReviewsConf;
    public Integration_Settings__c apiProductConf;
    public Integration_Settings__c apiItemDetailsConf;
    public Integration_Settings__c apiProductFilterConf;
    public Integration_Settings__c apiEcommPricingConf;
    
    public ProductAPIBaseHelper(){
        
        this.apiPathConf = getAPIPathConf();
        this.apiReviewsConf = getAPIConf(PRODUCT_REVIEWS_API_ENDPOINT_SETTING_NAME);
        this.apiProductConf = getAPIConf(PRODUCT_API_ENDPOINT_SETTING_NAME);
        this.apiItemDetailsConf = getAPIConf(ITEM_DETAIL_API_ENDPOINT_SETTING_NAME);
        this.apiProductFilterConf = getAPIConf(PRODUCT_FILTER_API_ENDPOINT_SETTING_NAME);
        this.apiEcommPricingConf = getAPIConf(ECOMM_PRICING_API_ENDPOINT_SETTING_NAME);
        
    }
    
    /**
*   @description <GET Method to connect Ashely API by using http call out, receive JSON type response, without customer header>
*   @param <sourceURL>
*   @return <returns String value, it is a JSON string>
**/
    public String connectToAPIGetJSON(String sourceURL) {
        
        String resJSON = connectToAPIJSON(sourceURL,null,'GET',null);  
        return formatJSON(resJSON);
    }
    public String formatJSON(String resJSON){
        if(resJSON!=null && resJSON.startsWith('[') && resJSON.endsWith(']')){
            resJSON = resJSON.substring(1,resJSON.length()-1);
        } 
        return resJSON;
    }
    /**
*   @description <GET Method to connect Ashely API by using http call out, receive JSON type response, with customer header>
*   @param <sourceURL>
*   @return <returns String value, it is a JSON string>
**/
    public String connectToAPIGetJSON(String sourceURL,Map<String, String> customHeaders) {
        system.debug('customHeaders-----'+customHeaders);
        system.debug('sourceURL: '+sourceURL);
        String resJSON = connectToAPIJSON(sourceURL,customHeaders,'GET',null);  
        return formatJSON(resJSON);
    }
    
    /**
*   @description <POST Method to connect Ashely API by using http call out, receive JSON type response, with custom header>
*   @param <sourceURL>
*   @return <returns String value, it is a JSON string>
**/
    public String connectToAPIPostJSON(String sourceURL,Map<String, String> customHeaders, String rawPost){
        String resJSON = connectToAPIJSON(sourceURL,customHeaders,'POST',rawPost);  
        
        return resJSON;
    }
    
    /**
*   @description <Method to connect Ashely API by using http call out, receive JSON type response>
*   @param <sourceURL>
*   @return <returns String value, it is a JSON string>
**/
    public String connectToAPIJSON(String sourceURL,Map<String, String> customHeaders, String method, String rawPost) {
        //URLEncoder.encode(String sourceURL);
        system.debug('sourceURL---1---'+sourceURL);
        string sourceURL1 = sourceURL.replaceAll('&#124;','|');
        System.debug(sourceURL1);
        system.debug('rawPost----1--'+rawPost);
        system.debug('method---1---'+method);        
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        if(customHeaders!=null && customHeaders.size()>0)
            for(String headerName:customHeaders.keySet()){
                system.debug('headerName------'+headerName+'----'+customHeaders.get(headerName));
                req.setHeader(headerName,customHeaders.get(headerName));
            }
        req.setHeader('Content-Type','application/json');
        req.setHeader('Accept', 'application/json');
        req.setHeader('Connection','close');
        System.debug('header apiKey:'+req.getHeader('apiKey'));
        
        // string[] StartUrl= sourceURL.split('?');
        // string StartUrlEnd = StartUrl[1];
        //  system.debug('StartUrlEnd--1-'+StartUrlEnd);
        //req.setEndpoint(sourceURL);
      // req.setEndpoint('https://stageapigw.ashleyfurniture.com/inventory/retail?as=8888300-164&sqt=D697-324&#124;1&#124;false');
        req.setEndpoint(sourceURL1);
        system.debug('setEndpoint method---1---'+sourceURL);
        req.setMethod(method);
        
        req.setTimeout(90000);
        if(rawPost!=null){            
            req.setBody(rawPost);
        }
        
        System.debug('req:'+req);
        try{
            HttpResponse res = h.send(req);
            //REQ-438 item 5 and item 9, only return response body.            
            String responseDetail = 'Response Status Code: ' + res.getStatusCode() + ', response body: ' +res.getBody();
            System.debug(responseDetail);
            system.debug('response---1---'+res.getBody());
            return res.getBody();
        }catch(CalloutException ex){     
            System.debug(LoggingLevel.ERROR, 'Failed to Connect Ashely API:'+ex.getMessage());
            new ErrorLogController().createLog(new ErrorLogController.Log('ProductAPIBaseHelper', 'connectToAPIJSON','Failed to Connect Ashely API: ' + ex.getMessage() +' Stack Trace: ' + ex.getStackTraceString()));                   
            
        }
        return null;
    }
    
    
    /**
* @description <get APIKey>                                                        
* @return <returns String value>
**/
    public virtual String getAPIKey(){
        if(apiProductConf!=null){
            return apiProductConf.API_Key__c; 
        }else{
            return '';
        }
    }
    
    
    /**
* @description <get base url of Ashley Retail API>                                                        
* @return <returns String value>
**/
    public virtual String getBaseUrlAPIEndpoint(){      
        if(apiProductConf!=null){
            return apiProductConf.End_Point_URL__c; 
        }else{
            return '';
        }
    }
    
    /**
* @description <get API Endpoint>                                                        
* @return <returns String value>
**/
    public virtual String getAPIEndpoint(String parameterId){      
        return '';
    }
    
    /**
* @description <get APIVersion>                                                        
* @return <returns String value>
**/
    public virtual String getAPIVersion(){
        return '';
    }
    /**
* @description <Method to custom setting value ConciergeProductAPISetting__c>                                                        
* @return <returns String value>
**/
    public ConciergeProductAPISetting__c getAPIPathConf(){
        try{
            ConciergeProductAPISetting__c apiPathConf= ConciergeProductAPISetting__c.getValues(PRODUCT_API_SETTING_NAME);
            if(apiPathConf==null){
                new ErrorLogController().createLog(new ErrorLogController.Log('ProductAPIBaseHelper', 'getAPIPathConf','Without Custom setting for ProductAPISetting'));   
            }
            return apiPathConf;
        }catch(Exception ex){
            System.debug(LoggingLevel.ERROR, 'Failed To get product Path api conf from ConciergeProductAPISetting__c, Error Message:' + ex.getMessage());
            new ErrorLogController().createLog(new ErrorLogController.Log('ProductAPIBaseHelper', 'getAPIPathConf','Failed to get API conf from custom setting: ' + ex.getMessage() +' Stack Trace: ' + ex.getStackTraceString()));   
        }
        return null; 
    }
    
    /**
* @description <Method to custom setting value of Integration_Settings__c>                                                        
* @return <returns String value>
**/
    public Integration_Settings__c getAPIConf(String apiName){
        try{
            Integration_Settings__c apiConf= Integration_Settings__c.getValues(apiName);
            if(apiConf==null){
                new ErrorLogController().createLog(new ErrorLogController.Log('ProductAPIBaseHelper', 'getAPIConf','Without Custom setting for '+apiName));   
            }
            return apiConf;
        }catch(Exception ex){
            System.debug(LoggingLevel.ERROR, 'Failed To get '+apiName+' api conf from Integration_Settings__c, Error Message:' + ex.getMessage());
            new ErrorLogController().createLog(new ErrorLogController.Log('ProductAPIBaseHelper', 'getAPIConf','Failed to get API conf from custom setting: ' + ex.getMessage() +' Stack Trace: ' + ex.getStackTraceString()));   
        }
        return null; 
    }
}