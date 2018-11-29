/****** v1 | Description: Test methods for estimated delivery date controller class | 1/16/2018 | L OMeara */
@isTest
public class EstimatedDeliveryDateController_Test {

    private static final String ONE_SOURCE_API_KEY = 'iuvg18wbwA3LwIyy4aj3wEPRTaQGGGYN';
    private static final String FULFILLERID = '8888300-164';

    @testSetup 
    static void setup() {
        TestDataFactory.prepareAPICustomSetting();
        
    }

    /* test query to get delivery date */
    @isTest
    static void testGetDeliveryDate() {

        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new Mock());
        String retVal = EstimatedDeliveryDateController.getDatesFromZip('33547', '1200020', 1);
        API_ATCClient.ATCResponseWrapper resp = (API_ATCClient.ATCResponseWrapper)JSON.deserialize(retVal, API_ATCClient.ATCResponseWrapper.class);
        
		Test.stopTest();
        
        system.assert(resp.isSuccess);
        system.assert(resp.deliveryWindows.size() > 0);
    }

    public class Mock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json');
            if (req.getEndPoint().contains(ONE_SOURCE_API_KEY)){
                res.setBody(getStoreInfoResponse());            
            } else {
                res.setBody(getDeliveryDateResponse());               
            }               
            res.setStatusCode(200);
            res.setStatus('OK');
            return res;
        }
    }

    private static String getDeliveryDateResponse(){
        String sampleResponse = '{"deliveryWindows": [';
        for(Integer i=0; i < 5; i++){
            sampleResponse += '{';
            sampleResponse += '"start": "' + API_ATCClient.formatDateToISO8601(Date.today().addDays(i)) + '",';
            sampleResponse += '"end": "' + API_ATCClient.formatDateToISO8601(Date.today().addDays(i)) + '",';
            sampleResponse += '"sortIndex": ' + String.valueOf(i);
            sampleResponse += '}';
            if(i != 4){
                sampleResponse += ',';
            }
        }      
        sampleResponse += ']}';
        return sampleResponse;         
    }

    private static String getStoreInfoResponse() {
        return '{"oneSourceID":"14444","LocationID":"2667","OneSourceName":"Alpharetta, GA","LocationName":"Alpharetta, GA","LegacyStoreID":"133","ProfitCenter":"34","AccountNo":"8888300","Shipto":"298","ZIP":"30022","RDCNUM":"164","FulfillerID":"' + FULFILLERID + '"}';
    }        
}