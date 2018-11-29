/****** v1 | Description:Shopping Cart detail info of selected customer | 1/3/2018 | JoJo Zhao */
public class ShoppingCartDetailCmpCtrl {
    public static final String CHECKOUT_PROFILENAMESKEY = 'ShowCheckoutTo';
    public static final String ALL_PROFILES = 'all';
    public static final String ATC_CALL_DAYS_API_SETTING_NAME = 'ATC_CALL_DAYS API';
   	public static final String PATH_SETTING_NAME = 'ProductAPISetting';
    public class ATC_CALL_DAYS_APIException extends Exception {}

    @AuraEnabled
    public static List<Shopping_cart_line_item__c> getShoppingCartLineItems(String accountId){
        //Select (Select Product_SKU__c, Discount__c, Opportunity__c from  Shopping_cart_line_items__r) 
        //From Opportunity where Contact__c='0032F000008OvR2' and createdDate = LAST_N_DAYS:30
        List<Shopping_cart_line_item__c> shoppingDetail = new  List<Shopping_cart_line_item__c>();
        
        //REQ-438,  add Product_Title__c for Discount Modal product name column show for items list
        for (Opportunity master : [Select (Select Id, WarrantySku__c,  Product_Title__c, Product_SKU__c, Discount__c,Discount_Price__c,DiscountType__c,
                                           Flat_Discounted_Amount__c,Flat_Discounted_Amount_On_Total__c,Discount_Approver__c,Discount_Approver__r.Name,Last_Price__c,List_Price__c, Average_Cost__c, Quantity__c,Extended_Price__c,ItemType__c,
                                           Opportunity__c,Delivery_Mode__c,DeliveryType__c,Discount_Reason_Code__c,Discount_Status__c, Estimated_Tax__c,DeliveryDate__c,As_Is__c,isCallItem__c
                                           from  Shopping_cart_line_items__r ) 
                                   From Opportunity where AccountId=:accountId 
                                   and StageName != 'Closed Won' 
								   and StageName != 'Closed Lost'
                                   and StageName != 'Sale Suspended' 
                                   and createdDate = LAST_N_DAYS:30]){   
                                       for (Shopping_cart_line_item__c detail : master.Shopping_cart_line_items__r) {
                                           //if(!detail.Product_SKU__c.startsWith('*')){
                                               shoppingDetail.add(detail);
                                          // }
                                       }
                                   }
        return shoppingDetail;
    }
   
    @AuraEnabled
    public static Opportunity getShoppingCart(String accountId){
        Opportunity currentCart = new Opportunity();
        //REQ-438, add Discount__c,Discount_Reason_Code__c for cart level discount
        Opportunity[] opps = [Select Id,AccountId, Account.Name, Cart_ZipCode__c, Cart_State__c, Discount__c,Discount_Reason_Code__c From Opportunity where  
                              AccountId=:accountId 
                              and StageName != 'Closed Won'
                              and StageName != 'Closed Lost'
                              and StageName != 'Sale Suspended' 
                              and createdDate = LAST_N_DAYS:30];
        if(opps.size()>0)
            currentCart = opps[0];
        return currentCart;
    }
    
    
    @AuraEnabled
    public static List<PairObj> getShippingWayList() {  
        String objectName = 'Shopping_cart_line_item__c';
        String picklistFieldName = 'Delivery_Mode__c';
        List<PairObj> picklistOptionList =  getPairObj(objectName,picklistFieldName ); 
        return picklistOptionList;
    }
    
    @AuraEnabled
    public static List<PairObj> getDiscountReasonList() {  
        String objectName = 'Shopping_cart_line_item__c';
        String picklistFieldName = 'Discount_Reason_Code__c';
        List<PairObj> picklistOptionList =  getPairObj(objectName,picklistFieldName ); 
        return picklistOptionList;
    }
    
    @AuraEnabled
    public static String getRSAOneSourceId() {  
        User usr = [SELECT Last_Checked_Store_Info__c, One_Source_ID__c, AcctNo_ShipTo_ProfitCtr__c 
                    FROM User WHERE Id = :UserInfo.getUserId()][0];
        
        
        return usr.One_Source_ID__c;
    }
    
    @AuraEnabled
    public static List<PairObj> getCartStateList() {  
        String objectName = 'Opportunity';
        String picklistFieldName = 'Cart_State__c';
        List<PairObj> picklistOptionList =  getPairObj(objectName,picklistFieldName ); 
        return picklistOptionList;
    }
    
