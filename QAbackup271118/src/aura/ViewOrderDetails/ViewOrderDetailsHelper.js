({
    loadOrder : function(cmp, helper) {
		var order = cmp.get("v.order");
       var toastErrorHandler = cmp.find('toastErrorHandler');
        var action = cmp.get("c.getOrder");
        action.setParams({ "orderId"  : order.ExternalId }); 
   		action.setCallback(this, function(response) {
            toastErrorHandler.handleResponse(
                response, // handle failure
                function(response){ // report success and navigate to contact record
                    var results = response.getReturnValue();
                    cmp.set("v.orderItems", results);
                }, 
                function(response, message){ // report failure
                    helper.showToast("error", 'Order Detail Load Error', cmp,
                                     message);
                }
            )
        });

        $A.enqueueAction(action);
	},
    showToast : function(type, title, component, message) {
        var inConsole = component.get("v.inSvcConsole");
        if (!inConsole) { // if we're in lightning message this way
	        var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                type: type,
                // note - leaving mode field for reference 
                //mode: 'dismissible',
                title: title, 
                message: message,
            });
            toastEvent.fire();
        } else {
            component.set("v.messageType", type);
            component.set("v.message", message);
        }
    }    
})