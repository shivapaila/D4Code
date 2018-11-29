/* *******************************************************************************************************************
* Class Name   : ManageCustomerCartsTest
* Description  : Controller class for AllCustomerCarts and ActiveCustomerCarts Lightning Component.     
* Author       : Theyagarajan Sadhasivam (Perficient, Inc.)
* Created On   : 01/15/2017
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer                                   Date                   Modification ID      Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
*JoJo Zhao (Perficient)                       2/4/2018                                    Updated for Person Account.
**************************************************************************************************************************************/
@isTest
public class ManageCustomerCartsTest {
    
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
    public static void getAllCartsTest()
    {
        Account acc=ManageCustomerCartsTest.createAccounts();
        Opportunity opp = new Opportunity();
        opp.Name='test';
        opp.AccountId=acc.Id;
        opp.CloseDate=system.today();
        opp.StageName='Saved Shopping Cart';
        insert opp;
        List<Opportunity> oppLst=ManageCustomerCarts.getAllCarts(acc.Id);
        system.assert(!oppLst.isEmpty());
        
    }
    
    @isTest
    public static void getCustomerwithActiveCartsTest()
    {
        Account acc=ManageCustomerCartsTest.createAccounts();
        Opportunity opp = new Opportunity();
        opp.Name='test';
        opp.AccountId=acc.Id;
        opp.CloseDate=system.today();
        opp.StageName='Saved Shopping Cart';
        insert opp;
        Shopping_cart_line_item__c lineitem =new Shopping_cart_line_item__c ();
        lineitem.Product_SKU__c='12637';
        lineitem.Quantity__c=1;
        lineitem.Opportunity__c=opp.Id;
        insert lineitem;
        List<ManageCustomerCarts> oppLst=ManageCustomerCarts.getCustomerwithActiveCarts();
        system.assert(!oppLst.isEmpty());
        
    }
    
    @isTest
    public static void fetchContactTest()
    {
        Account acc=ManageCustomerCartsTest.createAccounts();
        Opportunity opp = new Opportunity();
        opp.Name='test';
        opp.AccountId=acc.Id;
        opp.CloseDate=system.today();
        opp.StageName='Saved Shopping Cart';
        insert opp;
        Shopping_cart_line_item__c lineitem =new Shopping_cart_line_item__c ();
        lineitem.Product_SKU__c='12637';
        lineitem.Quantity__c=1;
        lineitem.Opportunity__c=opp.Id;
        insert lineitem;
        List<ManageCustomerCarts> accLst=ManageCustomerCarts.fetchAccount('test');
        system.assert(!accLst.isEmpty());
    }
    
    
}