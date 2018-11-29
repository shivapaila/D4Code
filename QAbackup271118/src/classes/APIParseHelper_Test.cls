/****** v1 | Description: parse tests | 12/21/2017 | Lauren OMeara */
@isTest
public class APIParseHelper_Test {
    /* test parse customer request */
	@isTest
    static void testParseCustomerRequest() {
        String testString = '{'+
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
                    '}' +
                ']'+
            '}';
        List<CustomerWrapper> listResults = APIParseHelper.parseCustomerRequest(testString);
        system.assertEquals(listResults.size(), 1);
    }
}