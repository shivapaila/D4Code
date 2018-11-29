/* *******************************************************************************************************************
* Class Name   : RSAAccountInfoController
* Description  : This is lightning controller class that communicates with the component RSAAccountInfo
*				
* Author       : Sriram (Perficient, Inc.)
* Created On   : 05/23/2018
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer                                   Date                   Modification ID      Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* Sriram									  07/23									      This controller is deprecated.
*																						  Please use the ConciergeServiceController
**************************************************************************************************************************************/
public class RSAAccountInfoController {
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
		} catch (Exception ex){
			System.debug(LoggingLevel.ERROR, 'Failed to retrieve RSA Account Info: '+ ex.getMessage());
			ErrorLogController.createLogFuture('RSAAccountInfoController', 'getRSAAccountInfo', 'Failed to retrieve RSA Account Info: ' + ex.getMessage() +  ' Stack Trace: ' + ex.getStackTraceString() );			
			throw new AuraHandledException(ex.getMessage());
		}
		return rsaAccountInfo;
	}

}