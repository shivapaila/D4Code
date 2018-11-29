/* This is a controller class for NewCaseLineFromCase lightning component which has a botton to launch a new Case Line Item 
screen populated with default values from the case and associated order. The Component is added to the Case Lightning Page.*/

public with sharing class NewCaseLineFromCaseController {
	@AuraEnabled
	public static InitializationDataResponse getInitializationData(Id caseId) {
		InitializationDataResponse response = new InitializationDataResponse();
		try{
			Case caseInContext = [Select Id, Sales_order__c from Case where Id =: caseId];
			response.caseId = caseInContext.Id;
			if(caseInContext.Sales_order__c != null){
				SalesOrder__x order = SalesOrderDAO.getOrderByExternalId(caseInContext.Sales_order__c);
				if(order != null){
					response.salesOrderNumber = order.phhSalesOrder__c;
					response.fulfillerID = order.fulfillerID__c;
				} 
			}
			response.isSuccess = true;
		}
		catch(Exception ex){
			response.isSuccess = false;
			response.errorMessage = ex.getMessage();
		}
		return response;
		
	}

	public class InitializationDataResponse implements Attributable{
		@AuraEnabled
		public Id caseId {get;set;}
		@AuraEnabled
		public String salesOrderNumber {get;set;}
		@AuraEnabled
		public boolean isSuccess {get;set;}
		@AuraEnabled
		public String errorMessage {get;set;}
		@AuraEnabled
		public String fulfillerID {get;set;}

	}
}