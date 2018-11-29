/****** v1 | Description: Item-Details API | 01/11/2017 | JoJo Zhao */
public class ShoppingCartItemDetailsAPIHelper  extends ProductAPIBaseHelper {
    /**
*   @description <Method to connect Ashely API by using http call out, receive JSON type response>
*   @param <sourceURL sample: https://ashley-preprod-sandbox.apigee.net/homestores/<AccountNo>-<Shipto>/item-details?profitCenter=<profitCenter> >
*   @return <returns String value, it is a JSON string>
**/
    public String connectAPIPostJSON(String sourceURL, String rawPost) {
        return super.connectToAPIPostJSON(sourceURL,new Map<String, String> {'apiKey'=>getAPIKey()}, rawPost);
    }
    
    //DEF-0328
    public String prepareCartItemRawPostWithoutOpp( List<Shopping_cart_line_item__c> lineItems){
        ShoppingCartWrapper cartInfo =  prepareCartItemRawPostSalesOrderLine(lineItems);
        
        cartInfo.Delivery = new ShoppingCartDeliveryWrapper();
        
        ShoppingCartAddressWrapper address = new ShoppingCartAddressWrapper();
        NewOpportunityDefaultAddress__c defaultOppAddress = NewOpportunityDefaultAddress__c.getValues('defaultOppAddress');
        address.PostalCode = defaultOppAddress.PostCode__c; 
        address.StateOrProvince = defaultOppAddress.StateOrProvince__c;
        
        ShoppingCartDeliveryWrapper delivery = new ShoppingCartDeliveryWrapper();
        delivery.Address = address;
        cartInfo.Delivery = delivery;
        String rawPost = JSON.serialize(cartInfo);
        System.debug('rawPost:'+rawPost);
        return rawPost;
    }
    
    public ShoppingCartWrapper prepareCartItemRawPostSalesOrderLine( List<Shopping_cart_line_item__c> lineItems){
        ShoppingCartWrapper cartInfo = new ShoppingCartWrapper();
        cartInfo.SalesOrderLineList = new List<SalesOrderLineWrapper>();
        Integer index = 1;
        for(Shopping_cart_line_item__c cartLine:lineItems){
            
            SalesOrderLineWrapper line= new SalesOrderLineWrapper();
            line.ActionCode = 1;
            
            //TODO, when visit closed cart, it's deliveryDate maybe the date earlier than today
            //Need to think about this, For visiting history cart, we may not call item-detail again.
            Datetime ATCDate;
            if(cartLine.DeliveryDate__c!=null){
                Datetime cartLineDeliveryDatetime=Datetime.newInstanceGmt(cartLine.DeliveryDate__c, time.newInstance(6, 0, 0, 0));
               
                if(cartLineDeliveryDatetime < System.now()){
                    ATCDate = System.now(); 
                }else{
                    ATCDate = cartLineDeliveryDatetime; 
                }
            }else{
                ATCDate = System.now(); 
            }
            line.AvailableDate = ATCDate.format('yyyy-MM-dd\'T\'HH:mm:ss.000XXX', 'CST');
			
			//REQ-488
            if(cartLine.isCallItem__c == true){
                line.Iscall= true;
            }
            SalesOrderLineWrapper.DiscountInfo  discountPrice;
            String reason =cartLine.Discount_Reason_Code__c;
            
            if(cartLine.DiscountType__c=='Percent' && cartLine.Discount__c>0 && cartLine.Discount_Reason_Code__c!=null){
                discountPrice = new SalesOrderLineWrapper.DiscountInfo(cartLine.Discount__c, reason);
                line.UnitPriceAdjustments = new List<SalesOrderLineWrapper.DiscountInfo>{discountPrice};
                    }else if(cartLine.DiscountType__c=='Flat' && cartLine.Flat_Discounted_Amount__c>0 && cartLine.Discount_Reason_Code__c!=null){  
                        discountPrice = new SalesOrderLineWrapper.DiscountInfo((cartLine.Flat_Discounted_Amount__c/cartLine.List_Price__c)*100, 
                                                                               reason);
                        line.UnitPriceAdjustments = new List<SalesOrderLineWrapper.DiscountInfo>{discountPrice};
                            }
            
            line.ItemType=cartLine.ItemType__c==null ? 0:Integer.valueOf(cartLine.ItemType__c);                
            line.ExtendedPrice=cartLine.Extended_Price__c==null ? 0:cartLine.Extended_Price__c;
            line.WarrantySku=cartLine.WarrantySku__c==null ? '':cartLine.WarrantySku__c;
            line.ItemNumber = cartLine.Product_SKU__c;
            line.OriginalPrice = cartLine.List_Price__c==null ? 0: cartLine.List_Price__c;
            
            line.UnitCost = cartLine.Average_Cost__c==null ? 0: cartLine.Average_Cost__c;
            line.LineNumber = index;
         line.DeliverViaCode=cartLine.Delivery_Mode__c; 
             /*Using to pass Threshold Parameter*/
            if(cartLine.Delivery_Mode__c == 'HD')
            {
                if(cartLine.DeliveryType__c == 'THD')
                {
                line.HDServiceType = 'THD';
                    }
                else if(cartLine.DeliveryType__c == 'PDI')
            {
                line.HDServiceType = 'PDI';
            }
                else{
                   line.HDServiceType =''; 
                }
            }   
            else
            {
                line.HDServiceType ='';
            }
            
            line.TotalTax = cartLine.Estimated_Tax__c==null ? 0: cartLine.Estimated_Tax__c;
            //REQ-480
            line.PackageLineNumber = 0; 
            if(line.ItemType==1){
                line.Quantity = 1;
                for(Integer repeat =0; repeat < cartLine.Quantity__c; repeat++){                      
                    cartInfo.SalesOrderLineList.add(line);
                }
            }else{
                cartInfo.SalesOrderLineList.add(line);
                line.Quantity = cartLine.Quantity__c;
            }
			//new line for As_Is
            if(cartLine.As_Is__c){
                //only keep line's DeliveryViaCode for *AS IS lineItem, reset other attribute.
                SalesOrderLineWrapper asIsline= line.clone();
                asIsline.ItemNumber ='*AS IS';
                asIsline.Quantity =1;
                asIsline.UnitPriceAdjustments = null;
                asIsline.WarrantySku = '';
                asIsline.ItemType = 0;
                asIsline.TotalTax=0;
                asIsline.UnitCost=0;
                asIsline.OriginalPrice=0;
                asIsline.ExtendedPrice=0;
                cartInfo.SalesOrderLineList.add(asIsline);
            }
            index++;
        }
        return cartInfo;
    }
    
