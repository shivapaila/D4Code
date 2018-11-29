({
    doInit : function(component, event, helper) {
        helper.initDate(component);        
        component.set("v.prevSelectedPaymentOptions", component.get("v.currSelectedPaymentOptions"));
    },
    
    handlePaymentOptionsChange : function(component, event, helper){
        var currSelectedPaymentOptions = component.get("v.currSelectedPaymentOptions");
        var prevSelectedPaymentOptions = component.get("v.prevSelectedPaymentOptions");
        var addPaymentMethod = false;
        var removePaymentMethod = false;
        var selectedPaymentType = null;

        if (prevSelectedPaymentOptions.length > currSelectedPaymentOptions.length){
            removePaymentMethod = true;
        } else if (prevSelectedPaymentOptions.length < currSelectedPaymentOptions.length){
            addPaymentMethod = true;
        }
        if (addPaymentMethod){
            for (var i=0; i < currSelectedPaymentOptions.length; i++){
                var currPaymentType = currSelectedPaymentOptions[i];
                if (prevSelectedPaymentOptions.indexOf(currPaymentType) == -1){
                    selectedPaymentType = currPaymentType;
                }
            }
        } else if (removePaymentMethod){
            for (var i=0; i < prevSelectedPaymentOptions.length; i++){
                var prevPaymentType = prevSelectedPaymentOptions[i];
                if (currSelectedPaymentOptions.indexOf(prevPaymentType) == -1){
                    selectedPaymentType = prevPaymentType;
                }
            }
        }

        if (addPaymentMethod){
            helper.addPaymentMethod(component, selectedPaymentType);
        } else if (removePaymentMethod){
            helper.removePaymentMethod(component, selectedPaymentType);
            // DEF-0898 - update amount after an incomplete payment is removed
            var updateAmountAction = component.get("c.updateAmountApplied");
            $A.enqueueAction(updateAmountAction);
        }

        if($A.util.isEmpty(currSelectedPaymentOptions)){
            helper.toastMessage("error", '', 'Please select a payment method');
        }
        component.set("v.prevSelectedPaymentOptions", component.get("v.currSelectedPaymentOptions"));
    },    
    
    checkAmount : function(component, event, helper){
        var targetAmount = component.get("v.targetAmount");
        var existingPMs = component.get("v.paymentMethods");
        var sum = 0;
        for(var i in existingPMs){
            var pmWrapper = existingPMs[i];
            var pm = pmWrapper.paymentTrans;        
            if(!$A.util.isEmpty(pm.Payment_Amount__c)){
                if(pm.Payment_Type__c === 'Financing' && ($A.util.isEmpty(pmWrapper.FINnum))){
                    helper.toastMessage("error","","Please input Financing Number.");
                }else if(pm.Payment_Amount__c <= 0){
                    helper.toastMessage("error","","Please input valid amount.");
                }else{
                    sum += pm.Payment_Amount__c;
                    // send completed payment information up to parent component
                }
            }
        }
        component.set("v.totalAmount",sum);
        if(sum > targetAmount){
            helper.toastMessage("error","","The amount exceed the total amount.");
        }
    },
    
    processPayment : function(component, event, helper){
        var selectedItem = event.currentTarget;
        var idx = selectedItem.dataset.record;
        var paymentInfo = component.get("v.paymentMethods")[idx];

        if (helper.isPmtValid(component,paymentInfo,helper)){
            helper.processPayment(component,paymentInfo,helper);                  
        }
    }, 
    addFinancePayment : function(component, event, helper){
        var selectedItem = event.currentTarget;
        var idx = selectedItem.dataset.record;
        var paymentInfo = component.get("v.paymentMethods")[idx];
        helper.addPaymentMethod(component, 'Financing');                  
    },
    addCardPayment : function(component, event, helper){
        var selectedItem = event.currentTarget;
        var idx = selectedItem.dataset.record;
        var paymentInfo = component.get("v.paymentMethods")[idx];
        helper.addPaymentMethod(component, 'Credit/Debit Card');                  
    },      
    updateCash: function(component, event, helper){
        var selectedItem = event.currentTarget;
        var idx = selectedItem.dataset.record;
        var paymentInfo = component.get("v.paymentMethods")[idx];
        helper.updatePayment(component,paymentInfo,helper); 
    }, 
    displayTermOptions : function (component, event, helper) {
        var selectedItem = event.currentTarget;
        var idx = selectedItem.dataset.record;
        var paymentInfo = component.get("v.paymentMethods")[idx];
        
        if (helper.isPmtValid(component,paymentInfo,helper)){
            component.set("v.selectedItem", idx);
            helper.displayTerms(component, paymentInfo, helper);
        }
    },
    
    closeTerms : function (component, event, helper) {
        component.set("v.showTerms", false);
        var backdrop = component.find("backdropContainer");
        $A.util.removeClass(backdrop, 'slds-backdrop--open');
        $A.util.addClass(backdrop, 'slds-modal-backdrop--close');
        // update the payment in the list
        var idx = component.get("v.selectedItem"); 
        var payments = component.get("v.paymentMethods");
        payments[idx] = component.get("v.pmtToDisplayTerms");
        component.set("v.paymentMethods", payments);
    } ,
    ApplyAmount :function (component, event, helper) {
        var isChecked = event.getSource().get("v.checked");
        var idx = event.getSource().get("v.name").split('-')[1];
        var paymentInfo = component.get("v.paymentMethods")[idx];
        if(isChecked){
            paymentInfo.paymentTrans.Payment_Amount__c  = component.get("v.targetAmount");  
            var existingPMs = component.get("v.paymentMethods");  
            existingPMs[idx] = paymentInfo;
            component.set("v.paymentMethods",existingPMs);
        }
    },

    addAnotherPaymentEvtHandler : function(component, event, helper) {
        helper.addPaymentMethod(component, event.getParam('paymentType'));
    },

    updateAmountApplied : function(component, event, helper) {
        var targetAmount = component.get("v.targetAmount");
        var existingPMs = component.get("v.paymentMethods");
        var sum = 0;
        for(var i=0; i<existingPMs.length; i++){
            var pmWrapper = existingPMs[i];
            var pm = pmWrapper.paymentTrans;
            if(!$A.util.isEmpty(pm.Payment_Amount__c)){
                // DEF-809 fix
                //sum += pm.Payment_Amount__c;
                sum = new Big(sum).plus(pm.Payment_Amount__c);
            }
        }
        // DEF-809 fix
        component.set("v.totalAmount",parseFloat(sum));
        if(sum > targetAmount){
            helper.toastMessage("error","","The amount exceed the total amount.");
        }
    }
})