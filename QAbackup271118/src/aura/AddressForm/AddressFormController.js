({
     validateAddressForm : function(component, event, helper) {
        var addr1 = component.find('addr1').get("v.value");
        var city = component.find('city').get("v.value");
        var state = component.find('state').get("v.value");
        var postalCode = component.find('postalCode').get("v.value");
        var isErr = false;
        var reqFields = '';

          var addr1Cmp = component.find('addr1');        
        if(addr1 == undefined || addr1 == "") {
            $A.util.addClass(addr1Cmp, 'required');
            isErr = true;
            reqFields += 'Address Line 1';
        }
        else {
            $A.util.removeClass(addr1Cmp, 'required');
        }
        
        var cityCmp = component.find('city');
        if(city == undefined || city == "") {
          $A.util.addClass(cityCmp, 'required');
            isErr = true;
            reqFields += (reqFields.length > 0)? ', City' : 'City'; 
        }
        else {
            $A.util.removeClass(cityCmp, 'required');
        }
        
        var stateCmp = component.find('state');
        if(state == undefined || state == "") {
          $A.util.addClass(stateCmp, 'required');
            isErr = true;
            reqFields += (reqFields.length > 0)? ', State' : 'State';   
        }
        else {
            $A.util.removeClass(stateCmp, 'required');
        }
        
        var postalCmp = component.find('postalCode');
        if(postalCode == undefined || postalCode == "") {
          $A.util.addClass(postalCmp, 'required');
            isErr = true;
            reqFields += (reqFields.length > 0)? ', Postal Code' : 'Postal Code';
        }
        else {
            $A.util.removeClass(postalCmp, 'required');
        }
        
        if(isErr) {
            helper.showToast("Error","",component,$A.get("$Label.c.Address_Form_Mandatory_Fields_Error")+'. Enter :'+reqFields);
            var message = $A.get("$Label.c.Address_Form_Mandatory_Fields_Error")+'<br>'+reqFields;
            return message;
        }
        else {
            return 'Success';
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
    }
})