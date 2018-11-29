@isTest
public class UpdAdrStateBatchTest {
    @isTest
    static void testMethod1() {
        Account testCustomer = new Account(
            FirstName ='TestCoverage',
            LastName = 'CoveragePerson', 
            PersonEmail = 'tc@example.com', 
            Phone = '615-555-1212', 
            Primary_Language__pc = 'English'
        );
        insert testCustomer;

        List<Address__c> addlist = new List<Address__c>();
        Address__c adr1 = new Address__c(
            Address_Line_1__c = '123 Other Test Coverage St', 
            Address_Line_2__c = '123 test',
            City__c = 'Franklin', 
            State__c = 'FLORIDA',
            Address_Type__c = 'Bill To',
            Address_Validation_Status__c = 'test',
            Country__c = 'USA',
            AccountId__c = testCustomer.Id
        );
        addlist.add(adr1);
        Address__c adr2 = new Address__c(
            Address_Line_1__c = '123 Other Test Coverage St', 
            Address_Line_2__c = '123 test',
            City__c = 'Franklin', 
            State__c = 'Minnesota',
            Address_Type__c = 'Bill To',
            Address_Validation_Status__c = 'test',
            Country__c = 'USA',
            AccountId__c = testCustomer.Id
        );
        addlist.add(adr2);
        Address__c adr3 = new Address__c(
            Address_Line_1__c = '123 Other Test Coverage St', 
            Address_Line_2__c = '123 test',
            City__c = 'Franklin', 
            State__c = 'N',
            Address_Type__c = 'Bill To',
            Address_Validation_Status__c = 'test',
            Country__c = 'USA',
            AccountId__c = testCustomer.Id
        );
        addlist.add(adr3);
        Address__c adr4 = new Address__c(
            Address_Line_1__c = '123 Other Test Coverage St', 
            Address_Line_2__c = '123 test',
            City__c = 'Franklin', 
            State__c = 'Ohio',
            Address_Type__c = 'Bill To',
            Address_Validation_Status__c = 'test',
            Country__c = 'USA',
            AccountId__c = testCustomer.Id
        );
        addlist.add(adr4);
        Address__c adr5 = new Address__c(
            Address_Line_1__c = '123 Other Test Coverage St', 
            Address_Line_2__c = '123 test',
            City__c = 'Franklin', 
            State__c = 'GA',
            Address_Type__c = 'Bill To',
            Address_Validation_Status__c = 'test',
            Country__c = 'USA',
            AccountId__c = testCustomer.Id
        );
        addlist.add(adr5);
        Address__c adr6 = new Address__c(
            Address_Line_1__c = '123 Other Test Coverage St', 
            Address_Line_2__c = '123 test',
            City__c = 'Franklin', 
            State__c = '**',
            Address_Type__c = 'Bill To',
            Address_Validation_Status__c = 'test',
            Country__c = 'USA',
            AccountId__c = testCustomer.Id
        );
        addlist.add(adr6);
        Address__c adr7 = new Address__c(
            Address_Line_1__c = '123 Other Test Coverage St', 
            Address_Line_2__c = '123 test',
            City__c = 'Franklin', 
            State__c = '',
            Address_Type__c = 'Bill To',
            Address_Validation_Status__c = 'test',
            Country__c = 'USA',
            AccountId__c = testCustomer.Id
        );
        addlist.add(adr7);
        insert addlist;

        Test.startTest();
        Database.executeBatch(new UpdAdrStateBatch());
        Test.stopTest();
    }
}