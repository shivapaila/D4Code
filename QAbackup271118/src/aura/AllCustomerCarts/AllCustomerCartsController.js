({
	Init : function(cmp, event, helper) {
        
        // Load all cart data
        var action = cmp.get("c.getAllCarts");
        action.setParams({
            "Id":cmp.get('v.recordId')
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var val=response.getReturnValue();
                if(val != ''){
                   cmp.set("v.CartLst", val);
                   
                    cmp.set("v.Message", false);
                    
                 
                }
                else {
                    cmp.set("v.Message", true);
                    
                } 
                
            }

        });
         $A.enqueueAction(action);
    },
    goToRecord : function(component, event, helper) {
        // Fire the event to navigate to the contact record
        var selectedItem = event.currentTarget; 
        var RecordId = selectedItem.dataset.record;
        /*var evt  = $A.get("e.force:navigateToURL");
        evt.setParams({
            "url": '/one/one.app#/n/CustomersCart?recordId=' + RecordId
        })
        evt.fire();*/
         var appEvent = $A.get("e.c:NavigateToWrapperComponentAppEvent");
        appEvent.setParams({
            "targetCmpName" : 'CustomersCartWrapperCmp',
            "targetCmpParameters" : {"recordId": RecordId}
        });
        appEvent.fire();

    },

})