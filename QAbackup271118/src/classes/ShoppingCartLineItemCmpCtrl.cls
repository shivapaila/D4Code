/****** v1 | Description:Operation on Shopping Cart Line Item  | 1/3/2018 | JoJo Zhao */
public class ShoppingCartLineItemCmpCtrl {
    public static final String DISCOUNT_PENDING_APPROVAL='Discount Pending Approval';
    public static final String NOT_APPLICABLE='Not Applicable';
    public static final String ATP_API_SETTING_NAME = 'AtpAPI';
    public static final String PATH_SETTING_NAME = 'ProductAPISetting';
    public class ATPApiException extends Exception {}
    /**
* @description <get one product detail>                                                        
* @param <productSKUId : product sku value>
* @return <ProductWrapper>
**/
    @AuraEnabled
    public static ProductWrapper getProductDetail(String productSKUId, String lineItemId) {  
        ProductWrapper pw = ProductDetailCmpCtrl.getProductDetail(productSKUId);
        //REQ-438 to save productTitle to lineItem
        if(lineItemId!=null && pw!=null){
            Shopping_cart_line_item__c updateItem = new Shopping_cart_line_item__c(Id=lineItemId);
            updateItem.Product_Title__c = pw.productTitle;
            update updateItem;
        }
        return pw;
    }
    
    /**
* @description <get product list of certain searchKey>                                                        
* @param <searchKey: searchKey>
* @return <A list of ProductWrapper>
**/
    @AuraEnabled
    public static String getProductListSearch(String searchKey, Integer currentIndex, Integer rows, String filterStr, String lineItemId) {
        return ProductListCmpCtrl.getProductListSearch(searchKey, currentIndex, rows, filterStr);
    }   
    @AuraEnabled
    public static void saveProductTitle(String productTitle, String lineItemId) {
        Shopping_cart_line_item__c updateItem = new Shopping_cart_line_item__c(Id=lineItemId);
        updateItem.Product_Title__c = productTitle;
        update updateItem;
    }    
    
    @AuraEnabled
    public static Shopping_cart_line_item__c getLineItemDetail(String lineItemId) {  
        //REQ-438,  add Product_Title__c for Discount Modal product name column show for items list
        Shopping_cart_line_item__c lineItem = [Select Id, WarrantySku__c,Product_Title__c,Product_SKU__c, Discount__c,Discount_Price__c,DiscountType__c,
                                               Flat_Discounted_Amount__c,Flat_Discounted_Amount_On_Total__c,Last_Price__c,List_Price__c,
                                               List_Price_on_Total__c,Average_Cost__c, Quantity__c, As_Is__c,isCallItem__c,
                                               Opportunity__c,Delivery_Mode__c,DeliveryType__c,Discount_Reason_Code__c,Discount_Status__c,Extended_Price__c,ItemType__c,DeliveryDate__c,
                                               Discount_Approver__c,Discount_Approver__r.Name,
                                               // DEF-0780 - ATC Call
                                               Opportunity__r.Cart_State__c, Opportunity__r.Cart_ZipCode__c,
                                               // DEF-0780 - retrieve from cached info
                                               eComm_Small_Image__c, Item_Color__c 
                                                from Shopping_cart_line_item__c where id=:lineItemId];
        System.debug(lineItem);
        
        //REQ-438
        Decimal itemTotalPrice = 0.0;
        if(lineItem.List_Price__c != null && lineItem.Quantity__c != null){
           itemTotalPrice = lineItem.List_Price__c*lineItem.Quantity__c;
        }
        
        if(lineItem.DiscountType__c=='Percent'){
            lineItem.Flat_Discounted_Amount_On_Total__c =itemTotalPrice - lineItem.Last_Price__c;
        }else if(lineItem.DiscountType__c=='Flat'){
            lineItem.Flat_Discounted_Amount_On_Total__c =lineItem.Flat_Discounted_Amount__c * lineItem.Quantity__c;
            Decimal discountDoublePlus = 10000*(itemTotalPrice - lineItem.Last_Price__c)/itemTotalPrice;
            lineItem.Discount__c = discountDoublePlus.round(System.RoundingMode.HALF_UP)/100;
        }else{
            lineItem.Flat_Discounted_Amount_On_Total__c =0;
            lineItem.Discount__c =0;
        }
        lineItem.List_Price_on_Total__c = lineItem.Last_Price__c;
        
        return lineItem;
    }
    
