({
    customerIsValid : function(newCustomer, newShipping, newBilling, title, body, component, helper) {
        var valid = true;
        var messages = [];
        
        // CONTACT VALIDATION
        if ($A.util.isEmpty(newCustomer.FirstName))
        {
            messages.push('Please include First Name.');
            valid = false;
        }
        if ($A.util.isEmpty(newCustomer.LastName)) 
        {
            messages.push('Please include Last Name.');
            valid = false;
        }
        
        if ( ($A.util.isEmpty(newCustomer.PersonEmail)) && ($A.util.isEmpty(newCustomer.Phone)))
        {
            messages.push('Please include atleast one primary email address or Phone Number.');
            valid = false;
        }
        
      /*  if ( $A.util.isEmpty(newCustomer.Phone))
        {
            messages.push('Please include atleast one primary phone number.');
            valid=false;            
        }*/
        
        var phoneResponse; 
        if (phoneResponse = helper.isPhoneValid(newCustomer.Phone, 'Phone')) {
            messages.push(phoneResponse);
            valid = false;
        }
        if (phoneResponse = helper.isPhoneValid(newCustomer.Phone_2__pc, 'Phone 2')) {
            messages.push(phoneResponse);
            valid = false;
        }
        if (phoneResponse = helper.isPhoneValid(newCustomer.Phone_3__pc, 'Phone 3')) {
            messages.push(phoneResponse);
            valid = false;
        }
        
        if ( !$A.util.isEmpty(newShipping)) {  
            valid = helper.isAddrValid(newShipping, 'Shipping', component, helper) && valid;
        }
        
        if ( !$A.util.isEmpty(newBilling)) {
            valid = helper.isAddrValid(newBilling, 'Billing', component, helper) && valid;
        }
        
        // push out contact toasts
        if (!valid) { 
            for (let message of messages) {
                helper.showToast("error", 'Guest Form Errors', component, message);
            }
        }
        
        // NOTE VALIDATION 
        // body is empty and title is not
        if (!$A.util.isEmpty(title) && $A.util.isEmpty(body))
        {
            helper.showToast("error", 'Missing Note Body', component,
                             'Note title was set but body is empty. Please create a note.');
            valid = false;
        }
        
        // title is empty and body is not
        if ($A.util.isEmpty(title) && !$A.util.isEmpty(body))
        {
            helper.showToast("error", 'Missing Note Title', component,
                             'Note was set but title is empty. Please create a title for note.');
            valid = false;
        }
        
        
        return valid; 
    }, 
    makeAddrNull : function(addr) {
        if ($A.util.isEmpty(addr.Address_Line_1__c) && $A.util.isEmpty(addr.Address_Line_2__c) 
            && $A.util.isEmpty(addr.City__c) && $A.util.isEmpty(addr.State__c)
            && $A.util.isEmpty(addr.Zip_Code__c))  
        {
            return null;
        }
        return addr;
    }, 
    isPhoneValid : function(phoneValue, phoneType) {
        var response = null; 
        // validate phone number
        if (!$A.util.isEmpty(phoneValue)) {
            var phoneno = /^\(?([0-9]{3})\)?[-. ]?([0-9]{3})[-. ]?([0-9]{4})$/;
            if(!phoneValue.match(phoneno)) {
                response = 'Phone number (' + phoneType + ') entry is an invalid phone number. Please enter a valid 10 digit phone number';
            } 
        } 
        return response;
    },
    isAddrValid : function(addr, addrType, component, helper) {
        var valid = true;
        var messages = [];
        
        // if any address field is not empty, then we need all the required address fields
        if (!$A.util.isEmpty(addr.Address_Line_1__c) || !$A.util.isEmpty(addr.Address_Line_2__c) 
            || !$A.util.isEmpty(addr.City__c) || !$A.util.isEmpty(addr.State__c)
            || !$A.util.isEmpty(addr.Zip_Code__c)) 
        {
            if ($A.util.isEmpty(addr.Address_Line_1__c)) 
            {
                messages.push('Please include ' + addrType + ' Street Address.');
                valid = false;
            }            
            if ($A.util.isEmpty(addr.City__c)) 
            {
                messages.push('Please include ' + addrType + ' City.');
                valid = false;
            }  
            if ($A.util.isEmpty(addr.State__c))
            {
                messages.push('Please include ' + addrType + ' State.');
                valid = false;
            }  
            if ($A.util.isEmpty(addr.Zip_Code__c)) 
            {
                messages.push('Please include ' + addrType + ' Postal Code.');
                valid = false;
            }  
        }
        
        // push out address toasts
        if (!valid) { 
            for (let message of messages) {
                helper.showToast("error", addrType + ' Address Fields Missing', component, message);
            }
        }
        
        return valid;
    },
    createCustomer : function(component, newCustomer, newShipping, newBilling, noteString, success, failure) {
        var toastErrorHandler = component.find('toastErrorHandler');
        
        var action = component.get("c.createCustomerRecords");
        
        action.setParams({ "newCustomer"  : newCustomer, 
                          "newShipping" : newShipping, 
                          "newBilling"  : newBilling, 
                          "noteStr"     : noteString
                         });
        
        action.setCallback(this, function(response){
            toastErrorHandler.handleResponse(
                response, // handle failure
                function(response){ // navigate to contact record
                    if (success) {
                        success.call(this, response);
                    }
                }, 
                function(response, message){ // report failure
                    if (failure) {
                        failure.call(this, response, message);
                    }
                }
            )
        });
        
        $A.enqueueAction(action);        
    }, 
    updateCustomer : function(component, newCustomer, noteString, success, failure) {
        var toastErrorHandler = component.find('toastErrorHandler');
        
        var action = component.get("c.updateCustomerRecords");
        
        action.setParams({ "newCustomer"  : newCustomer, 
                          "noteStr"     : noteString
                         });
        
        action.setCallback(this, function(response){
            toastErrorHandler.handleResponse(
                response, // handle failure
                function(response){ // navigate to contact record
                    if (success) {
                        success.call(this, response);
                    }
                }, 
                function(response, message){ // report failure
                    if (failure) {
                        failure.call(this, response, message);
                    }
                }
            )
        });
        
        $A.enqueueAction(action);        
    }, 
    showToast : function(type, title, component, message) {
        var inConsole = component.get("v.inSvcConsole");
        if (!inConsole) { // if we're in lightning message this way
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                type: type,
                // note - leaving mode field for reference 
                //mode: 'sticky',
                title: title, 
                message: message,
            });
            toastEvent.fire();
        } else {
            component.set("v.messageType", type);
            component.set("v.message", message);
        }
    }, 
    clearMsg : function(component) {
        component.set("v.messageType", '');
        component.set("v.message", '');
    },
    navigateTo: function(component, recId) {
        var inConsole = component.get("v.inSvcConsole");
        
        //add to add functionality on creating a customer DEF-0191
        if(component.get('v.addNewCustomerCart') == true)
        {
            //event to notify Parent to add to cart
            var eventComponent = component.getEvent("NotifyParentAddToCart");
            eventComponent.setParams({"notifyParam": recId,  "notifyParam1": 'AddCustomer' });
            eventComponent.fire();

        }
        else
        {
            if (!inConsole) { // if we're in lightning navigate this way
                var appEvent = $A.get("e.c:NavigateToWrapperComponentAppEvent");
                appEvent.setParams({
                    "targetCmpName" : 'CustomerDetailViewWrapperCmp',
                    "targetCmpParameters" : { "recordId": recId }
                });
                appEvent.fire();
            } else {
                sforce.one.navigateToSObject(recId);
            }
        }
    },
    // EDQ added Validation logic
    getSettings : function() {
        return {
            // Default country will be taken if auraId for the country is not specified
            defaultCountry : 'usa',
            // Country's auraId and the field name of the object containing the value
            country : {
                auraId : null,
                fieldName : null
            },
            // Street's auraId and the field name of the object containing the value
            street : {
                auraId : 'shippingstreet',
                fieldName : 'Address_Line_1__c'
            },
            // Second street's auraId and the field name of the object containing the value
            apartmentNumber : {
                auraId : 'shippingapt',
                fieldName : 'Address_Line_2__c'
            },
            // City's auraId and the field name of the object containing the value
            city : {
                auraId : 'shippingcity',
                fieldName : 'City__c'
            },
            // State's auraId and the field name of the object containing the value
            state : {
                auraId : 'shippingstate',
                fieldName : 'State__c'
            },
            // Zip's auraId and the field name of the object containing the value
            zip : {
                auraId : 'shippingpostalcode',
                fieldName : 'Zip_Code__c'
            },
            // Validation status's auraId and the field name of the object containing the value
            status : {
                auraId : 'shippingAddrValStatus',
                fieldName : 'Address_Validation_Status__c'
            },

            // Validation response mapping. The keys of this object represent the keys returned by the validation
            // service's response. If the value of a key in this mapping is null, the result from the validation will
            // not be reflected. If the value of a key in this mapping is provided it must reflect a key from the above
            // settings (country, street, city, etc.) and then the value from the validation response will be reflected
            addressMapping : {
                "country" : null,
                "addressLine1" : 'street',
                "subBuilding1" : 'apartmentNumber',
                "locality" : 'city',
                "province" : 'state',
                "postalCode" : 'zip',
            },
            // Id of the spinner
            loaderId : 'loader',

            // The property name of the object containing the address
            addressObjectPropertyName : 'newShipping',
            // The property name of the object containing the address snapshot
            addressObjectSnapshotPropertyName : 'ShippingAddressObjectSnapshot',

            // Apex method name for address search
            searchAddressActionName : 'SearchAddress',
            // Apex method name for detailed address search
            formatAddressActionName : 'FormatAddress',

            // The property name of the hasSuggestions boolean
            hasSuggestionsVariableName : 'hasSuggestions',
            // The property name of the object containing the suggestions
            suggestionsVariableName : 'suggestions',
            // Whether would we display errors or not
            displayErrors: false,
            // The property name of the object containing the timeout identifier's value
            timeoutIdentifierVariableName: 'timeoutIdentifier',

            // Partial value of the suggestion index html id
            suggestionIndexClassPrefix : '-suggestion-index-',
            MaxSuggestionsToTake : 10,

            // Value of the status if validation is successful
            verifiedByServiceStatus : 'Verified by Experian!',
            // Value of the status if validation has passed but the user changed some value
            userPreferredStatus : 'User Preferred!',
            // Value of the status if validation has failed
            unknownStatus : 'Unknown!'
        };
    },
    // EDQ added Validation logic
    getOtherSettings : function() {
        return {
            // Default country will be taken if auraId for the country is not specified
            defaultCountry : 'usa',
            // Country's auraId and the field name of the object containing the value
            country : {
                auraId : null,
                fieldName : null
            },
            // Street's auraId and the field name of the object containing the value
            street : {
                auraId : 'billingstreet',
                fieldName : 'Address_Line_1__c'
            },
            // Second street's auraId and the field name of the object containing the value
            apartmentNumber : {
                auraId : 'billingapt',
                fieldName : 'Address_Line_2__c'
            },
            // City's auraId and the field name of the object containing the value
            city : {
                auraId : 'billingcity',
                fieldName : 'City__c'
            },
            // State's auraId and the field name of the object containing the value
            state : {
                auraId : 'billingstate',
                fieldName : 'State__c'
            },
            // Zip's auraId and the field name of the object containing the value
            zip : {
                auraId : 'billingpostalcode',
                fieldName : 'Zip_Code__c'
            },
            // Validation status's auraId and the field name of the object containing the value
            status : {
                auraId : 'billingAddrValStatus',
                fieldName : 'Address_Validation_Status__c'
            },

            // Validation response mapping. The keys of this object represent the keys returned by the validation
            // service's response. If the value of a key in this mapping is null, the result from the validation will
            // not be reflected. If the value of a key in this mapping is provided it must reflect a key from the above
            // settings (country, street, city, etc.) and then the value from the validation response will be reflected
            addressMapping : {
                "country" : null,
                "addressLine1" : 'street',
                "subBuilding1" : 'apartmentNumber',
                "locality" : 'city',
                "province" : 'state',
                "postalCode" : 'zip',
            },
            // Id of the spinner
            loaderId : 'otherLoader',

            // The property name of the object containing the address
            addressObjectPropertyName : 'newBilling',
            // The property name of the object containing the address snapshot
            addressObjectSnapshotPropertyName : 'BillingAddressObjectSnapshot',

            // Apex method name for address search
            searchAddressActionName : 'SearchAddress',
            // Apex method name for detailed address search
            formatAddressActionName : 'FormatAddress',

            // The property name of the hasSuggestions boolean
            hasSuggestionsVariableName : 'hasOtherSuggestions',
            // The property name of the object containing the suggestions
            suggestionsVariableName : 'otherSuggestions',
            // Whether would we display errors or not
            displayErrors: false,
            // The property name of the object containing the timeout identifier's value
            timeoutIdentifierVariableName: 'timeoutIdentifier',

            // Partial value of the suggestion index html id
            suggestionIndexClassPrefix : '-other-suggestion-index-',
            MaxSuggestionsToTake : 10,

            // Value of the status if validation is successful
            verifiedByServiceStatus : 'Verified by Experian!',
            // Value of the status if validation has passed but the user changed some value
            userPreferredStatus : 'User Preferred!',
            // Value of the status if validation has failed
            unknownStatus : 'Unknown!'
        };
    },
    // EDQ added Validation logic
    handleSearchChange : function(component, event, settings) {
        var countryValue = this.getCountry(component, settings);

        var keyCode = event.which;
        if(keyCode == 13) { // Enter
            this.acceptFirstSuggestion(component, settings);
        } else if(keyCode == 40) { //Arrow down
            this.selectNextSuggestion(component, null, settings);
        } else if(keyCode == 38) { //Arrow up
            this.hideSuggestions(component, settings);
        } else {
            this.getSuggestions(component, settings);
        }
    },
    // EDQ added Validation logic
    onSuggestionKeyUp : function(component, event, settings) {
        var keyCode = event.which;
        if(keyCode == 40) { // Arrow down
            this.selectNextSuggestion(component, event.target, settings);
        } else if(keyCode == 38) { // Arrow up
            this.selectPreviousSuggestion(component, event.target, settings);
        } else if(keyCode > 40) { // User is typing a character, set the focus on the text field and add the character there.
            this.appendKeyCodeToEndOfInput(component, keyCode, settings);
        }
    },
    // EDQ added Validation logic
    handleResultSelect: function(component, event, settings) {
        var addressFormatId = event.target.title;
        //alert('addressFormatId-----'+addressFormatId);
        this.getFullAddress(component, addressFormatId, settings);
    },
    // EDQ added Validation logic
    getSuggestions : function(component, settings) {
        var searchTermValue = this.getElementValue(component, settings.street.auraId);

        this.hideAndRemoveSuggestions(component, settings);

        if("undefined" === typeof searchTermValue || searchTermValue.trim().length < 3 ){return;}

        var country = this.getCountry(component, settings);

        var action = component.get("c." + settings.searchAddressActionName);
        action.setParams({
            searchTerm : searchTermValue,
            country : country,
            take : settings.MaxSuggestionsToTake
        });

        action.setCallback(this, function(a) {
            this.hideLoader(component, settings);

            if (a.getState() === "SUCCESS") {
                try {
                    var resultAsString = a.getReturnValue();
                    var retJSON = JSON.parse(resultAsString);
                    var requestHasFailed = retJSON.hasOwnProperty('Message');
                    if (requestHasFailed) {
                        if (settings.displayErrors) {
                            this.showToast("error", 'Validation failed', component, retJSON['Message']);
                        }
                        this.changeValidationStatus(component, settings.status, settings['unknownStatus']);
                        return;
                    }
                    var results = retJSON.results;
                    for(var i = 0; i < results.length; i++) {
                        results[i].index = i;
                    }

                    if (results.length > 0) {
                        this.setVariableValue(component, settings.hasSuggestionsVariableName, true);
                        this.setVariableValue(component, settings.suggestionsVariableName, results);
                    }
                } catch(error) {
                    this.log(error);
                }
            } else {
                this.log(a);
            }
        });

        var timeoutIdentifier = this.getVariableValue(component, settings.timeoutIdentifierVariableName);
        if(timeoutIdentifier != null || timeoutIdentifier != undefined)
            clearTimeout(timeoutIdentifier);

        var helper = this;
        timeoutIdentifier = window.setTimeout($A.getCallback(function() {
            helper.showLoader(component, settings);
            $A.enqueueAction(action);
        })
        , 1000);

        this.setVariableValue(component, settings.timeoutIdentifierVariableName, timeoutIdentifier);
    },
    // EDQ added Validation logic
    getFullAddress : function(component, formatAddressUrl, settings) {
        var _this = this;
        this.hideAndRemoveSuggestions(component, settings);
        this.cleanupAddressFields(component, settings);
        var action = component.get("c." + settings.formatAddressActionName);
        action.setParams({formatUrl : formatAddressUrl});

        this.showLoader(component, settings);
        action.setCallback(this, function(a) {
            this.hideLoader(component, settings);

            if (a.getState() === "SUCCESS") {
                try {
                    var resultAsString = a.getReturnValue();
                    var retJSON = JSON.parse(resultAsString);
                    var requestHasFailed = retJSON.hasOwnProperty('Message');
                    if (requestHasFailed) {
                        if (settings.displayErrors) {
                            this.showToast("error", 'Validation failed', component, retJSON['Message']);
                        }
                        this.changeValidationStatus(component, settings.status, settings['unknownStatus']);
                        return;
                    }
                    var mapping = settings.addressMapping;
                    var parsedResult = this.parseResult(retJSON);
                    var validatedAddressSnapshot = {};
                    Object.keys(parsedResult).forEach(function(addressKeyFromService) {
                        if(mapping.hasOwnProperty(addressKeyFromService) && null !== mapping[addressKeyFromService]) {
                            var addressComponentAuraId = settings[mapping[addressKeyFromService]].auraId;
                            var addressComponentFieldName = settings[mapping[addressKeyFromService]].fieldName;
                            if(addressKeyFromService=='postalCode' && parsedResult['country']=='UNITED STATES OF AMERICA'){
                                var splittedZipCode = parsedResult[addressKeyFromService].split('-');
                                _this.setElementValue(component, addressComponentAuraId, splittedZipCode[0]);
                                validatedAddressSnapshot[addressComponentFieldName] = splittedZipCode[0];
                            }else{
                                _this.setElementValue(component, addressComponentAuraId, parsedResult[addressKeyFromService]);
                                validatedAddressSnapshot[addressComponentFieldName] = parsedResult[addressKeyFromService];
                            }
                        }
                    });

                    this.changeValidationStatus(component, settings.status, settings['verifiedByServiceStatus']);
                    this.saveSnapshot(component, settings, validatedAddressSnapshot);
                } catch(error) {
                    this.log(error);
                }
            } else {
                this.log(a);
            }
        });

        $A.enqueueAction(action);
    },
    // EDQ added Validation logic
    parseResult : function(resultJSON) {
        var parsedResult = {};
        for(var i = 0; i < resultJSON.address.length; i++) {
            var line = resultJSON.address[i];
            for(var key in line) {
                if(!line.hasOwnProperty(key)) { continue; }

                var value = line[key];
                parsedResult[key] = value;
            }
        }

        for(var i = 0; i < resultJSON.components.length; i++) {
            var line = resultJSON.components[i];
            for(var key in line) {
                if(!line.hasOwnProperty(key)) { continue; }

                var value = line[key];
                parsedResult[key] = value;
            }
        }
        return parsedResult;
    },
    // EDQ added Validation logic
    acceptFirstSuggestion : function(component, settings) {
        var suggestions =  this.getVariableValue(component, settings.suggestionsVariableName);
        if(this.isNull(suggestions) || suggestions.length == 0)
            return;

        this.getFullAddress(component, suggestions[0].format, settings);
    },
    // EDQ added Validation logic
    selectNextSuggestion : function(component, selectedSuggestion, settings) {
        var suggestions =  this.getVariableValue(component, settings.suggestionsVariableName);
        if(this.isNull(suggestions) || suggestions.length == 0)
            return;

        var selectedSuggestionIndex = this.getSelectedSuggestionIndex(component, selectedSuggestion, settings);
        if(selectedSuggestionIndex >= suggestions.length - 1) {
            selectedSuggestionIndex = -1;
        }

        selectedSuggestionIndex++;
        this.selectSuggestionById(component, selectedSuggestionIndex, settings);
    },
    // EDQ added Validation logic
    selectPreviousSuggestion : function(component, selectedSuggestion, settings) {
        var suggestions =  this.getVariableValue(component, settings.suggestionsVariableName);
        if(this.isNull(suggestions) || suggestions.length == 0)
            return;

        var selectedSuggestionIndex = this.getSelectedSuggestionIndex(component, selectedSuggestion, settings);
        if(selectedSuggestionIndex == -1)
            return;

        if(selectedSuggestionIndex == 0) {
            this.focusStreet(component, settings);
        } else {
            selectedSuggestionIndex--;
            this.selectSuggestionById(component, selectedSuggestionIndex, settings);
        }
    },
    // EDQ added Validation logic
    selectSuggestionById : function(component, suggestionId, settings) {
        var id = component.getGlobalId() + settings.suggestionIndexClassPrefix + suggestionId;
        document.getElementById(id).focus();
    },
    // EDQ added Validation logic
    getSelectedSuggestionIndex : function(component, selectedSuggestion, settings) {
        if(this.isNull(selectedSuggestion))
            return -1;

        var idPrefix = component.getGlobalId() + settings.suggestionIndexClassPrefix;
        var id = selectedSuggestion.id;
        var indexOfSuggestionIndexClassPrefix = id.indexOf(idPrefix);
        if(indexOfSuggestionIndexClassPrefix == 0) {
            var selectedIndexAsString = id.substring(indexOfSuggestionIndexClassPrefix + idPrefix.length);

            return parseInt(selectedIndexAsString);
        } else {
            return -1;
        }
    },
    // EDQ added Validation logic
    hideSuggestions : function(component, settings) {
        this.setVariableValue(component, settings.hasSuggestionsVariableName, false);
    },
    // EDQ added Validation logic
    hideAndRemoveSuggestions :  function(component, settings) {
        this.setVariableValue(component, settings.hasSuggestionsVariableName, false);
        this.setVariableValue(component, settings.suggestionsVariableName, []);
    },
    // EDQ added Validation logic
    focusStreet : function(component, settings) {
        component.find(settings.street.auraId).focus();
    },
    // EDQ added Validation logic
    appendKeyCodeToEndOfInput : function(component, keyCode, settings) {
        try {
            this.focusStreet(component, settings);

            var oldValue = this.getElementValue(component, settings.street.auraId);
            this.setElementValue(component, settings.street.auraId, oldValue + String.fromCharCode(keyCode).toLowerCase());
            this.getSuggestions(component, settings);
        }
        catch(error) { this.log(error); }
    },
    // EDQ added Validation logic
    getCountry : function(component, settings) {
        if(this.isNullOrEmpty(settings.country.auraId)) {
            return settings.defaultCountry;
        } else {
            return this.getElementValue(component, settings.country.auraId);
        }
    },
    // EDQ added Validation logic
    handleValidationStatus : function(component, settings) {
        var hasBeenValidated = null !== this.getVariableValue(component, settings.addressObjectSnapshotPropertyName);
        if (hasBeenValidated) {
            if (this.addressIsDifferentThanTheValidatedOne(component, settings)) {
                this.changeValidationStatus(component, settings.status, settings['userPreferredStatus']);
            } else {
                this.changeValidationStatus(component, settings.status, settings['verifiedByServiceStatus']);
            }
        }
    },
    // EDQ added Validation logic
    changeValidationStatus : function(component, statusConfig, value) {
        if (null === statusConfig.auraId) {
            return;
        }
        this.setElementValue(component, statusConfig.auraId, value);
    },
    // EDQ added Validation logic
    saveSnapshot : function(component, settings, validatedAddressSnapshot) {
        this.setVariableValue(component, settings.addressObjectSnapshotPropertyName, validatedAddressSnapshot);
    },
    // EDQ added Validation logic
    addressIsDifferentThanTheValidatedOne : function(component, settings) {
        var addressHasBeenChanged;
        var addressKeys = this.getMappedAddressFieldNames(settings);
        var currentAddress =  this.getVariableValue(component, settings.addressObjectPropertyName);
        var validatedAddress =  this.getVariableValue(component, settings.addressObjectSnapshotPropertyName);

        for (var index in addressKeys) {
           var key = addressKeys[index];
           if (currentAddress[key] === validatedAddress[key]) {
               addressHasBeenChanged = false;
           }  else {
               addressHasBeenChanged = true;
               break;
           }
        };

        return addressHasBeenChanged;
    },
    // EDQ added Validation logic
    getMappedAddressFieldNames : function(settings) {
        var mappedAddressKeys = [];
        Object.keys(settings.addressMapping).forEach(function(key){
            var mappedKey = settings.addressMapping[key];
            var hasMappedKey = null !== mappedKey;
            if (hasMappedKey) {
                mappedAddressKeys.push(settings[mappedKey].fieldName);
            }
        });

        return mappedAddressKeys;
    },
    //  <--- Utility functions --->
    // EDQ added Validation logic
    showLoader : function(component, settings) {
        var loader = component.find(settings.loaderId);
        $A.util.removeClass(loader, 'invisible');
        $A.util.addClass(loader, 'visible');
    },
    // EDQ added Validation logic
    hideLoader : function(component, settings) {
        var loader = component.find(settings.loaderId);
        $A.util.removeClass(loader, 'visible');
        $A.util.addClass(loader, 'invisible');
    },
    // EDQ added Validation logic
    getVariableValue : function(component, attributeName) {
        return component.get('v.' + attributeName);
    },
    // EDQ added Validation logic
    setVariableValue : function(component, attributeName, value) {
        component.set('v.' + attributeName, value);
    },
    // EDQ added Validation logic
    getElementValue : function(component, auraId) {
        return component.find(auraId).get('v.value');
    },
    // EDQ added Validation logic
    setElementValue : function(component, auraId, value) {
        component.find(auraId).set('v.value', value);
    },
    // EDQ added Validation logic
    isNullOrEmpty : function(value) {
        return this.isNull(value) || value == '';
    },
    // EDQ added Validation logic
    isNull : function(value) {
        return value == undefined || value == null;
    },
    // EDQ added Validation logic
    log : function(error) {
        if(this.isNull(window.console)) return;

        console.log(error);
    },
    // EDQ added Validation logic
    cleanupAddressFields : function(component, settings) {
        for(var addressMap in settings.addressMapping) {
            if(!settings.addressMapping.hasOwnProperty(addressMap)) continue;
            var settingsProperty = settings.addressMapping[addressMap];
            if(settings.hasOwnProperty(settingsProperty) && settings[settingsProperty] && settings[settingsProperty].auraId) {
                component.find(settings[settingsProperty].auraId).set('v.value', "");
            }
    	}
    }
})