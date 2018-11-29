({
	toastMessage : function(type,title,message){
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            type: type,
            title: title, 
            message: message,
        });
        toastEvent.fire();
    },
    processPayment : function(component,paymentInfo,helper){
        var toastErrorHandler = component.find('toastErrorHandler');
        var actionPP = component.get("c.addPayment");
        actionPP.setParams({
            "personAccId"   : component.get("v.guestId"),
            "pmtInfoString" : JSON.stringify(paymentInfo)
        });
        var spinner = component.find("largeSpinner");
        $A.util.toggleClass(spinner, "slds-hide");    
        actionPP.setCallback(this, function(response){
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        var paymentInfo = response.getReturnValue();
                        if(paymentInfo.paymentAPIStatus == 'success'){
                            var spinner = component.find("largeSpinner");
                            $A.util.toggleClass(spinner, "slds-hide");    
                            helper.toastMessage("success","","Payment has been applied. Thank you.");
                            var updateAmount = component.getEvent("updateAmount");
                            updateAmount.fire();
                            component.getEvent("NotifyParentPmtAdded").fire();
                        }else{
                            helper.toastMessage("error","ERROR",paymentInfo.paymentAPIStatus);
							var spinner = component.find("largeSpinner");
                            $A.util.toggleClass(spinner, "slds-hide");
                        }
                    }    
        });
        $A.enqueueAction(actionPP);                       
    },
    removePayment : function(component){
    	var paymentInfo = component.get("v.pm");
        var action = component.get("c.removePayment");
        action.setParams({
            "personAccId"   : component.get("v.guestId"),
            "pmtInfoString" : JSON.stringify(paymentInfo)
        });
        var spinner = component.find("largeSpinner");
        $A.util.toggleClass(spinner, "slds-hide");    
        action.setCallback(this, function(response){
            var spinner = component.find("largeSpinner");
            $A.util.toggleClass(spinner, "slds-hide");    
        	component.set("v.showVoidConfirmation", false);
            component.getEvent("updateAmount").fire();
            component.getEvent("NotifyParentPmtAdded").fire();
        });
        $A.enqueueAction(action);
    }
})