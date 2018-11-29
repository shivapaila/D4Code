({
    getPaymentTermOptions : function(component, helper) {
		var action = component.get("c.getPaymentTerms");
        var toastErrorHandler = component.find('toastErrorHandler');
        action.setParams({
            "pmtInfoStr" : JSON.stringify(component.get("v.paymentInfo"))
        });
        action.setCallback(this, function(response){
           toastErrorHandler.handleResponse(
               response, // handle failure
               function(response){ // report success and navigate to contact record
                   var val = response.getReturnValue(); 
                   console.log('val ', val);
                   component.set("v.termOptions",val);
               },
               function(response, message){ // report failure
                   helper.showToast("error", 'Terms Load Error', component, message);
               }
           );
            var spinner = component.find("termsSpinner");
            $A.util.addClass(spinner, "slds-hide");
        });
        $A.enqueueAction(action);
	},
    showToast : function(type, title, component, message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            type: type,
            // note - leaving mode field for reference 
            //mode: 'dismissible',
            title: title,
            message: message,
        });
        toastEvent.fire();
    } 
})