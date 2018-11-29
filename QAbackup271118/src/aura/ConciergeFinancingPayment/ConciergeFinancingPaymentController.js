({
    doInit : function(component, event, helper) {
        var pmJS = component.get("v.pm");
       // alert('pmjs is'+JSON.stringify(pmJS));
        if(pmJS.paymentTrans.Id != null && pmJS.paymentTrans.Id != '') {
            helper.hideSpinner(component);
            component.set("v.paymentSuccessful", true);
           
        }
        else {
           // alert('in else');
            helper.showSpinner(component);
            helper.getPaymentOptionsHelper(component);
            helper.getItemDetailsHelper(component);
        }
        component.set("v.originalTargetAmount", component.get("v.targetAmount"));
        component.set("v.originalTotalAmount", component.get("v.totalAmount"));
        // DEF-809 fix
        //component.set("v.originalAmountRemaining", component.get("v.originalTargetAmount") - component.get("v.originalTotalAmount"));
        component.set("v.originalAmountRemaining", parseFloat(new Big(component.get("v.originalTargetAmount")).minus(component.get("v.originalTotalAmount"))));
    },

    // clear out all fields when Payment Option is changed
    clearOutAllFields : function(component, event, helper) {
    	helper.showSpinner(component);
        var selected = component.find("fin_Type").get("v.value");
        // Amount Applied Fix
        /*
    	var newPM = {"SObjectType":"Cart_Payment_Transaction__c", "Payment_Type__c" : 'Financing', 'TenderCode__c' : selected}
        component.set("v.pm",{"Object":"PaymentMethodWrapper", "paymentTrans" : newPM,
        						// fields used in input text need to be explicitly set blank
    							"FINnum" : ""});*/
        component.set("v.pm.FINnum", "");
        component.set("v.pm.paymentTrans.Payment_Amount__c", 0);
        var cmpEvent = component.getEvent("updateAmount");
        cmpEvent.fire();
        helper.getPaymentTermsHelper(component, selected);
    },

    // To allow only numbers in an input text, use this validation
    validateNumber : function(component, event, helper) {
    	var auraId = event.getSource().getLocalId();
    	var inp = component.find(auraId).get("v.value");
        if(isNaN(inp))
            component.find(auraId).set('v.value', inp.substring(0, inp.length - 1));
    },

    accountLookup : function(component, event, helper) {
    	if(component.get("v.pm.FINnum") != '' 
    		&& component.get("v.pm.FINnum") != null){
    		helper.performAccountLookupHelper(component);
		}
		else {
			helper.showToast('error', '', 'Please enter a Financing Number');
		}
    },

    completeAccountLookup : function(component, event, helper) {
    	helper.completeAccountLookupHelper(component);
    },

    processPayment : function(component, event, helper) {
        // DEF-0846 - common PaymentBase component to validate
        var paymentInfo = component.get("v.pm");
        if(helper.validateAmount(paymentInfo.paymentTrans.Payment_Amount__c, component.get("v.totalAmount"), component.get("v.targetAmount"))) {
            helper.processPaymentHelper(component);
        }
    },

    addAnotherFinancing : function(component, event, helper) {
        var cmpEvent = component.getEvent("addAnotherPaymentEvent");
        cmpEvent.setParams({"paymentType" : "Financing"});
        cmpEvent.fire();
    },

    checkAmount : function(component, event, helper) {
        // DEF-809 fix
         ///alert('originalTotalAmount-----'+component.get("v.originalTotalAmount"));
        var amountRemaining = component.get("v.originalTargetAmount") - component.get("v.originalTotalAmount");
        //var amountRemaining = parseFloat(new Big(component.get("v.originalTargetAmount")).minus(component.get("v.originalTotalAmount")));
        var enteredAmount = component.get("v.pm.paymentTrans.Payment_Amount__c");
        var availableCredit = component.get("v.accountLookupResponse.AvailableCredit");
       alert('originalTargetAmount--->'+component.get("v.originalTargetAmount"));
       alert('originalTotalAmount--->'+component.get("v.originalTotalAmount"));
      alert('enteredAmount--->'+enteredAmount);
      alert('availableCredit-->'+availableCredit);
      alert('amountRemaining-->'+amountRemaining);
        if(enteredAmount > amountRemaining) {
            helper.showToast('Error', '', 'The amount exceeds the total amount.');
            component.set("v.termSelectionSuccessful", false);
        }
        if(enteredAmount > availableCredit) {
            helper.showToast('Error', '', 'The amount exceeds the available credit.');
            component.set("v.termSelectionSuccessful", false);
        }
        if(enteredAmount != availableCredit && component.get("v.applyTotalBalance")) {
            component.set("v.applyTotalBalance", false);
        }
        if(enteredAmount <= amountRemaining && enteredAmount <= availableCredit) {
            component.set("v.termSelectionSuccessful", true);
        }
        if(enteredAmount == null || enteredAmount == '') {
            component.set("v.termSelectionSuccessful", false);
        }
        var cmpEvent = component.getEvent("updateAmount");
        cmpEvent.fire();
    },

    displayVoidConfirmation : function(component, event, helper) {
        
        component.set("v.showVoidConfirmation", true);
       //  helper.getItemDetailsHelper(component);
        //component.set("v.showPaymentSection", false);
    },

    cancelVoidConfirmation : function(component, event, helper) {
        component.set("v.showVoidConfirmation", false);
    },
    performVoidConfirmation : function(component, event, helper) {
        helper.processVoidHelper(component);
    },

    applyAmount : function(component, event, helper) {
        var isApplyTotalBalance = component.get("v.applyTotalBalance");
        if(isApplyTotalBalance) {
            // DEF-809 fix
            //var amountRemaining = component.get("v.originalTargetAmount") - component.get("v.originalTotalAmount");
            // DEF-874 Fix
            var amountRemaining = parseFloat(new Big(component.get("v.targetAmount")).minus(component.get("v.paidAmt")));
            var availableCredit = component.get("v.accountLookupResponse.AvailableCredit");
            if(amountRemaining >= availableCredit) {
                component.set("v.pm.paymentTrans.Payment_Amount__c", availableCredit);
                component.set("v.termSelectionSuccessful", true);
                component.getEvent("updateAmount").fire();
            }
            else {
                component.set("v.pm.paymentTrans.Payment_Amount__c", amountRemaining);
                component.set("v.termSelectionSuccessful", true);
                component.getEvent("updateAmount").fire();
            }
        }
        else {
            component.set("v.pm.paymentTrans.Payment_Amount__c", null);
            component.set("v.termSelectionSuccessful", true);
            component.getEvent("updateAmount").fire();
        }
    },
    showHideVoidConfirmation : function(component, event, helper) {
        component.set("v.showPaymentSection", !component.get("v.showVoidConfirmation"));
    },
    showHideAccountLookup : function(component, event, helper) {
        component.set("v.showPaymentSection", !component.get("v.showAccountLookupModal"));
    },

    setSelectedPaymentTerm : function(component, event, helper) {
        var allTerms = component.get("v.paymentTermsOptions");
        for(var i=0; i<allTerms.length; i++) {
            if(allTerms[i].TermsCode == component.get("v.pm.FINterms")) {
                component.set("v.selectedPaymentTerm", allTerms[i]);
            }
        }
    }
})