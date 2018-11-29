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
        $A.util.toggleClass(component.find("largeSpinner"), "slds-hide");    
        actionPP.setCallback(this, function(response){
                            
            var state = response.getState();
            if (state === "SUCCESS") {
                var paymentInfo = response.getReturnValue();
                if(paymentInfo !=null){
                    $A.util.toggleClass(component.find("largeSpinner"), "slds-hide");    
                    helper.toastMessage("success","","Payment has been applied. Thank you.");
                    component.getEvent("NotifyParentPmtAdded").fire();
                    component.getEvent("updateAmount").fire();
                }else{
                    $A.util.toggleClass(component.find("largeSpinner"), "slds-hide"); 
                    helper.toastMessage("error","ERROR","Payment failed. Please check with administrator.");
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
        $A.util.toggleClass(component.find("largeSpinner"), "slds-hide");    
        action.setCallback(this, function(response){
            $A.util.toggleClass(component.find("largeSpinner"), "slds-hide");    
        	component.set("v.showVoidConfirmation", false);
            component.getEvent("updateAmount").fire();
            component.getEvent("NotifyParentPmtAdded").fire();
        });
        $A.enqueueAction(action);
    }
})