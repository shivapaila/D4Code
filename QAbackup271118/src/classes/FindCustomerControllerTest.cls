/* *******************************************************************************************************************
* Class Name   : FindCustomerControllerTest
* Description  : Test class for FindCustomerControllerTest Apex Class.     
* Author       : Theyagarajan Sadhasivam (Perficient, Inc.)
* Created On   : 12/27/2017
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer                                   Date                   Modification ID      Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
*JoJo Zhao (Perficient)                       2/4/2018                                    Updated for Person Account.
**************************************************************************************************************************************/
@isTest
public class FindCustomerControllerTest {

    public static Account createAccounts() 
    {

        RecordType customerAccRT = [Select Id from recordType where SObjectType='Account' and Name='Customer'];
        
        Account acc =  new Account();
        acc.FirstName = 'Test';
        acc.LastName = 'Acc';
        acc.RecordTypeId = customerAccRT.Id;
        acc.Phone ='(0)888-998-766';
        insert acc;
        return acc;
        
    }
    
     @isTest
    public static void findAccountTest()
    {
        Account acct=FindCustomerControllerTest.createAccounts();
        Id [] fixedSearchResults = new Id[]{acct.Id};
        Test.setFixedSearchResults(fixedSearchResults);
        List<Account> accLst=FindCustomerController.findAccount('Test');
        system.assert(!accLst.isEmpty());
    }
}