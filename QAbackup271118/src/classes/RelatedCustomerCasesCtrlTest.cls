/* *******************************************************************************************************************
* Class Name   : RelatedCustomerCasesCtrlTest
* Description  : Test class for RelatedCustomerCasesCtrl.     
* Author       : Theyagarajan Sadhasivam (Perficient, Inc.)
* Created On   : 1/08/2017
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer                                   Date                   Modification ID      Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* Prabha Kannan								  02/05/2018			 REQ-368			  Added account creation
**************************************************************************************************************************************/
@isTest
public class RelatedCustomerCasesCtrlTest {

    
    @isTest
    public static void getCasesTest()
    {
        Account acc =new Account();
        acc.LastName='Test Acc1';
        String rtypeId=[Select id From RecordType Where DeveloperName ='Customer' and sObjectType = 'Account'].id;
        acc.Phone='9090909090';
        acc.RecordTypeId=rtypeId;
        insert acc;
        
        Case cas=new Case();
        cas.Status='New';
        cas.AccountId=acc.Id;
        cas.Origin='Phone';
        cas.Type='Order';
        cas.Subject='test';
        cas.Description='test';
        insert cas;
        List<Case> csLst=RelatedCustomerCasesCtrl.getCases(acc.Id);
        system.assert(!csLst.isEmpty());
    }
}