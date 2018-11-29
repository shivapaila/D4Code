/* *******************************************************************************************************************
* Class Name   : ProductDetailCallOutMock
* Description  : Http Call Out Mock test class for Asheley Product Retail - Products API .
* Author       : JoJo Zhao (Perficient, Inc.)
* Created On   : 12/20/2017
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer                                   Date                   Modification ID      Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
*
**************************************************************************************************************************************///
@isTest
global class ProductDetailCallOutMock implements HttpCalloutMock {
    private String fetchType;
    /**
    * @description <Constructor for apiType> 
    **/
    global ProductDetailCallOutMock(String apiType){
        this.fetchType = apiType;
    }
    
    /**
    * @description <Implement the interface HttpCalloutMock's respond method to return mock response>
    * @return <return is the Mocked JSON string or throw a CalloutException>
    **/
	global HTTPResponse respond(HTTPRequest req) {
        if(fetchType == 'CalloutExceptionTest'){
            CalloutException e = (CalloutException)CalloutException.class.newInstance();
            e.setMessage('Throw CalloutException Test. Unauthorized endpoint, please check Setup->Security->Remote site settings.');
            throw e;
        }else{
            system.debug(req.getEndpoint());
            System.assertEquals('GET', req.getMethod());
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            
            ProductDetailWrapper productDetail;
            
            if(fetchType == 'JSONExceptionTest'){
                res.setBody('Non JSON format String to make it throw JSONException when do the JSON Parse');
            }else{
                productDetail = prepareProductDetail();
                String bodyContent = JSON.serialize(productDetail);
                res.setBody(bodyContent);
            }
            res.setStatusCode(200);
            return res;
        }
    }


     /**
    * @description <Simulate Product Detail info>                                                       
    * @return <Asserts return is the Mocked ProductDetailWrapper object>
    **/    
    public static ProductDetailWrapper prepareProductDetail(){
        ProductDetailWrapper productDetail = new ProductDetailWrapper();
        ProductWrapper p1 = new ProductWrapper();
        //Category Id: AFHS-0225
        //product Id: 'B136-53'
        String[] pImageUrls= new String[]{'https://ashleyfurniture.scene7.com/is/image/AshleyFurniture/R099001-DETAIL-WEB'};
            String[] pIds  = new String[]{'W669-88'};
                p1.sku = pIds[0];
        p1.productTitle = p1.sku+' Title name';
        p1.categoryId = 'AFHS-0225';
        p1.imageUrl = pImageUrls[0];
        SwatchesWrapper sw1 =  new SwatchesWrapper();
        sw1.sku =  p1.sku;
        sw1.color = 'red';
        SwatchesWrapper sw2 =  new SwatchesWrapper();
        sw2.sku =  p1.sku;
        sw2.color = 'green';
        p1.swatches = new List<SwatchesWrapper>{sw1,sw2};	
            
            productDetail.product = p1;
        return productDetail;
    }
    
}