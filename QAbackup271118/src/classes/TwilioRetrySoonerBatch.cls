/**************************************************************************************************
* Name       : TwilioRetrySoonerBatch
* Purpose    : will pick up open sooner Tasks and retry those SMS again upto a count of 3
***************************************************************************************************
* Author            | ModificationID    | Created Date    | Description
***************************************************************************************************
*Perficient         | REQ-195        	| 2/27/2018      | Initial Draft
**************************************************************************************************/

global class TwilioRetrySoonerBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful 
{
	
	String query;
	Set<string> closeStatuses = new Set<String>(Label.TwilioSMSDeliveredStatus.split(','));
	Set<string> retryStatuses = new Set<String>(Label.TwilioSMSRetryStatus.split(','));

	global TwilioRetrySoonerBatch(string queryStr) 
	{
		query = queryStr;
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) 
	{
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<sObject> scope) 
   	{
		List<Task> tasksToUpdate = new List<Task>();
		TwilioRestClient client = new TwilioRestClient(API_TwilioClient.TWILIO_ACCOUNT_ID, API_TwilioClient.TWILIO_TOKEN);

		for(Task t : (List<Task>) scope)
		{
			TwilioMessage msg;
			if(t.Twilio_Message_Id__c != null && t.Twilio_Message_Id__c != '')
				msg = client.getAccount().getMessage(t.Twilio_Message_Id__c);
			// when API_Sooner cls sent the SMS, if the delivery report was sent before the task was created (edge case)
			// task would not have been updated yet with the delivery status. For those tasks, get all the message status for last 24 hours
			// and check if it is delivered, if so mark the task completed and no need to retry
			if(msg != null && closeStatuses.contains(msg.getStatus().toLowercase()))
			{
				t.Status = 'Completed';
				tasksToUpdate.add(t);
			}
			// retry the non-delivered messages
			else if(msg == null || retryStatuses.contains(msg.getStatus().toLowercase()))
			{
				API_TwilioClient.TwilioSmsWrapper message = new API_TwilioClient.TwilioSmsWrapper(t);
				message = API_TwilioClient.sendSMSWithCallback(message);
				t.ActivityDate = system.today();
				t.Twilio_Message_Id__c = message.twilioMessageId;
				t.Sooner_Msg_Retry_Count__c ++;
				tasksToUpdate.add(t);
			}
		}

		if(!tasksToUpdate.isEmpty())
		{
			Database.update(tasksToUpdate, false);
		}
	}
	
	global void finish(Database.BatchableContext BC) 
	{
	
	}
}