    @AuraEnabled
    public static Boolean isLineItemLocked(String lineItemId) {  
        return Approval.isLocked(lineItemId);
    }
    
    @AuraEnabled
    public static String deleteFromCart(String lineItemId) {  
        Shopping_cart_line_item__c lineItems = getLineItemDetail(lineItemId);
        
        Id optyId = lineItems.Opportunity__c;//PArt of fix for DEF-0369
        delete lineItems;
        
        //Fix for DEF-0369
        //FIXME Update opportunity total appropriately in a trigger in Release 2
        List<AggregateResult> agr = [SELECT count(Id)numCartLineItems 
                                     FROM Shopping_cart_line_item__c 
                                     WHERE Opportunity__c = :optyId];
        if(agr[0].get('numCartLineItems') == 0){
            Opportunity opty = new Opportunity(Id = optyId, Cart_Grand_Total__c = 0);
            update opty;
        }
        //End of fix for DEF-0369
        
        return 'Success';
    }
    
    @AuraEnabled
    public static String updateAsIs(String lineItemId, Boolean asIs) {  
        Shopping_cart_line_item__c lineItem = getLineItemDetail(lineItemId);
        lineItem.As_Is__c = asIs; 
        update lineItem;
        return 'Success';
    }
    
    @AuraEnabled
    public static String updateQuantity(String lineItemId, Decimal num) {  
        Shopping_cart_line_item__c lineItem = getLineItemDetail(lineItemId);
        lineItem.Quantity__c = num; 
        lineItem.Flat_Discounted_Amount_On_Total__c = lineItem.Flat_Discounted_Amount__c * num;
        if(lineItem.DeliveryDate__c != null)
        {
            lineItem.DeliveryDate__c=null;
        }
        update lineItem;
        return 'Success';
    }
    
