/**************************************************************************************************
* Name       : VoidOrphanPayments
* Purpose    : Batch class for voiding payments
***************************************************************************************************
* Author            | Version    | Created Date    | Description
***************************************************************************************************
*Sridhar            | 1.0        | 3/8/2018        | Initial Draft
**************************************************************************************************/
global class VoidOrphanPayments implements Database.Batchable<sObject>, Database.AllowsCallouts {
	String query;
	global VoidOrphanPayments(String Id){
		query ='SELECT id, Transaction_Number__c, Payment_Type__c, Payment_Amount__c, ReferenceNumber__c, TermsCode__c, Opportunity__r.StageName, OrderNumber__c FROM Cart_Payment_Transaction__c WHERE Transaction_Number__c != null AND Opportunity__r.StageName != \'Closed Won\' AND OrderNumber__c = null AND Id =\''+Id+'\'';
	}

	global VoidOrphanPayments(){
		query ='SELECT id, Transaction_Number__c, Payment_Type__c, Payment_Amount__c, ReferenceNumber__c, TermsCode__c, Opportunity__r.StageName, OrderNumber__c FROM Cart_Payment_Transaction__c WHERE Transaction_Number__c != null AND Opportunity__r.StageName != \'Closed Won\' AND OrderNumber__c = null  AND isvoid__c = false AND Payment_Type__c !=\'cash\'';
	}

	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

	global void execute(Database.BatchableContext BC, List<sObject> scope) {
		List<Cart_Payment_Transaction__c> lstCpt = new List<Cart_Payment_Transaction__c>();
		for(Cart_Payment_Transaction__c cpt : (List<Cart_Payment_Transaction__c>)scope){
			VoidPaymentRequestWrapper vprw = new VoidPaymentRequestWrapper();
			vprw.initiatingTransactionId = cpt.id;
			vprw.AuthorizationId = cpt.Transaction_Number__c;
			vprw.Amount = cpt.Payment_Amount__c;
			vprw.Currencyc = 'USD';
			try{
				VoidPaymentReponseWrapper res = API_VoidPayment.VoidPayment(vprw);	
				if(res !=null){
					cpt.isVoid__c = true;
					lstCpt.add(cpt);
				}	
			}catch(Exception e){
				ErrorLogController.Log log = new ErrorLogController.Log('VoidOrphanPayments','execute',e.getStackTraceString());
            	new ErrorLogController().createLog(log);  
			}
		}
		if(!lstCpt.isEmpty())
			update lstCpt;
		
	}

	global void finish(Database.BatchableContext BC) {
	}
}