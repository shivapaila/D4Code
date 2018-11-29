({
   loadAddresses : function(cmp, helper) {
       // Load all contact data
       var action = cmp.get("c.getCustomerAddresses");
      	
       var recId = cmp.get("v.recordId");
       var toastErrorHandler = cmp.find('toastErrorHandler');
       if ($A.util.isEmpty(recId) || $A.util.isUndefined(recId) ) 
           return;

       action.setParams({ "customerId"  : recId });       
       
       action.setCallback(this, function(response) {
           toastErrorHandler.handleResponse(
               response, // handle failure
               function(response){ // report success and navigate to contact record
                   console.log('you are here ', response);
                   cmp.set("v.addresses", response.getReturnValue());
               }, 
               function(response, message){ // report failure
                   helper.showToast("error", 'Address Load Error', cmp,
                                    message);
               }
           )
       });
       $A.enqueueAction(action);
   },
   isAddrValid : function(addr, component, helper) {
        console.log('validating ', addr);
        console.log('city is ', addr.City__c);
        var valid = true;
        var messages = [];
        //if (!$A.util.isEmpty(addr.Address_Line_1__c) || !$A.util.isEmpty(addr.Address_Line_2__c)
        //    || !$A.util.isEmpty(addr.City__c) || !$A.util.isEmpty(addr.State__c)
        //    || !$A.util.isEmpty(addr.Zip_Code__c))
        //{
            if ($A.util.isEmpty(addr.Address_Line_1__c))
            {
                messages.push('Please include Street Address.');
                valid = false;
            }
            if ($A.util.isEmpty(addr.City__c))
            {
                console.log('city is empty');
                messages.push('Please include City.');
                valid = false;
            }
            if ($A.util.isEmpty(addr.State__c))
            {
                messages.push('Please include State.');
                valid = false;
            }
            if ($A.util.isEmpty(addr.Zip_Code__c))
            {
                messages.push('Please include Postal Code.');
                valid = false;
            }
            if ($A.util.isEmpty(addr.Address_Type__c))
            {
                messages.push('Please Select Shipping Or Billing.');
                valid = false;
            }
        //}

        // push out address toasts
        if (!valid) {
            for (let message of messages) {
              helper.showToast("error", 'Missing Address Fields', component, message);
            }
        }

        console.log('valid is ', valid);
      return valid;
    },
    clearAddrFormFields : function(component) {
        component.set("v.newAddress",{
            'sobjectType':'Address__c',
            // Dev Test issues - setting a '' as Id causes upsert failure
            //'Id' : '', 
            'Preferred__c ' : false, 
            'Address_Line_1__c' : '', 
            'Address_Line_2__c' : '', 
            'City__c' : '', 
            'State__c' : '', 
            'Zip_Code__c' : '',
            'Address_Validation_Status__c' : '',
            'Address_Validation_Timestamp__c' : ''
        });

        // nullify the snapshot when clearing the form
        var snapshotAttributeName = this.getSettings()['addressObjectSnapshotPropertyName'];
        this.setVariableValue(component, snapshotAttributeName, null);
        //component.set("v.selectedIndex", null);
    },
    showToast : function(type, title, component, message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            type: type,
            // note - leaving mode field for reference 
            //mode: 'dismissible',
            title: title, 
            message: message,
        });
        toastEvent.fire();
    },
    // EDQ added Validation logic Begin
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
                auraId : 'street',
                fieldName : 'Address_Line_1__c'
            },
            // Second street's auraId and the field name of the object containing the value
            apartmentNumber : {
                auraId : 'street2',
                fieldName : 'Address_Line_2__c'
            },
            // City's auraId and the field name of the object containing the value
            city : {
                auraId : 'city',
                fieldName : 'City__c'
            },
            // State's auraId and the field name of the object containing the value
            state : {
                auraId : 'state',
                fieldName : 'State__c'
            },
            // Zip's auraId and the field name of the object containing the value
            zip : {
                auraId : 'zip',
                fieldName : 'Zip_Code__c'
            },
            // Validation status's auraId and the field name of the object containing the value
            status : {
                auraId : 'addrValStatus',
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
            addressObjectPropertyName : 'newAddress',
            // The property name of the object containing the address snapshot
            addressObjectSnapshotPropertyName : 'addressObjectSnapshot',

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
    handleSearchChange : function(component, event, settings) {
        var countryValue = this.getCountry(component, settings);

        var keyCode = event.getParams().keyCode;
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
    onSuggestionKeyUp : function(component, event, settings) {
        var keyCode = event.keyCode;
        if(keyCode == 40) { // Arrow down
            this.selectNextSuggestion(component, event.target, settings);
        } else if(keyCode == 38) { // Arrow up
            this.selectPreviousSuggestion(component, event.target, settings);
        } else if(keyCode > 40) { // User is typing a character, set the focus on the text field and add the character there.
            this.appendKeyCodeToEndOfInput(component, keyCode, settings);
        }
    },
    handleResultSelect: function(component, event, settings) {
        var addressFormatId = event.target.title;
        this.getFullAddress(component, addressFormatId, settings);
    },
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
    acceptFirstSuggestion : function(component, settings) {
        var suggestions =  this.getVariableValue(component, settings.suggestionsVariableName);
        if(this.isNull(suggestions) || suggestions.length == 0)
            return;

        this.getFullAddress(component, suggestions[0].format, settings);
    },
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
    selectSuggestionById : function(component, suggestionId, settings) {
        var id = component.getGlobalId() + settings.suggestionIndexClassPrefix + suggestionId;
        document.getElementById(id).focus();
    },
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
    hideSuggestions : function(component, settings) {
        this.setVariableValue(component, settings.hasSuggestionsVariableName, false);
    },
    hideAndRemoveSuggestions :  function(component, settings) {
        this.setVariableValue(component, settings.hasSuggestionsVariableName, false);
        this.setVariableValue(component, settings.suggestionsVariableName, []);
    },
    focusStreet : function(component, settings) {
        component.find(settings.street.auraId).focus();
    },
    appendKeyCodeToEndOfInput : function(component, keyCode, settings) {
        try {
            this.focusStreet(component, settings);

            var oldValue = this.getElementValue(component, settings.street.auraId);
            this.setElementValue(component, settings.street.auraId, oldValue + String.fromCharCode(keyCode).toLowerCase());
            this.getSuggestions(component, settings);
        }
        catch(error) { this.log(error); }
    },
    getCountry : function(component, settings) {
        if(this.isNullOrEmpty(settings.country.auraId)) {
            return settings.defaultCountry;
        } else {
            return this.getElementValue(component, settings.country.auraId);
        }
    },
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
    changeValidationStatus : function(component, statusConfig, value) {
        if (null === statusConfig.auraId) {
            return;
        }
        this.setElementValue(component, statusConfig.auraId, value);
    },
    saveSnapshot : function(component, settings, validatedAddressSnapshot) {
        this.setVariableValue(component, settings.addressObjectSnapshotPropertyName, validatedAddressSnapshot);
    },
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
    showLoader : function(component, settings) {
        var loader = component.find(settings.loaderId);
        $A.util.removeClass(loader, 'invisible');
        $A.util.addClass(loader, 'visible');
    },
    hideLoader : function(component, settings) {
        var loader = component.find(settings.loaderId);
        $A.util.removeClass(loader, 'visible');
        $A.util.addClass(loader, 'invisible');
    },
    getVariableValue : function(component, attributeName) {
        return component.get('v.' + attributeName);
    },
    setVariableValue : function(component, attributeName, value) {
        component.set('v.' + attributeName, value);
    },
    getElementValue : function(component, auraId) {
        return component.find(auraId).get('v.value');
    },
    setElementValue : function(component, auraId, value) {
        component.find(auraId).set('v.value', value);
    },
    isNullOrEmpty : function(value) {
        return this.isNull(value) || value == '';
    },
    isNull : function(value) {
        return value == undefined || value == null;
    },
    log : function(error) {
        if(this.isNull(window.console)) return;

        console.log(error);
    },
    cleanupAddressFields : function(component, settings) {
        for(var addressMap in settings.addressMapping) {
            if(!settings.addressMapping.hasOwnProperty(addressMap)) continue;
            var settingsProperty = settings.addressMapping[addressMap];
            if(settings.hasOwnProperty(settingsProperty) && settings[settingsProperty] && settings[settingsProperty].auraId) {
                component.find(settings[settingsProperty].auraId).set('v.value', "");
            }
    	}
    }
    // EDQ added Validation logic End
})