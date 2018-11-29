/* *******************************************************************************************************************
* Class Name   : ATPCallOutMock
* Description  : Http Call Out Mock test class for ATP API .
* Author       : Theyagarajan Sadhasivam (Perficient, Inc.)
* Created On   : 01/24/2018
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer                                   Date                   Modification ID      Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
*
**************************************************************************************************************************************///
@isTest
global class ATPCallOutMock implements HttpCalloutMock {
    private String fetchType;
    /**
    * @description <Constructor to set api type> 
    **/
    global ATPCallOutMock(String apiType){

        this.fetchType = apiType;
    }
    
    /**
    * @description <Implement the interface HttpCalloutMock's respond method to return mock response>
    * @return <return is the Mocked JSON string or throw a CalloutException>
    **/
	global HTTPResponse respond(HTTPRequest req) {

        if(fetchType == 'CalloutExceptionTest'){
            CalloutException e = (CalloutException)CalloutException.class.newInstance();
            e.setMessage('Throw CalloutException Test. Unauthorized endpoint, please check Setup->Security->Remote site settings.');
            throw e;
        }else{
            HttpResponse res = new HttpResponse();
            
            res.setHeader('Content-Type', 'application/json');
            
            ATPWrapper atpWrapper;
            
            if(fetchType == 'JSONExceptionTest'){
                res.setBody('Non JSON format String to make it throw JSONException when do the JSON Parse');
            }else{
                atpWrapper = prepareresponse();
                String bodyContent = JSON.serialize(atpWrapper);
                res.setBody(bodyContent);
            }
            res.setStatusCode(200);
            return res;
        }
    }


        
    public static ATPWrapper prepareresponse(){
        
        
        ATPWrapper wrap = new ATPWrapper();
        String resJSON = '{"properties": { "accountShipTo": "8888300-164","postalCode": "30004","skuQuantity": "1200014|1|false"},"entities": [{"sku": "1200014","message": "Usually ships in 4 to 8 days","bestDate": "2018-05-12T00:00:00"}]}';
       
        
        JSONParser parser = JSON.createParser(resJSON);
         wrap=(ATPWrapper)parser.readValueAs(ATPWrapper.class);
        return wrap;
    }
    
}