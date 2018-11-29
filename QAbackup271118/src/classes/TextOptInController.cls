public class TextOptInController {
	@auraEnabled public Account guestRecord;
	@auraEnabled public Opportunity optyRecord;
    @auraEnabled public String signId;
    @auraEnabled public DateTime checkedTime;
    //REQ-455 - Text Opt In
    @auraEnabled public String entityFullName;
    public static final String TEXT_OPT_IN_TYPE = 'Opt into text messages';

    @auraEnabled
    public static TextOptInController getOpty(String personAccountId, String opportunityId) {
    	try {
    		TextOptInController ctrl=new TextOptInController();
    		Account personAcc = [SELECT Id, Name, Phone,PersonEmail,createdDate FROM Account 
                                                                                where Id = :personAccountId];
            ctrl.guestRecord = personAcc;
            Opportunity oppty = [Select Id, Survey_Opt_In__c, Text_Message_Opt_In__c, Declined_Survey_and_Text_Opt_In__c,
                                                                    Shipping_Phone__c 
    																from Opportunity where Id = :opportunityId];
    		ctrl.optyRecord = oppty;
    		List<Electronic_Signature__c> eSign =[SELECT Id,Signature_Type__c FROM Electronic_Signature__c WHERE AccountId__c = :personAccountId 
                                                                                and Signature_Type__c = :TEXT_OPT_IN_TYPE
                                                                                and ObjectID__c = :opportunityId
                                                                                order by CreatedDate desc Limit 1];
            if(eSign != null && !eSign.isEmpty()) {
                ctrl.signId = eSign[0].Id;
            }
            //REQ-455 - Text Opt In
            ctrl.entityFullName = TextOptInConsent.textOptIn();
    		return ctrl;
    	}
    	catch(Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @auraEnabled
    public static TextOptInController getOrCreateESignature(String personAccountId, String opportunityId, String eSignId) {
        Savepoint sp = Database.setSavepoint();
        try {
            TextOptInController ctrl=new TextOptInController();
            
            if(eSignId == null || eSignId == '') {
                Electronic_Signature__c eSignObj = new Electronic_Signature__c(AccountId__c = personAccountId, Logged_In_User__c = userInfo.getUserId(),
                                                                                Signature_Date_Time__c = System.Now(), Signature_Type__c = TEXT_OPT_IN_TYPE,
                                                                                ObjectID__c = opportunityId);
                insert eSignObj;
                ctrl.signId=eSignObj.Id;
            }
            else {
                ctrl.signId = eSignId;
            }
            ctrl.checkedTime = system.now();
            return ctrl;
        }
        catch(Exception e) {
            Database.rollback(sp);
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @auraEnabled
    public static String declineOptions(String personAccountId, String opportunityId) {
        Savepoint sp = Database.setSavepoint();
        try {
            update new Account(Id = personAccountId, Survey_Opt_In__pc = false, Text_Message_Opt_In__pc = false, Declined_Survey_and_Text_Opt_In__pc = true);
            update new Opportunity(Id = opportunityId, Survey_Opt_In__c = false, Text_Message_Opt_In__c = false, Declined_Survey_and_Text_Opt_In__c = true);
            List<Electronic_Signature__c> eSign = [Select Id from Electronic_Signature__c where AccountId__c = :personAccountId
                                                                                            and Signature_Type__c = :TEXT_OPT_IN_TYPE
                                                                                            and ObjectID__c = :opportunityId];
            if(eSign != null && !eSign.isEmpty()) {
                delete eSign;
            }
            return 'Decline Success';
        }
        catch(Exception e) {
            Database.rollback(sp);
            throw new AuraHandledException(e.getMessage());
        }
    }

    @auraEnabled
    public static String acceptOptions(String personAccountId, String opportunityId, String eSignId, Boolean promotionalEmails, Boolean textOptIn,
                                        DateTime timeWhenCheckedTextOptIn,String legalContent) {
        Savepoint sp = Database.setSavepoint();
        Boolean customerSigned = false;
        if(!promotionalEmails && !textOptIn) {
            throw new AuraHandledException('Please check at least one of the options');
        }
        if(textOptIn && timeWhenCheckedTextOptIn != null) {
            List<ContentDocumentLink> attachments = [SELECT Id, ContentDocument.ContentModifiedDate FROM ContentDocumentLink WHERE LinkedEntityId = :eSignId order by ContentDocument.ContentModifiedDate Limit 1];
            if(attachments != null && !attachments.isEmpty()) {
                if(attachments[0].ContentDocument.ContentModifiedDate > timeWhenCheckedTextOptIn) {
                    customerSigned = true;
                }
                else {
                    throw new AuraHandledException('Please sign the signature panel before clicking Accept');
                }
            }
            else {
                throw new AuraHandledException('Please sign the signature panel before clicking Accept');
            }
        }
        else if(!textOptIn && eSignId != null) {
            delete new Electronic_Signature__c(Id = eSignId);
        }
        //DEF-0863
        Electronic_Signature__c eSign;
        if(String.isNotBlank(legalContent)){
            eSign = [Select Id,LegalVerbiage__c from Electronic_Signature__c 
                                               where Id = :eSignId
                                               and Signature_Type__c = :TEXT_OPT_IN_TYPE];
        }
        try {
			if(eSign != null) 
			{
					eSign.LegalVerbiage__c= legalContent;
					update eSign;
			 }
	  //end of DEF-0863
			upsert new Account(Id = personAccountId, Survey_Opt_In__pc = promotionalEmails, Text_Message_Opt_In__pc = textOptIn, Declined_Survey_and_Text_Opt_In__pc = (!promotionalEmails && !textOptIn));
			upsert new Opportunity(Id = opportunityId, Survey_Opt_In__c = promotionalEmails, Text_Message_Opt_In__c = textOptIn, Declined_Survey_and_Text_Opt_In__c = (!promotionalEmails && !textOptIn));
			return 'Success';
		}
		catch(Exception e) {
			Database.rollback(sp);
			throw new AuraHandledException(e.getMessage());
		}
      
    }
}