({
    initDate : function(component){
        var yearList = [];
        var monthList = [{"value":"01", "label": "01 - January"}, 
                         {"value":"02", "label": "02 - February"}, 
                         {"value":"03", "label": "03 - March"},
                         {"value":"04", "label": "04 - April"},
                         {"value":"05", "label": "05 - May"},
                         {"value":"06", "label": "06 - June"},
                         {"value":"07", "label": "07 - July"},
                         {"value":"08", "label": "08 - August"},
                         {"value":"09", "label": "09 - September"},
                         {"value":"10", "label": "10 - October"},
                         {"value":"11", "label": "11 - November"},
                         {"value":"12", "label": "12 - December"}];
        var currentYear = (new Date()).getFullYear();
        
        var i=0;
        for(;i<21;i++){
            var opt = {"value":(currentYear+i) %100, "label": currentYear+i};
            yearList.push(opt);
        }
        component.set("v.yearList",yearList);        
        component.set("v.monthList",monthList);
        
        var payOpts =[];
        var actionLoadPMs = component.get("c.getPaymentOptions");
        actionLoadPMs.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
				var firstRun = true;
                for(var key in result){
                    if( result[key].TenderCodeDescription__c != 'DO NOT USE' &&
                        result[key].TenderCodeDescription__c != 'Cash')
                        if(firstRun){
                            payOpts.push({"value":key, "label": result[key].TenderCodeDescription__c, "selected":true});
                            firstRun = false;    
                        }else{
                            payOpts.push({"value":key, "label": result[key].TenderCodeDescription__c, "selected":false});    
                        }
                }
                component.set("v.payOptions",payOpts);
            }
        });
        $A.enqueueAction(actionLoadPMs);
    },
    
    addPaymentMethod : function(component, selectedPaymentType) {
        var existingPMs = component.get("v.paymentMethods");
        var newPM = {"SObjectType":"Cart_Payment_Transaction__c", "Payment_Type__c" : selectedPaymentType}
        var payTerminals = component.get("v.payTerminalOptions");
        var lstpayTerminals =[];
        for(var i in payTerminals){
            lstpayTerminals.push(payTerminals[i].value);
        }
        var newPMWrapper = (selectedPaymentType === 'Credit/Debit Card' || selectedPaymentType == 'Financing')
                            ?   {"Object":"PaymentMethodWrapper", "paymentTrans" : newPM, "paymentTerminals":lstpayTerminals}
                            :   {"Object":"PaymentMethodWrapper", "paymentTrans" : newPM}
        existingPMs.push(newPMWrapper);
        component.set("v.paymentMethods",existingPMs);        
    },

    removePaymentMethod : function(component, selectedPaymentType) {
        try {
            var paymentMethods = component.get("v.paymentMethods");
            var updatePaymentMethods = [];
            for (var i=0; i < paymentMethods.length; i++){
                // DEF-0898 - added paymentTrans Id check so any completed payment will not be removed
                if(paymentMethods[i] && paymentMethods[i].paymentTrans
                    && (paymentMethods[i].paymentTrans.Id != null || paymentMethods[i].paymentTrans.Payment_Type__c !== selectedPaymentType)){
                    updatePaymentMethods.push(JSON.parse(JSON.stringify(paymentMethods[i])));
                }
            }
            component.set("v.paymentMethods", updatePaymentMethods);
        } catch (e){
        }
    },

    toastMessage : function(type,title,message){
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            type: type,
            title: title, 
            message: message,
        });
        toastEvent.fire();
    },

    displayTerms : function(component,paymentInfo,helper){
        component.set("v.pmtToDisplayTerms", paymentInfo);
        component.set("v.showTerms", true);
        var backdrop = component.find("backdropContainer");
        $A.util.removeClass(backdrop, 'slds-backdrop--open');
        $A.util.addClass(backdrop, 'slds-modal-backdrop--close');
    },
    
    isPmtValid : function(component,paymentInfo,helper){
        var goodToGo = true;
        
        // if CC, validate CC inputs
        // FIXME - type value should be a var
        if (paymentInfo.paymentTrans.Payment_Type__c === "Credit/Debit Card") {
            /*if($A.util.isEmpty(paymentInfo.CCnum)){
                helper.toastMessage("error","","Please input valid card number.");
                goodToGo = false;
            }
            if($A.util.isEmpty(paymentInfo.CCcvv)){
                helper.toastMessage("error","","Please input valid CVV number.");
                goodToGo = false;
            }  
            var currentDate = new Date();
            var currentYear = currentDate.getFullYear();
            var currentMonth = currentDate.getMonth() + 1;
            var expYear  = paymentInfo.CCexpYear;
            var expMonth = parseInt(paymentInfo.CCexpMonth,10);
            if(expYear === currentYear && expMonth <= currentMonth){
                helper.toastMessage("error","","Please select valid Expiration Date.");
                goodToGo = false;
            }*/
        }

        // if financing, validate inputs)
        if (paymentInfo.paymentTrans.Payment_Type__c === "Financing") {
            if($A.util.isEmpty(paymentInfo.FINnum)){
                helper.toastMessage("error","","Please input valid financing number.");
                goodToGo = false;
            }    
        }
        
        if(paymentInfo.Payment_Amount__c <= 0){
            helper.toastMessage("error","","Please input valid amount.");
            goodToGo = false;
        }
        if(component.get("v.totalAmount") > component.get("v.targetAmount")){
            helper.toastMessage("error","","The amount exceed the total amount.");
            goodToGo = false;
        }
        
        return goodToGo; 
    },
    addCardPayment : function(cmp, event, helper){
        var existingPMs = component.get("v.paymentMethods");
        var newPM = {"SObjectType":"Cart_Payment_Transaction__c", "Payment_Type__c" : "Credit/Debit Card"}
        var newPMWrapper = {"Object":"PaymentMethodWrapper", "paymentTrans" : newPM,
                             "paymentTerminals":component.get("v.payTerminalOptions")};
        existingPMs.push(newPMWrapper);
        component.set("v.paymentMethods",existingPMs);
    },
    processPayment : function(component,paymentInfo,helper){
        var toastErrorHandler = component.find('toastErrorHandler');
        var actionPP = component.get("c.addPayment");
        actionPP.setParams({
            "personAccId"   : component.get("v.guestId"),
            "pmtInfoString" : JSON.stringify(paymentInfo)
        });
        actionPP.setCallback(this, function(response){
            toastErrorHandler.handleResponse(
                response, // handle failure
                function(response){ // navigate to contact record                
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        var paymentInfo = response.getReturnValue();
                        if(paymentInfo.paymentAPIStatus == 'success'){
                            helper.toastMessage("success","","Payment has been applied. Thank you.");
                        }else{
                            helper.toastMessage("error","ERROR",paymentInfo.paymentAPIStatus);
                        }
                    }    
                    component.getEvent("NotifyParentPmtAdded").fire();
                },
                function(response, message){ // report failure
                    helper.toastMessage("error", "ERROR : " + message);
                }
            )
        });
        $A.enqueueAction(actionPP);                       
    },
    updatePayment : function(component,paymentInfo,helper){
        var toastErrorHandler = component.find('toastErrorHandler');

        var actionPP = component.get("c.updatePayment");
        actionPP.setParams({
            "pmtInfoString" : JSON.stringify(paymentInfo)
        });
        actionPP.setCallback(this, function(response){
            toastErrorHandler.handleResponse(
                response, // handle failure
                function(response){ // navigate to contact record                    
                    helper.toastMessage("success","","Payment has been applied. Thank you.");
                    component.getEvent("NotifyParentPmtAdded").fire();
                },
                function(response, message){ // report failure
                    helper.toastMessage("error", "ERROR : " + message);
                }
            )
        });
        $A.enqueueAction(actionPP);                       
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
})