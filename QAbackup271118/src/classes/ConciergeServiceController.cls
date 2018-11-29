/* *******************************************************************************************************************
* Class Name   : ConciergeServiceController
* Description  : This is lightning controller class that communicates with the Concierge Service lightning component
*				
* Author       : Sriram (Perficient, Inc.)
* Created On   : 07/05/2018
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer                                   Date                   Modification ID      Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* 
**************************************************************************************************************************************/
public class ConciergeServiceController {

	public static final String OPPORTUNITY_STAGE_PAYMENT = 'Payment Process Started';

   /*
   	*	Get the RSA Account information for the current User
   	*	- RSA Id is retrieved from the User Object
   	*	- For profit center, the StoreInfo class is leveraged
   	*/
	@AuraEnabled
	public static RSAAccountInfoWrapper getRSAAccountInfo() {
		RSAAccountInfoWrapper rsaAccountInfo = null;
		try {
			User currentUser = [Select RSA_ID__c from user where Id = :UserInfo.getUserId()];
			StoreInfoWrapper storeInfo = StoreInfo.getStoreInfo();
			rsaAccountInfo = new RSAAccountInfoWrapper();
			rsaAccountInfo.rsaName = UserInfo.getName();
			rsaAccountInfo.rsaId = currentUser.RSA_ID__c;
			rsaAccountInfo.profitCenter = storeInfo.profitCtr;
			rsaAccountInfo.marketCode = storeInfo.marketCode;
		} catch (Exception ex){
			System.debug(LoggingLevel.ERROR, 'Failed to retrieve RSA Account Info: '+ ex.getMessage());
			ErrorLogController.createLogFuture('ConciergeServiceController', 'getRSAAccountInfo', 'Failed to retrieve RSA Account Info: ' + ex.getMessage() +  ' Stack Trace: ' + ex.getStackTraceString() );			
			throw new AuraHandledException(ex.getMessage());
		}
		return rsaAccountInfo;
	}	

   /*
   	*	Is the Opportunity(Cart) for the Guest (Account) in payment stage ?
   	*/
	@AuraEnabled
	public static Boolean isPaymentStage(String guestId) {
		try {
			Opportunity opportunity = null;
	        for (Opportunity o : [	SELECT Id, StageName 
		                            FROM Opportunity 
		                            WHERE AccountId=:guestId 
		                            AND StageName != 'Closed Won' 
		                            AND StageName != 'Closed Lost'
		                            AND StageName != 'Sale Suspended'
		                            AND createdDate=LAST_N_DAYS:30]){
	        	opportunity = o;
	        }
			return (opportunity!=null && OPPORTUNITY_STAGE_PAYMENT.equals(opportunity.StageName));
		} catch (Exception ex){
			System.debug(LoggingLevel.ERROR, 'Failed to retrieve opportunity for guest Id ' + guestId + ' : '+ ex.getMessage());
			ErrorLogController.createLogFuture('ConciergeServiceController', 'isPaymentStage', 'Failed to retrieve opportunity for guest Id ' + guestId + ' : '+ ex.getMessage() + ' Stack Trace: ' + ex.getStackTraceString() );			
			throw new AuraHandledException(ex.getMessage());
		}
	}
}