    public static List<PairObj> getPairObj(String objectName,String picklistFieldName ) {  
        
        Map<String, Schema.SObjectType> GlobalMap = Schema.getGlobalDescribe();
        
        Schema.DescribeSObjectResult obj = GlobalMap.get(objectName).getDescribe();
        
        Schema.DescribeFieldResult watchField = obj.Fields.getMap().get(picklistFieldName).getDescribe();
        
        List<PairObj> picklistOptionList = new List<PairObj>();
        
        List<Schema.PicklistEntry> pkListValue =watchField.getPicklistValues();
        for( Schema.PicklistEntry pk: pklistValue){
            if(pk.isActive())
                picklistOptionList.add(new PairObj(pk.getValue(),pk.getLabel()));
        }
        
        return picklistOptionList;
    }
    
    
    /**
* @description: get tax information for shopping cart                                                      
* @param: accountId - customer Id
* @return: ShoppingCartResponseWrapper
**/
    @AuraEnabled
    public static ShoppingCartResponseWrapper getShoppingCartTaxInfo(String accountId) {  
        ShoppingCartResponseWrapper scwRes = new   ShoppingCartResponseWrapper();
        List<Shopping_cart_line_item__c> lineItems = getShoppingCartLineItems(accountId);
        system.debug('lineItems---'+lineItems);
        if(lineItems.size()>0){
            
            ShoppingCartItemDetailsAPIHelper taxAPIHelper = new ShoppingCartItemDetailsAPIHelper();
            String sourceURL = taxAPIHelper.getAPIEndpoint();
            System.debug('sourceURL:'+sourceURL);
            String rawPost = taxAPIHelper.prepareCartItemRawPost(lineItems,accountId);
            String resJSON = taxAPIHelper.connectAPIPostJSON(sourceURL, rawPost);
            system.debug('resJSON---'+resJSON);
            scwRes =  taxAPIHelper.parseJSONToShoppingCartWrapperList(resJSON);
            if(scwRes==null){

                //REQ-489 item 5 and item 9
                if(  Pattern.matches('\"PostalCode [0-9]* is not valid .\"', resJSON)){
                    throw new AuraHandledException('Please enter a valid zip code.');   
                }/*DEF-0777 fix -else if( resJSON.contains('Input Cart Details invalid.')&& ( resJSON.contains('PostalCode') || resJSON.contains('City') || resJSON.contains('State'))){
                    throw new AuraHandledException('Please input a valid address.');   
                
                }*/
                else if( resJSON.contains('Input Cart Details invalid.')){
                    throw new AuraHandledException(parseErrorMsg(resJSON));   
                
                }
                else{
                    throw new AuraHandledException('Error in retrieving tax information.'+ resJSON +' Please correct data or contact a system administrator.');
                }
            }
            Map<String, Decimal> originalPriceMap = new Map<String, Decimal>();
            Map<String, Decimal> extendedPriceMap = new Map<String, Decimal>();
            Map<String, Decimal> itemTypeMap = new Map<String, Decimal>();
            
            Map<String, Decimal> sMap = new Map<String, Decimal>();
            Map<String, Decimal> averageCostMap = new Map<String, Decimal>();
            //Set default 199 delivery fee -For R1, To refactor in R2
            //scwRes.TotalDeliveryAmount = 199;
            scwRes.TotalProductLastAmount = 0;
            //scwRes.SalesGrandTotal =  0;
            //scwRes.TotalTaxAmount = 0;
            scwRes.WarrantyItemAmount = new ShoppingCartResponseWrapper.PairValueObj[]{};
            for(SalesOrderLineWrapper s: scwRes.SalesOrderLineList){
                
                /* if(s.ItemNumber.startsWith('*DELI')){
// scwRes.TotalDeliveryAmount = scwRes.TotalDeliveryAmount + s.OriginalPrice;
scwRes.TotalTaxAmount =  scwRes.TotalTaxAmount - s.TotalTax;
}*/
               // System.debug('ItemType'+s.ItemType);
                if( (!s.ItemNumber.startsWith('*') && s.ItemType!=2) || (s.ItemNumber.startsWith('*') && s.ItemType==5)){ 
                    //ItemType = 0 is normal product
                    //ItemType = 1 is package/kit product marster
                    //ItemType = 2 is package/kit product sub
                    //ItemType = 5 is fpp item
                  //  scwRes.TotalTaxAmount = scwRes.TotalTaxAmount + s.TotalTax;
                   // scwRes.SalesGrandTotal = scwRes.SalesGrandTotal + s.ExtendedPrice;
                }

                if (s.ItemNumber.startsWith('*') && s.ItemType==5){
                    //ItemType = 5 and start with * is fpp item
                    String key ='FPP('+ s.ItemNumber.substring(1)+')';
                   
                    ShoppingCartResponseWrapper.PairValueObj pvo = new ShoppingCartResponseWrapper.PairValueObj(key,s.ExtendedPrice);
                    
                    scwRes.WarrantyItemAmount.add(pvo);
                }
                originalPriceMap.put(s.ItemNumber, s.OriginalPrice);
                sMap.put(s.ItemNumber, s.TotalTax);
                averageCostMap.put(s.ItemNumber, s.UnitCost);
                extendedPriceMap.put(s.ItemNumber, s.ExtendedPrice);
                itemTypeMap.put(s.ItemNumber, s.ItemType);
                //include Mannual input *SKU price into financial price
                Boolean isSKUorStarSKU = (s.ItemType==0 || s.ItemType==1);
                Boolean isPackageSub = !s.ItemNumber.startsWith('*') && s.ItemType==2;
                if(isSKUorStarSKU && !isPackageSub){
                    //To get select finacial price based total amount, the total of all product item's off price
                    //ItemType is 2, is the package/kit product sub, package master has been a total of sub items, not caculate price again
                    scwRes.TotalProductLastAmount = scwRes.TotalProductLastAmount + s.ExtendedPrice;
                }
            }
            //Set default 7% tax amount(13.93) of 199 delivery fee -For R1, To refactor in R2
            //scwRes.TotalTaxAmount = scwRes.TotalTaxAmount + 13.93;
            //Set default 199 delivery fee -For R1, To refactor in R2
            //scwRes.SalesGrandTotal =scwRes.SalesGrandTotal +scwRes.TotalTaxAmount + 199;
            
            //updating cartTotal in opportunity theyagu-DEF-0342
            if(!lineItems.isEmpty()){
                Opportunity opp=[Select Id,Name,StageName,Cart_Grand_Total__c 
                                 from Opportunity where id=:lineItems[0].Opportunity__c];
                if(opp != null){
                    opp.Cart_Grand_Total__c=scwRes.SalesGrandTotal;
                    update opp;
                }
            }
            for(Shopping_cart_line_item__c ln: lineItems){
                ln.List_Price__c = originalPriceMap.get(ln.Product_Sku__c);
                ln.Estimated_Tax__c = sMap.get(ln.Product_Sku__c);
                ln.Average_Cost__c = averageCostMap.get(ln.Product_Sku__c);
                ln.Extended_Price__c = extendedPriceMap.get(ln.Product_Sku__c);
                ln.ItemType__c = itemTypeMap.get(ln.Product_Sku__c);
                
            }
            
            update lineItems;          
        }
        return  scwRes;
    }   
    
