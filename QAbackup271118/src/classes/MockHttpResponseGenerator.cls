/* *******************************************************************************************************************
* Class Name   : MockHttpResponseGenerator
* Description  : Mock Http CallOut for WishListControllerTest.     
* Author       : Prabha Kannan (Perficient, Inc.)
* Created On   : 02/09/2018
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer                                   Date                   Modification ID      Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
*
**************************************************************************************************************************************/
@isTest
global class MockHttpResponseGenerator implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        if(!req.getEndpoint().contains('productinformation')) {
        	res.setBody('[{"sku":"7500038", "productName":"Darcy Sofa", "purchasedQuantity": 0, "quantity": 1}]');		    
        }
        else {
            res.setBody('{"product":{"sku":"7500038", "productTitle":"Darcy Sofa", "eCommLargeImage":"sampleUrl","eCommSmallImage":"sampleUrl"}}');
        }
        res.setStatusCode(200);
        return res;
    }
}