    /*Using to pass Threshold Parameter*/
    public String prepareCartItemRawPost( List<Shopping_cart_line_item__c> lineItems, String accountId, String deliveryType){
        ShoppingCartWrapper cartInfo =  prepareCartItemRawPostSalesOrderLine(lineItems);
      
        //get cart address info
        Opportunity opp = ShoppingCartDetailCmpCtrl.getShoppingCart(accountId);
        System.debug('opp:'+opp);
        cartInfo.Delivery = new ShoppingCartDeliveryWrapper();
        
        ShoppingCartAddressWrapper address = new ShoppingCartAddressWrapper();
        if(opp!=null){
            address.PostalCode =  opp.Cart_ZipCode__c; //'30004';
            address.StateOrProvince =  opp.Cart_State__c; // 'GA';
        }else{
            address.PostalCode = '';
            address.StateOrProvince = ''; 
        }
        
        ShoppingCartDeliveryWrapper delivery = new ShoppingCartDeliveryWrapper();
        delivery.Address = address;
        cartInfo.Delivery = delivery;
        String rawPost = JSON.serialize(cartInfo);
        System.debug('rawPost:'+rawPost);
        return rawPost;
    }
    
    public String prepareCartItemRawPost( List<Shopping_cart_line_item__c> lineItems, String accountId){
        ShoppingCartWrapper cartInfo =  prepareCartItemRawPostSalesOrderLine(lineItems);
        
        //get cart address info
        Opportunity opp = ShoppingCartDetailCmpCtrl.getShoppingCart(accountId);
        System.debug('opp:'+opp);
        cartInfo.Delivery = new ShoppingCartDeliveryWrapper();
        
        ShoppingCartAddressWrapper address = new ShoppingCartAddressWrapper();
        if(opp!=null){
            address.PostalCode =  opp.Cart_ZipCode__c; //'30004';
            address.StateOrProvince =  opp.Cart_State__c; // 'GA';
        }else{
            address.PostalCode = '';
            address.StateOrProvince = ''; 
        }
        
        ShoppingCartDeliveryWrapper delivery = new ShoppingCartDeliveryWrapper();
        delivery.Address = address;
        cartInfo.Delivery = delivery;
        String rawPost = JSON.serialize(cartInfo);
        System.debug('rawPost:'+rawPost);
        return rawPost;
    }
    
     public String prepareCheckOutItemsRawPost( List<Shopping_cart_line_item__c> lineItems, String accountId, ShoppingCartDeliveryWrapper shiptoAddress){
        ShoppingCartWrapper cartInfo =  prepareCartItemRawPostSalesOrderLine(lineItems);
        
        //get cart address info
        cartInfo.Delivery = new ShoppingCartDeliveryWrapper();
        ShoppingCartDeliveryWrapper delivery = new ShoppingCartDeliveryWrapper();
        delivery.Address = shiptoAddress.Address;
        cartInfo.Delivery = delivery;
        String rawPost = JSON.serialize(cartInfo);
        System.debug('rawPost:'+rawPost);
        return rawPost;
    }
    
