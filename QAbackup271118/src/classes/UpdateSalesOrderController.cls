/**
* This is a controller class for UpdateSalesOrder Lightning component that provides ability to edit Sales orders and associated 
* order line items. Delivery Date updates involve API call outs to get available Delivery Days from ATC(Available to Customer) API.
* Once changes are made to Orders/Order line items that are represented as external objects, the changes are sent to Source systems through API call outs.
*/
public with sharing class UpdateSalesOrderController
{
    public static final string ASHCOMM_ORDER_SOURCE_INDICATOR = '636';
    public static final string DELIVERY_MODE_DIRECT_SHIP = 'Direct Ship';
    public static final string DELIVERED_ORDER_INDICATOR = 'Invoiced';
    public static final string CANCELLED_ORDER_INDICATOR = 'Canceled';
    public static final string CAN_INV_ORDER_INDICATOR = 'Canceled/Invoiced';
    public static final string PARTIAL_SHIP_ORDER_INDICATOR = 'Open/Invoiced';
    
    /**
* Gets Sales Order and related Order LIne items.Sales Orders are represented as External Objects and the method will be used
* in a lightning component that will provide a user Interface for updating Order/Order Line item and send the Updates to source systems.
*
* @param  salesforceOrderId the salesforce Id of the Sales order
* @return a SalesOrderWrapper that contains order, order line item and some calculated order attributes 
*/
    @AuraEnabled
    public static SalesOrderWrapper getOrderData(Id salesforceOrderId) {
        //get delivery type code to delivery mode map
        Map<string,string> deliveryCodeTYpeToDeliveryModeMap = getDeliveryCodeTYpeToDeliveryModeMap();
        
        
        SalesOrder__x order = SalesOrderDAO.getOrderById(salesforceOrderId);
        List<SalesOrderItem__x> lineItems = SalesOrderDAO.getOrderLineItemsByOrderExternalId(order.ExternalId);
        
        SalesOrderWrapper orderWrapper = new SalesOrderWrapper();
        orderWrapper.isAshcommOrder = isAshcommOrder(order.phhStoreID__c);
        if(isEditable(order, orderWrapper.isAshcommOrder) == false){
            orderWrapper.isEditable = false;
        }
        else{
            //load reschedule reason options
            for(Reschedule_Reason_Map__mdt rrm: [Select Id, Increments_Strike_Counter__c, Reschedule_Reason__c, Reschedule_Reason_Code__c
                                                 from Reschedule_Reason_Map__mdt
                                                 order by Reschedule_Reason__c]){
                                                     orderWrapper.rescheduleReasonOptions.add(rrm);
                                                 }
            
            system.debug('order-----'+order);
            system.debug('lineItems-----'+lineItems);
            system.debug('Externalid is:'+order.ExternalId);
            orderWrapper.isEditable = true;
            orderWrapper.hot = order.phhHot__c;
            orderWrapper.WindowBegin = order.phhWindowBegin__c;
            orderWrapper.WindowEnd	= order.phhWindowEnd__c;
            orderWrapper.asap = order.phhASAP__c;
            orderWrapper.vip = order.VIPFlag__c;
            orderWrapper.lib = order.LIBFlag__c;
            orderWrapper.servicelevel = order.phhServiceLevel__c;
            orderWrapper.deliveryComments = order.phhOrder_Notes__c;
            orderWrapper.currentDeliverydate = Date.valueOf(order.phhDatePromised__c);
            orderWrapper.salesforceId = order.Id;
            orderWrapper.externalId = order.ExternalId;
            orderWrapper.profitCenter = order.phhProfitcenter__c;
            orderWrapper.orderNumber = order.phhSalesOrder__c;
            
            updateOrderWithOpenLineItemShipToAddress(orderWrapper, lineItems);
            if(order.phhDeliveryType__c != null){
                orderWrapper.deliveryMode = deliveryCodeTYpeToDeliveryModeMap.get(order.phhDeliveryType__c.toUpperCase());
            }
            
            //drive the account number/rdc id from fulfiller Id
            if(order.fulfillerID__c != null && order.fulfillerID__c.contains('-')){
                List<String> parts = order.fulfillerID__c.split('-');
                orderWrapper.accountNumber = parts[0];
                orderWrapper.rdcId = parts[1];
            }
            
            
            if(!lineItems.isEmpty()){
                orderWrapper.lineItems = new List<SalesOrderLineWrapper>();
                for(SalesOrderItem__x orderLineItem: lineItems){
                    SalesOrderLineWrapper lineItemWrapper = new SalesOrderLineWrapper();
                    lineItemWrapper.deliverydate = Date.valueOf(orderLineItem.phdDeliveryDueDate__c);
                    lineItemWrapper.productName = orderLineItem.phdItemDesc__c;
                    lineItemWrapper.quantity = String.valueof(orderLineItem.phdQuantity__c);
                    lineItemWrapper.salesforceId = orderLineItem.Id;
                    lineItemWrapper.sku = orderLineItem.phdItemSKU__c;
                    lineItemWrapper.externalId = orderLineItem.ExternalId;
                    orderWrapper.lineItems.add(lineItemWrapper);
                }
            }   
        }   
        return orderWrapper;
    }
    
    public class SalesOrderWrapper implements Attributable{
        @AuraEnabled
        public string  salesforceId {get;set;}
        
        @AuraEnabled
        public string externalId {get;set;}
        
        @AuraEnabled
        public string  orderNumber {get;set;}
        
        @AuraEnabled        
        public string  orderSource {get;set;}
        
        //Home Delivery / Direct Ship
        @AuraEnabled
        public string  deliveryMode {get;set;}
        
        @AuraEnabled
        public string  shipToStreet1 {get;set;}
        
        @AuraEnabled
        public string  shipToStreet2 {get;set;}
        
        @AuraEnabled
        public string  shipToCity {get;set;}
        
        @AuraEnabled
        public string  shipToState {get;set;}
        
        @AuraEnabled
        public string  shipToPostalcode {get;set;}
        
        @AuraEnabled
        public string  shipToCountry {get;set;}
        
        @AuraEnabled
        public string  deliveryComments {get;set;}
        
        @AuraEnabled
        public Boolean  hot {get;set;}
        
        @AuraEnabled
        public Boolean  isHotReset {get;set;}
        
        @AuraEnabled
        public String  WindowBegin {get;set;}
        
        @AuraEnabled
        public String  WindowEnd {get;set;}
        
        @AuraEnabled
        public Boolean  asap {get;set;}
 
        @AuraEnabled
        public Boolean  vip {get;set;}
        
        @AuraEnabled
        public Boolean  lib {get;set;}
        
        @AuraEnabled
        public String  servicelevel {get;set;}
        
        @AuraEnabled
        public Date  currentDeliverydate {get;set;}
        
        @AuraEnabled
        public List<SalesOrderLineWrapper>  lineItems {get;set;}
        
        @AuraEnabled
        public Boolean isAshcommOrder {get;set;}
        
        @AuraEnabled
        public string accountNumber {get;set;}
        
        @AuraEnabled
        public string rdcId {get;set;}
        
        @AuraEnabled
        public boolean isEditable {get;set;}
        
        @AuraEnabled
        public string rescheduleReasonCodeId {get;set;}
        
        @AuraEnabled
        public Decimal  profitCenter {get;set;}
        
        @AuraEnabled
        public List<Reschedule_Reason_Map__mdt> rescheduleReasonOptions {get;set;}
        
        public SalesOrderWrapper(){
            isAshcommOrder = false;
            rescheduleReasonOptions = new List<Reschedule_Reason_Map__mdt>(); 
        }
    }
    
    public class SalesOrderLineWrapper{
        @AuraEnabled
        public string  salesforceId {get;set;}
        
        @AuraEnabled
        public string externalId {get;set;}
        
        @AuraEnabled
        public Date  deliverydate {get;set;}
        
        @AuraEnabled
        public string  productName {get;set;}
        
        @AuraEnabled
        public string  sku {get;set;}
        
        @AuraEnabled
        public string  quantity {get;set;}
        
    }
    
    
    
    /**
* Identifies an order has having Ashcomm as a source or not. 636 in the store identifier is considered as an indicator for Ashcomm order.
* All other orders are considered to be sourced from "Homes".
*
* @param  storeId the store Id from which the order was sold from
* @return a boolean indicating if the order is an Ashcomm order or not
*/
    public static boolean isAshcommOrder(string storeId){
        boolean isAshcommOrder = false;
        if(storeId != null){
            string identifier;
            if(storeId.contains('-')){
                identifier = storeId.split('-')[1];
            }
            else{
                identifier = storeId;
            }
            if(identifier == ASHCOMM_ORDER_SOURCE_INDICATOR){
                isAshcommOrder = true;
            }
        }
        return isAshcommOrder;
    }   
    
    /**
* Prepares a Delivery Type Code --> Delivery Mode map that will be used in determining edit behaviour on orders/order line items along with the 
* order source. The map is built from information stored in a custom metadata type.
*
* @return a boolean indicating if the order is an Ashcomm order or not
*/
    public static Map<string,string> getDeliveryCodeTYpeToDeliveryModeMap(){
        Map<string,string> deliveryCodeMap = new Map<string,string>();
        for(Delivery_Type_Code_to_Delivery_Mode_Map__mdt m: [Select Delivery_Mode__c, Delivery_Type_Code__c from Delivery_Type_Code_to_Delivery_Mode_Map__mdt]){
            deliveryCodeMap.put(m.Delivery_Type_Code__c.toUpperCase(), m.Delivery_Mode__c.toUpperCase());
        }
        return deliveryCodeMap;
    }
    
    /**
* method evaluates if an order is editable in salesforce. Orders with SaleType = D (delivered) or with blank Fulfiller Ids are not editable. 
* Ashcomm orders are also not editable at this moment in salesforce. Future phases will implement edit functionality for AshComm orders.
*
* @param order the salesforce order object reprsenting the current order 
* @param isAshcommOrder a boolean indicating if an order is an Ashcomm sourced order
* @return a boolean indicating if the order is editable or not
*/
    public static boolean isEditable(SalesOrder__x order, boolean isASshcommOrder){
        Boolean isEditable = true;
        if(order.fulfillerID__c == null || DELIVERED_ORDER_INDICATOR.equalsIgnoreCase(order.phhSaleType__c) ||
           CANCELLED_ORDER_INDICATOR.equalsIgnoreCase(order.phhSaleType__c) || 
           CAN_INV_ORDER_INDICATOR.equalsIgnoreCase(order.phhSaleType__c) ||
           PARTIAL_SHIP_ORDER_INDICATOR.equalsIgnoreCase(order.phhSaleType__c) ||isASshcommOrder){
               isEditable = false;
           }
        return isEditable;
    }
    
    /**
* Poupulates the order Wrapper with an address that can be used as a starting point to edit order address. Only Open orders can be edited and 
* The address from the first line Item of an open order can be considered as a starting point.
*
* @param order an order wrapper object reprsenting the current order 
* @param lineItems list of line items associated to the order
*/
    public static void updateOrderWithOpenLineItemShipToAddress(SalesOrderWrapper order, List<SalesOrderItem__x> lineItems){
        if(lineItems != null){
            order.shipToStreet1 = lineItems[0].phdShipAddress1__c;
            order.shipToStreet2 = lineItems[0].phdShipAddress2__c;
            order.shipToCity = lineItems[0].phdShipCity__c;
            order.shipToState = lineItems[0].phdShipState__c;
            order.shipToPostalcode = lineItems[0].phdShipZip__c;
        }
    }
    
    @AuraEnabled
    public static UpdateSalesOrderResponse updateSalesOrder(string salesOrderInfo) {
        
        UpdateSalesOrderResponse response = new UpdateSalesOrderResponse();
        
        List<String> successMessages = new List<String>();
        List<String> errorMessages = new List<String>();
        boolean orderIsUpdated = false;
        
        SalesOrderWrapper orderFromUpdate = (SalesOrderWrapper)JSON.deserialize(salesOrderInfo, UpdateSalesOrderController.SalesOrderWrapper.Class);
        
        
        SalesOrder__x currentOrderValues = SalesOrderDAO.getOrderById(orderFromUpdate.salesforceId);
        List<SalesOrderItem__x> lineItems = SalesOrderDAO.getOrderLineItemsByOrderExternalId(currentOrderValues.ExternalId);
        
        //update delivery date
        if(String.isNotBlank(orderFromUpdate.rescheduleReasonCodeId) && orderFromUpdate.currentDeliverydate != null){
            orderIsUpdated = true;
            
            //get reason code mapping record
            Reschedule_Reason_Map__mdt reasonCode = [Select Id, Increments_Strike_Counter__c, Reschedule_Reason__c, Reschedule_Reason_Code__c
                                                     from Reschedule_Reason_Map__mdt
                                                     where Id =: orderFromUpdate.rescheduleReasonCodeId];
            System.debug('My Reschedule Reason is:  '+reasonCode.Reschedule_Reason__c);
            System.debug('My Reschedule Reason Code is:  '+reasonCode.Reschedule_Reason_Code__c);
            System.debug('ASAP-----'+orderFromUpdate.asap);
            API_BaseResponse deliveryDateResponse = API_UpdateSalesOrderClient.updateSalesOrderDeliveryDate(currentOrderValues.fulfillerID__c, 
                                                                                                            currentOrderValues.phhSalesOrder__c,
                                                                                                            orderFromUpdate.asap,
                                                                                                            Integer.valueof(currentOrderValues.phhProfitcenter__c), 
                                                                                                            orderFromUpdate.currentDeliverydate, 
                                                                                                            lineItems[0].phdDeliveryType__c,
                                                                                                            reasonCode.Reschedule_Reason__c);
            System.debug('******** deliveryDateResponse: ' + deliveryDateResponse);
            if(deliveryDateResponse.isSuccess){
                successMessages.add(deliveryDateResponse.message);
                //update strike counter if reason code is applicable
                if(reasonCode.Increments_Strike_Counter__c){
                    updateStrikeCounter(currentOrderValues.phhGuestID__c);
                }
            }
            else{
                response.hasErrors = true;
                errorMessages.add(deliveryDateResponse.message);
            }
        }
        
                
        //update Hot status
        if(currentOrderValues.phhHot__c != orderFromUpdate.hot || currentOrderValues.phhWindowBegin__c != orderFromUpdate.WindowBegin || currentOrderValues.phhWindowEnd__c != orderFromUpdate.WindowEnd){
            orderIsUpdated = true;
            API_BaseResponse hotResponse = API_UpdateSalesOrderClient.updateSalesOrderHotStatus(currentOrderValues.fulfillerID__c, 
                                                                                                currentOrderValues.phhSalesOrder__c, orderFromUpdate.hot,orderFromUpdate.WindowBegin,orderFromUpdate.WindowEnd,orderFromUpdate.currentDeliverydate,orderFromUpdate.Profitcenter);
            if(hotResponse.isSuccess){
                successMessages.add(hotResponse.message);
            }
            else{
                response.hasErrors = true;
                errorMessages.add(hotResponse.message);
            }
        }
        
        
        //update VIPLIB status
        if(currentOrderValues.VIPFlag__c != orderFromUpdate.vip || currentOrderValues.LIBFlag__c != orderFromUpdate.lib){
            orderIsUpdated = true;
            API_BaseResponse viplibResponse = API_UpdateSalesOrderClient.updateSalesOrderVIPLIBStatus(currentOrderValues.fulfillerID__c, 
                                                                                                currentOrderValues.phhSalesOrder__c, orderFromUpdate.vip,orderFromUpdate.lib, currentOrderValues.VIPFlag__c, currentOrderValues.LIBFlag__c );
            
             System.debug('********libResponse: ' + viplibResponse);
            if(viplibResponse.isSuccess){
                successMessages.add(viplibResponse.message);
            }
            else{
                response.hasErrors = true;
                errorMessages.add(viplibResponse.message);
            }
        }
        
        //update shipping address
        string shipSt1 = lineItems.isEmpty() ? null : lineItems[0].phdShipAddress1__c;
        string shipSt2 = lineItems.isEmpty() ? null : lineItems[0].phdShipAddress2__c;
        string shipCity = lineItems.isEmpty() ? null : lineItems[0].phdShipCity__c;
        string shipState = lineItems.isEmpty() ? null : lineItems[0].phdShipState__c;
        string shipZip = lineItems.isEmpty() ? null : lineItems[0].phdShipZip__c;
        if(shipSt1 != orderFromUpdate.shipToStreet1 || shipSt2 != orderFromUpdate.shipToStreet2 || shipCity != orderFromUpdate.shipToCity
           || shipState != orderFromUpdate.shipToState || shipZip != orderFromUpdate.shipToPostalcode){
               orderIsUpdated = true;
               API_BaseResponse shipingAddressResponse = API_UpdateSalesOrderClient.updateShippingAddress(currentOrderValues.fulfillerID__c, 
                                                                                                          currentOrderValues.phhSalesOrder__c, 
                                                                                                          Integer.valueof(currentOrderValues.phhProfitcenter__c), 
                                                                                                          currentOrderValues.phhCustomerName__c,
                                                                                                          orderFromUpdate.shipToStreet1, 
                                                                                                          orderFromUpdate.shipToStreet2, 
                                                                                                          orderFromUpdate.shipToCity, 
                                                                                                          orderFromUpdate.shipToState, 
                                                                                                          orderFromUpdate.shipToPostalcode
                                                                                                         );
               if(shipingAddressResponse.isSuccess){
                   successMessages.add(shipingAddressResponse.message);
               }
               else{
                   response.hasErrors = true;
                   errorMessages.add(shipingAddressResponse.message);
               }
           }
        
        //update delivery comments
        if(currentOrderValues.phhOrder_Notes__c != orderFromUpdate.deliveryComments){
            if(orderFromUpdate.deliveryComments.Contains('\n')) {
                orderFromUpdate.deliveryComments = orderFromUpdate.deliveryComments.replace('\n',' ');
                
            }
            orderIsUpdated = true;
            API_BaseResponse orderCommentsResponse = API_UpdateSalesOrderClient.updateSalesOrderComments(currentOrderValues.fulfillerID__c, 
                                                                                                         orderFromUpdate.deliveryComments, 
                                                                                                         currentOrderValues.phhSalesOrder__c, 
                                                                                                         Integer.valueof(currentOrderValues.phhProfitcenter__c));
            
            if(orderCommentsResponse.isSuccess){
                successMessages.add(orderCommentsResponse.message);
            }
            else{
                response.hasErrors = true;
                errorMessages.add(orderCommentsResponse.message);
            }
        }
        
        if(!orderIsUpdated){
            errorMessages.add(Label.Sales_Order_Saved_With_No_Changes_Error_Message);
            response.hasErrors = true;
        }
        if(!successMessages.isEmpty()){
            response.successMessages = String.join(successMessages, ',') + Label.Sales_Order_Update_Delayed_Sync_Message;
        }
        if(!errorMessages.isEmpty()){
            response.errorMessages = String.join(errorMessages, ',');
        }
        System.debug('******* response: '+response);
        return response;
        
    }
    
    public class UpdateSalesOrderResponse implements Attributable{
        @AuraEnabled
        public boolean  hasErrors {get;set;}
        
        @AuraEnabled
        public string  errorMessages {get;set;}
        
        @AuraEnabled
        public string  successMessages {get;set;}
        
        public UpdateSalesOrderResponse(){
            hasErrors = false;
        }
    }
    
    @future
    public static void updateStrikeCounter(Id customerId){
        API_UpdateStrikeCounter.doPatch(new List<Id>{customerId});
    }
    
    // EDQ added
    @AuraEnabled
    public static String SearchAddress(string searchTerm, string country, Integer take) {
        return EDQService.SearchAddress(searchTerm, country, take);
    }
    
    // EDQ added
    @AuraEnabled
    public static String FormatAddress(string formatUrl) {
        return EDQService.FormatAddress(formatUrl);
    }
}