    /**
* @description: get tax information for shopping cart                                                      
* @param: accountId - customer Id
* @return: ShoppingCartResponseWrapper
**/
    @AuraEnabled
    public static ShoppingCartResponseWrapper getCheckoutSummaryInfo(String accountId, String shipAddr) {  
        ShoppingCartResponseWrapper scwRes = new   ShoppingCartResponseWrapper();
        List<Shopping_cart_line_item__c> lineItems = getShoppingCartLineItems(accountId);
        if(lineItems.size()>0){
            
            ShoppingCartItemDetailsAPIHelper taxAPIHelper = new ShoppingCartItemDetailsAPIHelper();
            String sourceURL = taxAPIHelper.getAPIEndpoint();
            System.debug('sourceURL:'+sourceURL);
             ShoppingCartDeliveryWrapper shipToAddress= new ShoppingCartDeliveryWrapper();
            if(shipAddr!=null && shipAddr!=''){
                shipToAddress= CreateSalesOrderHelper.getAddress( accountId, shipAddr, null, null, null, null);
                
            }
            System.debug('In ShoppingCartDetailCmpCtrl getCheckoutSummaryInfo shipToAddress:'+shipToAddress);
             String rawPost;
            if(shipToAddress!=null && shipToAddress.Address!=null
               && !String.isEmpty(shipToAddress.Address.PostalCode) 
               && !String.isEmpty(shipToAddress.Address.StateOrProvince)){
                    rawPost = taxAPIHelper.prepareCheckOutItemsRawPost(lineItems,accountId,shipToAddress);
        
            }else{
                rawPost = taxAPIHelper.prepareCartItemRawPost(lineItems,accountId);
           
            }
           
            String resJSON = taxAPIHelper.connectAPIPostJSON(sourceURL, rawPost);
            scwRes =  taxAPIHelper.parseJSONToShoppingCartWrapperList(resJSON);
            if(scwRes==null){
                //REQ-489 item 5 and item 9 
                if(  Pattern.matches('\"PostalCode [0-9]* is not valid .\"', resJSON)){
                    throw new AuraHandledException('Please enter a valid zip code.');   
                }else if( resJSON.contains('Input Cart Details invalid.')&& ( resJSON.contains('PostalCode') || resJSON.contains('City') || resJSON.contains('State'))){
                    throw new AuraHandledException('Please input a valid address.');   
                
                }else{
                    throw new AuraHandledException('Error in retrieving tax information.'+ resJSON +' Please correct data or contact a system administrator.');
                }
            }
            scwRes.TotalProductLastAmount = 0;
            scwRes.WarrantyItemAmount = new ShoppingCartResponseWrapper.PairValueObj[]{};
            for(SalesOrderLineWrapper s: scwRes.SalesOrderLineList){
                
                if(!s.ItemNumber.startsWith('*') && s.ItemType!=2){
                    //To get select finacial price based total amount, the total of all product item's off price
                    //ItemType is 2, is the package/kit product sub, package master has been a total of sub items, not caculate price again
                    scwRes.TotalProductLastAmount = scwRes.TotalProductLastAmount + s.ExtendedPrice;
                }

                if (s.ItemNumber.startsWith('*') && s.ItemType==5){
                    //ItemType = 5 and start with * is fpp item
                    String key ='FPP('+ s.ItemNumber.substring(1)+')';
                   
                    ShoppingCartResponseWrapper.PairValueObj pvo = new ShoppingCartResponseWrapper.PairValueObj(key,s.ExtendedPrice);
                    
                    scwRes.WarrantyItemAmount.add(pvo);
                }
            }       
        }
        return  scwRes;
    }   
    
