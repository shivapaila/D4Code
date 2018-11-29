/* *******************************************************************************************************************
* Class Name   : TwilioCallback
* Description  : Twilio will report Sooner SMS staus back to this callback url
* Author       : Sorna (Perficient, Inc.)
* Created On   : 1/14/2017
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer					Date 			Modification ID 			Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* Sorna						02/09/2018		REQ-195						Twilio will report Sooner SMS status back to this callback url
**************************************************************************************************************************************/

@RestResource(urlMapping='/twilioCallback')
global class TwilioCallback
{
	@HttpPost
    global static void reportSMSStatus()
    {
        try
        {
	        String expectedSignature = RestContext.request.headers.get('X-Twilio-Signature');
	        String url = 'https://' + RestContext.request.headers.get('Host') + '/services/apexrest' + RestContext.request.requestURI;
	        Map <String, String> params = RestContext.request.params;
	        
	       // Validate signature
	        
	        if (validateRequest(expectedSignature, url, params))
	        {
	            String msgId = params.get('SmsSid');
	            if(msgId != null && msgId != '')
	            {
	                List<Task> sentSMSTasks = [Select Id, Status from Task where Is_Sooner__c = :true and Twilio_Message_Id__c = :msgId];
	                if(sentSMSTasks.size() == 1)
	                {
	                    if(params.get('SmsStatus') == 'Delivered')
	                    {
	                    	sentSMSTasks[0].Status = 'Completed';
	                    	update sentSMSTasks[0];
	                	}
	                    RestContext.response.statusCode = 200;
	            		RestContext.response.responseBody = Blob.valueOf('Success');
	            		return;
	                }
	                else if(sentSMSTasks.isEmpty() || sentSMSTasks.size() > 1)
	                {
	                	RestContext.response.statusCode = 300;
	            		RestContext.response.responseBody = Blob.valueOf('No SMS ID or more than one SMS ID found');
	            		return;
	                }
	            }
	            else
	            {
	            	RestContext.response.statusCode = 400;
	            	RestContext.response.responseBody = Blob.valueOf('Bad Request');
	            	return;
	            }
	        }
	        else
	        {
	            RestContext.response.statusCode = 401;
	            RestContext.response.responseBody = Blob.valueOf('Signature did not match');
	            return;
	        }
    	}
    	catch(Exception e)
    	{
    		RestContext.response.statusCode = 500;
            RestContext.response.responseBody = Blob.valueOf('Internal Server Error');
            return;
    	}
    }
    // an entry method for test class bypass
    private static boolean validateRequest(string expectedSignature, string url, Map<string, string>params)
    {
    	if(!Test.isRunningTest())
    	{
    		TwilioRestClient client = new TwilioRestClient(API_TwilioClient.TWILIO_ACCOUNT_ID, API_TwilioClient.TWILIO_TOKEN);
    		return client.validateRequest(expectedSignature, url, params);
    	}
    	else
    	{
    		return true; // for test class
    	}
    }
}