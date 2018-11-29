/**************************************************************************************************
* Name       : ConciergeTaskNewController
* Purpose    : Servier-Side Controller for ConciergeTaskNew and ConciergeAppointmentNew components
***************************************************************************************************
* Author            | Version    | Created Date    | Description
***************************************************************************************************
*Perficient         | 1.0        | 2/20/2018      | Initial Draft
**************************************************************************************************/
public with sharing class ConciergeTaskNewController 
{
	// Creates Event
	@auraEnabled
	public static ResultWrapper createEvent(Event eventRecord)
	{
		try
		{
			if(eventRecord != null)
			{
				eventRecord.OwnerId = userinfo.getUserId();
				insert eventRecord;
				return new ResultWrapper('200', 'SUCCESS', eventRecord.Id);
			}
			else
			{
				return new ResultWrapper('400', 'Task Record is empty', '');
			}
		}
		catch(Exception e)
		{
			return new ResultWrapper('400', e.getMessage(), '');
		}
	}
	// Creates Task
	@auraEnabled
	public static ResultWrapper createTask(Task taskRecord)
	{
		try
		{
			if(taskRecord != null)
			{
				taskRecord.OwnerId = userinfo.getUserId();
				insert taskRecord;
				return new ResultWrapper('200', 'SUCCESS', taskRecord.Id);
			}
			else
			{
				return new ResultWrapper('400', 'Task Record is empty', '');
			}
		}
		catch(Exception e)
		{
			return new ResultWrapper('400', e.getMessage(), '');
		}
	}
    //REQ-479
    @auraEnabled
	public static Account getCustomer(String customerId)
    {
        List<Account> CustAcc=[Select Id,Name from Account where Id=:customerId];
        if(!CustAcc.isEmpty()){
            return CustAcc[0];
        }
        else{
            return null;
        }
    }

	// Result back to Lightning JS controller
	public class ResultWrapper
	{
		@auraEnabled public String resultCode {get;set;}
		@auraEnabled public String resultMsg {get;set;}
		@auraEnabled public String recordId {get;set;}

		public ResultWrapper(String code, String msg, String rId)
		{
			resultCode = code;
			resultMsg = msg;
			recordId = rId;
		}
	}
}