    @AuraEnabled  
    public static Decimal getRSAMarketDiscountThreshholds(){
        //REQ-438, get discount threshold from Rest API
        try{
            DiscountThreasholdAPIHelper apiHelper = new DiscountThreasholdAPIHelper();
            String sourceURL=apiHelper.getAPIEndpoint();
            String resJSON = apiHelper.connectAPIGetJSON(sourceURL);
            Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(resJSON);
            Decimal discountThreshold = Decimal.valueOf( (String)result.get('Value'));
            return discountThreshold;
        }catch(Exception ex){
            return 0;
        }
    }
    
    @AuraEnabled  
    public static String saveCartAddressInfo(Opportunity opp){
        system.debug('opp-->'+opp);
        try{             
            update opp;
        }catch(DMLException ex){
            System.debug(LoggingLevel.ERROR, 'DML Exception:' + ex.getMessage());
            new ErrorLogController().createLog(
                new ErrorLogController.Log(
                    'ShoppingCartDetailCmpCtrl', 'saveCartAddressInfo',
                    'DML Exception: ' + ex.getMessage() +';'+
                    ' Stack Trace: ' + ex.getStackTraceString()
                )
            );   
            return 'Error';
        }
        
        return 'Success';
    }
    @AuraEnabled
    public static List<WarrantyItemWrapper> getFPPTypes() {
        StoreInfoWrapper si = getStoreInfoInShoppingCartDetail();
        ShoppingCartItemDetailsAPIHelper itemDetailAPIHelper = new ShoppingCartItemDetailsAPIHelper();
        String sourceURL=itemDetailAPIHelper.getBaseUrlAPIEndpoint()+'/homestores/'+si.fulfillerId+'/warranty-types?profitcenter='+si.profitCtr;
        String resJSON = itemDetailAPIHelper.connectToAPIGetJSON(sourceURL,new Map<String, String> {'apiKey'=>itemDetailAPIHelper.getAPIKey()});
              
        JSONParser parser = JSON.createParser(resJSON);
        FppTypesWrapper fppTypes=(FppTypesWrapper)parser.readValueAs(FppTypesWrapper.class);
        List<String> fppTypeOpts=new List<String>();
        return fppTypes.items;
    }
    
    public static StoreInfoWrapper getStoreInfoInShoppingCartDetail(){
          StoreInfoWrapper si;
        if(Test.isRunningTest()){
            si = new StoreInfoWrapper('8888300-164-23-SWF');   
            si.fulfillerId = '8888300-164';
        }else{            
            si = StoreInfo.getStoreInfo();
        }
        return si;
    }
    // DEF-0780 - Manually add product performance fix - updated to return line item ids in a map
    @AuraEnabled
    public static Map<String, Object> updateLineItemWithSKU(Id recordId, Shopping_cart_line_item__c lineItem){
        List<Shopping_cart_line_item__c> lstLineItems = new  List<Shopping_cart_line_item__c>();

        //REQ-438,  add Product_Title__c for Discount Modal product name column show for items list
        for (Opportunity master : [Select (Select Id, WarrantySku__c,  Product_Title__c, Product_SKU__c, Discount__c,Discount_Price__c,DiscountType__c,
                                           Flat_Discounted_Amount__c,Flat_Discounted_Amount_On_Total__c,Last_Price__c,List_Price__c, Average_Cost__c, Quantity__c,Extended_Price__c,ItemType__c,
                                           Opportunity__c,Delivery_Mode__c,Discount_Reason_Code__c,Discount_Status__c, Estimated_Tax__c
                                           from  Shopping_cart_line_items__r ) 
                                   From Opportunity where 
                                   AccountId=:recordId 
                                   and StageName != 'Closed Won' 
								   and StageName != 'Closed Lost'
                                   and StageName != 'Sale Suspended'
                                   and createdDate = LAST_N_DAYS:30]) {
                                       
                                       for (Shopping_cart_line_item__c detail : master.Shopping_cart_line_items__r) {
                                           if(detail.Product_SKU__c.equals(lineItem.Product_SKU__c)){
                                               lstLineItems.add(detail);
                                           }
                                       }
                                   }
         if(lstLineItems !=null && lstLineItems.size() >0){
            Shopping_cart_line_item__c sLineItem = lstLineItems.get(0);
            sLineItem.Quantity__c = sLineItem.Quantity__c + lineItem.Quantity__c;
            update lstLineItems;
            return populateResult('Success', 'Updated', lstLineItems);
        }else{
            //Use central addToCart function in MyCustomerController -JoJoToTheyagu
            Map<String, String> objMap = new Map<String, String> ();
            objMap.put('sku', lineItem.Product_SKU__c.toUpperCase());
            objMap.put('productTitle', lineItem.Product_Title__c);
            
            //DEF-0648 getting Price from Api  
            try{
                ProductPriceWrapper prodPrice= new ProductPriceWrapper();
                //exclude *SKU when call Price API
                if(!lineItem.Product_SKU__c.startsWith('*')){                    
                    prodPrice=ProductPriceCmpCtrl.getProductPrice(lineItem.Product_SKU__c.toUpperCase());   
                }
                //Use central addToCart function in MyCustomerController
                lstLineItems = MyCustomerController.addToCart(recordId,JSON.serialize(objMap),JSON.serialize(prodPrice),Integer.valueOf(lineItem.Quantity__c));
                
            }catch(AuraHandledException auex){
                //ProductPriceCmpCtrl.getProductPrice throw exception, product is not found in Price API.
                //Because product list will exclude this kind of prod, so exclude this kind of prod from mannual add product process also.
                return populateResult('Error', 'ItemDetailsAPIError', lstLineItems);
            }catch(MyCustomerController.ItemDetailsAPIException ex){
                //MyCustomerController.addToCart throw exception, product is not found in item-details API
                return populateResult('Error', 'ItemDetailsAPIError', lstLineItems);
            }
            return populateResult('Success', 'Inserted', lstLineItems);
        }
        return null;
    }