    /**
    * @description: Method takes a sku, and pulls users store info, to combine item-details endpoint                                          
    * @return: Returns item-details url 
    **/
    public String getAPIEndpoint(){
        //   https://ashley-preprod-sandbox.apigee.net/homestores/<AccountNo>-<Shipto>/item-details?profitCenter=<profitCenter> 
        try {
            StoreInfoWrapper si;
            if(Test.isRunningTest()){
                si = new StoreInfoWrapper('8888300-164-23-SWF');   
                si.fulfillerId = '8888300-164';
            }else{            
                si = StoreInfo.getStoreInfo();
            }
            String[] paramList = new List<String>{si.fulfillerId,si.profitCtr};
            String path ='';
            if(apiPathConf!=null){
                if(apiPathConf.Product_API_ItemDetail_Path__c!=null){                
                       path = apiPathConf.Product_API_ItemDetail_Path__c;
                }
            }
            return getBaseUrlAPIEndpoint() + String.format(path, paramList);            
        } catch (Exception ex) {
            System.debug(LoggingLevel.ERROR, 'Store Information Exception:' + ex.getMessage() );
            new ErrorLogController().createLog(
                new ErrorLogController.Log(
                    'ShoppingCartTaxAPIHelper',
                    'getAPIEndpoint',
                    'Store Information Exception: ' + ex.getMessage() +
                    ' Stack Trace: ' + ex.getStackTraceString()
                )
            );                              
            return null;            
        }

    }
    
     /**
    *   @description: Method to parse JSON string to a list of ShoppingCartWrapper
    *   @return: ShoppingCartWrapper
    */
    public ShoppingCartResponseWrapper parseJSONToShoppingCartWrapperList(String resJSON){
        
        if(resJSON!=null){
            try{
                 System.debug('json:'+resJSON);
                
                resJSON = resJSON.replace('"NaN"', '0');
                ShoppingCartResponseWrapper res = (ShoppingCartResponseWrapper)JSON.deserialize(resJSON, ShoppingCartResponseWrapper.class);
               
                return res;
            }catch(JSONException ex){
                System.debug(LoggingLevel.ERROR, 'JSON parse Exception:' + ex.getMessage()+';resJSON: '+resJSON );
                new ErrorLogController().createLog(
                    new ErrorLogController.Log(
                        'ShoppingCartTaxAPIHelper',
                        'parseJSONToShoppingCartWrapperList',
                        'JSON Parse Exception: ' + ex.getMessage() +
                        ' Stack Trace: ' + ex.getStackTraceString()
                    )
                );                               
                return null;
            }
        }
        return null;
    }
    
       /**
* @description <get APIKey>                                                        
* @return <returns String value>
**/
    public override String getAPIKey(){
        if(apiItemDetailsConf!=null){
            return apiItemDetailsConf.API_Key__c; 
        }else{
            return '';
        }
    }
    
    
    /**
* @description <get base url of Ashley HomeStore API>                                                        
* @return <returns String value>
**/
    public override String getBaseUrlAPIEndpoint(){      
        if(apiItemDetailsConf!=null){
            return apiItemDetailsConf.End_Point_URL__c; 
        }else{
            return '';
        }
    }
    
    //raw post for fpp
  /*  public String prepareCartItemFppRawPost( Shopping_cart_line_item__c lineItems, String accountId,String fppSku){
        ShoppingCartWrapper cartInfo = new ShoppingCartWrapper();
        cartInfo.SalesOrderLineList = new List<SalesOrderLineWrapper>();
       Integer index = 1;
            SalesOrderLineWrapper line= new SalesOrderLineWrapper();
            line.ActionCode = 1;
            //TODO update ATCDate to correct Estimated Delivery Date
            Date ATCDate = Date.Today().addDays(1);
            line.AvailableDate = ''+ ATCDate.year() +'-'+ATCDate.month() +'-' + ATCDate.day();
              //line.UnitPriceAdjustments = new List<SalesOrderLineWrapper.DiscountInfo>{discountPrice};           
            //If it's FPP type itemNumber, need to refactor here -JoToTheya
            line.ItemNumber =lineItems.Product_SKU__c;
            line.Quantity = lineItems.Quantity__c;
            line.LineNumber = index;
            line.DeliverViaCode=lineItems.Delivery_Mode__c;  
            line.TotalTax = 0;
            line.OriginalPrice=lineItems.List_Price__c;
            line.UnitCost=lineItems.List_Price__c;
            line.WarrantySku=fppSku;
            line.WarrantyPlanNumber=124517;//random number
            cartInfo.SalesOrderLineList.add(line);
            system.debug('cartInfo-->'+cartInfo);
            index++;
        
       
        
         //get cart address info
        Opportunity opp = ShoppingCartDetailCmpCtrl.getShoppingCart(accountId);
        system.debug('opp-->'+opp);
        cartInfo.Delivery = new ShoppingCartDeliveryWrapper();
        
        ShoppingCartAddressWrapper address = new ShoppingCartAddressWrapper();
        if(opp!=null){
            address.PostalCode =  opp.Cart_ZipCode__c; //'30004';
            address.StateOrProvince =  opp.Cart_State__c; // 'GA';
        }else{
            address.PostalCode = '';
            address.StateOrProvince = ''; 
        }
       
        ShoppingCartDeliveryWrapper delivery = new ShoppingCartDeliveryWrapper();
        delivery.Address = address;
        cartInfo.Delivery = delivery;
        String rawPost = JSON.serialize(cartInfo);
        System.debug('rawPost:'+rawPost);
        return rawPost;
    }*/
}