public class ConciergePaymentItemDetailsHelper {
    public static ItemDetailsWrapper getItemDetails(Id personAccountId) {
        
        return getItemDetails(personAccountId, false,null,null); 
    }
    public static ItemDetailsWrapper getItemDetails(Id personAccountId, Boolean needDML) {
        
        return getItemDetails(personAccountId, needDML,null,null); 
    }
    // get Item details and updates Opportunity.SalesGuid__c if blank
    public static ItemDetailsWrapper getItemDetails(Id personAccountId, Boolean needDML,
                                                    ShoppingCartDeliveryWrapper billToAddress,
                                                    ShoppingCartDeliveryWrapper shipToAddress) {
                                                        
        Opportunity oppt = CreateSalesOrderHelper.getOpportunity(personAccountId);
        if((billToAddress==null && oppt.Bill_To_Address__c == null) ||(shipToAddress==null&& oppt.ShipTo_Address__c == null)) {
            throw new AuraHandledException('please set shipTo and billTo Address');
        }
        if(billToAddress==null)
        	 billToAddress= CreateSalesOrderHelper.getAddress( personAccountId, oppt.Bill_To_Address__c, '', '', '', '');
         if(shipToAddress==null)
              shipToAddress= CreateSalesOrderHelper.getAddress( personAccountId, oppt.ShipTo_Address__c, '', '', '', '');
        if(oppt == null) {
            throw new AuraHandledException('Could not retrieve Opportunity details');
        }
        Map<String, Object> objectMap = new Map<String, Object>();
        Boolean  updateOpp = false;
        if(oppt.Cart_Item_Details__c != null && oppt.Cart_Item_Details__c != ''){
            try {
                objectMap = (Map<String, Object> ) JSON.deserializeUntyped(oppt.Cart_Item_Details__c);
            }catch(Exception e) {
                
            }
        }
             system.debug('objectMap-->'+objectMap);
        if(objectMap == null || (objectMap != null && objectMap.isEmpty())) {
            
            objectMap = getItemDetailsAPI(personAccountId, oppt, shipToAddress);
            
            oppt.Cart_Item_Details__c = (String) JSON.serialize(objectMap);
            updateOpp = true;
        }
        
        if(objectMap == null || (objectMap != null && objectMap.isEmpty())) {
            throw new AuraHandledException('Could not retrieve Item API details');
        }
        
        if(oppt.SalesGuid__c != null && oppt.SalesGuid__c != '') {
            objectMap.put('CartGuid', oppt.SalesGuid__c);
        }
        else {
            // update opportunity if SalesGuid__c is blank
            oppt.SalesGuid__c = (String)objectMap.get('CartGuid');
            updateOpp = true;
            
        }
        if(updateOpp && needDML){
            try {
                
                update oppt;
            }
            catch(Exception e) {
                throw e;
            }
        }
        return new ItemDetailsWrapper(oppt, objectMap,billToAddress, shipToAddress);
    }
    
       // Retrieve Item Details
    public static Map<String, Object> getItemDetailsAPI(Id personAccountId, Opportunity oppt, ShoppingCartDeliveryWrapper shipToAddress) {
        List<Shopping_cart_line_item__c> lineItems = CreateSalesOrderHelper.getShoppingCartLineItems(oppt.Id);
         if(lineItems.size() >0){
            ShoppingCartItemDetailsAPIHelper ItemAPI = new ShoppingCartItemDetailsAPIHelper();
            String sourceURL = ItemAPI.getAPIEndpoint();
            String rawData = ItemAPI.prepareCheckOutItemsRawPost(lineItems, personAccountId,shipToAddress);
            String resJSON = ItemAPI.connectAPIPostJSON(sourceURL, rawData);
            
            Map<String, Object>  objMap = new Map<String, Object>();
            try{
                objMap =(Map<String, Object> ) JSON.deserializeUntyped(resJSON);
                return objMap;
            }
            catch(Exception ex){
                throw new AuraHandledException('Get Error when calling Tax API, please check the response for reason:'
                                               +resJSON);
            }
        }
        else {
            throw new AuraHandledException('No line items in the cart');
        }
    }
    
      // to consolidate output from ItemdetailsWrapper
    public class ItemDetailsWrapper {
        @auraEnabled public Opportunity oppt {get;set;}
        @auraEnabled public Map<String, Object> objectMap {get;set;}
        @auraEnabled public ShoppingCartDeliveryWrapper billToAddress {get;set;}
        @auraEnabled public ShoppingCartDeliveryWrapper shipToAddress {get;set;}
        
        public ItemDetailsWrapper(Opportunity opp, Map<String, Object> oMap, 
                                  ShoppingCartDeliveryWrapper billTo, ShoppingCartDeliveryWrapper shipTo) {
                                      oppt = opp;
                                      objectMap = oMap;
                                      billToAddress =billTo;
                                      shipToAddress =shipTo;
                                  }
    }
}