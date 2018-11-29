/**************************************************************************************************
* Name       : TwilioRetrySoonerScheduler
* Purpose    : will pick up open sooner Tasks and retry those SMS again upto a count of 3
***************************************************************************************************
* Author            | ModificationID    | Created Date    | Description
***************************************************************************************************
*Perficient         | REQ-195        	| 2/27/2018      | Initial Draft
**************************************************************************************************/

global class TwilioRetrySoonerScheduler implements Schedulable 
{
	String queryStr;

	global TwilioRetrySoonerScheduler()
	{
		queryStr = Label.TwilioSoonerPollingBatch;
	}

	global TwilioRetrySoonerScheduler(String customQuery)
	{
		queryStr = customQuery;
	}

	global void execute(SchedulableContext sc) 
	{
		database.executebatch(new TwilioRetrySoonerBatch(queryStr), 1);	
	}
}