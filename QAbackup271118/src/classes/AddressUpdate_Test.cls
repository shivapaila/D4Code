@isTest
public class AddressUpdate_Test {
    @isTest
    static void testAddress() {
        Account testCustomer = new Account(
            FirstName ='TestCoverage',
            LastName = 'CoveragePerson', 
            PersonEmail = 'tc@example.com', 
            Phone = '615-555-1212', 
            Primary_Language__pc = 'English'
        );
        insert testCustomer;
        system.debug('test customer id is' +testCustomer.Id);
        List<Address__c> addlist = new List<Address__c>();
        Address__c testShipping = new Address__c(
           Address_Line_1__c = '123 Other Test Coverage St', 
            City__c = 'Franklin', 
            State__c = 'TN',
            Preferred__c = true,
            Address_Type__c ='Bill To',
            Address_Line_2__c='123 test',
            Address_Validation_Status__c='test',
            Country__c='India',
            AccountId__c = testCustomer.Id
        );
        addlist.add(testShipping);
        Address__c testBilling = new Address__c(
            Address_Line_1__c = '123 Other Test Coverage St', 
            City__c = 'Franklin', 
            State__c = 'TN',
            Preferred__c = true,
            Address_Type__c ='Bill To',
            Address_Line_2__c='1233 test',
            Address_Validation_Status__c='test1',
            Country__c='India',
            AccountId__c = testCustomer.Id
        );
        addlist.add(testBilling);
        system.debug('testis');
        insert addlist;

        Account testCustomer1 = new Account(
            FirstName ='TestCoverage',
            LastName = 'CoveragePerson', 
            PersonEmail = 'tc@example.com', 
            Phone = '615-555-1212', 
            Primary_Language__pc = 'English'
        );
        insert testCustomer1;
        List<Address__c> addlist1 = new List<Address__c>();
        Address__c testShipping1 = new Address__c(
            Address_Line_1__c = '123 Other Test Coveragew St', 
            City__c = 'Franklin', 
            State__c = 'TN',
            Preferred__c = true,
            Address_Type__c ='Bill To',
            Address_Line_2__c='1233 test',
            Address_Validation_Status__c='test1',
            Country__c='India',           
            AccountId__c = testCustomer1.Id
        );
        addlist1.add(testShipping1);
        insert addlist1;
        
        Test.startTest();
        Database.executeBatch(new AddressUpdate());
        Test.stopTest();
    }
}