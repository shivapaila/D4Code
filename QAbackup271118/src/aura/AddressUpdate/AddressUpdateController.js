({

    doInit: function (component, event, helper) {
        var actiondata = component.get("c.fetchAddress");
        actiondata.setParams({"AddressId": component.get("v.recordId")});
        actiondata.setCallback(this, function (response) {
            var state = response.getState();
            console.log("state=" + state)
            if (state === "SUCCESS") {
                var responseAddressRecord = response.getReturnValue();
                component.set("v.AddressObj", responseAddressRecord);

            } else if (state === "INCOMPLETE") {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "OFFLINE!",
                    "message": "You are in offline."
                });
                toastEvent.fire();
            } else if (state === "ERROR") {
                //Error message display logic.
                var errors = response.getError();
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "ERROR!",
                    "message": errors[0].message
                });
                toastEvent.fire();
            } else {
                //Unknown message display logic.
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "UNKOWN!",
                    "message": "Unknown error."
                });
                toastEvent.fire();
            }
        });

        $A.enqueueAction(actiondata);
    },

    doSave: function (component, event, helper) {
        var action = component.get("c.updateAddress");
        action.setParams({
            "Address": component.get("v.AddressObj")

        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "Address record has been updated successfully."
                });
                toastEvent.fire();
                window.location = "/" + component.get("v.recordId");
                var workspaceAPI = component.find("workspace");
                workspaceAPI.getFocusedTabInfo().then(function (response) {
                    var focusedTabId = response.tabId;
                    workspaceAPI.closeTab({tabId: focusedTabId});
                })
                    .catch(function (error) {
                        console.log(error);
                    });

            } else if (state === "INCOMPLETE") {
                //Offline message display logic.
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "OFFLINE!",
                    "message": "You are in offline."
                });
                toastEvent.fire();
            } else if (state === "ERROR") {

                var errors = response.getError();
                if (errors && Array.isArray(errors) && errors.length > 0) {
                    message = errors[0].message;
                }
                // Display the message
                console.error(message);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "ERROR!",
                    "message": errors[0].message
                });
                toastEvent.fire();
            } else {

                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "UNKOWN!",
                    "message": "Unknown error."
                });
                toastEvent.fire();
            }
        });

        $A.enqueueAction(action);

    },

    doCancel: function (component, event, helper) {
        var cmpTargetForEdit = component.find('modalIdForUpdateAddress');
        var cmpBackDropForEdit = component.find('backdropIdForEditAddress');
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
    // EDQ added Validation logic
    handleSearchChange : function(component, event, helper) { 
        var settings = helper.getSettings();
        helper.handleSearchChange(component, event, settings);
        helper.handleValidationStatus(component, settings);
    },
    // EDQ added Validation logic
    handleSuggestionNavigation :  function(component, event, helper) {
        var settings = helper.getSettings();
        var keyCode = event.which;
        if(keyCode == 13) { // Enter
            helper.acceptFirstSuggestion(component, settings);
        } else if(keyCode == 40) { //Arrow down
            helper.selectNextSuggestion(component, null, settings);
        } else if(keyCode == 38) { //Arrow up
            helper.hideAndRemoveSuggestions(component, settings);
        }
    },
    // EDQ event listener
    onSuggestionKeyUp : function(component, event, helper) {
        var settings = helper.getSettings();
        helper.onSuggestionKeyUp(component, event, settings);
    },
    // EDQ event listener
    handleResultSelect : function(component, event, helper) {
        var settings = helper.getSettings();
        helper.handleResultSelect(component, event, settings);
    },
    // EDQ event listener
    onAddressChanged : function(component, event, helper) {
        var settings = helper.getSettings();
        helper.handleValidationStatus(component, settings);
    },
    // EDQ event listener
    onElementFocusedOut : function (component, event, helper) {
        var settings = helper.getSettings();

        var useHasNotSelectedASuggestion = helper.isNull(event.relatedTarget) || event.relatedTarget.id.indexOf(settings.suggestionIndexClassPrefix) === -1;
        if (useHasNotSelectedASuggestion) {
            helper.hideAndRemoveSuggestions(component, settings);
        }
    }
})