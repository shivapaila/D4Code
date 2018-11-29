/* *******************************************************************************************************************
* Class Name   : CustomerOrderAcceptanceCntrl
* Description  : Controller class for CustomerOrderAcceptance component to show acceptance terms and save the signature
* Author       : Prabha Kannan (Perficient, Inc.)
* Created On   : 01/06/2018
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer                                   Date                   Modification ID      Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* Sridhar									14/8/18						1.1				Saved TsandCs text in signature object
**************************************************************************************************************************************/
public class CustomerOrderAcceptanceCntrl {
	public static final String SIGNATURE_TYPE = 'Customer Order Acceptance';

    // Method to create a signature object instance of type 'Customer Order Acceptance'
    @AuraEnabled
    public static Id createSignatureObj(String personAccId) {
        try {
            Opportunity[] oppt = [SELECT Id FROM Opportunity WHERE AccountId=:personAccId And StageName != 'Closed Won' And StageName != 'Closed Lost' And StageName != 'Sale Suspended' AND createdDate=LAST_N_DAYS:30];
            StoreInfoWrapper storeWrap = Storeinfo.getStoreInfo();
            String customerOrderAccptTerms = System.Label.Customer_Order_Acceptance_Terms;
            customerOrderAccptTerms = String.format(customerOrderAccptTerms, new String[]{storeWrap.legalEntityName});
            if(!oppt.isEmpty()) {
                Electronic_Signature__c  newSig = new Electronic_Signature__c(
                    AccountId__c = personAccId, 
                    Logged_In_User__c  = UserInfo.getUserId(), 
                    ObjectID__c = oppt[0].id, 
                    Signature_Date_Time__c = Datetime.now(),
                    Signature_Type__c = SIGNATURE_TYPE,
                    LegalVerbiage__c= customerOrderAccptTerms
                );
                insert newSig;            
                return newSig.Id;
            }
            return null;
        } catch (Exception e) {
            throw new AuraHandledException('Error creating signature. ' + 
                                           'Please contact administrator.'+ e.getMessage());
        }
    }
    
    // Method to check if customer has signed and to store customer order acceptance in opportunity object
    @AuraEnabled
    public static Boolean checkForSignature(String sigId) {
        try {
            // if sig object was created, this component load completed
            Electronic_Signature__c sig = [SELECT Id, ObjectID__c FROM Electronic_Signature__c WHERE Id=:sigId];
            if (sig == null) {
                return false;
            }
            // if signature has been provided, attachment will be found
            ContentDocumentLink[] attachments = [SELECT Id FROM ContentDocumentLink WHERE LinkedEntityId=:sigId];
            if (attachments.size() == 0) {
                return false;
            }
            // Set Customer Order Accpetance on the Opportunity to true
            List<Opportunity> oppt = [SELECT Id, Customer_Order_Acceptance__c FROM Opportunity WHERE Id = :sig.ObjectID__c];
            if(!oppt.isEmpty()) {
                oppt[0].Customer_Order_Acceptance__c = true;
            	update oppt[0];
            }
            return true;
        } catch (Exception e) {
            throw new AuraHandledException('Error finding signature. ' + 
                                           'Please contact administrator.'+ e.getMessage());
        }
    }
}