({
    goForward : function(cmp, helper) {
       // Load all contact data
       var action = cmp.get("c.saveDesiredDeliveryDate");

       var oppId = cmp.get("v.oppId");
        var selectedDay =  cmp.get("v.newSelectedDeliveryDate");
       var toastErrorHandler = cmp.find('toastErrorHandler');
       if ($A.util.isEmpty(oppId) || $A.util.isUndefined(oppId) )
           return;
        if ($A.util.isEmpty(selectedDay) || $A.util.isUndefined(selectedDay) ){
             helper.showToast("error", 'No Delivery Date selected', cmp, 
                              'Please select a desired delivery date before continuing');
             return;
        }
       action.setParams({ "oppId"  : oppId,
                         "selectedDesiredDate" :selectedDay });

       action.setCallback(this, function(response) {
           toastErrorHandler.handleResponse(
               response, // handle failure
               function(response){ // report success and navigate to contact record
                   var saved = response.getReturnValue();
                   if (saved == true) {
                       cmp.getEvent("NotifyParentFinishedDesiredDate").setParams({"notifyParam":selectedDay}).fire();
                   }
               },
               function(response, message){ // report failure
                   helper.showToast("error", 'Save Desired Date Error', cmp, message);
               }
           )
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
    }
})