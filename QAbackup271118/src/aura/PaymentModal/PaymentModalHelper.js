({
    setPaymentStageOnOpportunity : function(component, success, failure){
        var params = {"personAccId" : component.get("v.guestId")};
        this.callout(component, 'setPaymentStageOnOpportunity', params, function(response) {
            if (success) {
                success.call(this, response);
            }
        }, function(response, message){
            if (failure) {
                failure.call(this, response, message);
            }
        });
    },    
    getPaymentMethods : function(component) {
        var self = this;  
        var params = {"personAccId" : component.get("v.guestId")};
        this.callout(component, 'getPaymentMethods', params, function(response) {
            var paymentMethodsByType = response.getReturnValue();
            if(!$A.util.isEmpty(paymentMethodsByType)){
                var allPaymentMethods = [];
                var creditCardPaymentMethods = [];
                var selectedPaymentOptions = [];
                for (var paymentType in paymentMethodsByType){
                    var paymentMethods = paymentMethodsByType[paymentType];
                    for (var i=0; i < paymentMethods.length; i++){
                        if (paymentMethods[i].paymentTrans && paymentMethods[i].paymentTrans.Payment_Type__c){
                            if (paymentMethods[i].paymentTrans.Payment_Type__c === 'Credit/Debit Card'){
                                creditCardPaymentMethods.push(JSON.parse(JSON.stringify(paymentMethods[i])));
                            }
                            if ( !$A.util.isEmpty(paymentMethods[i].paymentTrans.Payment_Amount__c) 
                                    && (paymentMethods[i].paymentTrans.Payment_Amount__c > 0 ) ) {
                                allPaymentMethods.push(JSON.parse(JSON.stringify(paymentMethods[i])));
                                if (selectedPaymentOptions.indexOf(paymentType) < 0){
                                    selectedPaymentOptions.push(paymentType);
                                }
                            }
                        }
                    }
                }
                if ($A.util.isEmpty(allPaymentMethods)){
                    if (!$A.util.isEmpty(creditCardPaymentMethods) && creditCardPaymentMethods.length > 0){
                        allPaymentMethods.push(creditCardPaymentMethods[0]);
                        selectedPaymentOptions.push('Credit/Debit Card');
                    }
                }
                // Set the payment methods
                component.set("v.selectedPaymentOptions", selectedPaymentOptions);
                component.set("v.paymentMethods", allPaymentMethods);
                // Set the payment terminal options for payment type Credit/Debit
                var payTerminalOptions=[];
                for (var payment in creditCardPaymentMethods){
                    var terminalLst = creditCardPaymentMethods[payment].paymentTerminals;
                    if(!$A.util.isEmpty(terminalLst)){
                        for(var terminal in terminalLst){
                            payTerminalOptions.push({"value":terminalLst[terminal], "label": terminalLst[terminal]});
                        }
                    }
                }
                component.set("v.payTerminalOptions", payTerminalOptions);
                // Calculate the processed payment amount for all payment methods
                var sum = 0;
                for(var i in allPaymentMethods){
                    var pmWrapper = allPaymentMethods[i];
                    var pm = pmWrapper.paymentTrans; 
                    if(pm.Payment_Amount__c != null){
                        // DEF-809 fix
                        //sum += pm.Payment_Amount__c;
                        sum = new Big(sum).plus(pm.Payment_Amount__c);
                        console.log('Payment Modal - sum: ' + sum);
                    }
                }
                // DEF-809 fix
                component.set("v.totalAmount", parseFloat(sum));
                // DEF-0874 fix
                component.set("v.paidAmt", parseFloat(sum));
                component.set("v.processedPaymentAmount", parseFloat(sum));
                component.set("v.isExecuting", false);
                component.set("v.showPayment", true);
            }
        }, function(response, message){
            component.set("v.isExecuting", false);
            self.showToast("error", 'Unable to initialize payment methods', message);
        });
    },    
   /*
    *   Callout to Apex Lightning Controller
    */  
    callout: function(component, name, params, success, failure) {   
        var action = component.get('c.' + name);
        var toastErrorHandler = component.find('toastErrorHandler');
        if (params) {
            action.setParams(params);
        }
        action.setCallback(this, function(response){
            toastErrorHandler.handleResponse(response, success, failure);   
        });        
        action.setBackground();
        $A.enqueueAction(action);
    },
   /*
    *   Display the error message 
    */
    showToast : function(type, title, message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            type: type,
            title: title,
            message: message,
        });
        toastEvent.fire();
    },
    cancelDialogClearFields : function(cmp){
        var pAccId = cmp.get('v.guestId');
        var action = cmp.get("c.clearOpptyFields");
        action.setParams({personAccId : pAccId}); 
        action.setCallback(this, function(response) {
            toastErrorHandler.handleResponse(
                response,
                function(response){
                    if (success) {
                        success.call(this);
                    }
                },
                function(response, message){ // report failure
                    self.toastMessage("error", "ERROR : ", message);
                    if (failure) {
                        failure.call(this);
                    }                     
                }
            )
        });
        $A.enqueueAction(action);
    },
})