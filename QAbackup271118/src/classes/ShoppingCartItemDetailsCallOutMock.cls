/* *******************************************************************************************************************
* Class Name   : ShoppingCartItemDetailsCallOutMock
* Description  : Http Call Out Mock test class for Asheley Product HomeStore - Item-Details API .
* Author       : JoJo Zhao (Perficient, Inc.)
* Created On   : 01/18/2018
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer                                   Date                   Modification ID      Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
*
**************************************************************************************************************************************///
@isTest
global class ShoppingCartItemDetailsCallOutMock implements HttpCalloutMock {
    private String fetchType;
    /**
    * @description <Constructor to set api type> 
    **/
    
    global ShoppingCartItemDetailsCallOutMock(String apiType){
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
            }else if(fetchType == 'starSKU'){
                  itemDetails = prepareStarSKUItemDetails();
                String bodyContent = JSON.serialize(itemDetails);
                res.setBody(bodyContent);
            }else if(fetchType == 'packageSKU'){
                  itemDetails = preparePackageItemDetails();
                String bodyContent = JSON.serialize(itemDetails);
                res.setBody(bodyContent);
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

           "ItemNumber": "3510038",

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
       cartInfo.TotalCost=219.99;
        cartInfo.TotalDiscountAmount=0.99;
        cartInfo.TotalTaxAmount=9.99;
        cartInfo.TotalNextDayCharge=0;
        cartInfo.TotalWarrantyAmount=0;
        cartInfo.TotalRecycleAmount=0;
        cartInfo.TotalDeliveryAmount=199;
        cartInfo.TotalProductLastAmount=0;
        cartInfo.WarrantyItemAmount = new List<ShoppingCartResponseWrapper.PairValueObj>{new ShoppingCartResponseWrapper.PairValueObj('FPP',100.00)};
      
        cartInfo.SalesOrderLineList = new List<SalesOrderLineWrapper>();
        SalesOrderLineWrapper line= new SalesOrderLineWrapper();
        line.ActionCode = 1;
        
        Date ATCDate = Date.Today().addDays(1);
        line.AvailableDate = ''+ ATCDate.year() +'-'+ATCDate.month() +'-' + ATCDate.day();
        line.ItemNumber='3510038';
        line.OriginalPrice = 210.99;
        
        line.UnitCost = 50.99;
        
        line.Quantity = 1;
        line.LineNumber = 1;
        line.DeliverViaCode='HD';    
        line.TotalTax = 9.99;
        line.ExtendedPrice = 210.00;
        line.ItemType = 0;
        line.HDServiceType = 'THD';

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
    
         /**
    * @description <Simulate ProductPriceWrapper info>                                                       
    * @return <Asserts return is the Mocked ProductPriceWrapper object>
    **/    
    
    public static ShoppingCartResponseWrapper prepareStarSKUItemDetails(){
        
           /* Sample Data
{   "SalesOrderLineList": [

         {
         "ActionCode": 0,
         "LineNumber": 1,
         "PackageLineNumber": 0,
         "ItemNumber": "*HDTV42",
         "Quantity": 1,
         "DeliverViaCode": "HD",
         "AvailableDate": "2018-08-03T00:00:00",
         "ItemType": 0,
         "OriginalPrice": 497,
         "UnitCost": 0,
         "UnitPrice": 497,
         "ExtendedPrice": 497,
         "UnitDiscountAmount": 0,
         "UnitDiscountPercent": 0,
         "UnitPriceAdjustments": null,
         "RetailDescription": "42TV furniture was discounted by",
         "Itemcategory": "FMD",
         "CartonQuantity": 1,
         "Taxes":          {
            "TotalTaxAmount": 0,
            "Taxes":             [
                              {
                  "CalculationSequence": 1,
                  "TaxJurisdiction": "102",
                  "TaxRate": 7,
                  "TaxAmount": 34.79,
                  "TaxableAmount": 497
               },
                              {
                  "CalculationSequence": 2,
                  "TaxJurisdiction": "102",
                  "TaxRate": 0,
                  "TaxAmount": 0,
                  "TaxableAmount": 0
               },
                              {
                  "CalculationSequence": 3,
                  "TaxJurisdiction": "102",
                  "TaxRate": 0,
                  "TaxAmount": 0,
                  "TaxableAmount": 0
               }
            ],
            "TaxCode": "102",
            "TaxDescription": "Monroe"
         },
         "TotalTax": 34.79,
         "TaxAmount1": 34.79,
         "TaxAmount2": 0,
         "TaxAmount3": 0,
         "DefaultTaxCode": null,
         "WarrantySku": "",
         "HDServiceType": null
      }*/
        
        ShoppingCartResponseWrapper cartInfo = new ShoppingCartResponseWrapper();
        cartInfo.SalesOrderLineList = new List<SalesOrderLineWrapper>();
        SalesOrderLineWrapper line= new SalesOrderLineWrapper();
        line.ActionCode = 1;
        
        Date ATCDate = Date.Today().addDays(1);
        line.AvailableDate = ''+ ATCDate.year() +'-'+ATCDate.month() +'-' + ATCDate.day();
        line.ItemNumber='*HDTV42';
        line.OriginalPrice = 497.00;
        
        line.UnitCost = 0;
        
        line.Quantity = 1;
        line.LineNumber = 1;
        line.DeliverViaCode='HD';    
        line.TotalTax = 0;
        line.ExtendedPrice = 497.00;
        line.ItemType = 0;
        line.HDServiceType = 'THD';

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
    
          /**
    * @description <Simulate ProductPriceWrapper info>                                                       
    * @return <Asserts return is the Mocked ProductPriceWrapper object>
    **/    
    public static ShoppingCartResponseWrapper preparePackageItemDetails(){
        
           /* Sample Data
{   "SalesOrderLineList": [

           {
         "ActionCode": 0,
         "LineNumber": 1,
         "PackageLineNumber": 1,
         "ItemNumber": "APK-D697-50",
         "Quantity": 1,
         "DeliverViaCode": "HD",
         "AvailableDate": "2018-08-03T00:00:00",
         "ItemType": 1,
         "OriginalPrice": 799.99,
         "UnitCost": 286.29,
         "UnitPrice": 799.99,
         "ExtendedPrice": 799.99,
         "UnitDiscountAmount": 0,
         "UnitDiscountPercent": 0,
         "UnitPriceAdjustments": [],
         "RetailDescription": "2 Pc Round Pedestal Table",
         "Itemcategory": "",
         "CartonQuantity": 1,
         "Taxes":          {
            "TotalTaxAmount": 0,
            "Taxes":             [
                              {
                  "CalculationSequence": 1,
                  "TaxJurisdiction": "102",
                  "TaxRate": 7,
                  "TaxAmount": 55.9993,
                  "TaxableAmount": 799.99
               },
                              {
                  "CalculationSequence": 2,
                  "TaxJurisdiction": "102",
                  "TaxRate": 0,
                  "TaxAmount": 0,
                  "TaxableAmount": 0
               },
                              {
                  "CalculationSequence": 3,
                  "TaxJurisdiction": "102",
                  "TaxRate": 0,
                  "TaxAmount": 0,
                  "TaxableAmount": 0
               }
            ],
            "TaxCode": "102",
            "TaxDescription": "Monroe"
         },
         "TotalTax": 55.9993,
         "TaxAmount1": 55.9993,
         "TaxAmount2": 0,
         "TaxAmount3": 0,
         "DefaultTaxCode": null,
         "WarrantySku": "",
         "HDServiceType": null
      },
            {
         "ActionCode": 0,
         "LineNumber": 2,
         "PackageLineNumber": 1,
         "ItemNumber": "D697-50B",
         "Quantity": 1,
         "DeliverViaCode": "HD",
         "AvailableDate": "2018-08-03T00:00:00",
         "ItemType": 2,
         "OriginalPrice": 200,
         "UnitCost": 70.78,
         "UnitPrice": 200,
         "ExtendedPrice": 200,
         "UnitDiscountAmount": 0,
         "UnitDiscountPercent": 0,
         "UnitPriceAdjustments": null,
         "RetailDescription": "Round DRM Pedestal Table Base",
         "Itemcategory": "MD",
         "CartonQuantity": 1,
         "Taxes":          {
            "TotalTaxAmount": 0,
            "Taxes":             [
                              {
                  "CalculationSequence": 1,
                  "TaxJurisdiction": "102",
                  "TaxRate": 7,
                  "TaxAmount": 14,
                  "TaxableAmount": 200
               },
                              {
                  "CalculationSequence": 2,
                  "TaxJurisdiction": "102",
                  "TaxRate": 0,
                  "TaxAmount": 0,
                  "TaxableAmount": 0
               },
                              {
                  "CalculationSequence": 3,
                  "TaxJurisdiction": "102",
                  "TaxRate": 0,
                  "TaxAmount": 0,
                  "TaxableAmount": 0
               }
            ],
            "TaxCode": "102",
            "TaxDescription": "Monroe"
         },
         "TotalTax": 14,
         "TaxAmount1": 14,
         "TaxAmount2": 0,
         "TaxAmount3": 0,
         "DefaultTaxCode": null,
         "WarrantySku": "",
         "HDServiceType": "PDI"
      },
            {
         "ActionCode": 0,
         "LineNumber": 3,
         "PackageLineNumber": 1,
         "ItemNumber": "D697-50T",
         "Quantity": 1,
         "DeliverViaCode": "HD",
         "AvailableDate": "2018-08-03T00:00:00",
         "ItemType": 2,
         "OriginalPrice": 599.99,
         "UnitCost": 222.48,
         "UnitPrice": 599.99,
         "ExtendedPrice": 599.99,
         "UnitDiscountAmount": 0,
         "UnitDiscountPercent": 0,
         "UnitPriceAdjustments": null,
         "RetailDescription": "Round DRM EXT Pedestal TBL Top",
         "Itemcategory": "MD",
         "CartonQuantity": 1,
         "Taxes":          {
            "TotalTaxAmount": 0,
            "Taxes":             [
                              {
                  "CalculationSequence": 1,
                  "TaxJurisdiction": "102",
                  "TaxRate": 7,
                  "TaxAmount": 41.9993,
                  "TaxableAmount": 599.99
               },
                              {
                  "CalculationSequence": 2,
                  "TaxJurisdiction": "102",
                  "TaxRate": 0,
                  "TaxAmount": 0,
                  "TaxableAmount": 0
               },
                              {
                  "CalculationSequence": 3,
                  "TaxJurisdiction": "102",
                  "TaxRate": 0,
                  "TaxAmount": 0,
                  "TaxableAmount": 0
               }
            ],
            "TaxCode": "102",
            "TaxDescription": "Monroe"
         },
         "TotalTax": 41.9993,
         "TaxAmount1": 41.9993,
         "TaxAmount2": 0,
         "TaxAmount3": 0,
         "DefaultTaxCode": null,
         "WarrantySku": "",
         "HDServiceType": "PDI"
      }
*/
        
        ShoppingCartResponseWrapper cartInfo = new ShoppingCartResponseWrapper();
        cartInfo.SalesOrderLineList = new List<SalesOrderLineWrapper>();
        
        Date ATCDate = Date.Today().addDays(1);
        
        SalesOrderLineWrapper line= new SalesOrderLineWrapper();
        line.ActionCode = 0;
        line.AvailableDate = ''+ ATCDate.year() +'-'+ATCDate.month() +'-' + ATCDate.day();
        line.ItemNumber='APK-D697-50';
        line.PackageLineNumber=1;
        line.OriginalPrice = 799.99;
        line.UnitCost = 286.29;
        line.Quantity = 1;
        line.LineNumber = 1;
        line.DeliverViaCode='HD';    
        line.TotalTax = 0;
        line.ExtendedPrice = 799.99;
        line.ItemType = 1;

        cartInfo.SalesOrderLineList.add(line);
        
        SalesOrderLineWrapper lineSub1= new SalesOrderLineWrapper();
        lineSub1.ActionCode = 0;
        
        lineSub1.AvailableDate = ''+ ATCDate.year() +'-'+ATCDate.month() +'-' + ATCDate.day();
        lineSub1.ItemNumber='D697-50B';
        lineSub1.PackageLineNumber=1;
        lineSub1.OriginalPrice = 499.99;
        lineSub1.UnitCost = 186.29;
        lineSub1.Quantity = 1;
        lineSub1.LineNumber = 2;
        lineSub1.DeliverViaCode='HD';    
        lineSub1.TotalTax = 0;
        lineSub1.ExtendedPrice = 499.99;
        lineSub1.ItemType = 2;
        cartInfo.SalesOrderLineList.add(lineSub1);
        
         SalesOrderLineWrapper lineSub2= new SalesOrderLineWrapper();
        lineSub2.ActionCode = 0;
        
        lineSub2.AvailableDate = ''+ ATCDate.year() +'-'+ATCDate.month() +'-' + ATCDate.day();
        lineSub2.ItemNumber='D697-50T';
        lineSub2.PackageLineNumber=1;
        lineSub2.OriginalPrice = 300.00;
        lineSub2.UnitCost = 100;
        lineSub2.Quantity = 1;
        lineSub2.LineNumber = 3;
        lineSub2.DeliverViaCode='HD';    
        lineSub2.TotalTax = 0;
        lineSub2.ExtendedPrice = 300.00;
        lineSub2.ItemType = 2;
        cartInfo.SalesOrderLineList.add(lineSub2);
        
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