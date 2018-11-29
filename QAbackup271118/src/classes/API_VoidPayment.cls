/**************************************************************************************************
* Name       : API_VoidPayment
* Purpose    : API class for void callout
***************************************************************************************************
* Author            | Version    | Created Date    | Description
***************************************************************************************************
*Sridhar            | 1.0        | 3/8/2018        | Initial Draft
**************************************************************************************************/
public with sharing class API_VoidPayment {

	public static final String VOID_API_SETTING_NAME = 'VoidPaymentsAPI';
    public static final String PATH_SETTING_NAME = 'ProductAPISetting';
    public class VoidPaymentApiException extends Exception {}

    public static VoidPaymentReponseWrapper VoidPayment(VoidPaymentRequestWrapper reqString) {
		HttpResponse res;
        Http h = new Http();
		HttpRequest req = getHttpRequest();
        String str = JSON.serialize(reqString);
        str = str.replace('Currencyc', 'Currency');
		req.setBody(str);
		res = h.send(req);
		
        if(res.getStatusCode()==200){
        	String jsonString = res.getBody();
        	VoidPaymentReponseWrapper result = (VoidPaymentReponseWrapper)JSON.deserialize(jsonString, VoidPaymentReponseWrapper.class);
			system.debug('Response Status Code: ' + res.getStatusCode() + ', response body: ' +res.getBody());

        	return result;
    	}else{
    		String errorDetail = 'Response Status Code: ' + res.getStatusCode() + ', response body: ' +res.getBody();
            ErrorLogController.Log log = new ErrorLogController.Log('API_PaymentType','getAllPaymentTypes',errorDetail);
            new ErrorLogController().createLog(log);            
    	}
    	return null;
	}


    private static HttpRequest getHttpRequest(){		            
        //Get API key and End Point URL from Custom Settings  
        Integration_Settings__c pmtTypesConf= Integration_Settings__c.getValues(VOID_API_SETTING_NAME);
        if(pmtTypesConf==null){
            throw new VoidPaymentApiException('Payment Types config missing: Custom Setting > Integration Setting' 
                                               + VOID_API_SETTING_NAME);
        }      
        
        // Get endpoint path configuration from custom settings
        ConciergeProductAPISetting__c prodApiSetting = ConciergeProductAPISetting__c.getValues(PATH_SETTING_NAME);
        String path = prodApiSetting.Void_Payment__c;
        
        List<String> strList = new List<String>();
        strList.add(pmtTypesConf.API_Key__c); // add api key to path
        String endPointURL = pmtTypesConf.End_Point_URL__c + String.format(path,strList);
        
        HttpRequest req = new HttpRequest();
        req.setHeader('Content-Type','application/json');
        req.setEndPoint(endPointURL);        
        req.setMethod('POST');  
        req.setHeader('Content-Length','0');                   
        return req;
	}


}