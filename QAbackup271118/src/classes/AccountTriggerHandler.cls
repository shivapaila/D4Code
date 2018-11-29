/**************************************************************************************************
* Name       : AccountTriggerHandler
* Purpose    : TriggerHandler for Account
***************************************************************************************************
* Author            | REQ    | Created Date    | Description
***************************************************************************************************
*Perficient         |         | 03/05/2018      | Initial Draft
**************************************************************************************************/

public class AccountTriggerHandler 
{
	public static void afterUpdate(Map<Id, Account> oldMap, Map<Id, Account> newMap)
	{
		Set<Id> accountIdsToSendCARA = new Set<Id>();
		for(Id accountId : newMap.keySet())
		{
			// if any integration fields are changed, send the account to CARA
			if(newMap.get(accountId).IsPersonAccount 
				&& hasIntegrationFieldsChanged(oldMap.get(accountId), newMap.get(accountId)))
			{
				accountIdsToSendCARA.add(accountId);
			}
		}
		// custom setting flag to switch on/off integration
		// probably for a bulk load of more than 10K records
		if(Trigger_Integration__c.getInstance().Account_Updates_to_CARA__c
				&& API_CaraAccountUpdates.accountsToCARACodeLevelFlag
				&& !accountIdsToSendCARA.isEmpty() && !system.isBatch() && !system.isFuture())
		{
			API_CaraAccountUpdates.sendAccountsToCara(accountIdsToSendCARA);
		}
	}

	// method to check if any integration fields are changed; list of integration fields are in API_CaraAccountUpdates.cls
	private static boolean hasIntegrationFieldsChanged(Account oldAccount, Account newAccount)
	{
		for(SObjectField sf : API_CaraAccountUpdates.accountFields)
		{
			if(oldAccount.get(sf) != newAccount.get(sf))
			{
				return true;
			}
		}
		return false;
	}
}