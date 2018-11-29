({
    searchHelper: function(component, event,helper) {
        component.set("v.noResults", false);
        component.set("v.showSpinner", true);
        component.set("v.nextDate", null);
        var action = component.get("c.getDatesFromZip");
        action.setParams({
            'postalCode': component.get("v.searchZip"), 
            'sku' : component.get("v.searchSku"),
            'quantity' : component.get("v.numSelected"),
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var dateResponse = JSON.parse(response.getReturnValue());
                if ((Object.keys(dateResponse).length === 0 && dateResponse.constructor === Object) 
                    || (!dateResponse.isSuccess)
                    || (dateResponse.deliveryWindows.length === 0))
                {
                    component.set("v.noResults", true);
                } else {
                    var nextDate = new Date(dateResponse.deliveryWindows[0].startDateString);
                    component.set("v.nextDate", nextDate.toDateString());
                }
            }
            component.set("v.showSpinner", false);            
        });
        $A.enqueueAction(action);
    }, 
    showToast : function(type, title, component, message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            type: type,
            title: title,
            message: message,
        });
        toastEvent.fire();
    },    
})