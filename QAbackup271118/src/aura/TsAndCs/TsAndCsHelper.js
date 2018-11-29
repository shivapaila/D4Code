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
                   cmp.set("v.sigId", response.getReturnValue().Id);
                   cmp.set("v.signObj", response.getReturnValue());
               },
               function(response, message){ // report failure
                   helper.showToast("error", 'Cart Load Error', cmp, message);
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
              //  $A.get('e.force:refreshView').fire(); 
               },
               function(response, message){ // report failure
                   helper.showToast("error", 'Cart Load Error', cmp, message);
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