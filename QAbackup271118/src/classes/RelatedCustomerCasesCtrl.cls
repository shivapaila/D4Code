/* *******************************************************************************************************************
* Class Name   : RelatedCustomerCasesCtrl
* Description  : Controller class for RelatedCustomerCases component.     
* Author       : Theyagarajan Sadhasivam (Perficient, Inc.)
* Created On   : 12/29/2017
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer                                   Date                   Modification ID      Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
*
**************************************************************************************************************************************/
public class RelatedCustomerCasesCtrl {
   
    @AuraEnabled
    public static List<Case> getCases(String accountId){
        
        List<Case> caseLst=[Select id,CaseNumber,status, Account.id ,Subject
                            From Case 
                            where Account.id= :accountId and status != 'Closed'];
        if(!caseLst.isEmpty()){
           return caseLst; 
        }
        return null;
    }
}