    @AuraEnabled  
    public static String saveDiscount(String lineItemId, 
                                      String discountType, 
                                      Decimal percentDiscountAmount, 
                                      Decimal flatDiscountAmount,
                                      String discountReasonCode,
                                      Integer discountApplyOption,
                                      Id approverId) { 
                                          
                                          Decimal marginCriteria = ShoppingCartDetailCmpCtrl.getRSAMarketDiscountThreshholds();
                                          
                                          
                                          //Get current Item   
                                          Shopping_cart_line_item__c currentLineItem =getLineItemDetail(lineItemId);
                                          
                                          
                                          List<Shopping_cart_line_item__c> shoppingDetail = new  List<Shopping_cart_line_item__c>();
                                          List<Shopping_cart_line_item__c> needToApproveItems = new  List<Shopping_cart_line_item__c>();
                                          //Apply to this item
                                          if(discountApplyOption==0){
                                              
                                              currentLineItem.DiscountType__c = discountType;
                                              Decimal averageCost = currentLineItem.Average_Cost__c;
                                              Decimal originalPrice =  currentLineItem.List_Price__c;
                                              
                                              system.debug('costs are: ' + averageCost + ' ' + originalPrice + ' ' + marginCriteria);
                                              
                                              Decimal averageDiscountCriteria = (1-((averageCost*100)/(originalPrice*(100-marginCriteria))))*100;
                                              if(averageCost==0){
                                                  averageDiscountCriteria = 0;
                                              }
                                              
                                              system.debug('averageDiscountCriteria: ' + averageDiscountCriteria);
                                              
                                              if(discountType=='Percent'){
                                                  
                                                  currentLineItem.Discount__c = percentDiscountAmount;
                                                  currentLineItem.Discount_Reason_Code__c = discountReasonCode;
                                                  if(percentDiscountAmount>0 && percentDiscountAmount>averageDiscountCriteria){
                                                      needToApproveItems.add(currentLineItem);
                                                      currentLineItem.Discount_Status__c = DISCOUNT_PENDING_APPROVAL;
                                                      currentLineItem.Discount_Approver__c =  approverId;
                                                  }else{
                                                      currentLineItem.Discount_Status__c = NOT_APPLICABLE;
                                                  }
                                              }else if(discountType=='Flat'){                  
                                                  currentLineItem.Flat_Discounted_Amount__c = flatDiscountAmount/currentLineItem.Quantity__c;                
                                                  currentLineItem.Flat_Discounted_Amount_On_Total__c =flatDiscountAmount;
                                                  
                                                  currentLineItem.Discount_Reason_Code__c = discountReasonCode;
                                                  if(flatDiscountAmount>0 && (flatDiscountAmount/(currentLineItem.List_Price__c*currentLineItem.Quantity__c))*100>averageDiscountCriteria){
                                                      needToApproveItems.add(currentLineItem);
                                                      currentLineItem.Discount_Status__c = DISCOUNT_PENDING_APPROVAL;
                                                      currentLineItem.Discount_Approver__c =  approverId;
                                                  }else{
                                                      currentLineItem.Discount_Status__c = NOT_APPLICABLE;
                                                  }
                                              }
                                              shoppingDetail.add(currentLineItem);
                                          }else if(discountApplyOption==1){ 	//Apply to all items
                                              
                                              //Get All items via current item's opportunity info                    
                                              for (Opportunity master : [Select (Select Id, Product_SKU__c, Discount__c,Discount_Price__c,DiscountType__c,
                                                                                 Flat_Discounted_Amount__c,Last_Price__c, List_Price__c,Average_Cost__c,Quantity__c,
                                                                                 Opportunity__c,Delivery_Mode__c,Discount_Reason_Code__c,Discount_Status__c, 
                                                                                 Discount_Approver__c,Discount_Approver__r.Name from  Shopping_cart_line_items__r) 
                                                                         From Opportunity where id = : currentLineItem.Opportunity__c]){
                                                                             for (Shopping_cart_line_item__c detail : master.Shopping_cart_line_items__r) {
                                                                                 
                                                                                 if(!Approval.isLocked(detail.Id) && !detail.Product_SKU__c.startsWith('*')){
                                                                                     detail.DiscountType__c = discountType;
                                                                                     Decimal averageCost = detail.Average_Cost__c;
                                                                                     Decimal originalPrice =  detail.List_Price__c;
                                                                                     System.debug('averageCost:'+averageCost);
                                                                                     System.debug('originalPrice:'+originalPrice);
                                                                                     System.debug('marginCriteria:'+marginCriteria);
                                                                                     Decimal averageDiscountCriteria = (1-((averageCost*100)/(originalPrice*(100-marginCriteria))))*100;
                                                                                     if(averageCost==0){
                                                                                         averageDiscountCriteria = 0;
                                                                                     }
                                                                                     System.debug('averageDiscountCriteria:'+averageDiscountCriteria);
                                                                                     
                                                                                     if(discountType=='Percent'){
                                                                                         
                                                                                         detail.Discount__c = percentDiscountAmount; 
                                                                                         
                                                                                         detail.Discount_Reason_Code__c = discountReasonCode;
                                                                                         if(percentDiscountAmount>0 && percentDiscountAmount>averageDiscountCriteria){
                                                                                             needToApproveItems.add(detail);
                                                                                             detail.Discount_Status__c = DISCOUNT_PENDING_APPROVAL;
                                                                                             detail.Discount_Approver__c =  approverId;
                                                                                         }else{
                                                                                             detail.Discount_Status__c = NOT_APPLICABLE;
                                                                                         }
                                                                                     }else if(discountType=='Flat'){                 
                                                                                         detail.Flat_Discounted_Amount__c = flatDiscountAmount/detail.Quantity__c;
                                                                                         detail.Flat_Discounted_Amount_On_Total__c =flatDiscountAmount;
                                                                                         
                                                                                         detail.Discount_Reason_Code__c = discountReasonCode;
                                                                                         if(flatDiscountAmount>0 && (flatDiscountAmount/(detail.List_Price__c*detail.Quantity__c))*100>averageDiscountCriteria){
                                                                                             needToApproveItems.add(detail);
                                                                                             detail.Discount_Status__c = DISCOUNT_PENDING_APPROVAL;
                                                                                             detail.Discount_Approver__c =  approverId;
                                                                                         }else{
                                                                                             detail.Discount_Status__c = NOT_APPLICABLE;
                                                                                         }
                                                                                     }
                                                                                     shoppingDetail.add(detail);
                                                                                 }
                                                                             }
                                                                         }                           
                                          } 
                                          
                                          //check whether discount need to approve
                                          update shoppingDetail;       
                                          
                                          requestApproveDiscount(needToApproveItems);
                                          return 'Success';
                                      }
    
