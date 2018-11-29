/* *******************************************************************************************************************
* Class Name   : Checkout_SignatureCaptureCtrl
* Description  : controller class for ThankYou lightning component     
* Author       : Theyagarajan S (Perficient, Inc.)
* Created On   : 02/22/2018
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer                                   Date                   Modification ID      Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
*
**************************************************************************************************************************************/
public class Checkout_SignatureCaptureCtrl {
    @AuraEnabled
    public Account guestRecord;
    @AuraEnabled
    public String signId;
    @AuraEnabled
    public static Checkout_SignatureCaptureCtrl createSignatureRecord(String personAccId, String oppId) {
        Checkout_SignatureCaptureCtrl ctrl=new Checkout_SignatureCaptureCtrl();
        Electronic_Signature__c esObj= new Electronic_Signature__c();
        List < Account > returnList = new List < Account > ();
        List < Account > lst = [SELECT Id, Name, Phone,PersonEmail,createdDate
                                FROM Account 
                                where id=:personAccId ];
        List<Opportunity> oppt = new List<Opportunity>();
        if(!String.isEmpty(oppId)){            
        	oppt = [SELECT Id FROM Opportunity WHERE id=:oppId];
        }
        List<Electronic_Signature__c> esObjLst=[SELECT Id,Signature_Type__c FROM Electronic_Signature__c WHERE AccountId__c=:personAccId and (Signature_Type__c like '%Receieve promotional emails%' OR Signature_Type__c like '%Opt into text messages%')];
        if(!lst.isEmpty())
        {
            ctrl.guestRecord=lst[0];
            if(esObjLst.isEmpty()){
                //esObj.Name=lst[0].Name;
                esObj.AccountId__c=lst[0].Id;
                //esObj.Email__c=lst[0].PersonEmail;
                //esObj.Phone__c=lst[0].Phone;
                esObj.Logged_In_User__c=UserInfo.getUserId();
                esObj.Signature_Date_Time__c=system.now();
                esObj.Signature_Type__c='';//input form the radio buttons
                if(!oppt.isEmpty())
                {
                    esObj.ObjectID__c = oppt[0].id;
                }
                insert esObj;   
                ctrl.signId=esObj.Id;
            }
            else{
                
                ctrl.signId=esObjLst[0].Id;
                
            }
            
        }
        
        return ctrl;
    }
    
    @AuraEnabled
    public static Id updateSignatureRecord(String signId,Boolean promotionalEmails,Boolean textMessages,String personAccId) 
    {
        String type;
        Contact con;
        Account  acc = [SELECT Id, Name, Phone,PersonEmail,createdDate,Survey_Opt_In__pc,Text_Message_Opt_In__pc
                        FROM Account 
                        where id=:personAccId];
        if(acc != null)
        {
            con=[SELECT Id, Name,createdDate,Survey_Opt_In__c,Text_Message_Opt_In__c
                 FROM contact
                 where AccountId=:acc.Id];
        }
        if(promotionalEmails == true){
            type='Receieve promotional emails';
            con.Survey_Opt_In__c=true;
        }
        else{
            con.Survey_Opt_In__c=false;
        }
        if(textMessages == true){
            type='Opt into text messages';
            con.Text_Message_Opt_In__c=true;
        }
        else{
            con.Text_Message_Opt_In__c=false;
        }
        if(textMessages == true && promotionalEmails == true){
            type='Receieve promotional emails,Opt into text messages';
            
        }
        List<Electronic_Signature__c> esObj=[SELECT Id,Signature_Type__c FROM Electronic_Signature__c WHERE Id=:signId];
        if(!esObj.isEmpty())
        {
            
            esObj[0].Signature_Type__c=type;
            update esObj;
        }
        if(con != null){
            update con;
        }
        return signId;
    }
	
	@AuraEnabled
    public static Boolean checkForSignature(String sigId) {
        try {
            // if sig object was created, this component load completed
            Electronic_Signature__c sig = [SELECT Id, ObjectID__c,Signature_Type__c FROM Electronic_Signature__c WHERE Id=:sigId and Signature_Type__c != 'Terms and Conditions'];
            if (sig == null) {
                return false;
            }
            
            // if signature has been provided, attachment will be found
            ContentDocumentLink[] attachments = [SELECT Id FROM ContentDocumentLink WHERE LinkedEntityId=:sigId];
            if (attachments.size() == 0) {
                return false;
            }
            
            
            return true;
        } catch (Exception e) {
            throw new AuraHandledException('Error finding signature. ' + 
                                           'Please contact administrator.'+ e.getMessage());
        }
    }
    
    
}