    private static Map<String, Object> populateResult(String status, String action, List<Shopping_cart_line_item__c> lineItems) {
        Set<Id> lineItemIds = new Set<Id>();
        for(Shopping_cart_line_item__c lineItem : lineItems) {
            lineItemIds.add(lineItem.Id);
        }
        return new Map<String, Object> {'status' => status, 'msg' => action, 'lineItemIds' => lineItemIds};
    }
    
   @AuraEnabled
    public static String canViewCheckout(String accountId) { 
        String canViewCheckoutPOS = '';
        Boolean canViewCheckOnPendingItems = canViewCheckOnPendingItems(accountId);
        //REQ-489 item 7
        Boolean canViewCheckOnCartIsNotEmpty = canViewCheckOnCartIsNotEmpty(accountId);
        Boolean canViewCheckOnProfile = canViewCheckOnProfile();
        
        if(canViewCheckOnPendingItems & canViewCheckOnCartIsNotEmpty & canViewCheckOnProfile){
            canViewCheckoutPOS += 'viewCheckout';
        }
        if(canViewCheckOnPendingItems & canViewCheckOnCartIsNotEmpty){
            // UAT Testing Issue - change it to suspend POS so it wont conflict with viewcheckout
            canViewCheckoutPOS += 'viewSuspendPOS';
        }
       return canViewCheckoutPOS;
    }    
    
    @AuraEnabled
    public static Boolean canViewCheckOnPendingItems(String accountId) {
        //Check whether there's pending approval items , if yes, hide checkout button
        for (Opportunity master : [Select (Select Id, WarrantySku__c,Product_SKU__c, Discount__c,Discount_Price__c,DiscountType__c,
                                           Flat_Discounted_Amount__c,Flat_Discounted_Amount_On_Total__c,Last_Price__c,List_Price__c, Average_Cost__c, Quantity__c,Extended_Price__c,ItemType__c,
                                           Opportunity__c,Delivery_Mode__c,Discount_Reason_Code__c,Discount_Status__c, Estimated_Tax__c,DeliveryDate__c
                                           from  Shopping_cart_line_items__r ) From Opportunity where AccountId=:accountId and StageName != 'Closed Won' 
                                   and StageName != 'Closed Lost'
                                   and StageName != 'Sale Suspended' 
                                   and createdDate = LAST_N_DAYS:30]){   
                                       for (Shopping_cart_line_item__c detail : master.Shopping_cart_line_items__r) {
                                           if(detail.Discount_Status__c.equalsIgnoreCase(ShoppingCartLineItemCmpCtrl.DISCOUNT_PENDING_APPROVAL) ){
                                               return false;
                                           }
                                       }
                                   }
        return true;
    }    

