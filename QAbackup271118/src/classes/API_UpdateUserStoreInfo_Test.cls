/****** v1 | Description: Test coverage for update user endpoint | 1/30/2018| L OMeara */
@isTest
public class API_UpdateUserStoreInfo_Test {
    /* test valid rest input */
    @isTest
    static void testCustomerEndpoint() {
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, One_Source_ID__c='10278', 
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg.com');
        
        String sfdcURL = URL.getSalesforceBaseUrl().toExternalForm(); 
        String restAPIURL = sfdcURL + '/services/apexrest/User/StoreInformation/';  
        
        HttpRequest httpRequest = new HttpRequest(); 
        httpRequest.setMethod('POST'); 
        httpRequest.setHeader('Content-Type', 'application/json; charset=utf-8');
        httpRequest.setEndpoint(restAPIURL);  
        httpRequest.setBody(JSON.serialize(u));
        String response = '';
        Test.startTest();
        API_UpdateUserStoreInfo.updateStoreInfo();
        Test.stopTest();    
    }
}