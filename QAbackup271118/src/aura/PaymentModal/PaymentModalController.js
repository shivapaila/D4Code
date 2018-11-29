({
    doInit : function(component, event, helper) {
        component.set("v.isExecuting", true);
        console.log('testing');
        var appEvent = $A.get("e.c:NotifyHeaderComponentEvent"); 
            appEvent.fire();
        helper.setPaymentStageOnOpportunity(component, function(response){
            helper.getPaymentMethods(component);
        },
        function(response, message){
            component.set("v.isExecuting", false);
            helper.showToast("error", 'Unable to initialize payment', message);            
        });
    }, 	
    cancelDialog : function(component, event, helper) {
    	component.getEvent("NotifyParentClosePayment").fire();
        helper.cancelDialogClearFields(component);
    },
    doSuspendToPOS: function(component, event, helper) {
        component.getEvent("NotifyParentSuspendSales").fire();
    },
    doCustomerOrderAcceptance: function(component, event, helper) {
        component.set("v.showPayment", false);
        component.set("v.showCustomerOrderAcceptance", true);
    },     
    confirmSuspendToPOS: function(component, event, helper) {
        component.set("v.isSuspendToPOSConfirmed", true);
    },
    cancelSuspendToPOS: function(component, event, helper) {
        component.set("v.isSuspendToPOSConfirmed", false);
    }, 
    cancelAcceptance: function(component, event, helper) {
        component.set("v.showCustomerOrderAcceptance", false);
        component.set("v.showPayment", true);
    },
    handlePaymentProcessed: function(component, event, helper) {
        component.set("v.showPayment", false);
        helper.getPaymentMethods(component);
    }   
})