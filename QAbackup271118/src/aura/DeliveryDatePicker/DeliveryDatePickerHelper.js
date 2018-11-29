({
    getCalendar : function(component, helper,selectedDate) {
        if(selectedDate != ''){
             component.set("v.showCalender",true);
        $A.createComponent(
            "c:DeliveryWindowLookup",
            {
                "lineItemMap": component.get('v.lineItemMap'),
                "accountNumber": component.get('v.accountNumber'),
                "rdcId": component.get('v.rdcId'),
                "orderLineId":component.get('v.lineItem')[0].Id,
                "isConciergeApp":true,
                "lineItemDeliveryDate":component.get('v.lineItem')[0].DeliveryDate__c,
                "deliveryMode" : component.get('v.deliveryMode'),
                "shipToAddr" :   component.get("v.shipAddr") 
            },
            function(newcomponent){
                if (component.isValid()) {
                    var body = component.get("v.body");
                    body.push(newcomponent);
                    component.set("v.body", body);   
                    
                    
                }
               
            }            
        );
        
    }
        else{
            alert('Select a Desired Delivery Date');
        }
    },
    callItemCheck : function(component, success, failure) {
        var params = {
                "preferredDeliveryDate" : component.get('v.selectedDesiredDeliveryDate'),
                "selectedItems": component.get('v.selectedLineItems'),
                "accId":component.get('v.GuestId'),
                "shipToAddr" :   component.get("v.shipAddr")
            };
        this.callout(component, 'callItemCheck', params, function(response) {
            if (success) {
                success.call(this, response);
            }
        }, function(response, message){
            if (failure) {
                failure.call(this, response, message);
            }
        });        
    },
    updateDeliveryDate : function(component, deliveryDate, success, failure) {
        var params = {
                    "selectedDate"  : deliveryDate,
                    "selectedItems": component.get('v.selectedLineItems'),
                    "accId":component.get('v.GuestId')
                };
        this.callout(component, 'updateShoppingCartLineItems', params, function(response) {
            if (success) {
                success.call(this, response);
            }
        }, function(response, message){
            if (failure) {
                failure.call(this, response, message);
            }
        });        
    },
    postDeliveryDateUpdate : function(component, lineItemMap, deliveryDate){
        var items = [];
        for(var key in lineItemMap){
            items.push({value:lineItemMap[key], key:key,selected: false});
        }
        component.set('v.lineItemMap', items);
        component.set('v.selectedDesiredDeliveryDate', deliveryDate);
        //fire the DeliveryDateSelected app event
        var deliveryDateSelectedEvent = $A.get("e.c:DeliveryDateSelected");
        deliveryDateSelectedEvent.setParams({
            "deliveryDate": deliveryDate, 
            "deliveryMode": component.get("v.deliveryMode")
        }).fire();        
        //event to notify CheckoutSummary refresh when DeliveryDate is updated
        var eventComponent = component.getEvent("DeliveryDateChangeNotifyToCheckoutSummary");
        eventComponent.setParams({ "notifyParam":  true});
        eventComponent.fire(); 
    },    
   /*
    *   Callout to Apex Lightning Controller
    */  
    callout: function(component, name, params, success, failure) {   
        var action = component.get('c.' + name);
        var toastErrorHandler = component.find('toastErrorHandler');
        if (params) {
            action.setParams(params);
        }
        action.setCallback(this, function(response){
            toastErrorHandler.handleResponse(response, success, failure);   
        });        
        action.setBackground();
        $A.enqueueAction(action);
    },
   /*
    *   Display the error message 
    */
    showToast : function(type, title, message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            type: type,
            title: title,
            message: message,
        });
        toastEvent.fire();
    },             
})