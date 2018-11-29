/* *******************************************************************************************************************
* Class Name   : TwilioClientSmsBatch
* Description  : Batch class to process Twilio API messages.
* Author       : Magdiel Herrera (Perficient, Inc.)
* Created On   : 01/19/2018
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer                                   Date                   Modification ID      Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* Sorna                                       02/27/2018              REQ-195             Added logic to create sooner msg
**************************************************************************************************************************************/
global class TwilioClientSmsBatch implements 
	Database.batchable<API_TwilioClient.TwilioSmsWrapper>, Database.AllowsCallouts, Database.Stateful{
 
 global List<API_TwilioClient.TwilioSmsWrapper> SmsList;
 global Boolean requestCallBack;
 global Boolean isSooner;
 
 public TwilioClientSmsBatch(List<API_TwilioClient.TwilioSmsWrapper> SmsListParam){
   this.SmsList = SmsListParam;
 }

 public TwilioClientSmsBatch(List<API_TwilioClient.TwilioSmsWrapper> SmsListParam, Boolean isCallBack, Boolean sooner){
   this.SmsList = SmsListParam;
   this.requestCallBack = isCallBack;
   this.isSooner = sooner;
 }
 
 global Iterable<API_TwilioClient.TwilioSmsWrapper> start(Database.BatchableContext bc) {
   return SmsList;
 }
 
 global void execute(Database.BatchableContext bc, List<object> scope) {
 	// process one message at a time
  	API_TwilioClient.TwilioSmsWrapper message = (API_TwilioClient.TwilioSmsWrapper)scope[0];
    try
    {
        if(requestCallBack)
        {
            message = API_TwilioClient.sendSMSWithCallback(message);
            // REQ-195
            if(
              //message.isSuccess && 
              isSooner)
            {
                API_Sonner.createSoonerTask(message);
            }
        }
        else
        {
            message = API_TwilioClient.sendSMS(message);
        }
    }
    catch(Exception ex){
      message.isSuccess = false;
      message.errorMessage = ex.getMessage();
    }
 }
 
 global void finish(Database.BatchableContext BC) {
   //Add post-processing logic
 }
 
}