    //REQ-489 item 7
     @AuraEnabled
    public static Boolean canViewCheckOnCartIsNotEmpty(String accountId) {
        //Check whether there's pending approval items , if yes, hide checkout button
        for (Opportunity master : [Select (Select Id, WarrantySku__c,Product_SKU__c, Discount__c,Discount_Price__c,DiscountType__c,
                                           Flat_Discounted_Amount__c,Flat_Discounted_Amount_On_Total__c,Last_Price__c,List_Price__c, Average_Cost__c, Quantity__c,Extended_Price__c,ItemType__c,
                                           Opportunity__c,Delivery_Mode__c,Discount_Reason_Code__c,Discount_Status__c, Estimated_Tax__c,DeliveryDate__c
                                           from  Shopping_cart_line_items__r ) From Opportunity where AccountId=:accountId and StageName != 'Closed Won'
								   and StageName != 'Closed Lost'
                                   and StageName != 'Sale Suspended' 
                                   and createdDate = LAST_N_DAYS:30]){   
                                       if( master.Shopping_cart_line_items__r.isEmpty()){
                                           return false;
                                       }
                                       
                                   }
        return true;
    }   

    @AuraEnabled
    public static Boolean canViewCheckOnProfile() {        
        //Get all delivery and techinican profile names
        Profile_Details__c pd = Profile_Details__c.getInstance(CHECKOUT_PROFILENAMESKEY);
        // if no value is set, we gotta return false
        if (pd == null)
            return false;
        String checkoutProfiles = pd.Profile_Names__c;
        // if no value is set, we gotta return false
        if (checkoutProfiles == null)
            return false;
        
        // if set to allow all, return true;
        if (checkoutProfiles.toLowerCase() == ALL_PROFILES) 
            return true;
        
        // otherwise - check if user's profile matches an allowed profile
        Id currentUserProfileId = UserInfo.getProfileId();
        Id currentUserId = UserInfo.getUserId();
        User u = [select Division from user where id=:currentUserId];
        Profile p = [select Name from profile where id = :currentUserProfileId];
 
        //Check if current user's profile matches any of delivery/technician profiles        
        for(String cName : checkoutProfiles.split(',')){
            if(cName == p.Name){
                return true;
            }
            if (cName == u.Division) {
                return true;
            }
        }
        return false;
    } 

    @AuraEnabled
    public static Boolean checkSKUPresent(String enteredSKU){
        Boolean skuNotPresent = true;
        List<Shopping_cart_line_item__c> lstShoppingCartLineItems = [SELECT Id, Product_SKU__c FROM Shopping_cart_line_item__c WHERE Product_SKU__c =: enteredSKU];
        if(lstShoppingCartLineItems != null && lstShoppingCartLineItems.size() > 0){
            skuNotPresent = false;
        }
        return skuNotPresent;
    }      
    
