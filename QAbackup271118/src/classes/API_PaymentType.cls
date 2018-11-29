/********************************************************************************************************************
* Class Name   : API_PaymentType
* Description  : API Helper class for Payment Type API.  
* Author       : Moon Cui(Perficient, Inc.)
* Created On   : 02/23/2018
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer                                   Date                   Modification ID      Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
*
**************************************************************************************************************************************/

public with sharing class API_PaymentType {
    public static final String PAYMENT_TYPES_API_SETTING_NAME = 'PaymentTypesAPI';
    public static final String PATH_SETTING_NAME = 'ProductAPISetting';
    public class PaymentTypesApiException extends Exception {}
        
    public static List<PaymentTypeWrapper> getAllPaymentTypes() {
		HttpResponse res;
        Http h = new Http();
		HttpRequest req = getHttpRequest();
		res = h.send(req);
		
        if(res.getStatusCode()==200){
        	String jsonString = res.getBody();
            System.debug('-----> ' + jsonString);
        	List<PaymentTypeWrapper> result = (List<PaymentTypeWrapper>)JSON.deserialize(jsonString, List<PaymentTypeWrapper>.class);
        	return result;
    	}else{
    		String errorDetail = 'Response Status Code: ' + res.getStatusCode() + ', response body: ' +res.getBody();
            System.debug(errorDetail);
            ErrorLogController.Log log = new ErrorLogController.Log('API_PaymentType','getAllPaymentTypes',errorDetail);
            new ErrorLogController().createLog(log);            
    	}
    	return null;
	}

    public static List<PaymentTermWrapper> getPaymentTerm(String paymentType) {
        System.debug('enterd');
        HttpResponse res;
        Http h = new Http();
        HttpRequest req = getHttpRequest(paymentType);
        res = h.send(req);
        
        if(res.getStatusCode()==200){
            String jsonString = res.getBody();
            List<PaymentTermWrapper> result = (List<PaymentTermWrapper>)JSON.deserialize(jsonString, List<PaymentTermWrapper>.class);
            return result;
        }else{
            String errorDetail = 'Response Status Code: ' + res.getStatusCode() + ', response body: ' +res.getBody();
            System.debug(errorDetail);
            ErrorLogController.Log log = new ErrorLogController.Log('API_PaymentType','getPaymentTerm',errorDetail);
            new ErrorLogController().createLog(log);            
        }
        return null;
    }

	private static HttpRequest getHttpRequest(){		            
        //Get API key and End Point URL from Custom Settings  
        Integration_Settings__c pmtTypesConf= Integration_Settings__c.getValues(PAYMENT_TYPES_API_SETTING_NAME);
        if(pmtTypesConf==null){
            throw new PaymentTypesApiException('Payment Types config missing: Custom Setting > Integration Setting' 
                                               + PAYMENT_TYPES_API_SETTING_NAME);
        }      
        
        // Get endpoint path configuration from custom settings
        ConciergeProductAPISetting__c prodApiSetting = ConciergeProductAPISetting__c.getValues(PATH_SETTING_NAME);
        String path = prodApiSetting.Payment_API_Types_Path__c;
        
        // get store info
        StoreInfoWrapper si;
        if(Test.isRunningTest()){
            si = new StoreInfoWrapper('8888300-164-23-SWF');
            si.fulfillerId = '8888300-164';
        }else{
            si = StoreInfo.getStoreInfo();
        }
        
        List<String> strList = new List<String>();
        strList.add(si.fulfillerId); // add fulfiller to path
        strList.add(pmtTypesConf.API_Key__c); // add api key to path
        String endPointURL = pmtTypesConf.End_Point_URL__c + String.format(path,strList); //
        
        System.debug('>>endPointURL>>' + endPointURL);
        HttpRequest req = new HttpRequest();
        req.setHeader('Content-Type','application/json');
        req.setEndPoint(endPointURL);        
        req.setMethod('GET');  
        req.setHeader('Content-Length','0');                   
        return req;
	}

    private static HttpRequest getHttpRequest(String paymentType){                    
        System.debug('=====> ' + paymentType);
        //Get API key and End Point URL from Custom Settings  
        Integration_Settings__c pmtTypesConf= Integration_Settings__c.getValues(PAYMENT_TYPES_API_SETTING_NAME);
        if(pmtTypesConf==null){
            throw new PaymentTypesApiException('Payment Types config missing: Custom Setting > Integration Setting' 
                                               + PAYMENT_TYPES_API_SETTING_NAME);
        }      
        
        // Get endpoint path configuration from custom settings
        ConciergeProductAPISetting__c prodApiSetting = ConciergeProductAPISetting__c.getValues(PATH_SETTING_NAME);
        String path = prodApiSetting.Payment_API_Terms_Path__c;
        
        // get store info
        StoreInfoWrapper si;
        if(Test.isRunningTest()){
            si = new StoreInfoWrapper('8888300-164-23-SWF');
            si.fulfillerId = '8888300-164';
        }else{
            si = StoreInfo.getStoreInfo();
        }
        
        List<String> strList = new List<String>();
        strList.add(si.fulfillerId); // add fulfiller to path
        strList.add(paymentType); // add payment type to path
        strList.add(pmtTypesConf.API_Key__c); // add api key to path
        String endPointURL = pmtTypesConf.End_Point_URL__c + String.format(path,strList); //
        
        System.debug('>>endPointURL>>' + endPointURL);
        HttpRequest req = new HttpRequest();
        req.setHeader('Content-Type','application/json');
        req.setEndPoint(endPointURL);        
        req.setMethod('GET');  
        req.setHeader('Content-Length','0');                   
        return req;
    }

    public class PaymentTermWrapper{
        @auraEnabled public String TermsCode      {get;set;}
        @auraEnabled public String TermsCodeDescription {get;set;}
        @auraEnabled public String TermsPlanNumber  {get;set;}
        @auraEnabled public String ExpirationDays  {get;set;}
    }
	public class PaymentTypeWrapper{
		public String TenderCode      {get;set;}
		public String TenderCodeDescription {get;set;}
		public String DocumentNumber  {get;set;}
	}
	public class PaymentTypesWrapper{
		public List<PaymentTypeWrapper> paymentTypes {get;set;}
		public PaymentTypesWrapper (){
			paymentTypes = new List<PaymentTypeWrapper>();
		}
	}
}