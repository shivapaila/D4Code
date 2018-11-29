@isTest
public class ProductAPIBaseHelper_Test {
    
     @testSetup 
    static void setup() {
        TestDataFactory.prepareAPICustomSetting();
        
    }
    public static testMethod void apiConfTest(){
        Test.startTest();
        
        ProductAPIBaseHelper pbHelper = new ProductAPIBaseHelper();
        pbHelper.apiPathConf = pbHelper.getAPIPathConf();
        pbHelper.apiReviewsConf = pbHelper.getAPIConf(ProductAPIBaseHelper.PRODUCT_REVIEWS_API_ENDPOINT_SETTING_NAME);
        pbHelper.apiProductConf = pbHelper.getAPIConf(ProductAPIBaseHelper.PRODUCT_API_ENDPOINT_SETTING_NAME);
        pbHelper.apiProductFilterConf = pbHelper.getAPIConf(ProductAPIBaseHelper.PRODUCT_FILTER_API_ENDPOINT_SETTING_NAME);
        
        Test.stopTest();
        System.assertNotEquals(null, pbHelper.apiPathConf);
        System.assertNotEquals(null, pbHelper.apiReviewsConf);
        System.assertNotEquals(null, pbHelper.apiProductConf);
        
        
    }
    public static testMethod void apiEndPointAndVersionTest(){
        ProductAPIBaseHelper pbHelper = new ProductAPIBaseHelper();
        System.assertEquals('', pbHelper.getAPIEndpoint(''));
        System.assertEquals('', pbHelper.getAPIVersion());
    }
    public static testMethod void formateJSONTest(){
        ProductAPIBaseHelper pbHelper = new ProductAPIBaseHelper();
        String resJSON = '[test json]';
        System.assertEquals('test json', pbHelper.formatJSON(resJSON));
    }
    public static testMethod void productDetailAPITest(){
     
        String fetchType='other';
        String productSkuId = 'W669-88';
        Test.setMock(HttpCalloutMock.class, new ProductDetailCallOutMock(fetchType));
        Test.startTest();
        ProductDetailAPIHelper prodDetailAPIHelper = new ProductDetailAPIHelper();
        
        String resJSON = prodDetailAPIHelper.connectToAPIGetJSON('http://testsource.com');
        System.assertNotEquals(null, resJSON);
        
        Test.stopTest();
    }

    @isTest
    public static void baseUrlAPIEndpointTest(){
        ProductAPIBaseHelper prodDetailAPIHelper = new ProductAPIBaseHelper();
        System.assert(prodDetailAPIHelper.getBaseUrlAPIEndpoint()!=null);
        System.assert(prodDetailAPIHelper.getAPIKey()!=null);
        System.assert(ProductAPIBaseHelper.PRODUCT_API_SETTING_NAME!=null);
        System.assert(ProductAPIBaseHelper.ITEM_DETAIL_API_ENDPOINT_SETTING_NAME!=null);
        System.assert(ProductAPIBaseHelper.PRODUCT_API_ENDPOINT_SETTING_NAME!=null);
        System.assert(ProductAPIBaseHelper.PRODUCT_REVIEWS_API_ENDPOINT_SETTING_NAME!=null);
        System.assert(ProductAPIBaseHelper.PRODUCT_FILTER_API_ENDPOINT_SETTING_NAME!=null);
        System.assert(ProductAPIBaseHelper.ECOMM_PRICING_API_ENDPOINT_SETTING_NAME!=null);
    }
    
    public static testMethod void testConnectToAPIGetJSON() {
        ProductAPIBaseHelper prodDetailAPIHelper = new ProductAPIBaseHelper();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Mock());
        prodDetailAPIHelper.connectToAPIGetJSON('https://testSourceURL.sfdc.afi.testclass.com', null);
        Test.stopTest();
    }
    public static testMethod void testConnectToAPIPostJSON() {
        ProductAPIBaseHelper prodDetailAPIHelper = new ProductAPIBaseHelper();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Mock());
        prodDetailAPIHelper.connectToAPIPostJSON('https://testSourceURL.sfdc.afi.testclass.com', null, null);
        Test.stopTest();
    }
    // Mock callouts for all Financing api calls
    public class Mock implements HttpCalloutMock {
        public Mock() {
        }
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setBody('Success');
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            res.setStatus('OK');
            return res;
        }
    }
}