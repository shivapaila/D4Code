({
    doInit: function(component, event, helper) {
        helper.loadAddresses(component, helper);
    }, 
    handleShowEdit: function(component, event, helper) {
        component.set("v.showModal", true);
        var overlay = component.find('overlay');
        $A.util.addClass(overlay, 'slds-backdrop--open'); 
    }, 
    closeModal: function(component, event, helper) {
        component.set("v.showModal", false);
        var overlay = component.find('overlay');
        $A.util.removeClass(overlay, 'slds-backdrop--open');
        component.find('forceRecordContact').reloadRecord(true);
	},
    toggleAddresses: function(component, event, helper) {
        var end = component.get("v.end");
        component.set("v.end", end==2? 5 : 2);
        var addrExpand = component.get("v.addrExpand");
        component.set("v.addrExpand", addrExpand == 'view more addresses' ? 'show fewer addresses' : 'view more addresses');
    },
    toggleAddrEdit: function(component, event, helper) {
        component.set("v.open", !component.get("v.open"));
    },
    loadAddr: function(component, event, helper) {
        var selectedAddr = event.currentTarget;
        var idx = selectedAddr.dataset.index;
        var addr = component.get("v.addresses")[idx];

        // Since all fields with no values are excluded from the objects returned from the back-end we need to manually
        // check if status field is missing and set it to empty be default. We do this because while changing
        // addresses if the address displayed had status value and the one you are changing it with does not have a
        // value, the status value of the first address will be used and displayed because it is not overridden (reset)
        var validationStatusField = helper.getSettings().status.fieldName;
        if (!addr.hasOwnProperty(validationStatusField)) {
            addr[validationStatusField] = '';
        }

        var isOpen = component.get("v.open");
        
        // load the selected address into the form
        component.set("v.newAddress", addr);
        
        // if the form isn't open, open it
        if (!isOpen) {
            component.set("v.open", true);
		}
    },
    cancelAddrEdit: function(component, event, helper) {
		helper.clearAddrFormFields(component);
    }, 
    saveAddr: function(component, event, helper) {
        var action = component.get("c.saveAddress");
        var address = component.get("v.newAddress");
	
		// validate
        if (!helper.isAddrValid(address, component, helper)) {
            return;
        }
        
        // add account id to address record
        var contact = component.get("v.contactRecord");
		address.AccountId__c = contact.Id;
		
        // prepare to send
        var toastErrorHandler = component.find('toastErrorHandler');
        action.setParams({ "toSave"  : address });  
        
        // send address
        action.setCallback(this, function(response) {
            toastErrorHandler.handleResponse(
                response, // handle failure
                function(response){ // report success and navigate to contact record
                    helper.showToast("success", 'Address Saved', component,
                                     "The address has been saved.");
                	// reload addresses
                	helper.loadAddresses(component, helper);
                    helper.clearAddrFormFields(component);
                }, 
                function(response, message){ // report failure
                 //   helper.showToast("error", 'Address Save Error', component,
                //                     message);
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
                
            )
        });
        $A.enqueueAction(action);        
    },
    // EDQ added Validation logic Begin
    handleSearchChange : function(component, event, helper) {
        var settings = helper.getSettings();
        helper.handleSearchChange(component, event, settings);
        helper.handleValidationStatus(component, settings);
    },
    onSuggestionKeyUp : function(component, event, helper) {
        var settings = helper.getSettings();
        helper.onSuggestionKeyUp(component, event, settings);
    },
    handleResultSelect : function(component, event, helper) {
        var settings = helper.getSettings();
        helper.handleResultSelect(component, event, settings);
    },
    onAddressChanged : function(component, event, helper) {
        var settings = helper.getSettings();
        helper.handleValidationStatus(component, settings);
    },
    onElementFocusedOut : function (component, event, helper) {
        var settings = helper.getSettings();

        var useHasNotSelectedASuggestion = helper.isNull(event.relatedTarget) || event.relatedTarget.id.indexOf(settings.suggestionIndexClassPrefix) === -1;
        if (useHasNotSelectedASuggestion) {
            helper.hideAndRemoveSuggestions(component, settings);
        }
    },
    // EDQ added Validation logic End
    makeMyGuest: function(cmp, event, helper) {
      var selectedItem = event.currentTarget; 
        var RecordId = selectedItem.dataset.record;
        var action = cmp.get("c.updateOwner");
        action.setParams({
            "Id":RecordId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            //alert('state is '+state);
            if (state === "SUCCESS") {
                // DEF-0725  reload force:recordData to refresh new data from database
                cmp.find('forceRecordContact').reloadRecord(true) 
                
                var toastEvent = $A.get("e.force:showToast");
                	toastEvent.setParams({
                    title: 'Success!',
                     type: 'success',
                    message: 'Guest has been reassigned to you'
                     });
                 toastEvent.fire();
            }
            
        });
         $A.enqueueAction(action);
    }
})