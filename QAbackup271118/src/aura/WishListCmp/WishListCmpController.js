({
    // Pass recordId to apex controller and get wishlist records
	getWishLst : function(component, event, helper) {
        
        var action = component.get("c.getWishlist");
        action.setParams({
                "accountId" : component.get('v.recordId')
            });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set('v.isWishlistEmpty',true);
                var val=response.getReturnValue();
                if(val != null){
                    component.set("v.wishLst", val);
                    component.set('v.isWishlistEmpty',false);
                }
            }
            else{
                var errors = response.getError();
                var message = 'Unknown error'; // Default error message
                // Retrieve the error message sent by the server
                if (errors && Array.isArray(errors) && errors.length > 0) {
                    message = errors[0].message;
                }
                // Display the message
                console.log('Error in getting wihslist: ' + message);
                component.set('v.isWishlistEmpty',true);
            }

        });
         $A.enqueueAction(action);
	},
    goToProduct : function(component, event, helper){
        var selectedItem = event.currentTarget; // Get the target object
        var productDetailId = selectedItem.dataset.record; // Get its binding value

        var appEvent = $A.get("e.c:NavigateToWrapperComponentAppEvent");
        appEvent.setParams({
            "targetCmpName" : 'ProductCategoryWrapperCmp',
            "targetCmpParameters" : {"parentCategoryId": null, "productDetailId": productDetailId, "searchKey": null}
        });
        appEvent.fire();        
    }   
})