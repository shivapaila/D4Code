/****** v1 | Description: Test coverage for create customer endpoints methods | 12/1/2017 | L OMeara */
@isTest
public class API_CustomerInformation_Test {
    /* test valid rest input */
	@isTest
    static void testCustomerEndpoint() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse(); 
        
        req.requestURI = '/services/apexrest/CreateCustomer';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(
            '{'+
                '"Customers" : [' +
                    '{' +  
            			'"globalID" : "testAPIId1",' +
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
                    '},' +
                    '{' +  
            			'"globalID" : "testAPIId2",' +
                        '"firstName" : "Rest2Test",' +
                        '"lastName" : "Person2",' +
                        '"addressLine1" : "123 Test2 Street",' + 
                        '"addressLine2" : "Apartment 3D",' + 
                        '"city" : "Franklin",' + 
                        '"state" : "TN",' + 
                        '"zip" : "37067",' +  
                        '"email" : "rest_test3@example.com",' +
                        '"phone" : "615-555-1214",' +
                        '"phone2" : "615-555-1235",' +
                        '"phone3" : "615-555-2226"' +
                    '}' +
                ']'+
            '}'
        ); 
        RestContext.request = req;
        RestContext.response = res; 
        
        Test.startTest();
        CustomerResponseWrapper retVal = API_CustomerInformation.addCustomerInfo();
        Test.stopTest();
        
        system.assertEquals(retVal.isSuccess, true);
        system.assertEquals(retVal.createdIds.size(), 2);

    }
    
    /* test valid sparse input */
	@isTest
    static void testSparseCustomerEndpoint() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse(); 
        
        req.requestURI = '/services/apexrest/CreateCustomer';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(
            '{'+
                '"Customers" : [' +
                    '{' +  
            			'"globalID" : "testAPIId1",' +
                        '"FirstName" : "RestTest",' +
                        '"LastName" : "Person",' +
                        '"Email" : "rest_test1@example.com"' +
                    '},' +
                    '{' +  
            			'"globalID" : "testAPIId2",' +
                        '"firstName" : "Rest2Test",' +
                        '"lastName" : "Person2",' +
                        '"phone" : "615-555-1214"' +
                    '}' +
                ']'+
            '}'
        ); 
        RestContext.request = req;
        RestContext.response = res; 
        
        Test.startTest();
        CustomerResponseWrapper retVal = API_CustomerInformation.addCustomerInfo();
        Test.stopTest();
        
        system.assertEquals(retVal.isSuccess, true);
        system.assertEquals(retVal.createdIds.size(), 2);

    }
    /* test exception handling, by providing an invalid picklist value on strict picklist */
    @isTest
    static void testCustomerEndpointException() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse(); 
        
        req.requestURI = '/services/apexrest/CreateCustomer';
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
            CustomerResponseWrapper retVal = API_CustomerInformation.addCustomerInfo();
            Test.stopTest();
        } catch (Exception e) {
            // verify we caught the exception we just generated in the system log object
            DateTime X1MinuteAgo = System.now().addMinutes(-1);
            ErrorLog__c errLogEntry  = [SELECT Id, ApexClass__c , Message__c, Method__c 
                                        FROM ErrorLog__c  
                                        WHERE ApexClass__c='API_CustomerInformation' 
                                        AND CreatedDate > :X1MinuteAgo];
            
            system.assert(errLogEntry.Message__c.contains(e.getMessage()));
        }        
    }
}