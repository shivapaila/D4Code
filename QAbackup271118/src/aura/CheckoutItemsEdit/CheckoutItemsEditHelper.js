({
    showToast : function(type, title, component, message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            type: type,
            title: title,
            message: message,
        });
        toastEvent.fire();
    },
    getShoppingCartLineItems : function(component,helper) {
         //alert('checkoutitemsedithelper Called');
        var action = component.get("c.getShoppingCartLineItems");
        // alert('checkoutitemsedithelper action'+action);
        action.setParams({"accountId" : component.get('v.recordId')});
        
        var toastErrorHandler = component.find('toastErrorHandler');
        action.setCallback(this, function(response){
            toastErrorHandler.handleResponse(
                response,
                function(response){
                    var rtnValue = response.getReturnValue();
                   // alert('checkoutitemsedithelper rtnValue'+JSON.stringify(rtnValue));
                    if (rtnValue !== null) {    
                        component.set("v.shoppingCartLineItems", rtnValue);
                    }else {
                        helper.showToast("error", 'Cart is empty', component,
                                         'Could not find Cart Line Items.');                        
                    }
                },
                function(response, message){ // report failure
                    helper.showToast("error", 'Cart query failed', component,
                                     message);
                     //alert('checkoutitemsedithelper Cart query failed');
                }
            )
        });            
        action.setBackground();
        $A.enqueueAction(action); 
    },
    getCustomerInfo: function(component,helper) {
        var action = component.get("c.getShoppingCart");
        action.setParams({"accountId" : component.get('v.recordId')});
             
        var toastErrorHandler = component.find('toastErrorHandler');
        action.setCallback(this, function(response){
            toastErrorHandler.handleResponse(
                response,
                function(response){
                    var rtnValue = response.getReturnValue();
                    if (rtnValue !== null) {  
                            component.set("v.opp", rtnValue);
                    }else {
                        helper.showToast("error", 'Customer Address info empty', component,
                                         'Could not find Customer Address info empty.');                        
                    }
                },
                function(response, message){ // report failure
                    helper.showToast("error", 'Could not find Customer Address info', component,
                                     message);
                }
            )
        });            
        action.setBackground();
        $A.enqueueAction(action); 
    },
    
    getShippingWayList: function(component,helper) {
         var action = component.get("c.getShippingWayList");
        var toastErrorHandler = component.find('toastErrorHandler');
        action.setCallback(this, function(response){
            toastErrorHandler.handleResponse(
                response,
                function(response){
                    var rtnValue = response.getReturnValue();
                    console.log(rtnValue);
                    if (rtnValue !== null) {    
                        console.log(rtnValue);
                        component.set("v.shippingWayList", rtnValue);
                    }else {
                        helper.showToast("error", 'Shipping way are empty', component,
                                         'Could not find Shipping way .');                        
                    }
                },
                function(response, message){ // report failure
                    helper.showToast("error", 'Shipping way are empty', component,
                                     message);
                }
            )
        });            
        action.setBackground();
        $A.enqueueAction(action); 
    },
    getDiscountReasonList: function(component,helper) {
         var action = component.get("c.getDiscountReasonList");
        var toastErrorHandler = component.find('toastErrorHandler');
        action.setCallback(this, function(response){
            toastErrorHandler.handleResponse(
                response,
                function(response){
                    var rtnValue = response.getReturnValue();
                    console.log(rtnValue);
                    if (rtnValue !== null) {    
                        console.log(rtnValue);
                        component.set("v.discountReasonList", rtnValue);
                    }else {
                        helper.showToast("error", 'Discount Reason are empty', component,
                                         'Could not find Discount Reason  .');                        
                    }
                },
                function(response, message){ // report failure
                    helper.showToast("error", 'Discount Reason  are empty', component,
                                     message);
                }
            )
        });            
        action.setBackground();
        $A.enqueueAction(action); 
    },
    getMarketDiscountCriteria: function(component,helper) {
        var action = component.get("c.getRSAMarketDiscountThreshholds");
        var toastErrorHandler = component.find('toastErrorHandler');
        action.setCallback(this, function(response){
            toastErrorHandler.handleResponse(
                response,
                function(response){
                    var rtnValue = response.getReturnValue();
                    console.log(rtnValue);
                    if (rtnValue !== null) {    
                        console.log(rtnValue);
                        component.set("v.marketDiscountCriteria", rtnValue);
                    }else {
                        helper.showToast("error", 'Market Discount Criteria are empty', component,
                                         'Could not find Market Discount Criteria.');                        
                    }
                },
                function(response, message){ // report failure
                    helper.showToast("error", 'Market Discount Criteria are empty', component,
                                     message);
                }
            )
        });            
        action.setBackground();
        $A.enqueueAction(action); 
    },
    getAccountStoreInfo: function(component,helper) {
         var action = component.get("c.getRSAOneSourceId");
        var toastErrorHandler = component.find('toastErrorHandler');
        action.setCallback(this, function(response){
            toastErrorHandler.handleResponse(
                response,
                function(response){
                    var rtnValue = response.getReturnValue();
                    console.log(rtnValue);
                    if (rtnValue !== null) {    
                        console.log(rtnValue);
                        component.set("v.accountStoreInfo", rtnValue);
                    }else {
                        helper.showToast("error", 'RSA One Source Id Info are empty', component,
                                         'Could not find RSA One Source Id Info.');                        
                    }
                },
                function(response, message){ // report failure
                    helper.showToast("error", 'RSA One Source Id Info are empty', component,
                                     message);
                }
            )
        });            
        action.setBackground();
        $A.enqueueAction(action); 
    },
    
    updateLineItem : function(component,helper) {
        var action = component.get("c.updateLineItemWithSKU");
        action.setParams({"recordId" : component.get('v.recordId'),
            "lineItem" : component.get('v.manualShoppingCartLineItem')});
        
        var toastErrorHandler = component.find('toastErrorHandler');
        action.setCallback(this, function(response){
            toastErrorHandler.handleResponse(
                response,
                function(response){
                    var rtnValue = response.getReturnValue();
                    if (rtnValue !== null) {    
                        if(rtnValue == 'Updated'){
                            helper.showToast("success", 'Item addition to cart is successful', component,
                                     'Existing item has been updated');    
                        }else if(rtnValue == 'Inserted'){
                            helper.showToast("success", 'Item addition to cart is successful', component,
                                     'New item has been created');    
                        }
                        $A.get('e.force:refreshView').fire();
                    }else {
                        helper.showToast("error", 'Error while creating/updating LineItem', component,
                                         'Error while creating/updating LineItem.');                        
                    }
                },
                function(response, message){ // report failure
                    helper.showToast("error", 'Error while creating/updating LineItem', component,
                                         'Error while creating/updating LineItem.'); 
                }
            )
        });            
        action.setBackground();
        $A.enqueueAction(action); 
    },
})