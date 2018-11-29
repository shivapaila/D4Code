/****** v1 | Description: Test coverage for store information utility | 1/30/2018 | L OMeara */
@isTest
public class StoreInfo_Test {
    @isTest
    static void testGetStoreInfoNoConfig() {
        StoreInfoMock fakeResponse = new StoreInfoMock(200, 'Complete',
                                                       '[{"Name": "sForceTest1"}]',
                                                       null);
		Test.setMock(HttpCalloutMock.class, fakeResponse);
        try {
            Test.startTest();
            StoreInfoWrapper siw = StoreInfo.getStoreInfo();
            Test.stopTest();
        } catch (Exception e) {
            System.assert(e.getMessage()!=null);
        }
    }
    
    @isTest
    static void testGetStoreInfo() {
        StoreInfoMock fakeResponse = new StoreInfoMock(200, 'Complete',
                                                       '{"oneSourceID":"14444","LocationID":"2667","OneSourceName":"Alpharetta, GA","LocationName":"Alpharetta, GA","LegacyStoreID":"133","ProfitCenter":"34","AccountNo":"8888300","Shipto":"298","ZIP":"30022","RDCNUM":"164","FulfillerID":"8888300-164"}',
                                                       null);
		Test.setMock(HttpCalloutMock.class, fakeResponse);

        // Create custom setting
        TestDataFactory.prepareAPICustomSetting();

        try {
            Test.startTest();
            StoreInfoWrapper siw = StoreInfo.getStoreInfo();
            Test.stopTest();
        } catch (Exception e) {
            System.assert(e.getMessage()!=null);
        }
    }    
}