/* *******************************************************************************************************************
* Class Name   : FppTypesCallOutMock
* Description  : Http Call Out Mock test class for Asheley Product HomeStore - Warranty-Types API .
* Author       : Theyagarajan Sadhasivam (Perficient, Inc.)
* Created On   : 01/24/2018
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer                                   Date                   Modification ID      Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
*
**************************************************************************************************************************************///
@isTest
global class FppTypesCallOutMock implements HttpCalloutMock {
    private String fetchType;
    /**
    * @description <Constructor to set api type> 
    **/
    global FppTypesCallOutMock(String apiType){
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
            
            FppTypesWrapper fppTypes;
            
            if(fetchType == 'JSONExceptionTest'){
                res.setBody('Non JSON format String to make it throw JSONException when do the JSON Parse');
            }else{
                fppTypes = preparefpp();
                String bodyContent = JSON.serialize(fppTypes);
                res.setBody(bodyContent);
            }
            res.setStatusCode(200);
            return res;
        }
    }


        
    public static FppTypesWrapper preparefpp(){
        
           /* Sample Data
{
    "items": [
        {
            "Warrantyitem": "*ADJ5Y NT"
        },
        {
            "Warrantyitem": "*ADJPRO NT"
        }
    ]
}

*/
        
        FppTypesWrapper fpp = new FppTypesWrapper();
        String resJSON = '{"items": [{"Warrantyitem": "*ADJ5Y NT"},{"Warrantyitem": "*ADJPRO NT"}]}';
        if(resJSON.startsWith('[') && resJSON.endsWith(']')){
            resJSON = resJSON.substring(1,resJSON.length()-1);
        }
        
        JSONParser parser = JSON.createParser(resJSON);
         fpp=(FppTypesWrapper)parser.readValueAs(FppTypesWrapper.class);
        return fpp;
    }
    
}