public class API_PaymentTerminal {
	public static final String PAYMENT_TERMINAL_API_SETTING_NAME = 'PaymentTerminalAPI';
    public static final String PATH_SETTING_NAME = 'ProductAPISetting';
    public class PaymentTerminalApiException extends Exception {}
    
    public static PaymentTerminalWrapper getPaymentTerminal() {
		HttpResponse res;
        Http h = new Http();
		HttpRequest req = getHttpRequest();
		res = h.send(req);
		
        if(res.getStatusCode()==200){
        	String jsonString = res.getBody();
        	PaymentTerminalWrapper result = (PaymentTerminalWrapper)JSON.deserialize(jsonString, PaymentTerminalWrapper.class);
			system.debug('Response Status Code: ' + res.getStatusCode() + ', response body: ' +res.getBody());
        	return result;
    	}else{
    		String errorDetail = 'Response Status Code: ' + res.getStatusCode() + ', response body: ' +res.getBody();
            system.debug('Response Status Code: ' + res.getStatusCode() + ', response body: ' +res.getBody());
            ErrorLogController.Log log = new ErrorLogController.Log('API_PaymentTerminal','getPaymentTerminal',errorDetail);
            new ErrorLogController().createLog(log);            
    	}
    	return null;
	}
    
    private static HttpRequest getHttpRequest(){		            
        //Get API key and End Point URL from Custom Settings  
        Integration_Settings__c pmtTypesConf= Integration_Settings__c.getValues(PAYMENT_TERMINAL_API_SETTING_NAME);
        if(pmtTypesConf==null){
            throw new PaymentTerminalApiException('Payment Types config missing: Custom Setting > Integration Setting' 
                                               + PAYMENT_TERMINAL_API_SETTING_NAME);
        }      
        
        // Get endpoint path configuration from custom settings
        ConciergeProductAPISetting__c prodApiSetting = ConciergeProductAPISetting__c.getValues(PATH_SETTING_NAME);
        String path = prodApiSetting.Payment_Terminal__c;
        
        // get store info
        StoreInfoWrapper si;
        if(Test.isRunningTest()){
            si = new StoreInfoWrapper('8888300-164-23-SWF');
            si.fulfillerId = '8888300-164';
        }else{
            si = StoreInfo.getStoreInfo();
        }

        User currentuser = [SELECT Id, RSA_iPad_Device_Name__c FROM User WHERE Id =:UserInfo.getUserId()];
        List<String> strList = new List<String>();
        strList.add(si.fulfillerId); // add fulfillerId to path
        strList.add(currentuser.RSA_iPad_Device_Name__c);
        strList.add(pmtTypesConf.API_Key__c); // add api key to path
        String endPointURL = pmtTypesConf.End_Point_URL__c + String.format(path,strList);
        
        HttpRequest req = new HttpRequest();
        req.setHeader('Content-Type','application/json');
        system.debug('endpointurlpayemnt' +endPointURL );
        req.setEndPoint(endPointURL);        
        req.setMethod('GET');  
        req.setHeader('Content-Length','0');                   
        return req;
	}
}