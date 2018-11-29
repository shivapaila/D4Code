/* *******************************************************************************************************************
* Class Name   : ProductPriceCallOutMock
* Description  : Http Call Out Mock test class for Asheley Product HomeStore - Product price and availability API .
* Author       : JoJo Zhao (Perficient, Inc.)
* Created On   : 12/20/2017
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer                                   Date                   Modification ID      Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
*
**************************************************************************************************************************************///
@isTest
global class ProductPriceCallOutMock implements HttpCalloutMock {
    private String fetchType;
    /**
    * @description <Constructor to set api type> 
    **/
    global ProductPriceCallOutMock(String apiType){
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
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            
            ProductPriceWrapper productPrice;
            
            if(fetchType == 'JSONExceptionTest'){
                res.setBody('Non JSON format String to make it throw JSONException when do the JSON Parse');
            }else{
                productPrice = prepareProductPrice();
                String bodyContent = JSON.serialize(productPrice);
                res.setBody(bodyContent);
            }
            res.setStatusCode(200);
            return res;
        }
    }


     /**
    * @description <Simulate ProductPriceWrapper info>                                                       
    * @return <Asserts return is the Mocked ProductPriceWrapper object>
    **/    
    public static ProductPriceWrapper prepareProductPrice(){
        ProductPriceWrapper productPrice = new ProductPriceWrapper();
        productPrice.ImagePath = 'https://www.ashleydirect.com/graphics/AD_Images/W669-88-SW.jpg';
        productPrice.ItemDescription = 'XL TV Stand w/Fireplace Option';
        productPrice.ItemSku = 'W669-88';
        productPrice.NailedDamagedQty = 1.00;
        //productPrice.OnOrderAvailableQty = 100.00;
        productPrice.OnHandAvailableQty = 100.00;
        productPrice.OriginalPrice = 899.99;
        productPrice.SalePrice = 799.99;
        return productPrice;
    }
    
}