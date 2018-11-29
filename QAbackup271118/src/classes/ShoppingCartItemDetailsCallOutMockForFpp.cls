/* *******************************************************************************************************************
* Class Name   : ShoppingCartItemDetailsCallOutMockForFpp
* Description  : Http Call Out Mock test class for Asheley Product HomeStore - Item-Details API .
* Author       : Theyagarajan (Perficient, Inc.)
* Created On   : 01/24/2018
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer                                   Date                   Modification ID      Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
*
**************************************************************************************************************************************///
@isTest
global class ShoppingCartItemDetailsCallOutMockForFpp implements HttpCalloutMock {
    private String fetchType;
    /**
    * @description <Constructor to set api type> 
    **/
    global ShoppingCartItemDetailsCallOutMockForFpp(String apiType){
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
            
            ShoppingCartResponseWrapper itemDetails;
            
            if(fetchType == 'JSONExceptionTest'){
                res.setBody('Non JSON format String to make it throw JSONException when do the JSON Parse');
            }else{
                itemDetails = prepareItemDetails();
                String bodyContent = JSON.serialize(itemDetails);
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
    public static ShoppingCartResponseWrapper prepareItemDetails(){
        
           /* Sample Data
{   "SalesOrderLineList": [

       {

           "ActionCode": 2,

           "ItemNumber": "*KSADJPR5YNT",

           "DeliverViaCode": "CPS",

            "Quantity": 1,

           "AvailableDate": "2018-01-30",

           "LineNumber" :1,

           "UnitPriceAdjustments":[

             {

                             "Percent":10,

                             "ReasonCode":"Store Discount"

             }]

       }
    ],

   "Delivery": {

       "Address": {

           "City": "ALPHARETTA",

           "PostalCode": "30004",

           "StateOrProvince": "GA"

       }

   }

}*/
        
        ShoppingCartResponseWrapper cartInfo = new ShoppingCartResponseWrapper();
        cartInfo.SalesOrderLineList = new List<SalesOrderLineWrapper>();
        SalesOrderLineWrapper line= new SalesOrderLineWrapper();
        line.ActionCode = 1;
        
        Date ATCDate = Date.Today().addDays(1);
        line.AvailableDate = ''+ ATCDate.year() +'-'+ATCDate.month() +'-' + ATCDate.day();
        line.ItemNumber='*KSADJPR5YNT';
        line.OriginalPrice = 210.99;
        
        line.UnitCost = 50.99;
        
        line.Quantity = 1;
        line.LineNumber = 1;
        line.DeliverViaCode='HD';    
        line.TotalTax = 9.99;
        
        cartInfo.SalesOrderLineList.add(line);
        
        cartInfo.Delivery = new ShoppingCartDeliveryWrapper();
        
        ShoppingCartAddressWrapper address = new ShoppingCartAddressWrapper();
        address.PostalCode = '30004';
        address.StateOrProvince = 'GA'; 
        
        ShoppingCartDeliveryWrapper delivery = new ShoppingCartDeliveryWrapper();
        delivery.Address = address;
        cartInfo.Delivery = delivery;
        return cartInfo;
    }
    
}