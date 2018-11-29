/****** v1 | Description: Ts & Cs controller class | 2/21/2018 | L OMeara */
public class TsAndCsCtrl {
    public static final String SIGNATURE_TYPE = 'Terms and Conditions';
    
    @AuraEnabled
    public static Electronic_Signature__c createSignatureObj(String personAccId) {
        try {
            String tsAndCs;
            TermsAndCondition__mdt [] tsAndCsMdt = [SELECT content__c FROM TermsAndCondition__mdt];
            for(TermsAndCondition__mdt ts:tsAndCsMdt){
                tsAndCs=ts.content__c;
            }
			StoreInfoWrapper storeWrap = Storeinfo.getStoreInfo();
            tsAndCs = String.format(tsAndCs, new String[]{storeWrap.legalEntityName});
            Opportunity[] oppt = [SELECT Id FROM Opportunity WHERE AccountId=:personAccId And StageName != 'Closed Won' And StageName != 'Closed Lost' and StageName != 'Sale Suspended' AND createdDate=LAST_N_DAYS:30];
            Electronic_Signature__c  newSig = new Electronic_Signature__c(
                AccountId__c = personAccId, 
                Logged_In_User__c  = UserInfo.getUserId(), 
                ObjectID__c = oppt[0].id, 
                Signature_Date_Time__c = Datetime.now(),
                Signature_Type__c = SIGNATURE_TYPE,
                LegalVerbiage__c= tsAndCs
            );
            insert newSig;            
            return newSig;
        } catch (Exception e) {
            throw new AuraHandledException('Error creating signature. ' + 
                                           'Please contact administrator.'+ e.getMessage());
        }
    }
    
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
            
            // Set ToC Accpetance on the Opportunity to true
            Opportunity oppt = [SELECT Id, Sales_Order_ToC_Acceptance__c FROM Opportunity WHERE Id=:sig.ObjectID__c];
            oppt.Sales_Order_ToC_Acceptance__c = true;
            update oppt;
            
            return true;
        } catch (Exception e) {
            throw new AuraHandledException('Error finding signature. ' + 
                                           'Please contact administrator.'+ e.getMessage());
        }
    }
    
}