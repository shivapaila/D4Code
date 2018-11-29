/* *******************************************************************************************************************
* Class Name   : PaymentControllerTest
* Description  : A test class for the Lightning Apex Controller Commission Controller
*               
* Author       : Sriram (Perficient, Inc.)
* Created On   : 06/13/2018
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer                                   Date                   Modification ID      Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* 
**************************************************************************************************************************************/
@isTest
public class CommissionsCtrl_Test {

    @isTest
    public static void testGetCurrentRSA(){
        TestDataFactory.prepareAPICustomSetting();
        User rsaUser = TestDataFactory.createRSAUser();
        insert rsaUser;
        System.runAs(rsaUser) {
            Test.setMock(HttpCalloutMock.class, new StoreInfoMock());

            Test.startTest();
             CommissionsCtrl.CommissionCurrentRSAUserWrapper currentRSA = CommissionsCtrl.getCurrentRSA();
            Test.stopTest();
            System.assertEquals(true, currentRSA.user.Id.equals(rsaUser.Id), ' Expecting the current RSA User record.');
        }
    }    

    @isTest
    public static void testGetCommissionEntries(){
        User rsaUser = TestDataFactory.createRSAUser();
        insert rsaUser;
        System.runAs(rsaUser) {
            Account account = createAccount();
            Opportunity opportunity = prepareShoppingCart(account);
            Test.startTest();
            List<CommissionsCtrl.CommissionEntry> commissionEntries = CommissionsCtrl.getCommissionEntries(account.Id);
            Test.stopTest();
            System.assertEquals(true, !commissionEntries.isEmpty(), ' Expecting at least one commission entry');
            System.assertEquals(100, commissionEntries.get(0).percentage, ' Expecting the commission entry with value 100');
            System.assertEquals(true, String.isNotBlank(commissionEntries.get(0).id), ' Expecting a valid opportunity split record');
        }
    }

    @isTest
    public static void testSaveCommissionEntries(){
        User rsaUser1 = TestDataFactory.createRSAUser();
        rsaUser1.userName = 'rsaUser1@test.com';
        User rsaUser2 = TestDataFactory.createRSAUser();
        rsaUser2.userName = 'rsaUser2@test.com';
        List<User> users = new List<User>{rsaUser1, rsaUser2};
        insert users;
        System.runAs(rsaUser1) {
            Account account = createAccount();
            Opportunity opportunity = prepareShoppingCart(account);
            List<CommissionsCtrl.CommissionEntry> inputCommissionEntries = new List<CommissionsCtrl.CommissionEntry>{new CommissionsCtrl.CommissionEntry(null, rsaUser2, 0.03)};
            Test.startTest();
            List<CommissionsCtrl.CommissionEntry> commissionEntries = CommissionsCtrl.saveCommissionEntries(account.Id, JSON.serialize(inputCommissionEntries));
            Test.stopTest();
            System.assertEquals(true, !commissionEntries.isEmpty(), ' Expecting a non-empty commission entry list');
            System.assertEquals(true, commissionEntries.size()==2, ' Expecting two commission entry records');
        }
    }    

    private static Account createAccount(){
        RecordType customerAccRT = [Select Id from recordType where SObjectType='Account' and Name='Customer'];
        Account acc =  new Account();
        acc.FirstName = 'testAccF';
        acc.LastName = 'testAccL';
        acc.RecordTypeId = customerAccRT.Id;
        acc.Phone ='(0)888-998-766';
        insert acc;
        return acc;
    }

    private static Opportunity prepareShoppingCart(Account acc){
        Opportunity opp =  new Opportunity();
        opp.AccountId = acc.Id;
        opp.Name=acc.Name+'-'+system.today().format();
        opp.StageName='Saved Shopping Cart';
        opp.CloseDate=Date.Today().addDays(30);
        
        insert opp;
        
        List<Shopping_cart_line_item__c> lineItems = new  List<Shopping_cart_line_item__c>();
        Shopping_cart_line_item__c line = new Shopping_cart_line_item__c();
        line.Product_SKU__c ='1200014';
        line.Quantity__c =1;
        line.Delivery_Mode__c='HD';
        line.List_Price__c = 288.99;
        line.Average_Cost__c = 188.99;
        line.Opportunity__c = opp.Id;
        lineItems.add(line);
        
        Shopping_cart_line_item__c line2 = new Shopping_cart_line_item__c();
        line2.Product_SKU__c ='M80221';
        line2.Quantity__c =1;
        line2.List_Price__c = 284;
        line.Average_Cost__c = 184.99;
        line2.Opportunity__c = opp.Id;
        lineItems.add(line2);
        
        Shopping_cart_line_item__c line3 = new Shopping_cart_line_item__c();
        line3.Product_SKU__c ='*KSADJPR5YNT';
        line3.Quantity__c =1;
        line3.List_Price__c = 249.99;
        line.Average_Cost__c = 149.99;
        line3.Opportunity__c = opp.Id;
        lineItems.add(line3);
        insert lineItems;
        return opp;
    }      
}