    @AuraEnabled  
    public static String saveDeliveryMode(String lineItemId, 
                                          String selectedShippingWay,String accId,string deliveryType){ 
                                              //Integer shippingWayApplyOption) { 
                                              //Get current Item   
                                              String error='';
                                              Shopping_cart_line_item__c currentLineItem = getLineItemDetail(lineItemId);
                                              List<Shopping_cart_line_item__c> shoppingDetail = new  List<Shopping_cart_line_item__c>();
                                              //Apply to this item
                                              //if(shippingWayApplyOption==0){
                                              
                                              currentLineItem.Delivery_Mode__c = selectedShippingWay;
                                              shoppingDetail.add(currentLineItem);
                                              if(selectedShippingWay == 'DS' || selectedShippingWay == 'TW'){                                           
                                                  if(shoppingDetail.size()>0){
                                                      
                                                      ShoppingCartItemDetailsAPIHelper taxAPIHelper = new ShoppingCartItemDetailsAPIHelper();
                                                      String sourceURL = taxAPIHelper.getAPIEndpoint();
                                                      System.debug('sourceURL:'+sourceURL);
                                                      String rawPost = taxAPIHelper.prepareCartItemRawPost(shoppingDetail,accId);
                                                      String resJSON = taxAPIHelper.connectAPIPostJSON(sourceURL, rawPost);                                             
                                                      
                                                       if(resJSON.contains('Direct Shipment is  not available') || resJSON.contains('Take With is not available'))
                                                      {                                                          
                                                          error=resJSON; 
                                                          error=error.remove('"');
                                                      }
                                                  }
                                              }
                                              
                                              /*}else if(shippingWayApplyOption==1){ 	//Apply to all items

                                            //Get All items via current item's opportunity info                    
                                            for (Opportunity master : [Select (Select Id, Product_SKU__c, Discount__c,Discount_Price__c,DiscountType__c,
                                            Flat_Discounted_Amount__c,Last_Price__c,List_Price__c, Average_Cost__c,Quantity__c,
                                            Opportunity__c,Delivery_Mode__c,Discount_Reason_Code__c,Discount_Status__c,
                                            Discount_Approver__c,Discount_Approver__r.Name from  Shopping_cart_line_items__r) 
                                            From Opportunity where id = : currentLineItem.Opportunity__c]){
                                            for (Shopping_cart_line_item__c detail : master.Shopping_cart_line_items__r) {
                                            if(!Approval.isLocked(detail.Id)  && !detail.Product_SKU__c.startsWith('*')){
                                            detail.Delivery_Mode__c = selectedShippingWay;
                                            shoppingDetail.add(detail);
                                            }
                                            
                                            }
                                            }                           
                                            } 
                                            */
                                              if(String.isEmpty(error))
                                              {
                                                  update shoppingDetail;    
                                              }  
                                              //Empty the delivery date DEF-0424
                                              List<Shopping_cart_line_item__c> lineitems=[Select Id, Product_SKU__c, Opportunity__c,Quantity__c,Delivery_Mode__c,DeliveryDate__c
                                                                                          From Shopping_cart_line_item__c 
                                                                                          Where Opportunity__c=:currentLineItem.Opportunity__c and Delivery_Mode__c=: selectedShippingWay]; 
                                              
                                              List<Shopping_cart_line_item__c> lstToBeUpdated= new List<Shopping_cart_line_item__c>();
                                              if(!lineitems.isEmpty()){
                                                  for(Shopping_cart_line_item__c line:lineitems)
                                                  {                                                      
                                                      if(line.Delivery_Mode__c != 'TW')
                                                      {
                                                          line.DeliveryDate__c=null;
                                                          
                                                      }
                                                      else
                                                      {
                                                          //DEF-0416 default today as delivery date for TW
                                                          line.DeliveryDate__c=Date.today();
                                                      }
                                                      if(line.Delivery_Mode__c == 'HD')
                                                      {
                                                          line.DeliveryType__c = deliveryType;
                                                      }else{
                                                          
                                                        line.DeliveryType__c = deliveryType;  
                                                      }
													  
                                                      lstToBeUpdated.add(line);
                                                     
                                                  }
                                                  
                                                  update lstToBeUpdated;
                                              }
                                              //End of DEF-0424 block
                                              
                                              if(String.isNotEmpty(error)){
                                                  
                                                  return error;
                                              }
                                              else{
                                                  return 'Success';
                                              }
                                          }
    
