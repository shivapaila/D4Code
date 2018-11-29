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
        //alert('CheckoutitemdetailsHelper');
		 var action = component.get("c.getShoppingCartLineItems");
        console.log(component.get('v.recordId'));
       // alert('CheckoutitemdetailsHelper RecordId'+recordId);
        action.setParams({"accountId" : component.get('v.recordId')});
        var toastErrorHandler = component.find('toastErrorHandler');
        action.setCallback(this, function(response){
            toastErrorHandler.handleResponse(
                response,
                function(response){
                    var rtnValue = response.getReturnValue();
                    // alert('CheckoutitemdetailsHelper rtnValue'+JSON.stringify(rtnValue));
                    if (rtnValue !== null) {    
                        console.log(rtnValue);
                        component.set("v.shoppingCartLineItems", rtnValue);
      // alert('CheckoutitemdetailsHelper shoppingCartLineItems'+component.get("v.shoppingCartLineItems"));
                    }else {
                        helper.showToast("error", 'Cart is empty', component,
                                         'Could not find Cart Line Items.');                        
                    }
                },
                function(response, message){ // report failure
                    helper.showToast("error", 'Cart query failed', component,
                                     message);
                    //alert('error message');
                }
            )
        });            
        action.setBackground();
        $A.enqueueAction(action); 
    },
    getCustomerInfo: function(component,helper) {
        var action = component.get("c.getShoppingCart");
        console.log(component.get('v.recordId'));
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
    }
})