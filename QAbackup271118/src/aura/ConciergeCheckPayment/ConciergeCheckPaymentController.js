({
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

    // To allow only numbers in an input text, use this validation
    validateNumber : function(component, event, helper) {
        var auraId = event.getSource().getLocalId();
        var inp = component.find(auraId).get("v.value");
        if(isNaN(inp))
            component.find(auraId).set('v.value', inp.substring(0, inp.length - 1));
    },
	
    ApplyAmount :function (component, event, helper) {
        var isChecked = event.getSource().get("v.checked");
        var paymentInfo = component.get("v.pm");
        if(isChecked){
            // DEF-809 fix
            //paymentInfo.paymentTrans.Payment_Amount__c  = component.get("v.targetAmount") - component.get("v.totalAmount");  
            // DEF-0874 fix
            //paymentInfo.paymentTrans.Payment_Amount__c  = parseFloat(new Big(component.get("v.targetAmount")).minus(component.get("v.totalAmount")));  
            paymentInfo.paymentTrans.Payment_Amount__c  = parseFloat(new Big(component.get("v.targetAmount")).minus(component.get("v.paidAmt")));
        }else{
            paymentInfo.paymentTrans.Payment_Amount__c  = null;  
        }
        component.set("v.pm",paymentInfo);
        var cmpEvent = component.getEvent("updateAmount");
        cmpEvent.fire();
    },

    addCardPayment : function(component, event, helper) {
        var cmpEvent = component.getEvent("addAnotherPaymentEvent");
        cmpEvent.setParams({"paymentType" : "Check"});
        cmpEvent.fire();
    },

    checkAmount : function(component, event, helper) {
        var checkBox = component.find("auraApplyBalance");
        var paymentInfo = component.get("v.pm");
        // DEF-809 fix
        //if(paymentInfo.paymentTrans.Payment_Amount__c != (component.get("v.targetAmount") - component.get("v.totalAmount"))){
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
        }else if ($A.util.isEmpty(paymentInfo.paymentTrans.Check_DocumentNumber__c)){
            helper.toastMessage("error","","Please enter Check number.");
        }else if ($A.util.isEmpty(paymentInfo.paymentTrans.Payment_Amount__c)|| isNaN(paymentInfo.paymentTrans.Payment_Amount__c) ){
            helper.toastMessage("error","","Please enter valid amount.");
        }*//* DEF-0787 - not needed as max length is used now
        else if(paymentInfo.paymentTrans.Check_DocumentNumber__c > 999999999){
            helper.toastMessage("error","","Please input valid Check number.");
        }
        *//*else{
            helper.processPayment(component,paymentInfo,helper);
        }*/
        // DEF-0846 - common PaymentBase component to validate
        if(helper.validateAmount(paymentInfo.paymentTrans.Payment_Amount__c, component.get("v.totalAmount"), component.get("v.targetAmount"))) {
            if($A.util.isEmpty(paymentInfo.paymentTrans.Check_DocumentNumber__c)){
                helper.toastMessage("error","","Please enter Check number.");
            }
            else{
                helper.processPayment(component,paymentInfo,helper);
            }
        }
    },
    //REQ-461 Check Payment Type Request to hide nested modals
    toggleFlags : function(component, event, helper) {
        component.set("v.showPaymentSection", !component.get("v.showVoidConfirmation"));
    }
})