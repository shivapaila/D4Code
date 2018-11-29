public class API_CCPayment {
    
    public static final String CC_API_SETTING_NAME = 'CCPaymentAPI';
    public static final String PATH_SETTING_NAME = 'ProductAPISetting';
    public class CCPaymentApiException extends Exception {}

    public static CCPaymentResponseWrapper makeCCPayment(CCPaymentRequestWrapper ccpayReqWrap) {
        CCPaymentResponseWrapper errorResponse = new CCPaymentResponseWrapper();
		HttpResponse res= new HttpResponse();
        Http h = new Http();
		HttpRequest req = getHttpRequest();
        String str = JSON.serialize(ccpayReqWrap);
        system.debug('cc input fields and values-->'+str);
        req.setTimeout(120000);
		req.setBody(str);
        System.debug('=====> ' + req.getBody());
		res = h.send(req);
		//res.setStatusCode(200);
		//res.setBody('{"TransactionTime":"084311","TransactionDate":"053018","TermsCodeDescription":"Visa Card","TermsCode":"VM ","TenderCode":"VISA","Status":"COMPLETE","SalesGuid":"a9999583-c92d-4547-ad15-82725f25378f","ReferenceNumber":"30484588","PaymentReceived":true,"FinanceTerms":"","ExpirationDays":0,"DocumentNumber":400,"CashGroup":0,"AuthorizationNumber":"127513","Amount":100.0,"AccountNumber":"xxxx-xxxx-xxxx-0119","AccountLookUpRequestID":""}');
        if(res.getStatusCode()==200){
        	String jsonString = res.getBody();
        	system.debug('cc output -->'+jsonString);
            try{
                CCPaymentResponseWrapper result = (CCPaymentResponseWrapper)JSON.deserialize(jsonString, CCPaymentResponseWrapper.class);
                system.debug('Response Status Code: ' + res.getStatusCode() + ', response body: ' +res.getBody());
                if( result.PaymentReceived == null || !result.PaymentReceived){
                    errorResponse.Status='Credit/Debit Card Payment Declined';
                }else{
                    return result;        
                }
            }catch(Exception e){
                //CCPaymentResponseWrapper result = new CCPaymentResponseWrapper();
                //errorResponse.PaymentReceived = false;
                //return result;
                errorResponse.Status = 'Something went wrong - Try again';
            }
    	}else if(res.getStatusCode()==408){
            errorResponse.Status = 'Timed Out - Terminal could not be reached';
        }else if(res.getStatusCode()==500){
            errorResponse.Status = 'Timed Out - Terminal could not be reached';
        }else{
            errorResponse.Status = 'Something went wrong - Try again';
    		//String errorDetail = 'Response Status Code: ' + res.getStatusCode() + ', response body: ' +res.getBody();
      //      system.debug('Response Status Code: ' + res.getStatusCode() + ', response body: ' +res.getBody());
      //      ErrorLogController.Log log = new ErrorLogController.Log('API_CCPayment','makeCCPayment',errorDetail);
      //      new ErrorLogController().createLog(log);            
    	}
        String errorDetail = 'Response Status Code: ' + res.getStatusCode() + ', response body: ' +res.getBody();
        system.debug('Response Status Code: ' + res.getStatusCode() + ', response body: ' +res.getBody());
            
    	return errorResponse;
	}

	public static CCVoidPaymentResponseWrapper voidCCPayment(CCVoidPaymentRequestWrapper ccpayReqWrap) {
		HttpResponse res;
        Http h = new Http();
		HttpRequest req = getHttpRequest();
        String str = JSON.serialize(ccpayReqWrap);
        system.debug('void cc input -->'+str);
        req.setTimeout(120000);
		req.setBody(str);
		res = h.send(req);
        String jsonString = res.getBody();
		system.debug('cc output -->'+jsonString);
        if(res.getStatusCode()==200){
        	//String jsonString = res.getBody();
        	CCVoidPaymentResponseWrapper result = (CCVoidPaymentResponseWrapper)JSON.deserialize(jsonString, CCVoidPaymentResponseWrapper.class);
			system.debug('Response Status Code: ' + res.getStatusCode() + ', response body: ' +res.getBody());
	       	return result;
    	}else{
    		String errorDetail = 'Response Status Code: ' + res.getStatusCode() + ', response body: ' +res.getBody();
            system.debug('Response Status Code: ' + res.getStatusCode() + ', response body: ' +res.getBody());
            ErrorLogController.Log log = new ErrorLogController.Log('API_CCPayment','makeCCPayment',errorDetail);
            new ErrorLogController().createLog(log);            
    	}
    	return null;
	}

    public static List<CCSalesLookupResponseWrapper> checkOrphanPayment(CCPaymentRequestWrapper ccpayReqWrap) {
        HttpRequest req = getHttpRequest();
        Http h = new Http();
        String endpoint = req.getEndpoint();
        endpoint = endpoint.replace('?', '/'+ccpayReqWrap.SalesGuid+'?');
        req.setEndpoint(endpoint);
        req.setMethod('GET');
        HttpResponse res = h.send(req);
        String jsonString = res.getBody();
        if(res.getStatusCode()==200){
            List<CCSalesLookupResponseWrapper> result = (List<CCSalesLookupResponseWrapper>)JSON.deserialize(jsonString, List<CCSalesLookupResponseWrapper>.class);
            system.debug('Response Status Code: ' + res.getStatusCode() + ', response body: ' +res.getBody());
            return result;
        }else{
            String errorDetail = 'Response Status Code: ' + res.getStatusCode() + ', response body: ' +res.getBody();
            system.debug('Response Status Code: ' + res.getStatusCode() + ', response body: ' +res.getBody());
            ErrorLogController.Log log = new ErrorLogController.Log('API_CCPayment','makeCCPayment',errorDetail);
            new ErrorLogController().createLog(log);            
        }
        return null;

    }

    private static HttpRequest getHttpRequest(){		            
        //Get API key and End Point URL from Custom Settings  
        Integration_Settings__c pmtTypesConf= Integration_Settings__c.getValues(CC_API_SETTING_NAME);
        if(pmtTypesConf==null){
            throw new CCPaymentApiException('Payment Types config missing: Custom Setting > Integration Setting' 
                                               + CC_API_SETTING_NAME);
        }      
        
        // Get endpoint path configuration from custom settings
        ConciergeProductAPISetting__c prodApiSetting = ConciergeProductAPISetting__c.getValues(PATH_SETTING_NAME);
        String path = prodApiSetting.CC_Sales_API_Path__c;
        
        StoreInfoWrapper si;
        if(Test.isRunningTest()){
            si = new StoreInfoWrapper('8888300-164-23-SWF');
            si.fulfillerId = '8888300-164';
        }else{
            si = StoreInfo.getStoreInfo();
        }

        List<String> strList = new List<String>();
        strList.add(si.fulfillerId);
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