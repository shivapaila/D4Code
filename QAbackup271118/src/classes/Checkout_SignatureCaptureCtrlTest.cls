/* *******************************************************************************************************************
* Class Name   : Checkout_SignatureCaptureCtrlTest
* Description  : Test class for Checkout_SignatureCaptureCtrl     
* Author       : Theyagarajan S (Perficient, Inc.)
* Created On   : 02/23/2018
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer                                   Date                   Modification ID      Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
*
**************************************************************************************************************************************/
@isTest
public class Checkout_SignatureCaptureCtrlTest {

    @isTest
    public static void createSignatureRecordTest() 
    {
        RecordType customerAccRT = [Select Id from recordType where SObjectType='Account' and Name='Customer'];
        
        // Create account
        Account acc =  new Account();
        acc.FirstName = 'Test';
        acc.LastName = 'Acc';
        acc.RecordTypeId = customerAccRT.Id;
        acc.Phone ='(0)888-998-766';
        acc.PersonEmail = 'spalakkode@ashleyfurniture.com';
        insert acc;
        Checkout_SignatureCaptureCtrl ctrl=Checkout_SignatureCaptureCtrl.createSignatureRecord(acc.Id,null);
        system.assert(ctrl.signId != null);
        
    }
    
    @isTest
    public static void updateSignatureRecordTest() 
    {
        RecordType customerAccRT = [Select Id from recordType where SObjectType='Account' and Name='Customer'];
        
        // Create account
        Account acc =  new Account();
        acc.FirstName = 'Test';
        acc.LastName = 'Acc';
        acc.RecordTypeId = customerAccRT.Id;
        acc.Phone ='(0)888-998-766';
        acc.PersonEmail = 'spalakkode@ashleyfurniture.com';
        insert acc;
 
        Electronic_Signature__c signObj=new Electronic_Signature__c();
        signObj.AccountId__c=acc.Id;
        insert signObj;
        String Id=Checkout_SignatureCaptureCtrl.updateSignatureRecord(signObj.Id, true, true, acc.Id);
        List<Electronic_Signature__c> esObj=[SELECT Id,Signature_Type__c FROM Electronic_Signature__c WHERE Id=:Id];
        if(!esObj.isEmpty()){
            system.assertEquals('Receieve promotional emails,Opt into text messages', esObj[0].Signature_Type__c);
        }
        
      
        
    }
}