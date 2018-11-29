({
   createSignatureObj : function(cmp, helper) {
       // Load all contact data
       var action = cmp.get("c.createSignatureObj");

       var recId = cmp.get("v.guestId");
       var toastErrorHandler = cmp.find('toastErrorHandler');
       if ($A.util.isEmpty(recId) || $A.util.isUndefined(recId) )
           return;
       
       action.setParams({ "personAccId"  : recId });

       action.setCallback(this, function(response) {
           toastErrorHandler.handleResponse(
               response, // handle failure
               function(response){ // report success and navigate to contact record
                   cmp.set("v.sigId", response.getReturnValue());
               },
               function(response, message){ // report failure
                   helper.showToast("error", 'Error in loading signature', cmp, 'Error in loading Customer Order Acceptance signature. Please contact a system administrator with the following error message'+ message);
               }
           )
       });
       $A.enqueueAction(action);
    }, 
    
    goForward : function(cmp, helper) {
       // Load all contact data
       var action = cmp.get("c.checkForSignature");

       var recId = cmp.get("v.sigId");
       var toastErrorHandler = cmp.find('toastErrorHandler');
       if ($A.util.isEmpty(recId) || $A.util.isUndefined(recId) )
           return;
       
       action.setParams({ "sigId"  : recId });

       action.setCallback(this, function(response) {
           toastErrorHandler.handleResponse(
               response, // handle failure
               function(response){ // report success and navigate to contact record
                   var attachmentFound = response.getReturnValue();
                   if (attachmentFound == true) {
                       cmp.getEvent("NotifyParentFinishedSign").fire();
                   }
               },
               function(response, message){ // report failure
                   helper.showToast("error", 'Error in saving signature', cmp, 'Error in saving Customer Order Acceptance signature. Please contact a system administrator with the following error message'+ message);
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
    },
  
})