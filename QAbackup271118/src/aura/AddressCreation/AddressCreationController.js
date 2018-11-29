({
    doInit: function (component, event, helper) {
        var recordid = component.get("v.recordId");
        var actiondata;
        //alert(recordid);
        if(recordid != null && recordid != '')
        {
          //alert(recordid); 
          component.set("v.isEdit",true); 
            actiondata = component.get("c.getAddress");
            //alert('recordid--1----'+recordid);  
			actiondata.setParams({"AddressId": recordid});
        
            actiondata.setCallback(this, function (response) {
                var resState = response.getState();
                //alert("resState=" + resState)
                if (resState === "SUCCESS") {
                    var responseAddressRecord = response.getReturnValue();
                    //alert('test-----'+responseAddressRecord);
                    component.set("v.newAddress", responseAddressRecord);    
                }                     
                 else if (resState === "ERROR") {
                    //Error message display logic.
                    var errors = response.getError();
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "ERROR!",
                        "message": errors[0].message
                    });
                    toastEvent.fire();
                } 
            });
        
		
        	$A.enqueueAction(actiondata);
        }
    },


    doCancel: function (component, event, helper) {
        var cmpTargetForEdit = component.find('modalIdForAddressCreation');
        var cmpBackDropForEdit = component.find('backdropIdForCreationAddress');
        $A.util.removeClass(cmpBackDropForEdit, 'slds-backdrop--open');
        $A.util.removeClass(cmpTargetForEdit, 'slds-fade-in-open');
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function (response) {
            var focusedTabId = response.tabId;
            workspaceAPI.closeTab({tabId: focusedTabId});
        })
            .catch(function (error) {
                console.log(error);
            });

    },

    clickCreate: function (component, event, helper) {
        /*var allValid = component.find('formFieldToValidate').reduce(function (validSoFar, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            return validSoFar && !inputCmp.get('v.validity').valueMissing;
        }, true);*/
        var allValid = true;
        //alert('test');
        if((component.get("v.newAddress.Address_Line_1__c") ==  null || component.get("v.newAddress.Address_Line_1__c") == '')||
           (component.get("v.newAddress.Address_Line_2__c") ==  null || component.get("v.newAddress.Address_Line_2__c") == '')||
           (component.get("v.newAddress.Address_Type__c") ==  null || component.get("v.newAddress.Address_Type__c") == '') ||
           (component.get("v.newAddress.Address_Validation_Status__c") ==  null || component.get("v.newAddress.Address_Validation_Status__c") == '')||
           (component.get("v.newAddress.City__c") ==  null || component.get("v.newAddress.City__c") == '') ||
           (component.get("v.newAddress.StatePL__c") ==  null || component.get("v.newAddress.StatePL__c") == '')||
           (component.get("v.newAddress.Zip_Code__c") ==  null || component.get("v.newAddress.Zip_Code__c") == '') || 
           (component.get("v.newAddress.Country__c") ==  null || component.get("v.newAddress.Country__c") ==  '')
          )
            /* (component.get("v.newAddress.Geocode__Latitude__s") ==  null || component.get("v.newAddress.Geocode__Latitude__s") ==  '')|| 
            (component.get("v.newAddress.Geocode__Longitude__s") ==  null || component.get("v.newAddress.Geocode__Longitude__s") ==  '') */
            
        {
            allValid = false;
        }
        //alert('recordid---1--'+recordid);
        //alert('allValid------'+allValid);
        if (allValid) {
            var newAddress = component.get("v.newAddress");
            console.log("Create Address: " + JSON.stringify(newAddress));
            var recordid = component.get("v.recordId");
            //alert('recordid---3--'+recordid);
            //alert('newAddress-----'+component.get("v.newAddress.AccountId__c"));
            
            var actiondata = component.get("c.saveAddress");
            
            actiondata.setParams({
                "Address": newAddress
                
            });
            actiondata.setCallback(this, function (response) {
                var resState = response.getState();
                //alert('resState---- '+ resState);
                if (resState === "SUCCESS") {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Success!",
                        "type": "success",
                        "message": "Address record has been successfully added."
                        
                    });
                    toastEvent.fire();
                    
                    var workspaceAPI = component.find("workspace");
                    workspaceAPI.getFocusedTabInfo().then(function (response) {
                        var focusedTabId = response.tabId;
                        workspaceAPI.closeTab({tabId: focusedTabId});
                    })
                    .catch(function (error) {
                        console.log(error);
                    });
                    var navEvt = $A.get("e.force:navigateToSObject");
                    navEvt.setParams({
                        "recordId": component.get("v.newAddress.AccountId__c"),
                        "slideDevName": "related"
                    });
                    navEvt.fire();
                }
                else{
                    var toastParams = {
                        title: "Error",
                        message: "Unknown error", // Default error message
                        type: "error"
                    };
                    var errors=response.getError();
                    if (errors && Array.isArray(errors) && errors.length > 0) {
                        toastParams.message = 'Address Already Exists For This Customer';
                    }
                    // Fire error toast
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams(toastParams);
                    toastEvent.fire();
                } 
            });
            
            $A.enqueueAction(actiondata);
        }
        else {
            alert('Please enter the values in all mandatory fields.');
        }
    },
    // EDQ added Validation logic
    handleSearchChange: function (component, event, helper) {
        var settings = helper.getSettings();        
        helper.handleSearchChange(component, event, settings);
        helper.handleValidationStatus(component, settings);       
    },
    // EDQ added Validation logic
    handleSuggestionNavigation: function (component, event, helper) {
        var settings = helper.getSettings();
        var keyCode = event.which;
        if (keyCode == 13) { // Enter
            helper.acceptFirstSuggestion(component, settings);
        } else if (keyCode == 40) { //Arrow down
            helper.selectNextSuggestion(component, null, settings);
        } else if (keyCode == 38) { //Arrow up
            helper.hideAndRemoveSuggestions(component, settings);
        }
    },
    // EDQ event listener
    onSuggestionKeyUp: function (component, event, helper) {
        var settings = helper.getSettings();
        helper.onSuggestionKeyUp(component, event, settings);
    },
    // EDQ event listener
    handleResultSelect: function (component, event, helper) {
        var settings = helper.getSettings();
        helper.handleResultSelect(component, event, settings);
    },
    // EDQ event listener
    onAddressChanged: function (component, event, helper) {
        var settings = helper.getSettings();
        helper.handleValidationStatus(component, settings);
    },
    // EDQ event listener
    onElementFocusedOut: function (component, event, helper) {
        var settings = helper.getSettings();

        var useHasNotSelectedASuggestion = helper.isNull(event.relatedTarget) || event.relatedTarget.id.indexOf(settings.suggestionIndexClassPrefix) === -1;
        if (useHasNotSelectedASuggestion) {
            helper.hideAndRemoveSuggestions(component, settings);
        }
    }
})