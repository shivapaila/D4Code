@isTest
public class AddressTriggerHandler_Test {

    @isTest
    static void testCreateCustomerRecordsGoodInputs() {
        Account testCustomer = new Account(
            FirstName ='TestCoverage',
            LastName = 'CoveragePerson', 
            PersonEmail = 'tc@example.com', 
            Phone = '615-555-1212', 
            Primary_Language__pc = 'English'
        );
        
        insert testCustomer;
        
        List<Address__c> addrList = new List<Address__c>();
        
        Address__c testShipping = new Address__c(
            Address_Line_1__c = '123 Test Coverage St', 
            City__c = 'Franklin', 
            State__c = 'TN',
            Preferred__c = true,
            Address_Type__c ='Ship To',
            AccountId__c = testCustomer.Id
        );
        addrList.add(testShipping);
        Address__c testBilling = new Address__c(
            Address_Line_1__c = '123 Other Test Coverage St', 
            City__c = 'Franklin', 
            State__c = 'TN',
            Preferred__c = true,
            Address_Type__c ='Bill To',
            AccountId__c = testCustomer.Id
        );
        
        addrList.add(testBilling);
        
        insert addrList;
        
        testShipping.State__c = 'LA';
        update testShipping;
        
        Address__c testaddr = new Address__c(
            Address_Line_1__c = '123 Other Test Coverage ', 
            City__c = 'Franklin', 
            State__c = 'TN',
            Preferred__c = true,
            Address_Type__c ='Bill To',
            AccountId__c = testCustomer.Id
        );
        
        insert testaddr;
        
        testBilling.Preferred__c = true;
        testBilling.Address_Type__c ='Ship To';
        
        update testBilling;
    }
    
    @isTest
    static void testCreateCustomerRecordsGoodInputs1() {
        Account testCustomer = new Account(
            FirstName ='TestCoverage',
            LastName = 'CoveragePerson', 
            PersonEmail = 'tc@example.com', 
            Phone = '615-555-1212', 
            Primary_Language__pc = 'English'
        );
        
        insert testCustomer;
        
        List<Address__c> addrList = new List<Address__c>();
        
        Address__c testShipping = new Address__c(
            Address_Line_1__c = '123 Test Coverage St', 
            City__c = 'Franklin', 
            State__c = 'TN',
            Preferred__c = true,
            Address_Type__c ='Ship To',
            AccountId__c = testCustomer.Id
        );
        addrList.add(testShipping);
        Address__c testBilling = new Address__c(
            Address_Line_1__c = '123 Other Test Coverage St', 
            City__c = 'Franklin', 
            State__c = 'TN',
            Preferred__c = false,
            Address_Type__c ='Bill To',
            AccountId__c = testCustomer.Id
        );
        
        addrList.add(testBilling);
        
        insert addrList;
        
        testShipping.Preferred__c = true;
        update testShipping;
        
        
    }
}