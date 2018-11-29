/****** v1 | Description: Test coverage for update customer endpoints methods | 12/21/2017 | L OMeara */
@isTest
public class API_CustomerUpdate_Test {
    /* test valid rest input */
	@isTest
    static void testCustomerEndpoint() {
        String first = 'TestCoverage';
        String last = 'CoveragePerson';
        Account account = new Account(
            name = first + ' ' + last + ' Account'
        );
        insert account;
        
        // create a test contact
        Contact contact = new Contact(
            AccountId = account.id,
            FirstName = first,
            LastName = last,
            Email = 'tc@example.com',
            Phone = '615-555-1212',
            Primary_Language__c = 'English'
        );
        
        insert contact;
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse(); 
        
        req.requestURI = '/services/apexrest/UpdateCustomer';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(
            '{'+
                '"Customers" : [' +
                    '{' +  
            			'"globalID" : "testAPIId1",' +
            			'"customerID" : "'+contact.id+'",' + 
                        '"FirstName" : "RestTest",' +
                        '"LastName" : "Person",' +
                        '"Email" : "rest_test1@example.com",' +
                        '"Email2" : "rest_test2@example.com",' +
                        '"Phone" : "615-555-1212",' +
                        '"Phone2" : "615-555-1234",' +
                        '"Phone3" : "615-555-2222",' +
                        '"PrimaryLanguage": "English",' +
                        '"TaxExempt" : false,' + 
                        '"SeeManagement": false,' + 
                        '"TwitterId": "example",' + 
                        '"FacebookId": "example",' + 
                        '"InstagramId" : "example",' + 
                        '"SnapchatId" : "example",' + 
                        '"YouTubeId" : "example",' + 
                        '"PinterestId" : "example",' +
                        '"addressLine1" : "123 Test Street",' +
                        '"addressLine2" : "Apartment 3C",' + 
                        '"City" : "Franklin",' + 
                        '"State" : "TN",' + 
                        '"Zip" : "37067",' +
                        '"Country" : "USA"' + 
                    '}' +
                ']'+
            '}'
        ); 
        RestContext.request = req;
        RestContext.response = res; 
        
        Test.startTest();
        CustomerResponseWrapper retVal = API_CustomerUpdate.updateCustomerInfo();
        Test.stopTest();
        
        system.assertEquals(retVal.isSuccess, true);
        system.assertEquals(retVal.createdIds.size(), 1);

    }

    /* test update no address */
	@isTest
    static void testCustomerUpdateNoAddr() {
        String first = 'TestCoverage';
        String last = 'CoveragePerson';
        Account account = new Account(
            name = first + ' ' + last + ' Account'
        );
        insert account;
        
        // create a test contact
        Contact contact = new Contact(
            AccountId = account.id,
            FirstName = first,
            LastName = last,
            Email = 'tc@example.com',
            Phone = '615-555-1212',
            Primary_Language__c = 'English'
        );
        
        insert contact;
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse(); 
        
        req.requestURI = '/services/apexrest/UpdateCustomer';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(
            '{'+
                '"Customers" : [' +
                    '{' +  
            			'"globalID" : "testAPIId1",' +
            			'"customerID" : "'+contact.id+'",' + 
                        '"FirstName" : "RestTest",' +
                        '"LastName" : "Person",' +
                        '"Email" : "rest_test1@example.com"' +
                    '}' +
                ']'+
            '}'
        ); 
        RestContext.request = req;
        RestContext.response = res; 
        
        Test.startTest();
        CustomerResponseWrapper retVal = API_CustomerUpdate.updateCustomerInfo();
        Test.stopTest();
        
        system.assertEquals(retVal.isSuccess, true);
        system.assertEquals(retVal.createdIds.size(), 1);

    }    
    
    /* test exception handling, by providing an invalid picklist value on strict picklist */
    @isTest
    static void testCustomerEndpointException() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse(); 
        
        req.requestURI = '/services/apexrest/UpdateCustomer';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(
            '{'+
                '"Customers" : [' +
                    '{' +  
            			'"globalID" : "testAPIId",' +
                        '"FirstName" : "RestTest",' +
                        '"LastName" : "Person",' +
                        '"Email" : "rest_test1@example.com",' +
                        '"Email2" : "rest_test2@example.com",' +
                        '"Phone" : "615-555-1212",' +
                        '"Phone2" : "615-555-1234",' +
                        '"Phone3" : "615-555-2222",' +
                        '"PrimaryLanguage": "EnglishEnglishEnglishEnglish",' +
                        '"TaxExempt" : false,' + 
                        '"SeeManagement": false,' + 
                        '"TwitterId": "example",' + 
                        '"FacebookId": "example",' + 
                        '"InstagramId" : "example",' + 
                        '"SnapchatId" : "example",' + 
                        '"YouTubeId" : "example",' + 
                        '"PinterestId" : "example",' +
                        '"addressLine1" : "123 Test Street",' +
                        '"addressLine2" : "Apartment 3C",' + 
                        '"City" : "Franklin",' + 
                        '"State" : "TN",' + 
                        '"Zip" : "37067",' +
                        '"Country" : "USA"' + 
                    '}' +
                ']'+
            '}'
        ); 
        RestContext.request = req;
        RestContext.response = res; 

        try {
            Test.startTest();
            CustomerResponseWrapper retVal = API_CustomerUpdate.updateCustomerInfo();
            Test.stopTest();
        } catch (Exception e) {
            // verify we caught the exception we just generated in the system log object
            DateTime X1MinuteAgo = System.now().addMinutes(-1);
            ErrorLog__c errLogEntry  = [SELECT Id, ApexClass__c , Message__c, Method__c 
                                        FROM ErrorLog__c  
                                        WHERE ApexClass__c='API_CustomerUpdate' 
                                        AND CreatedDate > :X1MinuteAgo];
            
            system.assert(errLogEntry.Message__c.contains(e.getMessage()));
        }        
    }
}