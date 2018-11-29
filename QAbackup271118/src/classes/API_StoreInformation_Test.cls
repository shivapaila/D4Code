/****** v1 | Description: Test coverage for store informatio endpoint | 12/1/2017 | L OMeara */
@isTest
public class API_StoreInformation_Test {
	@isTest
    static void testStoreEndpoint() {
		RestRequest req = new RestRequest();
        RestResponse res = new RestResponse(); 
        
        String testStoreId = 'TEST STORE ID';
        String testStoreName = 'Ashley TestStore';
        String testStoreAddr = '123 Test Street';
        String testStoreCity = 'Franklin';
        String testStoreZip = '37067';
        String testStoreState = 'TN';
        String testStoreCountry = 'US';
        String testStorePhone = '+16155551212';
        String testStoreHours = 'Mon: 10:00AM-08:00PM &lt;br/&gt;Tue: 10:00AM-08:00PM &lt;br/&gt;Wed: 10:00AM-08:00PM &lt;br/&gt;Thu: 10:00AM-08:00PM &lt;br/&gt;Fri: 10:00AM-08:00PM &lt;br/&gt;Sat: 10:00AM-06:00PM &lt;br/&gt;Sun: 12:00PM-06:00PM';
        
        req.requestURI = '/services/apexrest/Account/StoreInformation';
        req.httpMethod = 'POST';
        req.addHeader('Content-Type', 'application/xml; charset=UTF-8');
        req.addHeader('Accept', 'application/xml');
        req.requestBody = Blob.valueOf('<?xml version="1.0" encoding="utf-8"?>' +
            '<stores xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns="http://www.demandware.com/xml/impex/store/2007-04-30">' +
                '<store store-id="'+testStoreId+'">' + 
                    '<name>'+ testStoreName +'</name>'+
                    '<address1>' + testStoreAddr + '</address1>'+
                    '<city>'+testStoreCity+'</city>'+
                    '<postal-code>'+testStoreZip+'</postal-code>'+
                    '<state-code>'+testStoreState+'</state-code>'+
                    '<country-code>'+testStoreCountry+'</country-code>'+
                    '<phone>'+testStorePhone+'</phone>'+
                    '<store-hours xml:lang="x-default">'+testStoreHours+'</store-hours>'+
                    '<latitude>0</latitude>'+ // we don't use this value
                    '<longitude>0</longitude>'+ // we don't use this value
                    '<custom-attributes>'+
                        '<custom-attribute attribute-id="isRdc">true</custom-attribute>'+
                        '<custom-attribute attribute-id="customerServiceHours">test hours</custom-attribute>'+
                        '<custom-attribute attribute-id="customerServicePhone">6155551212</custom-attribute>'+
                        '<custom-attribute attribute-id="fulfillerDisplayName">Test Fulfiller Value</custom-attribute>'+
                    '</custom-attributes>'+
                '</store>'+
            '</stores>');            
        
        RestContext.request = req;
        RestContext.response = res; 
        
        Test.startTest();
        String retVal = API_StoreInformation.addUpdateStoreInfo();
        Test.stopTest();
        
        Account newAcct = [SELECT Id, Name, Phone, Store_Id__c, Store_Hours__c, RecordTypeId, 
                           ShippingStreet, ShippingCity, ShippingState, ShippingCountry, ShippingPostalCode, 
                           BillingStreet, BillingCity, BillingState, BillingCountry, BillingPostalCode 
                           FROM Account 
                           WHERE Store_Id__c = :testStoreId];

        system.assertEquals(retVal, 'success');
        system.assertEquals(newAcct.Name, testStoreName);
        system.assertEquals(newAcct.Phone, testStorePhone);        

        system.assertEquals(newAcct.ShippingStreet, testStoreAddr);
        system.assertEquals(newAcct.BillingStreet, testStoreAddr);

        system.assertEquals(newAcct.ShippingCity, testStoreCity);
        system.assertEquals(newAcct.BillingCity, testStoreCity);

        system.assertEquals(newAcct.ShippingState, testStoreState);
        system.assertEquals(newAcct.BillingState, testStoreState);

        system.assertEquals(newAcct.ShippingPostalCode, testStoreZip);
        system.assertEquals(newAcct.BillingPostalCode, testStoreZip);

        system.assertEquals(newAcct.ShippingCountry, testStoreCountry);
        system.assertEquals(newAcct.BillingCountry, testStoreCountry);        
    }
    
	@isTest
    static void testStoreEndpointException() {
		RestRequest req = new RestRequest();
        RestResponse res = new RestResponse(); 
        
        String testStoreId = 'TEST STORE ID';
        
        req.requestURI = '/services/apexrest/Account/StoreInformation';
        req.httpMethod = 'POST';
        req.addHeader('Content-Type', 'application/xml; charset=UTF-8');
        req.addHeader('Accept', 'application/xml');
        req.requestBody = Blob.valueOf('<?xml version="1.0" encoding="utf-8"?>' +
            '<stores xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns="http://www.demandware.com/xml/impex/store/2007-04-30">' +
                '<store store-id="'+testStoreId+'">' + 
                    '<name>Test Store</name>'+
                    '<address1>123 Test St</address1>'+
                    '<city>Franklin</city>'+
                    '<postal-code>37067</postal-code>'+
                    '<state-code>TN</state-code>'+
                    '<country-code>US</country-code>'+
                    '<phone>+16155551212</phone>'+
                    '<store-hours xml:lang="x-default">Mon: 10:00AM-08:00PM &lt;br/&gt;Tue: 10:00AM-08:00PM &lt;br/&gt;Wed: 10:00AM-08:00PM &lt;br/&gt;Thu: 10:00AM-08:00PM &lt;br/&gt;Fri: 10:00AM-08:00PM &lt;br/&gt;Sat: 10:00AM-06:00PM &lt;br/&gt;Sun: 12:00PM-06:00PM</store-hours>'+
                    '<latitude>0</latitude>'+ // we don't use this value
                    '<longitude>0</longitude>'+ // we don't use this value
                    '<custom-attributes>'+
                        '<custom-attribute attribute-id="isRdc">true</custom-attribute>'+
                        '<custom-attribute attribute-id="customerServiceHours">test hours</custom-attribute>'+
                        '<custom-attribute attribute-id="customerServicePhone">6155551212</custom-attribute>'+
                        '<custom-attribute attribute-id="fulfillerDisplayName">abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyz</custom-attribute>'+
                    '</custom-attributes>'+
                '</store>'+
            '</stores>');            
        
        RestContext.request = req;
        RestContext.response = res; 
        
        try {
            Test.startTest();
            String retVal = API_StoreInformation.addUpdateStoreInfo();
            Test.stopTest();            
        } catch (Exception e) {
            // verify we caught the exception we just generated in the system log object
            DateTime X1MinuteAgo = System.now().addMinutes(-1);
            ErrorLog__c errLogEntry  = [SELECT Id, ApexClass__c , Message__c, Method__c 
                                        FROM ErrorLog__c  
                                        WHERE ApexClass__c='API_StoreInformation' 
                                        AND CreatedDate > :X1MinuteAgo];   
            System.assert(errLogEntry.Message__c.contains(e.getMessage()));
        }
    }    
}