    public static void requestApproveDiscount(List<Shopping_cart_line_item__c> lineItems){
        for(Shopping_cart_line_item__c lineItem: lineItems){
            Approval.ProcessSubmitRequest psr = new Approval.ProcessSubmitRequest();
            psr.setComments('Submitting for approval.');
            psr.setObjectId(lineItem.id);
            psr.setSubmitterId( UserInfo.getUserId() ); 
            psr.setProcessDefinitionNameOrId('Discount_Approval_Process');
            psr.setSkipEntryCriteria(true); 
            psr.setNextApproverIds(new List<Id>{lineItem.Discount_Approver__c});
            try{
                Approval.ProcessResult result = Approval.process(psr);
                if(!result.isSuccess()){
                    System.debug(result.getErrors());
                    new ErrorLogController().createLog(
                        new ErrorLogController.Log(
                            'ShoppingCartLineItemCmpCtrl', 'requestApproveDiscount',
                            'Failed to request discount approval: ' + result.getErrors()
                        )
                    );          
                }
            }catch(Exception ex){
                System.debug(ex);
                new ErrorLogController().createLog(
                    new ErrorLogController.Log(
                        'ShoppingCartLineItemCmpCtrl', 'requestApproveDiscount',
                        'Failed to request discount approval: ' + ex.getMessage() +
                        ' Stack Trace: ' + ex.getStackTraceString()
                    )
                );          
            }
        }
        
    }
    @AuraEnabled
    public static String updateFppToLineItem(String fppSku,String lineItemId) {
        Shopping_cart_line_item__c lineItem = getLineItemDetail(lineItemId);
        lineItem.WarrantySku__c = fppSku; 
        update lineItem;
        return 'Success';
    }
    
