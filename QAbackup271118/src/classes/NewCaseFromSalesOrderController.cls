/* This is a controller class for NewCaseFromSalesOrder Lightning Component. The Component is used to initilize a new case screen where  
 * the sales order, Account and Contact fields on the case are defaulted to records in context. The Component is launced from the "New Case" 
 * button on Sales Order Page Layout. Since the Sales Order field (external lookup) can't be defaulted directly, a temporary text field is used
 * for the default and the value on that field is copied to the Sales Order lookup on save in case trigger.
 */
public without sharing class NewCaseFromSalesOrderController {
	@AuraEnabled
	public static NewCaseInfo getOrderData(Id salesforceOrderId) {
		NewCaseInfo newCaseInfo = new NewCaseInfo();
		try{
			SalesOrder__x order = SalesOrderDAO.getOrderById(salesforceOrderId);
			newCaseInfo.orderExternalId = order.ExternalId;
			newCaseInfo.accountId = order.phhGuestID__c;

			//opulate contact id
			List<Contact> contacts = [Select Id from Contact where AccountId =: order.phhGuestID__c limit 2];
			if(contacts.size() == 1){
				newCaseInfo.contactId = contacts[0].Id;
			}
			newCaseInfo.isSuccess = true;
		}
		catch(Exception ex){
			newCaseInfo.isSuccess = false;
			newCaseInfo.errorMessage = ex.getMessage();
		}

		return newCaseInfo;
	}

	public class NewCaseInfo implements Attributable{
        @AuraEnabled
		public string orderExternalId {get;set;}
        @AuraEnabled
		public Id accountId {get;set;}
        @AuraEnabled
		public Id contactId {get;set;}
        @AuraEnabled
		public boolean isSuccess {get;set;}
        @AuraEnabled
		public string errorMessage {get;set;}
	}
}