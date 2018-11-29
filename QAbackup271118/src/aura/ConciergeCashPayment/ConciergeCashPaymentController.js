({
	doInit : function(component, event, helper) {
    },
    Cancel : function(component, event, helper) {
		component.set("v.showVoidConfirmation", false);
	},

    proceedtoVoid : function(component, event, helper) {
    	helper.removePayment(component);
        component.set("v.showVoidConfirmation", false);
	},

	showVoidConfirmation : function(component, event, helper) {
        component.set("v.showVoidConfirmation", true);
	},
	
    ApplyAmount :function (component, event, helper) {
        var isChecked = event.getSource().get("v.checked");
        var paymentInfo = component.get("v.pm");
        if(isChecked){
            // DEF-809 fix
            //paymentInfo.paymentTrans.Payment_Amount__c  = component.get("v.targetAmount") - component.get("v.totalAmount");  
            // DEF-874 Fix
            paymentInfo.paymentTrans.Payment_Amount__c  = parseFloat(new Big(component.get("v.targetAmount")).minus(component.get("v.paidAmt")));  
        }else{
            paymentInfo.paymentTrans.Payment_Amount__c  = null;  
        }
        component.set("v.pm",paymentInfo);
        var cmpEvent = component.getEvent("updateAmount");
        cmpEvent.fire();
    },

    addCashPayment : function(component, event, helper) {
        var cmpEvent = component.getEvent("addAnotherPaymentEvent");
        cmpEvent.setParams({"paymentType" : "Cash"});
        cmpEvent.fire();
    },

    checkAmount : function(component, event, helper) {
        var checkBox = component.find("auraApplyBalance");
        var paymentInfo = component.get("v.pm");
        // DEF-809 fix
        //if(paymentInfo.paymentTrans.Payment_Amount__c != (component.get("v.targetAmount") - component.get("v.totalAmount"))){
            // DEF-874 Fix
        if(paymentInfo.paymentTrans.Payment_Amount__c != parseFloat(new Big(component.get("v.targetAmount")).minus(component.get("v.paidAmt")))){
            checkBox.set("v.checked", false);
        }
        var cmpEvent = component.getEvent("updateAmount");
        cmpEvent.fire();
    },
    processPayment :  function(component, event, helper) {
        var paymentInfo = component.get("v.pm");
        /*if(component.get("v.totalAmount") > component.get("v.targetAmount")){
            helper.toastMessage("error","","The amount exceed the total amount.");
        }else if ($A.util.isEmpty(paymentInfo.paymentTrans.Payment_Amount__c)|| isNaN(paymentInfo.paymentTrans.Payment_Amount__c) ){
            helper.toastMessage("error","","Please enter valid amount.");
        }else{
            helper.processPayment(component,paymentInfo,helper);
        }*/
        // DEF-0846 - common PaymentBase component to validate
        if(helper.validateAmount(paymentInfo.paymentTrans.Payment_Amount__c, component.get("v.totalAmount"), component.get("v.targetAmount"))) {
            helper.processPayment(component,paymentInfo,helper);
        }
    },
     toggleFlags : function(component, event, helper) {
        component.set("v.showPaymentSection", !component.get("v.showVoidConfirmation"));
    }
})