    @AuraEnabled
    public static List<lineItemWrapper> getShoppingCartLineItemsWrapper(String accountId, String[] lineItemIds) {
        // added to avoid any technical error messages in the front-end
        try {
            //Select (Select Product_SKU__c, Discount__c, Opportunity__c from  Shopping_cart_line_items__r) 
            //From Opportunity where Contact__c='0032F000008OvR2' and createdDate = LAST_N_DAYS:30
            List<Shopping_cart_line_item__c> callLineItem=new List<Shopping_cart_line_item__c>();
            List<lineItemWrapper> shoppingDetail = new  List<lineItemWrapper>();
            Boolean callATC =false;
            String postalCode;
            Decimal marginCriteria = ShoppingCartDetailCmpCtrl.getRSAMarketDiscountThreshholds();
            System.debug('marginCriteria-->'+marginCriteria);
            StoreInfoWrapper si = ShoppingCartDetailCmpCtrl.getStoreInfoInShoppingCartDetail();
            //Get API key and End Point URL from Custom Settings     
            Integration_Settings__c pmtTypesConf= Integration_Settings__c.getValues(ShoppingCartLineItemCmpCtrl.ATP_API_SETTING_NAME);
            
            if(pmtTypesConf==null){
                throw new ShoppingCartLineItemCmpCtrl.ATPApiException('ATP config missing: Custom Setting > Integration Setting' 
                                                                      + ShoppingCartLineItemCmpCtrl.ATP_API_SETTING_NAME);
            }      
            String url='/retail?as='+si.fulfillerId+'&sqt=';
			//ATC_CALL_DAYS API
            Delivery_Window__c del=callDeliveryWindowApi(si);
                                
            String soql = 'SELECT Id, Cart_ZipCode__c, '
                        +   ' ( SELECT Id, WarrantySku__c,  Product_Title__c,Product_SKU__c, Discount__c,Discount_Price__c,DiscountType__c, ' 
                        +   ' Flat_Discounted_Amount__c, Flat_Discounted_Amount_On_Total__c, Discount_Approver__c, Discount_Approver__r.Name , '
                        +   ' Last_Price__c, List_Price__c, Average_Cost__c, Quantity__c, Extended_Price__c, ItemType__c, '
                        +   ' Opportunity__c, Opportunity__r.Cart_State__c, Opportunity__r.Cart_ZipCode__c, '
                        +   ' Delivery_Mode__c,Discount_Reason_Code__c,Discount_Status__c, Estimated_Tax__c,DeliveryDate__c,As_Is__c,isCallItem__c , '
                        // DEF-0780 - retrieve the cached info
                        +   ' eComm_Small_Image__c, Item_Color__c '
                        +   ' FROM  Shopping_cart_line_items__r '
                        +   ( (lineItemIds != null && lineItemIds.size() > 0) ? ' WHERE Id IN :lineItemIds ' : '')
                        +   ' ) '
                        +   ' FROM Opportunity where AccountId=:accountId '
                        +   ' AND StageName != \'Closed Won\'  '
                        +   ' AND StageName != \'Closed Lost\' '
                        +   ' AND StageName != \'Sale Suspended\' '
                        +   ' AND createdDate = LAST_N_DAYS:30 ';

            for (Opportunity master : Database.query(soql) ) {  
                postalCode=master.Cart_ZipCode__c;
                for (Shopping_cart_line_item__c detail : master.Shopping_cart_line_items__r) {
                    lineItemWrapper line =new lineItemWrapper();
                    line.item=detail;
                   
                    //exclude *SKU when call product feed API --JoToTheyagu
                    if(!detail.Product_SKU__c.startsWith('*')){

                        // DEF-0780 - no need to make product detail call as we are caching the info already
                        //ProductWrapper prod=ProductDetailCmpCtrl.getProductDetail(detail.Product_SKU__c);
                        //3X0000004153   is 3x  SKU, it's special,which has info from Unbxd, but Not Found in product feed detail API.    --JoToTheyagu                                      
                        //if(prod!=null){
                            if(detail.Delivery_Mode__c =='HD' || detail.Delivery_Mode__c =='DS')
                            {
                               callATC=true;
                               // DEF-0780 - retrieve from cached info
                               //url+=detail.Product_SKU__c+'|'+detail.Quantity__c+'|'+prod.isDirectShipOnly+',';
                              String Pipedelimiter = EncodingUtil.urlEncode('|','UTF-8');
                               url+=detail.Product_SKU__c+ Pipedelimiter +detail.Quantity__c+ Pipedelimiter +(detail.Delivery_Mode__c == 'DS' ? 'true' : 'false') +',';
                            }
                           
                            // DEF-0780 fix - ATC call has been moved to the line item
                           
                        //}
                        //REQ-438, Add By JoJo, check lineItem is locked or not
                        line.isLocked =Approval.isLocked(detail.Id);
                        //DEF-0885,  Add By JoJo, check lineItem has discount or not
                        line.isDiscountSelected = detail.Discount__c>0? true:false;
                        //REQ-438, Add By JoJo, get lineItem average cost and caculate averageDiscountCriteria
                        Decimal averageCost = detail.Average_Cost__c;

                        Decimal originalPrice = detail.List_Price__c;
                        Decimal averageDiscountCriteria;
                        //commented the code for atp error
                        if(originalPrice==0 || marginCriteria==100|| averageCost==0){
                            line.averageDiscountCriteria=0;
                        }else{
                            line.averageDiscountCriteria = (1-(averageCost*100)/(originalPrice*(100-marginCriteria)))*100; 
                        }
                    }
                    shoppingDetail.add(line);
               }
            }
            if(callATC){
                url=url.removeEnd(',');
                url+='&pc='+postalCode;
                String sourceURL = pmtTypesConf.End_Point_URL__c + url;
                
                shoppingDetail=ShoppingCartLineItemCmpCtrl.getATPResponse(sourceURL,shoppingDetail,pmtTypesConf);
            }
            //updating the custom setthings Delivery_Window__c here after all the api calls.
            update del;
            return shoppingDetail;

        } catch(Exception e) {    // added to avoid any technical error messages in the front-end
            throw new AuraHandledException('Error in retrieving Cart Line Items');
        }
    }
    
