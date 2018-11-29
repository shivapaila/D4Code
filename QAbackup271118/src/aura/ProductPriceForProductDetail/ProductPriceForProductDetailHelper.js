({
	getSalePrice : function(component, event, helper) {
        var action = component.get("c.getEcommPrice");
        var toastErrorHandler = component.find('toastErrorHandler');
        action.setParams({"productSKUId" : component.get('v.productDetailId')});
        action.setCallback(this, function(response){
            toastErrorHandler.handleResponse(
                response, // handle failure
                function(response){ // display expanded price with ecomm price value
                    				// or message that no price was found
                    var rtnValue = response.getReturnValue();
                    if (rtnValue !== null) {
                        component.set("v.ecommPrice", rtnValue);
                        helper.open(component);
                    } else {
                        component.set("v.ecommPrice", null);
					}
                },
                function(response, message){ // report failure
                    helper.showToast("error", 'Could not get eComm Price', component,
                                     message);
                }
            )
        });

        $A.enqueueAction(action);
	}, 
    open : function(component) {
        component.set("v.priceExpanded", true);
        component.set("v.icon", 'fa-minus');
    }, 
    close : function(component) {
        component.set("v.priceExpanded", false);
        component.set("v.icon", 'fa-plus');
    }    
})