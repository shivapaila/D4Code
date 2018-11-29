/****** v1 | Description: Test methods for view customer controller class | 12/5/2017 | L OMeara */
@isTest
public class ViewCustomerController_Test {
    /* ask about moving this into test data factory */
    public static List<Address__c> initializeAddresses(Id accountId, Integer numberOfRecords) {
        List<Address__c> addrs = new List<Address__c>();
        for (Integer i = 0 ; i < numberOfRecords ; i++ ) {            
            Address__c addr = new Address__c();
            addr.AccountId__c = accountId;
            addr.Address_Line_1__c = Math.random() + 'Test St';
            addr.Address_Line_1__c = 'Suite ' + Math.random();
            addr.City__c = 'Test City';
            addr.State__c = 'Test State';
            addr.Zip_Code__c = 'Test Zip';

            addrs.add( addr);
        }
        return addrs;
    }
    
    /* test query for customer which has no addresses */
    @isTest
    static void testGetCustomerZeroAddresses() {
        List<Account> testAccounts = TestDataFactory.initializeAccounts(1);
        insert testAccounts;
        List<Address__c> addrs = ViewCustomerController.getCustomerAddresses(testAccounts[0].id);
    }
    
    /* test query for customer with several addresses */
    @isTest
    static void testGetCustomerAddresses() {
        List<Account> testAccounts = TestDataFactory.initializeAccounts(1);
        insert testAccounts;
        List<Address__c> testAddrs = initializeAddresses(testAccounts[0].id,1);
        insert testAddrs;
        List<Address__c> addrs = ViewCustomerController.getCustomerAddresses(testAccounts[0].id);
    }

    /* test save a new address */
    @isTest
    static void testSaveNewAddress() { 
        List<Account> testAccounts = TestDataFactory.initializeAccounts(1);
        insert testAccounts;
        List<Address__c> testAddrs = initializeAddresses(testAccounts[0].id,1);
        insert testAddrs;
        
        ViewCustomerController.saveAddress(testAddrs[0]);
    }

    /* test save an existing address */
    @isTest
    static void testSaveAddress() { 
        List<Account> testAccounts = TestDataFactory.initializeAccounts(1);
        insert testAccounts;
        List<Address__c> testAddrs = initializeAddresses(testAccounts[0].id,1);
        insert testAddrs;    

        ViewCustomerController.saveAddress(testAddrs[0]);
    }

    @isTest
    static void testupdateOwner(){
        List<Account> testAccounts = TestDataFactory.initializeAccounts(1);
        insert testAccounts;
        List<Address__c> testAddrs = initializeAddresses(testAccounts[0].id,1);
        insert testAddrs;    

        ViewCustomerController.updateOwner(testAccounts[0].Id);
    }
    
    @isTest
    static void testSaveAddress2() { 
        List<Account> testAccounts = TestDataFactory.initializeAccounts(1);
        insert testAccounts;
        List<Address__c> testAddrs = initializeAddresses(testAccounts[0].id,1);
        insert testAddrs;   
        testAddrs[0].Preferred__c = true;
        update testAddrs[0];

        ViewCustomerController.saveAddress(testAddrs[0]);
    }
}