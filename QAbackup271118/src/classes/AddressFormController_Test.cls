/******Description: Test methods for address form controller class*/
@isTest
public class AddressFormController_Test {
    @testSetup 
    static void setup() {
        TestDataFactory.prepareAPICustomSetting();
    }
    
    @isTest
    static void testSearchAddress(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new EDQHttpResponseMock(200));
		String result = addressformcontroller.SearchAddress('Akron', 'US', 7);
		Test.stopTest();
    }
    
    @isTest
    static void testFormatAddress(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new EDQHttpResponseMock(200));
		String result = addressformcontroller.FormatAddress('https://api.edq.com/capture/address/v2/format?country=AUS&id=700AUS-NOAUSHAHgBwAAAAAIAwEAAAABV3R_gAAAAAAAAAAA..9kAAAAAP....8AAAAAAAAAAAAAAAAASGFtaWx0b24A');
        Test.stopTest();
    }
}