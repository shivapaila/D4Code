({
    getPaymentOptionsHelper : function(component) {
        var payOpts =[];
    	var actionLoadPMs = component.get("c.getPaymentOptions");
        actionLoadPMs.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue(); 
                 console.log('paymentdropdown' + JSON.stringify(result));
                component.set("v.payOptionsResult", result);              
                for(var key in result){
                    if( result[key].TenderCodeDescription__c != 'DO NOT USE' &&
                        result[key].TenderCodeDescription__c != 'Cash')
                        payOpts.push({"value":key, "label": result[key].TenderCodeDescription__c});
                }
                component.set("v.payOptions",payOpts);
                this.getPaymentTermsHelper(component, 'CITM');
            }
        });
        $A.enqueueAction(actionLoadPMs);
    },

    getPaymentTermsHelper : function(component, selectedTenderCode) {
        var selectedTenderCode = component.get("v.pm.paymentTrans.TenderCode__c");
        var action = component.get("c.getPaymentTerms");
        action.setParams({
            'selectedTenderCode' : selectedTenderCode
        });
        action.setCallback(this, function(response){
            this.hideSpinner(component);
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                component.set("v.paymentTermsOptions", result);
            }
            else if (state === "INCOMPLETE") {
                this.handlerError(null, true);
            }
            else if (state === "ERROR") {
                this.handlerError(response.getError(), false);
            }
        });
        $A.enqueueAction(action);
    },

    getItemDetailsHelper : function(component) {
        //alert('1');
        var action = component.get("c.getItemDetails");
        action.setParams({
            "personAccountId" : component.get("v.guestId")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                component.set("v.oppty", result.oppt);
                component.set("v.itemDetailsMap", result.objectMap);
                
            }
            
            else if (state === "INCOMPLETE") {
                this.handlerError(null, true);
            }
            else if (state === "ERROR") {
                this.handlerError(response.getError(), false);
            }
            
        });
        $A.enqueueAction(action);
    },

    performAccountLookupHelper : function(component) {
    	this.showSpinner(component);
        var action = component.get("c.performAccountLookup");
        action.setParams({
            "personAccountId" : component.get("v.guestId"),
            "oppt" : component.get("v.oppty"),
            "objectMap" : component.get("v.itemDetailsMap"),
            "pmJSON" : JSON.stringify(component.get("v.pm")),
            "ptermWrap" : JSON.stringify(component.get("v.paymentTermsOptions"))
        });
    	action.setCallback(this, function(response){
            this.hideSpinner(component);
    		var state = response.getState();
            if (state === "SUCCESS") {
            	var result = response.getReturnValue();
            	component.set("v.accountLookupResponse", result);
            	component.set("v.showAccountLookupModal", true);
            }
            else if (state === "INCOMPLETE") {
            	this.handlerError(null, true);
            }
            else if (state === "ERROR") {
            	this.handlerError(response.getError(), false);
            }
    	});
    	$A.enqueueAction(action);
    },

    completeAccountLookupHelper : function(component) {
    	if(component.get("v.customerIdConfirmed")) {
    		component.set("v.showAccountLookupModal", false);
    		component.set("v.accountLookupSuccessful", true);
            component.set("v.pm.paymentTrans.Payment_Amount__c", 0);
            var allTerms = component.get("v.paymentTermsOptions");
            component.set("v.selectedPaymentTerm", allTerms[0]);
    	}
    	else {
    		this.showToast('error', '', "Please confirm customer’s ID before continuing");
    	}
    },

    processPaymentHelper : function(component) {
        this.showSpinner(component);
        var action = component.get("c.processPaymentMethod");
        action.setParams({ 
            "personAccountId" : component.get("v.guestId"),
            "oppt" : component.get("v.oppty"),
            "objectMap" : component.get("v.itemDetailsMap"),
            "pmJSON" : JSON.stringify(component.get("v.pm")),
            "selectedPayTermJSON" : JSON.stringify(component.get("v.selectedPaymentTerm"))
        });
        
        action.setCallback(this, function(response){
            this.hideSpinner(component);
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                component.set("v.pm", result);
                component.set("v.paymentSuccessful", true);
                this.showToast('success', '', "Payment has been applied. Thank you.");
                component.getEvent("NotifyParentPmtAdded").fire();
            }
            else if (state === "INCOMPLETE") {
                this.handlerError(null, true);
            }
            else if (state === "ERROR") {
                this.handlerError(response.getError(), false);
                component.set("v.pm.paymentTrans.Payment_Amount__c", 0);
                var cmpEvent = component.getEvent("updateAmount");
                cmpEvent.fire();
            }
        });
        $A.enqueueAction(action);
    },

    processVoidHelper : function(component) {
        this.showSpinner(component);
        var action = component.get("c.voidPayment");
       // alert('action is -->'+JSON.stringify(action));
       // alert('acccount id is '+component.get("v.guestId"));
        // alert('itemDetailsMap id is '+JSON.stringify(component.get("v.itemDetailsMap")));
        action.setParams({ 
            
            "personAccountId" : component.get("v.guestId"),
            "oppt" : component.get("v.oppty"),
            "objectMap" : component.get("v.itemDetailsMap"),
            "pmJSON" : JSON.stringify(component.get("v.pm"))
        });
        action.setCallback(this, function(response){
            this.hideSpinner(component);
            var state = response.getState();
            alert('state is -->'+state);
            if (state === "SUCCESS") {
                
                var result = response.getReturnValue();
                alert('result is -->'+JSON.stringify(result));
                
                component.set("v.pm", result);
                component.set("v.showVoidConfirmation", false);
                alert('showVoidConfirmation-->'+component.get("v.showVoidConfirmation"));
                component.getEvent("NotifyParentPmtAdded").fire();
            }
            else if (state === "INCOMPLETE") {
                this.handlerError(null, true);
            }
            else if (state === "ERROR") {
                this.handlerError(response.getError(), false);
            }
        });
        $A.enqueueAction(action);
    },
    showSpinner : function(component) {
        component.set("v.showSpinner", true);
    },
    hideSpinner : function(component) {
        component.set("v.showSpinner", false);
    },
    handlerError : function(errors, isIncomplete) {
        var error = "Unknown error";
        if (errors) {
            if (errors[0] && errors[0].message) {
                error =  errors[0].message;
            }
        }
        if(isIncomplete) {
            error = 'could not complete request, please check back later';
        }
        this.showToast('Error', '', error);
    },
    showToast : function(type, title, message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message": message,
            "type": type,
        });
        toastEvent.fire();
    }
})