    public static Delivery_Window__c  callDeliveryWindowApi(StoreInfoWrapper si)
    {
        Delivery_Window__c del=[SELECT Name, SetupOwnerId, CreatedDate,LastUpdatedDate__c,LastModifiedDate,window__c,Number_of_hours__c 
                                                              FROM Delivery_Window__c 
                                                              WHERE IsDeleted = False and Name='Delivery Window'];
                                if(del != null){
                                    datetime updateDate;
                                    if(del.LastUpdatedDate__c == null && del.window__c == null)
                                    {
                                        del.LastUpdatedDate__c=system.now();
                                    }
                                    updateDate = del.LastUpdatedDate__c;
                                    updateDate = updateDate.addHours(Integer.valueOf(del.Number_of_hours__c));
                                    if(updateDate <= DateTime.now() || del.window__c == null)
                                    {
                                        system.debug('time to update the custom setthings Delivery_Window__c');
                                        //time to update the custom setthings Delivery_Window__c
                                        //Get API key and End Point URL from Custom Settings     
                                        Integration_Settings__c act_pmtTypesConf= Integration_Settings__c.getValues(ATC_CALL_DAYS_API_SETTING_NAME);
                                        
                                        if(act_pmtTypesConf==null){
                                            throw new ATC_CALL_DAYS_APIException('ATP config missing: Custom Setting > Integration Setting' 
                                                                                 + ATC_CALL_DAYS_API_SETTING_NAME+', Please contact a system administrator.');
                                        }      
                                        // Get endpoint path configuration from custom settings
                                        ConciergeProductAPISetting__c prodApiSetting = ConciergeProductAPISetting__c.getValues(PATH_SETTING_NAME);
                                        String path = prodApiSetting.ATC_CALL_DAYS_API__c;
                                        
                                        List<String> strList = new List<String>();
                                        strList.add(si.fulfillerId);
                                        strList.add(si.profitCtr);
                                        
                                        String endPointURL = act_pmtTypesConf.End_Point_URL__c + String.format(path,strList);
                                        //String endPointURL='https://ashley-preprod-dev.apigee.net/homestores/8888300-164/inventory/sales-order-settings/ATC_CALL_DAYS?profitCenter=23';                   
                                        
                                        ProductAPIBaseHelper apiCall = new ProductAPIBaseHelper();
                                        String resJSON = apiCall.connectToAPIGetJSON(endPointURL,new Map<String, String> {'apiKey'=> act_pmtTypesConf.API_Key__c});
                                        Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(resJSON); 
                                        del.window__c=Integer.valueOf(result.get('Value'));
                                        del.LastUpdatedDate__c=DateTime.now();
                                        
                                    }
                                    
                                }
        return del;
    }
    
    // REQ-433, Add Suspend Functionality on Cart Page
    // Method to get guest details like email, phone and address
    @AuraEnabled
    public static Account getGuestDetails(String accountId){
        Account currentGuest = new Account();
        Account[] accs = [Select Id, Phone, PersonEmail,(Select Id,Name,Address_Line_1__c,Address_Line_2__c,City__c,State__c,Zip_Code__c From Addresses__r Order By LastModifiedDate Desc Limit 1) From Account Where Id = :accountId];
        if(accs.size()>0)
            currentGuest = accs[0];
        return currentGuest;
    }
    
    // REQ-433 - Add Suspend Functionality on Cart Page
    @AuraEnabled 
    public static Boolean suspendToPosCart(String formWrapStr, String personAccId,String billAddr, String shipAddr){
        CheckoutFormWrapper formWrap = (CheckoutFormWrapper) JSON.deserialize(formWrapStr, CheckoutFormWrapper.class);  
        try{
            CreateSalesOrderHelper.createOrder(personAccId,true,billAddr,shipAddr,formWrap);
            //After Callout, maintain PaymentType, do the DML
            PaymentTypeHelper.maintainPaymentTypeMapping();
            Opportunity oppt = CreateSalesOrderHelper.getOpportunity(personAccId);
 		    
            //update opportunity
            oppt.StageName = 'Sale Suspended';
            oppt.ShipTo_Address__c = shipAddr;
            oppt.Bill_To_Address__c = billAddr;
            update oppt;
        }catch(AuraHandledException ae){
            throw ae;
        }catch(Exception e){
            ErrorLogController.Log log = new ErrorLogController.Log('CheckoutController','suspendSales',e.getMessage());
            new ErrorLogController().createLog(log);
            throw new AuraHandledException('Failed to Suspend Sales.');
        }
        return true;
    }
    
    // REQ-433 - Add Suspend Functionality on Cart Page
    @AuraEnabled
    public static String createNewAddress(String accId, Address__c addr) {
        List<Address__c> addrList = [Select Id,AccountId__c,Address_Line_1__c,Address_Line_2__c,City__c,State__c,Zip_Code__c 
             					     From Address__c Where AccountId__c = :accId And 
                                     					   Address_Line_1__c = :addr.Address_Line_1__c And 
                                     					   Address_Line_2__c = :addr.Address_Line_2__c And
             											   City__c = :addr.City__c And 
                                                           State__c = :addr.State__c And 
                                                           Zip_Code__c = :addr.Zip_Code__c];
        
        if(!addrList.isEmpty()) {
            return addrList[0].Id;
        }
        else {
            Address__c newAddr = addr;
            newAddr.Id = null;
            if(newAddr.AccountId__c == null) {
            	newAddr.AccountId__c = accId;    
            }
            insert newAddr;
            return newAddr.Id;
        }
    }   
    //DEF-0777 fix
    private static String parseErrorMsg(String responseBody) {
        String errorMsg = 'Unknown Exception';
        if(responseBody != null && responseBody != '') {
            errorMsg = responseBody;
            if(errorMsg.contains('"')) {
                errorMsg = errorMsg.replaceAll('"', '');
            }
        }
        return errorMsg;
    }
}