public class SignatureController {
    public static final String CALIFORNIA_LOOKUP_SIGNATURE_TYPE ='California Lookup';
    /****** REQ-299| 2/21/2017 | JoJo Zhao */
    @AuraEnabled
    public static Id saveCapturedSignature(){
        //Create Electronic_Signature__c  record
         Electronic_Signature__c escObj = new Electronic_Signature__c();
           
        try{
            escObj.Logged_In_User__c=UserInfo.getUserId();
            escObj.Signature_Date_Time__c=system.now();
            escObj.Signature_Type__c=CALIFORNIA_LOOKUP_SIGNATURE_TYPE;
            //esObj.ObjectID__c = ;//no opp now.
            //esObj.MAC_ID__c='';//dono how to get it
            insert escObj;
        } catch (Exception e) {
            system.debug('Fail to save Electronic Signature, exception ' + e.getMessage());
            new ErrorLogController().createLog(
                new ErrorLogController.Log(
                    'SignatureController', 'saveCapturedSignature',
                    'Save Electronic Signature Exception: ' + e.getMessage() +
                    ' Stack Trace: ' + e.getStackTraceString()
                )
            );
            throw new AuraHandledException('Get Error when Save Electronic Signature, Exception:'+e.getMessage());
            
        }
        if(escObj!=null && escObj.id!=null){
            //Attach signature pic to Electronic_Signature__c  record
            saveSignatureasAttachment(escObj.Id);
            return escObj.id;
        }
        return null;
    }
     @AuraEnabled
    public static List<Id> getCaliforniaSignatureList() {
        List<Electronic_Signature__c> escList = [ Select Id from Electronic_Signature__c where AccountId__c=null
                                                 and Logged_In_User__c = :UserInfo.getUserId() 
                                                 and Signature_Type__c=:CALIFORNIA_LOOKUP_SIGNATURE_TYPE 
                                                 and Signature_Date_Time__c=LAST_N_DAYS:1 ];
        Set<Id> escIdSet = new Set<Id>();
        for(Electronic_Signature__c esc : escList){
            escIdSet.add(esc.Id);
        }
        List<Attachment> attachmentList = [select Id, Body, ParentId from  Attachment where ParentId in :escIdSet];
         List<Id> attachmentIdSet = new List<Id>();
       for(Attachment attach : attachmentList){
            attachmentIdSet.add(attach.Id);
        }
        return attachmentIdSet;
    }
    @AuraEnabled
    public static Boolean checkSignatureSaved(){
        
        List<ContentVersion> SignatureVersion = [SELECT Id,ContentDocumentId,FileExtension,Title,VersionData FROM ContentVersion where OwnerId=:UserInfo.getUserId() and ContentDocument.Title =: 'Signature.png'];
        if(SignatureVersion!=null && SignatureVersion.size()>0){
            return true;
        }else{
            return false;
        }
    }
     @AuraEnabled
     public static Id saveSignatureToCustomer(String picId, String customerId){
         
         Attachment picAttach = [select Id, Body, ParentId from  Attachment where Id = :picId];
        
         Electronic_Signature__c escObj = [Select Id, AccountId__c from Electronic_Signature__c 
                                           where Id = :picAttach.ParentId
                                          and Signature_Type__c=:CALIFORNIA_LOOKUP_SIGNATURE_TYPE];
           
        try{
            escObj.AccountId__c=customerId;
            update escObj;
        } catch (Exception e) {
            system.debug('Fail to save Electronic Signature to Customer, exception ' + e.getMessage());
            new ErrorLogController().createLog(
                new ErrorLogController.Log(
                    'SignatureController', 'saveSignatureToCustomer',
                    'Save Electronic Signature to Customer Exception: ' + e.getMessage() +
                    ' Stack Trace: ' + e.getStackTraceString()
                )
            );
            throw new AuraHandledException('Get Error when Save Electronic Signature to Customer, Exception:'+e.getMessage());
            
        }
         return customerId;
    }
    
    private static void saveSignatureasAttachment(Id recId){
        List<ContentVersion> SignatureVersion = [SELECT Id,ContentDocumentId,FileExtension,Title,VersionData FROM ContentVersion where OwnerId=:UserInfo.getUserId() and ContentDocument.Title =: 'Signature.png' ORDER BY CreatedDate DESC];
        Attachment att = new Attachment();
        att.ParentId = recId;
        att.Body = SignatureVersion[0].VersionData;
        att.Name = 'SignatureConfirmation-'+ System.now().format('yyyy_MM_dd_hh_mm_ss') + '..png';
        insert att;
        
        //now delete the ContentDocument
        
        Delete [Select Id  from ContentDocument where Id=:SignatureVersion[0].ContentDocumentId];
    }
    
    //used in QuickAction component to navigate based on market code(California Check)
    @AuraEnabled
    static public Boolean isCaliforniaStore(){
        StoreInfoWrapper si = StoreInfo.getStoreInfo();
        
        Boolean showSignatureCapture = false;
        system.debug('si-->'+si);
        if(si.marketCode=='SLF'){
            showSignatureCapture=true;
        }
        return showSignatureCapture;
    }
    
}