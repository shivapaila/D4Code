/**************************************************************************************************
* Name       : API_CaraAccountUpdates
* Purpose    : Sends Account/Address information to CARA to HOMES when specific fields are updated
***************************************************************************************************
* Author            | REQ    | Created Date    | Description
***************************************************************************************************
*Perficient         |         | 03/05/2018      | Initial Draft
**************************************************************************************************/

public class API_CaraAccountUpdates 
{
	// this flag is used to control within apex context to fire this integration
	// If account and address is created by HOMES, the callout will not be fired
	public static boolean accountsToCARACodeLevelFlag = true;
	public static final string ORDER_UPDATE_NAMED_CREDENTIAL_PRODUCTION = 'Cara_Order_Odata_Prod';
    public static final string ORDER_UPDATE_NAMED_CREDENTIAL_SANDBOX = 'Cara_Order_Odata_Sandbox';
    // set of fields that are included in the integration
    public static final SobjectField[] accountFields = new SobjectField[]{Account.FirstName, Account.LastName, Account.Phone,
                                                        Account.Phone_2__pc, Account.Phone_3__pc, Account.PersonEmail};
    public static final SobjectField[] addressFields = new SobjectField[]{Address__c.Address_Line_1__c, Address__c.Address_Line_2__c, Address__c.City__c,
    													Address__c.State__c, Address__c.Zip_Code__c, Address__c.Country__c};
    // future method to send account information to CARA
    // supports only 100 callouts per context
    @future (callout = true)
    public static void sendAccountsToCara(Set<Id> accountIds)
    {
    	List<AccountWrapper> wrapperList = new List<AccountWrapper>();
		for(Account acc : [Select Id, FirstName, LastName, PersonEmail, Phone, Phone_2__pc, Phone_3__pc
								from Account where Id in :accountIds])
		{
			wrapperList.add(new AccountWrapper(acc));
		}

		callCaraAPI('{"updatedCustomers":' + JSON.serialize(wrapperList) + '}');
    }
    // future method to send account/address information to CARA
    // supports only 100 callouts per context
    @future (callout = true)
    public static void sendAccountsAndAddressesToCara(Set<Id> addressIds)
    {
    	List<AccountAddressWrapper> wrapperList = new List<AccountAddressWrapper>();
    	for(Address__c address : [Select Id, Address_Line_1__c, Address_Line_2__c, City__c, State__c,
										Zip_Code__c, Country__c, AccountId__c, 
										AccountId__r.FirstName, AccountId__r.LastName, AccountId__r.PersonEmail, 
										AccountId__r.Phone, AccountId__r.Phone_2__pc, AccountId__r.Phone_3__pc
									from Address__c where Id in :addressIds ])
		{
			wrapperList.add(new AccountAddressWrapper(address));
		}

		callCaraAPI('{"updatedCustomers":' + JSON.serialize(wrapperList) + '}');
    }

	public static void callCaraAPI(string jsonRequest)
	{
		string namedCredential = Utilities_SalesAndService.isSandbox ? ORDER_UPDATE_NAMED_CREDENTIAL_SANDBOX : ORDER_UPDATE_NAMED_CREDENTIAL_PRODUCTION;
		try
		{
			callAPI(namedCredential, jsonRequest);
		}
		catch(Exception e)
		{
			new ErrorLogController().createLog(
            	new ErrorLogController.Log(
                	'API_CaraAccountUpdates', 
                	'callCaraAPI', 
                	e.getMessage() + 
	            	' Stack Trace: ' + e.getStackTraceString()
            	)
            );
		}
	}

	// makes the http callout
	private static void callAPI(string namedCredential, string requestStr)
	{
		Boolean addErrorMsg = false;
		String errorMsg = '';
		HttpRequest req = new HttpRequest();
		req.setEndpoint('callout:' + namedCredential + '/cara/customers/');
		req.setMethod('POST');
		req.setHeader('Content-Type' ,'application/json');
		req.setBody(requestStr);
		req.setTimeout(20000);
		HttpResponse res = new Http().send(req);
		// status will be 200 even if one of the record is failed, so have to iterate through the response
		if(res.getStatusCode() == 200)
		{
			List<CaraAccountResponse> responseList = (List<CaraAccountResponse>)JSON.deserialize(res.getBody(), List<CaraAccountResponse>.class);
			for(CaraAccountResponse responseW : responseList)
			{
				if(!responseW.IsSuccess)
				{
					addErrorMsg = true;
					errorMsg += responseW.ResponseMessage;
				}
			}
			if(addErrorMsg)
			{
				errorMsg = errorMsg.length() > 32000 ? errorMsg.substring(0, 32000) + '-----Trimmed-----' : errorMsg;
				new ErrorLogController().createLog(
                	new ErrorLogController.Log(
                    	'API_CaraAccountUpdates', 
                    	'callAPI', 
                    	errorMsg
                	)
                );
			}
		}
		// if status code is not 200, server could be down or unavailable
		else
		{
			new ErrorLogController().createLog(
            	new ErrorLogController.Log(
                	'API_CaraAccountUpdates', 
                	'callAPI', 
                	res.getStatusCode() + ' - ' + res.getStatus() + ' - ' + res.getBody()
            	)
            );
		}
	}

	// used to serialize Account information alone
	public class AccountWrapper
	{
		public string sfGuestId;
		public string firstName;
		public string lastName;
		public string phone;
		public string phone2;
		public string phone3;
		public string email;

		public AccountWrapper(Account acc)
		{
			sfGuestId = acc.Id;
			firstName = acc.FirstName;
			lastName = acc.LastName;
			phone = acc.Phone != null 
							? TwilioSendSMSController.removePhoneFormatting(acc.Phone)
								: null;
			phone2 = acc.Phone_2__pc != null 
							? TwilioSendSMSController.removePhoneFormatting(acc.Phone_2__pc)
								: null;
			phone3 = acc.Phone_3__pc != null 
							? TwilioSendSMSController.removePhoneFormatting(acc.Phone_3__pc)
								: null;
			email = acc.PersonEmail;
		}
	}

	// to serialize account and address information together
	public class AccountAddressWrapper
	{
		public string sfGuestId;
		public string firstName;
		public string lastName;
		public string addressLine1;
		public string addressLine2;
		public string city;
		public string state;
		public string zip;
		public string country;
		public string phone;
		public string phone2;
		public string phone3;
		public string email;

		public AccountAddressWrapper(Address__c address)
		{
			sfGuestId = address.AccountId__c;
			firstName = address.AccountId__r.FirstName;
			lastName = address.AccountId__r.LastName;
			phone = address.AccountId__r.Phone != null 
							? TwilioSendSMSController.removePhoneFormatting(address.AccountId__r.Phone)
								: null;
			phone2 = address.AccountId__r.Phone_2__pc != null 
							? TwilioSendSMSController.removePhoneFormatting(address.AccountId__r.Phone_2__pc)
								: null;
			phone3 = address.AccountId__r.Phone_3__pc != null 
							? TwilioSendSMSController.removePhoneFormatting(address.AccountId__r.Phone_3__pc)
								: null;
			email = address.AccountId__r.PersonEmail;
			addressLine1 = address.Address_Line_1__c;
			addressLine2 = address.Address_Line_2__c;
			city = address.City__c;
			state = address.State__c;
			zip = address.Zip_Code__c;
			country = address.Country__c;
		}
	}

	public class CaraAccountResponse
	{
		public string SFGuestID;
		public boolean IsSuccess;
		public string ResponseMessage;
	}
}