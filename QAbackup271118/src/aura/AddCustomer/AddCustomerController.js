({
    doInit: function(component, event, helper) {
        var recId = component.get("v.recordId");
        if (recId) {
            component.set("v.modalContext", "Edit");
	        component.find('forceEditRecordCustomer').reloadRecord(true);
        }
    }, 
    saveRecords : function(component, event, helper) {

		helper.clearMsg(component);

        var newCustomer = component.get("v.newCustomer");
        var newShipping = component.get("v.newShipping");
        var newBilling = component.get("v.newBilling");
        var title = component.get("v.title");
        var body = component.get("v.body");
        var useShipping = component.get("v.useShipping");
       
        if (useShipping) {
        	newBilling = null;
        } else {
            // if address has no fields, make object null
            newBilling = helper.makeAddrNull(newBilling);
        }
        // if address has no fields, make object null
        newShipping = helper.makeAddrNull(newShipping);

        var isValid = helper.customerIsValid(newCustomer, newShipping, newBilling, title, body, component, helper);
                
        if (isValid) {
            component.set("v.isExecuting", true);
            var noteString = null; // default null 
            if (((title != null)&&(title != '')) && 
                ((body != null)&&(body != ''))) 
            {
                var noteObj = {
                    id: null,
                    title: title, 
                    body: body
                };    
    	
                var noteString = JSON.stringify(noteObj); 
            } 
            
            var mode = component.get("v.modalContext");
            if (mode == 'New') {
                helper.createCustomer(component, newCustomer, newShipping, newBilling, noteString, function(response){
                    helper.navigateTo( component, response.getReturnValue());
                },
                function(response, message){
                    component.set("v.isExecuting", false);
                    helper.showToast("error", 'Customer Creation Error', component, message);
                });   
            } else {
                helper.updateCustomer(component, newCustomer, noteString, function(response){
                    var inConsole = component.get("v.inSvcConsole");
                    if (!inConsole) {
                        component.getEvent("NotifyParentCloseModal").fire();
                    } else {
                        helper.navigateTo( component, response.getReturnValue());
                    }
                },
                function(response, message){
                    component.set("v.isExecuting", false);
                    helper.showToast("error", 'Customer Update Error', component, message);
                });   
            }
        }

	}, 

    cancelDialog : function(component, event, helper) {
        component.set("v.isExecuting", true);
        var inConsole = component.get("v.inSvcConsole");
        if (!inConsole) {
            component.getEvent("NotifyParentCloseModal").fire();
        } else {
            window.history.go(-1);
        }
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
    },
    // EDQ added ------------- Handler for second address --------------
    handleOtherSearchChange : function(component, event, helper) {
        var settings = helper.getOtherSettings();
        helper.handleSearchChange(component, event, settings);
        helper.handleValidationStatus(component, settings);
    },
    // EDQ event listener
    handleOtherSuggestionNavigation :  function(component, event, helper) {
        var settings = helper.getOtherSettings();
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
    onOtherSuggestionKeyUp : function(component, event, helper) {
        var settings = helper.getOtherSettings();
        helper.onSuggestionKeyUp(component, event, settings);
    },
    // EDQ event listener
    handleOtherResultSelect: function(component, event, helper) {
        var settings = helper.getOtherSettings()
        helper.handleResultSelect(component, event, settings);
    },
    // EDQ event listener
    onOtherAddressChanged : function(component, event, helper) {
        var settings = helper.getOtherSettings();
        helper.handleValidationStatus(component, settings);
    },
    // EDQ event listener
    onOtherElementFocusedOut : function (component, event, helper) {
        var settings = helper.getOtherSettings();

        var useHasNotSelectedASuggestion = helper.isNull(event.relatedTarget) || event.relatedTarget.id.indexOf(settings.suggestionIndexClassPrefix) === -1;
        if (useHasNotSelectedASuggestion) {
            helper.hideAndRemoveSuggestions(component, settings);
        }
    }
})