    @AuraEnabled
    public static List<lineItemWrapper> getATPResponse(String sourceURL,List<lineItemWrapper> lineItem,Integration_Settings__c pmtTypesConf) {
        String endPointURL;
        for(lineItemWrapper wrapper:lineItem)
        {  
            if(wrapper.item.Delivery_Mode__c == 'HD'){
                String[] urlArr = sourceURL.split('&pc');
                if(!urlArr.isEmpty()){
                    endPointURL=urlArr[0];
                }
                
            }
            else if(wrapper.item.Delivery_Mode__c == 'DS'){
                endPointURL=sourceURL;
            }
            
            
        }
        //String endPointURL='https://ashley-preprod-dev.apigee.net/inventory/retail?as=8888300-164&sqt=D553-224|3|false&pc=30004';                   
        system.debug('endPointURL-->'+endPointURL);
        ShoppingCartItemDetailsAPIHelper itemDetailAPIHelper = new ShoppingCartItemDetailsAPIHelper();
        String resJSON = itemDetailAPIHelper.connectToAPIGetJSON(endPointURL,new Map<String, String> {'apiKey'=>pmtTypesConf.API_Key__c});
        JSONParser parser = JSON.createParser(resJSON);
        ATPWrapper ATPResponse=(ATPWrapper)parser.readValueAs(ATPWrapper.class);
        system.debug('ATPResponse-->'+ATPResponse);
        for(lineItemWrapper wrapper:lineItem)
        {
            if(wrapper.item.Delivery_Mode__c == 'HD' || wrapper.item.Delivery_Mode__c == 'DS'){
                if(!ATPResponse.entities.isEmpty())
                {
                    for(EntitiesWrapper entity:ATPResponse.entities){
                        
                        if(entity.sku == wrapper.item.Product_SKU__c)
                        {
                            wrapper.msg=entity.message;
                            
                        }
                        
                    }
                }
                
                else{
                    wrapper.msg='This item is not presently available in store. Please select another delivery method.';
                }
            }
        }
        system.debug('lineItem after ATP-->'+lineItem);
        return lineItem;
    }
    // DEF-0780 - ATC call
    @AuraEnabled
    public static DateTime getBestDate(Shopping_cart_line_item__c detail) {
        try {
            if(detail.Delivery_Mode__c == 'TW') {
                return system.today();
            }
            else {
                // store info and delivery window will be retrieved from API if needed and set already by ShoppingCartDetailCmpCtrl
                // so this method will just query
                StoreInfoWrapper si = ShoppingCartDetailCmpCtrl.getStoreInfoInShoppingCartDetail();
                Delivery_Window__c deliveryWindowSetting = Delivery_Window__c.getInstance('Delivery Window');
                Integer window = deliveryWindowSetting != null ? (Integer) deliveryWindowSetting.Window__c : null;
                DateTime bestDate;
                if(window != null) {
                    Date preferredDeliveryDateCoverted = date.today();
                    preferredDeliveryDateCoverted=preferredDeliveryDateCoverted.addDays(1);
                    API_ATCClient.ATCPayload  payload = new API_ATCClient.ATCPayload();
                    payload.deliveryMode=detail.Delivery_Mode__c;

                    payload.region = detail.Opportunity__r.Cart_State__c;
                    payload.postalCode = detail.Opportunity__r.Cart_ZipCode__c;

                    payload.products.add(new API_ATCClient.ProductWrapper(detail.Product_SKU__c, Integer.valueOf(detail.Quantity__c)));

                    API_ATCClient.ATCResponseWrapper apiCallResponse = API_ATCClient.getAvailableDeliveryWindows(si.acctNo, si.RDC,preferredDeliveryDateCoverted, preferredDeliveryDateCoverted.addDays(window), payload);
                    if(!apiCallResponse.deliveryWindows.isEmpty())
                    {
                        Date windowDt=apiCallResponse.deliveryWindows[0].getStartDate();
                        Datetime dt = datetime.newInstance(windowDt.year(), windowDt.month(),windowDt.day());
                        bestDate=dt;
                    }
                }
                else {
                    throw new AuraHandledException('Error in retrieving Delivery Window');
                }
                return bestDate;
            }
        }
        catch(Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static String tresholdenabledcall(boolean b){
     
     StoreInfoWrapper si;
     si = StoreInfo.getStoreInfo();
     string fulfiller = si.fulfillerId;
     string profitcenter = si.profitCtr;
     string OneSourceID = si.OneSourceID;
     Map<string, OneSourceID__c> OneSourceMap = OneSourceID__c.getAll();
        
     if(OneSourceMap.containskey(OneSourceID)){
     system.debug('fulfiller,profitcenter'+fulfiller+profitcenter);  
      String endpoint = system.label.AshleyApigeeEndpoint+fulfiller+'/salesorders/sales-orders/settings/THRES_HOLD_ENABLED?profitcenter='+profitcenter;
      Http http = new http();
      Httprequest req = new HttpRequest();
      req.setHeader('apikey', system.label.AshleyApigeeApiKey);
      req.setEndpoint(endpoint);
      system.debug('tresholdenabledcall enpoint' + endpoint);
      req.setTimeOut(120000);
      req.setMethod('GET');
      HttpResponse res = http.send(req);
        
      System.debug('tresholdenabledcall response' + res.getBody());
       system.debug('tresholdenabledcall status' + res.getStatusCode());
        if(res.getStatusCode()==200) {
           
            
          return res.getBody();
        } else {
              String errMsg='No records founds--';  
                AuraHandledException ex = new AuraHandledException(errMsg);
                return errMsg;  
        
       
    	} 
     }else{
         
         return null;
     }
    }
}