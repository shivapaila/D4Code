({
   /*
    *   Is the form entry valid?
    */  
    isValidFormEntry: function(component) {
        var allValid = true;
        // Validate the percentage input field
        if (component.find('field')){
            if ($A.util.isArray(component.find('field'))){
                allValid = component.find('field').reduce(function (validSoFar, inputCmp) {
                    inputCmp.showHelpMessageIfInvalid();
                    return validSoFar && inputCmp.get('v.validity').valid;
                }, true);                
            } else {
                allValid = component.find("field").get("v.validity").valid;
            }
        }
        // Validate the user lookup field
        if (component.find('lookupUserfield')){
            if ($A.util.isArray(component.find('lookupUserfield'))){
                allValid = allValid && 
                            component.find('lookupUserfield').reduce(function (validSoFar, inputCmp) {
                                inputCmp.set("v.requiredErrorMessage", (!$A.util.isEmpty(inputCmp.get('v.value')) ? "" : "RSA is required"));
                                return validSoFar && !$A.util.isEmpty(inputCmp.get('v.value'));
                            }, true);                
            } else {
                var inputCmp = component.find('lookupUserfield');
                inputCmp.set("v.requiredErrorMessage", (!$A.util.isEmpty(inputCmp.get('v.value')) ? "" : "RSA is required"));
                allValid = allValid && !$A.util.isEmpty(inputCmp.get('v.value'));
            }
        }
        if (!allValid) {
            this.toastMessage("error", "", "Please update the invalid form entries and try again.");
        }
        return allValid;
    },
   /*
    *   Is valid commission entry?
    *   1.  The split is allowed upto 4 times (i.e current RSA may split with 3 other RSAs)
    *   2.  The total for the split (excluding the current RSA) should not be equal to or grreater than 1
    */  
    isValidCommissionEntries: function(component) {
        var valid = true;
        var splits = this.getAdjustedCommissionEntries(component);
        var totalPercentage = 0;
        for (var i=0; i < splits.length; i++){
            totalPercentage += parseFloat(splits[i].percentage);
        }        
        if (totalPercentage > 100){
            valid = false;
            this.toastMessage("error", "", "The split should not exceed 100%. Please adjust to zero for splits to exclude.");
        }
        return valid;
    },
   /*
    *   1.  Remove the commission entry for current RSA from the commission splits array
    *   2.  If duplicate RSA, add the split percentages and adjust it to a single commission entry 
    */     
    getAdjustedCommissionEntries: function(component) {
        var splits = component.get("v.commissionSplits");
        var currentRSA = component.get("v.currentRSA");
        var adjustedSplits = [];
        var adjustedSplitsMap = {};
        for (var i=0; i < splits.length; i++){
            var rsaId = splits[i].user.Id;
            if (rsaId != currentRSA.user.Id){            // Ignore commission entry for current RSA
                if (!adjustedSplitsMap[rsaId]){     // If split entry does not exist for RSA Id key in the adjusted split map
                    adjustedSplitsMap[rsaId] = this.getCombinedCommissionEntryForRSA(component, rsaId);
                }
            }
        }
        for (var rsaIdKey in adjustedSplitsMap){
            var adjustedSplit = adjustedSplitsMap[rsaIdKey];
            // What the split entries that need to be sent to Apex controller for upsert/deletion?
            // 1.   Either the split percentage is greater than zero
            // 2.   OR the split percentage is zero and it is an existing (or saved) split entry
            if (    (adjustedSplit.percentage > 0) 
                    ||
                    ( (adjustedSplit.percentage == 0) &&  !$A.util.isUndefinedOrNull(adjustedSplit.id) ) 
                ){      
                adjustedSplits.push(adjustedSplit);
            }
        }
        return adjustedSplits;
    },
   /*
    *   1.  If duplicate RSA, add the split percentages and adjust it to a single commission entry 
    */     
    getCombinedCommissionEntryForRSA: function(component, rsaId) {
        var splits = component.get("v.commissionSplits");
        var splitForRSA = null;
        for (var i=0; i < splits.length; i++){
            if (splits[i].user.Id == rsaId){
                if ($A.util.isUndefinedOrNull(splitForRSA)){
                    splitForRSA = JSON.parse(JSON.stringify(splits[i]));
                } else {
                    splitForRSA.percentage = parseFloat(splitForRSA.percentage) + parseFloat(splits[i].percentage);
                }
            }
        }
        return splitForRSA;
    },            
   /*
    *   Retrieve the commission entries
    */  
    getCurrentRSA: function(component, success) {
        var self = this; 
        var params = {}; 
        this.callout(component, 'getCurrentRSA', params, function(response) {
            var rtnValue = response.getReturnValue();
            if(!$A.util.isEmpty(rtnValue)){
                component.set("v.currentRSA", rtnValue);
                if (success) {
                    success.call(this);
                }                
            }
        }, function(response, message){
            self.toastMessage("error", 'Unable to retrieve current RSA', message);
        });
    },    
   /*
    *   Retrieve the commission entries
    */  
    getCommissionEntries: function(component) {
        var self = this; 
        var params = {'personAccId':component.get("v.guestId")}; 
        this.callout(component, 'getCommissionEntries', params, function(response) {
            var rtnValue = response.getReturnValue();
            if(!$A.util.isEmpty(rtnValue)){
                component.set("v.commissionSplits", rtnValue);
            }
        }, function(response, message){
            self.toastMessage("error", 'Unable to retrieve commissions entries', message);
        });
    },
   /*
    *   Save the commission entries
    */    
    saveCommissionEntries: function(component, commissionEntries, success) {
        var self = this; 
        var params = {'personAccId':component.get("v.guestId"), 'commissionEntriesJSON':JSON.stringify(commissionEntries)}; 
        this.callout(component, 'saveCommissionEntries', params, function(response) {
            var rtnValue = response.getReturnValue();
            if(!$A.util.isEmpty(rtnValue)){
                component.set("v.commissionSplits", rtnValue);
                if (success) {
                    success.call(this);
                }                
            }
        }, function(response, message){
            self.toastMessage("error", 'Unable to save commissions entries', message);
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
    toastMessage : function(type, title, message){
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            type: type,
            title: title,
            message: message,
        });
        toastEvent.fire();
    }    
})