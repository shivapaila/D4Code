/* *******************************************************************************************************************
* Class Name   : FindCustomerController
* Description  : Apex class for FindCustomer Lightning component.     
* Author       : Theyagarajan Sadhasivam (Perficient, Inc.)
* Created On   : 12/27/2017
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer                                   Date                   Modification ID      Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* JoJo Zhao (Perficient)                       2/4/2018                                    Updated for Person Account.
**************************************************************************************************************************************/
public class FindCustomerController {

    @AuraEnabled
    public static List <Account> findAccount(String searchKeyWord) {
        String searchKey = '*'+searchKeyWord+'*';
        List<List<sObject>> searchList = [FIND :searchKey IN ALL FIELDS RETURNING 
                                          Account(Id, Name, PersonMailingAddress, Phone, PersonEmail 
                                                  WHERE RecordType.DeveloperName='Customer' 
                                                  ORDER BY Name
                                                  LIMIT 2000)];
        return (List<Account>)searchList[0];
    }
}