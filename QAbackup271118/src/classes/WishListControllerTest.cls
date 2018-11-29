/* *******************************************************************************************************************
* Class Name   : WishListControllerTest
* Description  : Test class for WishListController.     
* Author       : Prabha Kannan (Perficient, Inc.)
* Created On   : 02/09/2018
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer                                   Date                   Modification ID      Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
*
**************************************************************************************************************************************/
@isTest
public class WishListControllerTest {
    
    @isTest
    public static void getWishlistTest() 
    {
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        RecordType customerAccRT = [Select Id from recordType where SObjectType='Account' and Name='Customer'];
        
        // Create custom setting
        TestDataFactory.prepareAPICustomSetting();

        Account acc =  new Account();
        acc.FirstName = 'Test';
        acc.LastName = 'Acc';
        acc.RecordTypeId = customerAccRT.Id;
        acc.Phone ='(0)888-998-766';
        acc.PersonEmail = 'spalakkode@ashleyfurniture.com';
        insert acc;
        
        List<Account> accList = [SELECT Id,PersonEmail FROM Account];
        
        if(!accList.isEmpty()) {
            Test.startTest();
            List<WishListWrapper> wrapper = WishListController.getWishlist(accList[0].Id);
            Test.stopTest();
            System.assert(wrapper.size()>0);
        }
    }

}