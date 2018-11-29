({
    // Get guestId from URL and pull addresses
	doInit : function(cmp, event, helper) {
    	cmp.set("v.showSuspendToPosModal",false);
     //   alert('isrenagainForUpdate'+cmp.get("v.isrenagainForUpdate"));
    	helper.cmpLoad(cmp, event, helper);
         
        
    },  
    
    // Get current selection of Shipping address
    showOrHideShipForm : function(cmp, event, helper) {
        var currVal = cmp.find("shipGroup").get("v.value");
        cmp.set("v.currShipAddr",currVal);        
        if(currVal == undefined || currVal == "") {
        	cmp.set("v.showShipAddForm",true);
                        
            // REQ 444 - Added
            cmp.set("v.shipAddEditBtn", false);
            var formWarp = cmp.get("v.formWrap");
            // DEF-860 - billing info and shiping info fix
            // should not set formWrapMap new as that will clear up everything including billing info
            // and phone/email
			var formWrapMap = cmp.get("v.formWrapMap");
            cmp.set("v.formWrap", helper.reInitializeAddressFields(cmp.get("v.formWrap"), formWrapMap ['New'], '', 'shipping'));
            /* DEF-860 - billing info and shiping info fix
            var formWrapMap = cmp.get("v.formWrapMap");
            var formWrap = formWrapMap['New'];
            cmp.set("v.formWrap", formWrap);*/
            // REQ 444 - END.
            /*
            if(cmp.get("v.phCount") <=1){
                cmp.set("v.isShipManualPhone",true);
                $A.util.addClass(cmp.find("selectShipPhone"), "slds-hide");
            }else
            cmp.set("v.isShipManualPhone",false);*/
        }
        else {	
            
            cmp.set("v.showShipAddForm",false);
            cmp.set("v.isShipFormError",  false);
            // REQ 444 - Added
            cmp.set("v.shipAddEditBtn", true);
        }
		if(cmp.find("shipCheckBox") != undefined && cmp.find("shipCheckBox").get("v.value")) {
            cmp.set("v.showBillingInfo",false);
        }   
        else {
            cmp.set("v.showBillingInfo",true);

        }
    },
    
    // Get current selection of Billing address
    showOrHideBillForm : function(cmp, event, helper) {
        var currVal = cmp.find("billGroup").get("v.value");
        cmp.set("v.currBillAddr",currVal);
        if(currVal == undefined || currVal == "") {
        	cmp.set("v.showBillAddForm",true); 
			cmp.set("v.billAddEditBtn", false);
            var formWarp = cmp.get("v.formWrap");
            // DEF-860 - billing info and shiping info fix
            // should not set formWrapMap new as that will clear up everything including billing info
            // and phone/email
            var formWrapMap = cmp.get("v.formWrapMap");
			cmp.set("v.formWrap", helper.reInitializeAddressFields(cmp.get("v.formWrap"), formWrapMap['New'], '', 'billing'));
            /* DEF-860 - billing info and shiping info fix
            var formWrapMap = cmp.get("v.formWrapMap");
            var formWrap = formWrapMap['New'];
            cmp.set("v.formWrap", formWrap);*/
            // REQ 444 - END.
            /*
            if(cmp.get("v.phCount") <=1){
                cmp.set("v.isBillManualPhone",true);
                $A.util.addClass(cmp.find("selectBillPhone"), "slds-hide");
            }else
            cmp.set("v.isBillManualPhone",false); */
        }
        else {
            cmp.set("v.showBillAddForm",false);
            cmp.set("v.isBillFormError",  false);
            cmp.set("v.billAddEditBtn", true);
        }
    },    
  /*saveSelectedShipAddress : function(component,event,helper) {
      var newphone = component.get("v.shipnewPhone");
       alert('newphone'+newphone); 
      var newemail = component.get("v.shipnewEmail");
      alert('newemail'+newemail); 
        var personId=component.get("v.guestId");
        alert('personId'+personId); 
        
        var action = component.get("c.createAddList");
                action.setParams({                                    
                                  "Phone ": newphone,
                                  "PersonEmail" : newemail,
                                  "personAccId" :personId ,})
									
         action.setCallback(this, function(response) {
                    var state = response.getState();
                       alert('state'+state); 
                    if (state === "SUCCESS") {
                        
         
                    }
               
                
            
                });
                $A.enqueueAction(action);
            }, */
                               
    // REQ 444 - Added Shipping Address Edit button logic
    editSelectedShipAddress : function(cmp, event, helper) {         
        var formWrapMap = cmp.get("v.formWrapMap");       
        var currVal = cmp.find("shipGroup").get("v.value");
       
        //console.log('formWrapMap-->'+JSON.stringify(formWrapMap));
        // DEF-0860 - initialize only address fields
        //var formWrap = formWrapMap[currVal];
        //formWrap.oldAddrId = currVal;
        //cmp.set("v.formWrap", formWrap);
        //
        //
        cmp.set("v.formWrap", helper.reInitializeAddressFields(cmp.get("v.formWrap"), formWrapMap[currVal], currVal, 'shipping'));       
        cmp.set("v.showShipAddForm", true);        
        cmp.set("v.shipAddEditBtn", false);
        
    },
   
	editSelectedBillAddress: function(cmp, event, helper) {
        var formWrapMap = cmp.get("v.formWrapMap");
        var currVal = cmp.find("billGroup").get("v.value");
        // DEF-0860 - initialize only address fields
        //var formWrap = formWrapMap[currVal];
        //formWrap.oldAddrId = currVal;
        //cmp.set("v.formWrap", formWrap);
        cmp.set("v.formWrap", helper.reInitializeAddressFields(cmp.get("v.formWrap"), formWrapMap[currVal], currVal, 'billing'));
        cmp.set("v.showBillAddForm", true);
        cmp.set("v.billAddEditBtn", false);
    },
    
    
    // Validate and store new shipping address
    useThisShippingAddr : function(cmp, event, helper) {
		
        var newAddr;
        //if(cmp.get("v.currShipAddr") == "") {
            cmp.set("v.isShipFormError",false);
            // DEF - 860 - Commented this line as it was overriding the entered Shipping Phone to undefined.
        	//cmp.set("v.formWrap.shipPhone", cmp.get("v.shipPhone"));
        	//cmp.set("v.formWrap.shipEmail", cmp.get("v.shipEmail"));
            helper.validateAddressForm(cmp,event,helper,'Shipping');

            if(!cmp.get("v.isShipFormError")) {
                if(cmp.get("v.formWrap").shipAddr2 == "") {
                    newAddr = cmp.get("v.formWrap").shipFirstName+' '+cmp.get("v.formWrap").shipLastName+' '+cmp.get("v.formWrap").shipAddr1+' '+
                              cmp.get("v.formWrap").shipCity+','+
                              cmp.get("v.formWrap").shipState+' '+cmp.get("v.formWrap").shipPostalCode;    
                }
                else {
                    newAddr = cmp.get("v.formWrap").shipFirstName+' '+cmp.get("v.formWrap").shipLastName+' '+cmp.get("v.formWrap").shipAddr1+' '+
                              cmp.get("v.formWrap").shipAddr2+','+cmp.get("v.formWrap").shipCity+','+
                              cmp.get("v.formWrap").shipState+' '+cmp.get("v.formWrap").shipPostalCode;    
                }
                var action = cmp.get("c.createNewAddress");
                action.setParams({ "addressList" : cmp.get("v.addresses"),
                                   "formWrapStr" : JSON.stringify(cmp.get("v.formWrap")),
                                    "isShipping" : true,
                                    
									"personAccId" : cmp.get("v.guestId"),
									"mapWrap" : JSON.stringify(cmp.get("v.formWrapMap"))});   

                
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        if(response.getReturnValue().error != null)
                        {
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                type: "error",
                                message: response.getReturnValue().error,
                            });
                            toastEvent.fire();
                            
                        }
                        else{
                            cmp.set("v.newShipAddr",response.getReturnValue().formWrap.newAddrId);
                            cmp.set("v.addresses",response.getReturnValue().formWrap.addressList);
                            cmp.set("v.currShipAddr",cmp.get("v.newShipAddr"));
                            cmp.set("v.formWrapMap",response.getReturnValue().formWrapMap); 
                            cmp.set("v.showShipAddForm",false);
                            // REQ 444 - Added
                            cmp.set("v.shipAddEditBtn", true);
                            //Refresh Summary when shipping address is updated
                            cmp.set("v.isRenderForUpdate",true);
                            if(cmp.find("shipCheckBox") != undefined && cmp.find("shipCheckBox").get("v.value")) {
                                cmp.set("v.showBillingInfo",false);
                                cmp.set("v.currBillAddr",cmp.get("v.currShipAddr"));
                            }  
                        }
                        cmp.set("v.formWrapMap",response.getReturnValue().formWrapMap);
                    }
                    else if (state === "ERROR") {
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
                $A.enqueueAction(action);
            }
       // }
    },
    
    // Validate and store new billing address
    useThisBillingAddr : function(cmp, event, helper) {
        var newAddr;
        //if(cmp.get("v.currBillAddr") == "") {
            cmp.set("v.isBillFormError",false);
            helper.validateAddressForm(cmp,event,helper,'Billing');
           
            if(!cmp.get("v.isBillFormError")) {
                if(cmp.get("v.formWrap").billAddr2 == "") {
                    newAddr = cmp.get("v.formWrap").billFirstName+' '+cmp.get("v.formWrap").billLastName+' '+cmp.get("v.formWrap").billAddr1+' '+
                              cmp.get("v.formWrap").billCity+','+
                              cmp.get("v.formWrap").billState+' '+cmp.get("v.formWrap").billPostalCode;
                }
                else {
                    newAddr = cmp.get("v.formWrap").billFirstName+' '+cmp.get("v.formWrap").billLastName+' '+cmp.get("v.formWrap").billAddr1+' '+
                              cmp.get("v.formWrap").billAddr2+','+cmp.get("v.formWrap").billCity+','+
                              cmp.get("v.formWrap").billState+' '+cmp.get("v.formWrap").billPostalCode;
                }
                var action = cmp.get("c.createNewAddress");
                           
                action.setParams({ "addressList1" : cmp.get("v.addresses1"),
                                   "formWrapStr" : JSON.stringify(cmp.get("v.formWrap")),
                                    "isShipping" : false,
                                   
									"personAccId" : cmp.get("v.guestId"),
									"mapWrap" : JSON.stringify(cmp.get("v.formWrapMap"))});       

                
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        if(response.getReturnValue().error != null)
                        {
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                type: "error",
                                message: response.getReturnValue().error,
                            });
                            toastEvent.fire();
                        }
                        else
                        {
                        cmp.set("v.newBillAddr",response.getReturnValue().formWrap.newAddrId);
                        cmp.set("v.addresses1",response.getReturnValue().formWrap.addressList1);
                        cmp.set("v.currBillAddr",cmp.get("v.newBillAddr"));
                        cmp.set("v.formWrapMap",response.getReturnValue().formWrapMap); 
                        cmp.set("v.billAddEditBtn", true);
                        cmp.set("v.showBillAddForm",false);
                        }
                        cmp.set("v.formWrapMap",response.getReturnValue().formWrapMap);
                    }
                    else if (state === "ERROR") {
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
                $A.enqueueAction(action);
            }
        //}
    },
    
    // Copy current shipping address selection to billing address
    copyShipToBill : function(cmp, event, helper) {
		var isChecked = cmp.find("shipCheckBox").get("v.value");
        if(isChecked) {
        	cmp.set("v.showBillingInfo",false);
            if(cmp.get("v.currShipAddr") != '') {
            	cmp.set("v.currBillAddr",cmp.get("v.currShipAddr"));   
            }
            else {
                cmp.set("v.newBillAddr",cmp.get("v.newShipAddr"));
            }
        }
        else {
            cmp.set("v.showBillingInfo",true);
        }            
    },
	
    openModal : function(component, event, helper){
        console.log("----in openModal");
        var selectedItem = event.currentTarget; 
        var containerName = selectedItem.dataset.record;       
        var popUp = component.find(containerName);
        // console.log(popUp);
        $A.util.removeClass(popUp, 'slds-fade-in-close');
        $A.util.addClass(popUp, 'slds-fade-in-open');
        var backdrop = component.find("backdropContainer");
        // console.log(backdrop);
        $A.util.removeClass(backdrop, 'slds-modal-backdrop--close');
        $A.util.addClass(backdrop, 'slds-modal-backdrop--open');
        component.set("v.body", []);
        helper.loadDeliveryModal(component, event, helper);
        /*$A.createComponent(
            "c:PickDeliveryDate",
          {
                "GuestId": component.get('v.guestId')
                
            },
            function(newcomponent){
                if (component.isValid()) {
                    var body = component.get("v.body");
                    body.push(newcomponent);
                    component.set("v.body", body);             
                }
            }            
        );*/
        
	
    },
    
    cancelModal : function(component, event, helper){
        var selectedItem = event.currentTarget; 
        var containerName = selectedItem.dataset.record;
        helper.closeModal(component,containerName);
		helper.isDeliveryDatesChosen(component,event,helper,containerName);
        
    },
	
    finishDeliveryDate : function(component, event, helper){
        var selectedItem = event.currentTarget; 
        var containerName = selectedItem.dataset.record;
        helper.isDeliveryDatesChosen(component,event,helper,containerName);
        
    },
    toggleDSdatePicker : function(component, event, helper){       
        var toggleDSdeliveryDate = component.find("DSdeliveryDate");
        var toggleShippingMethod = component.find("shippingMethodWrapper");
        $A.util.toggleClass(toggleDSdeliveryDate, "slds-hide");
        $A.util.toggleClass(toggleShippingMethod, "slds-hide");
    },
    openDesiredDeliveryDateModal: function(component, event, helper){
        component.set("v.showDesiredDeliveryDate", true);
        var overlay = component.find('overlay');
        $A.util.addClass(overlay, 'slds-backdrop--open');
    },
    cancelDesiredDeliveryDateRefresh : function(component, event, helper){
        var desiredDay =  event.getParam("notifyParam");
        component.set("v.showDesiredDeliveryDate", false);
        var overlay = component.find('overlay');
        $A.util.removeClass(overlay, 'slds-backdrop--open');
    
    	//Refresh to load saved desired date.
        component.set("v.selectedDesiredDeliveryDay",desiredDay);
    	
    },
    doPlaceOrderFromPaymentModal : function (component, event, helper) {
        console.log("Place order event listened");
        helper.closePaymentModal(component);
        var spinner = component.find("largeSpinner");
        $A.util.toggleClass(spinner, "slds-hide");   
        console.log("send order to home called");     
        helper.sendOrderToHome(component, function(){
            helper.placeOrderSuccess(component)
        }, function(){
            helper.openPaymentModal(component); 
        });       
        
        
    },
    doSuspendSalesFromPaymentModal : function (component, event, helper) {
        helper.closePaymentModal(component);
        var spinner = component.find("largeSpinner");
        $A.util.toggleClass(spinner, "slds-hide");        
        helper.doSuspendSales(component, function(){
            helper.suspendToPosSuccess(component)
        }, function(){
            helper.openPaymentModal(component); 
        });        
    },    
	// DEF - 800 - Cancel suspend sales 
    openSuspendToPosModal : function(cmp, event, helper) {
        cmp.set("v.showSuspendToPosModal",true);
    },
    
    closeSuspendToPosModal : function(cmp, event, helper) {
        cmp.set("v.showSuspendToPosModal",false);
    },
    // End of DEF - 800 - Cancel suspend sales

    doSuspendSales : function(cmp, event, helper){
        var appEvent = $A.get("e.c:NotifyHeaderComponentEvent"); 
            appEvent.fire();
        helper.validatePhoneAndEmail(cmp,event,helper,'Shipping');
        if(cmp.get("v.showShipAddForm"))
            helper.validateAddressForm(cmp,event,helper,'Shipping');
        
        helper.validatePhoneAndEmail(cmp,event,helper,'Billing');
        if(cmp.get("v.showBillAddForm"))
            helper.validateAddressForm(cmp,event,helper,'Billing');
        if(!cmp.get("v.isShipFormError")  
            && !cmp.get("v.isBillFormError") 
            && !cmp.get("v.isShipPhoneAndEmailError")  
            && !cmp.get("v.isBillPhoneAndEmailError")){
            var spinner = cmp.find("largeSpinner");
            $A.util.toggleClass(spinner, "slds-hide");
            helper.doSuspendSales(cmp, function(){
                helper.suspendToPosSuccess(cmp)
            });
        }else{
            helper.toastMessage("Error","","Failed In Form Validation");
        }
    },
    shipPhoneChange : function(cmp, event, helper){
        var phoneVal = cmp.find("selectShipPhone").get("v.value");
        if(phoneVal === "Add New"){
            cmp.set("v.formWrap.shipPhone",'');
            cmp.set("v.isShipManualPhone",true);
            cmp.set("v.issavebutton",true);
           // $A.util.addClass(event.getSource(),"slds-hide");
        }else{
              cmp.set("v.formWrap.shipPhone",phoneVal);
             cmp.set("v.isShipManualPhone",false);
            cmp.set("v.issavebutton",false);
        }
    },
    billPhoneChange : function(cmp, event, helper){
        var phoneVal = cmp.find("selectBillPhone").get("v.value");
        if(phoneVal === "Add New"){
            cmp.set("v.formWrap.billPhone",'');
            cmp.set("v.isBillManualPhone",true);            
           // $A.util.addClass(event.getSource(),"slds-hide");
        }else{
              cmp.set("v.formWrap.billPhone",phoneVal);
             cmp.set("v.isBillManualPhone",false);
        }
    },
    shipEmailChange : function(cmp, event, helper){
        var emailVal = cmp.find("selectShipEmail").get("v.value");
        if(emailVal === "Add New"){
            cmp.set("v.formWrap.shipEmail",'');
           // cmp.set("v.isShipPicklistEmail",true);
            cmp.set("v.isShipManualEmail",true);
            cmp.set("v.issavebutton",true);
           // $A.util.addClass(event.getSource(),"slds-hide");
        }else{
             cmp.set("v.formWrap.shipEmail",emailVal);
             cmp.set("v.isShipManualEmail",false);
            cmp.set("v.issavebutton",false);
        }
    },
    billEmailChange : function(cmp, event, helper){
        var emailVal = cmp.find("selectBillEmail").get("v.value");
        if(emailVal === "Add New"){
            cmp.set("v.formWrap.billEmail",'');
           // cmp.set("v.isBillPicklistEmail",true);
            cmp.set("v.isBillManualEmail",true);            
           // $A.util.addClass(event.getSource(),"slds-hide");
        }else{
             cmp.set("v.formWrap.billEmail",emailVal);
             cmp.set("v.isBillManualEmail",false);
        }
    },
    refreshCheckoutSummary : function(cmp, event, helper){
         cmp.set("v.isRenderForUpdate", event.getParam("notifyParam"));
    },
    // Validation logic
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
    // ------------- Handler for second address --------------
    handleOtherSearchChange : function(component, event, helper) {
        var settings = helper.getOtherSettings();
        helper.handleSearchChange(component, event, settings);
        helper.handleValidationStatus(component, settings);
    },
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
    onOtherSuggestionKeyUp : function(component, event, helper) {
        var settings = helper.getOtherSettings();
        helper.onSuggestionKeyUp(component, event, settings);
    },
    handleOtherResultSelect: function(component, event, helper) {
        var settings = helper.getOtherSettings()
        helper.handleResultSelect(component, event, settings);
    },
    onOtherAddressChanged : function(component, event, helper) {
        var settings = helper.getOtherSettings();
        helper.handleValidationStatus(component, settings);
    },
    onOtherElementFocusedOut : function (component, event, helper) {
        var settings = helper.getOtherSettings();

        var useHasNotSelectedASuggestion = helper.isNull(event.relatedTarget) || event.relatedTarget.id.indexOf(settings.suggestionIndexClassPrefix) === -1;
        if (useHasNotSelectedASuggestion) {
            helper.hideAndRemoveSuggestions(component, settings);
        }
    },
    openPaymentModal: function(component, event, helper){
        //Open spinner
       //alert('entered');
        var spinner = component.find("largeSpinner");
        $A.util.toggleClass(spinner, "slds-hide"); 
        // alert('entered 1');
        if (helper.isValidForm(component, event, helper)){
            // Performance issue fix - perform single update on opportunity instead of multiple updates
            helper.updateDetailsOnOpty(component, event, helper, function(){
                helper.openPaymentModal(component);
                //Close spinner
                var spinner = component.find("largeSpinner");
                $A.util.toggleClass(spinner, "slds-hide");  
            });
        }
        //DEF-955 Close spinner when billing details not entered
        else{
          //   alert('entered else');
            var spinner = component.find("largeSpinner");
            $A.util.toggleClass(spinner, "slds-hide");
        }
        //DEF-955 End
    },
    closePaymentModal: function(component, event, helper){
        helper.closePaymentModal(component);
    },    
    openTextOptInModal : function(component, event, helper) {
        component.set("v.showTextOptInModal", true);
        var overlay = component.find('overlay');
        $A.util.addClass(overlay, 'slds-backdrop--open');
    },
    doTextOptInDecline : function(component, event, helper) {
        component.set("v.showTextOptInModal", false);
        var overlay = component.find('overlay');
        $A.util.removeClass(overlay, 'slds-backdrop--open');
        component.set("v.textOptInCompleted", true);
    },
    ShipPhone : function(cmp, event, helper){
        var phoneRegExp = /^\(?([0-9]{3})\)?[-. ]?([0-9]{3})[-. ]?([0-9]{4})$/;
        var Shipvalue=cmp.get("v.formWrap.shipPhone");
        var validphone= phoneRegExp.test(cmp.get("v.formWrap.shipPhone"));
        var shipvalid = true;
        if((Shipvalue == null  || validphone == false || cmp.get("v.lstPhones").length >= 7 ||Shipvalue == '')) 
        {
            shipvalid=false;
        }
        
        if(shipvalid){  
            var action = cmp.get("c.updatePhone");
            if(!$A.util.isUndefinedOrNull(cmp.get("v.guestId"))){
                action.setParams({"PersonAccId" : cmp.get("v.guestId"),
                                  "Phonevalue" : Shipvalue
                                 });
            }
            
            action.setCallback(this, function(response) {           
                var state = response.getState();
                if (state === "SUCCESS") {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Success!",
                        "type": "success",
                        "message": "Phone Number added successfully."  
                    });
                    toastEvent.fire();    
                }        
            });     
            $A.enqueueAction(action);
        }
        else{
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error Message",
                "type": "error",
                "message": "Please check the Phone Number"  
            });
            toastEvent.fire();    
        }
    },
    BillPhone : function(cmp, event, helper){
        var phoneRegExp = /^\(?([0-9]{3})\)?[-. ]?([0-9]{3})[-. ]?([0-9]{4})$/;
        var Billvalue=cmp.get("v.formWrap.billPhone");
        var validphone= phoneRegExp.test(cmp.get("v.formWrap.billPhone"));
        var billvalid= true;
        if((Billvalue == null  || validphone == false || cmp.get("v.lstPhones").length >= 7 ||Billvalue == '')) 
        {
            billvalid=false;
        }
        if(billvalid){  
            var action = cmp.get("c.updatePhone");
            if(!$A.util.isUndefinedOrNull(cmp.get("v.guestId"))){
                action.setParams({"PersonAccId" : cmp.get("v.guestId"),
                                  "Phonevalue" : Billvalue
                                 });
            }
            
            action.setCallback(this, function(response) {           
                var state = response.getState();
                if (state === "SUCCESS") {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Success!",
                        "type": "success",
                        "message": "Phone Number added successfully."  
                    });
                    toastEvent.fire();    
                }        
            });     
            $A.enqueueAction(action);
        }
        else{
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error Message",
                "type": "error",
                "message": "Please check the Phone Number"  
            });
            toastEvent.fire();    
            
        }
    },    
        
    
    ShipEmail : function(cmp, event, helper){
        var Emailvalue=cmp.get("v.formWrap.shipEmail");
        var emailRegExp =  /^([A-Za-z0-9_\-\.])+\@([A-Za-z0-9_\-\.])+\.([A-Za-z]{2,4})$/;
        var validEmail= emailRegExp.test(Emailvalue); 
        var valid = true;
        if((cmp.get("v.formWrap.shipEmail") == null  || validEmail==false  || cmp.get("v.formWrap.shipEmail") == '')) 
        {  
            valid=false; 
        }
        if(valid){    
            var action = cmp.get("c.updatePhone");
            if(!$A.util.isUndefinedOrNull(cmp.get("v.guestId"))){
                action.setParams({"PersonAccId" : cmp.get("v.guestId"),
                                  "Emailvalue" : Emailvalue
                                 });
            } 
            action.setCallback(this, function(response) {           
                var state = response.getState();
                if (state === "SUCCESS") {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Success!",
                        "type": "success",
                        "message": "Email Added Successfully."  
                    });
                    toastEvent.fire();
                }
            });
            $A.enqueueAction(action);
        }
        else{
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error Message",
                "type": "error",
                "message": "Please check the Email"  
            });
            toastEvent.fire(); 
        }
    },
           
    BillEmail : function(cmp, event, helper){
        var Emailvalue=cmp.get("v.formWrap.billEmail");
        var emailRegExp =  /^([A-Za-z0-9_\-\.])+\@([A-Za-z0-9_\-\.])+\.([A-Za-z]{2,4})$/;
        var validEmail= emailRegExp.test(Emailvalue); 
        var valid = true;
        if((cmp.get("v.formWrap.billEmail") == null  || validEmail==false  || cmp.get("v.formWrap.billEmail") == '')) 
        {  
            valid=false; 
        }
        if(valid){    
            var action = cmp.get("c.updatePhone");
            if(!$A.util.isUndefinedOrNull(cmp.get("v.guestId"))){
                action.setParams({"PersonAccId" : cmp.get("v.guestId"),
                                  "Emailvalue" : Emailvalue
                                 });
            } 
            action.setCallback(this, function(response) {           
                var state = response.getState();
                if (state === "SUCCESS") {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Success!",
                        "type": "success",
                        "message": "Email Added Successfully."  
                    });
                    toastEvent.fire();
                }
            });
            $A.enqueueAction(action);
        }
        else{
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error Message",
                "type": "error",
                "message": "Please check the Email"  
            });
            toastEvent.fire(); 
        }
    },
    doTextOptInComplete : function(component, event, helper) {
        component.set("v.showTextOptInModal", false);
        var overlay = component.find('overlay');
        $A.util.removeClass(overlay, 'slds-backdrop--open');
        component.set("v.textOptInCompleted", true);
    }        
})