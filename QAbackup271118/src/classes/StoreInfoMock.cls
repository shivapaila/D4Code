/****** v1 | Description: Mocks for testing store info methods | 1/30/2018 | L OMeara */
@isTest
public class StoreInfoMock implements HttpCalloutMock {
		protected Integer code;
		protected String status;
		protected String bodyAsString;
		protected Blob bodyAsBlob;
		protected Map<String, String> responseHeaders;

    	public StoreInfoMock() {
			this.code = 200;
			this.status = 'Complete';
			this.bodyAsString = prepareMockResponse();
			this.bodyAsBlob = null;
			this.responseHeaders = responseHeaders;
		}
		public StoreInfoMock(Integer code, String status, String body,
                             Map<String, String> responseHeaders) {
			this.code = code;
			this.status = status;
			this.bodyAsString = body;
			this.bodyAsBlob = null;
			this.responseHeaders = responseHeaders;
		}

		public StoreInfoMock(Integer code, String status, Blob body,
                             Map<String, String> responseHeaders) {
			this.code = code;
			this.status = status;
			this.bodyAsBlob = body;
			this.bodyAsString = null;
			this.responseHeaders = responseHeaders;
		}

	    public HTTPResponse respond(HTTPRequest req) {
	        HttpResponse resp = new HttpResponse();
			resp.setStatusCode(code);
			resp.setStatus(status);
			if (bodyAsBlob != null) {
				resp.setBodyAsBlob(bodyAsBlob);
			} else {
				resp.setBody(bodyAsString);
			}

			if (responseHeaders != null) {
			     for (String key : responseHeaders.keySet()) {
				resp.setHeader(key, responseHeaders.get(key));
			     }
			}
			return resp;
	    }
    
         /**
    * @description <Simulate Product Detail info>                                                       
    * @return <Asserts return is the Mocked ProductDetailWrapper object>
    **/    
    public static String prepareMockResponse(){
        /* Sample Data
         '{"oneSourceID":"14444",
"LocationID":"2667",
"OneSourceName":"Alpharetta, GA",
"LocationName":"Alpharetta, GA",
"LegacyStoreID":"133",
"LegalEntityName":"Kingswere Furniture, LLC",
"ProfitCenter":"34",
"AccountNo":"8888300",
"Shipto":"298",
"ZIP":"30022",
"RDCNUM":"164",
"FulfillerID":"8888300-164"}'
*/
        Map<String,Object> storeInfo = new  Map<String,Object>();
        storeInfo.put('oneSourceID', '14444');
        storeInfo.put('LocationID', '2667');
        storeInfo.put('OneSourceName', 'Alpharetta, GA');
        storeInfo.put('LocationName', 'Alpharetta, GA');
        storeInfo.put('LegacyStoreID', '133');      
        storeInfo.put('LegalEntityName', 'Kingswere Furniture, LLC');
        storeInfo.put('ProfitCenter', '34');
        storeInfo.put('AccountNo', '8888300');
        storeInfo.put('Shipto', '298');
        storeInfo.put('ZIP', '30022');
        storeInfo.put('RDCNUM', '164');     
        storeInfo.put('FulfillerID', '8888300-164');
        
        return JSON.serialize(storeInfo);
    }
}