({
    // Validate new shipping and billing address form values
    cmpLoad : function(cmp,event,helper){
   
        
        //alert('showSuspendToPosModal----'+cmp.get("v.showSuspendToPosModal"));
		var action = cmp.get("c.getAddresses"); 
       	console.log('initmethodcalling..' + cmp.get("v.guestId"));
        // If navigation from another location
         if(!$A.util.isUndefinedOrNull(cmp.get("v.guestId"))){ 
                action.setParams({"personAccId" : cmp.get("v.guestId")});
            } 
        
        action.setCallback(this, function(response) {           
            var state = response.getState();
            //alert('state----'+state);
            if (state === "SUCCESS") {
               
                cmp.set("v.addresses",response.getReturnValue().addressList);  
                cmp.set("v.addresses1",response.getReturnValue().addressList1); 
                cmp.set("v.formWrap",response.getReturnValue().formWrap);
                cmp.set("v.currShipAddr",$A.util.isEmpty(response.getReturnValue().currShipAddr) ? response.getReturnValue().addressList[0].value : response.getReturnValue().currShipAddr);
                cmp.set("v.currBillAddr",$A.util.isEmpty(response.getReturnValue().currBillAddr) ? response.getReturnValue().addressList[0].value : response.getReturnValue().currBillAddr);
                cmp.set("v.formWrap.billFirstName",response.getReturnValue().billFirstName);
                cmp.set("v.formWrap.billLastName",response.getReturnValue().billLastName);
				cmp.set("v.formWrap.shipEmail", response.getReturnValue().shipEmail);
                cmp.set("v.formWrap.billEmail", response.getReturnValue().billEmail);
                var opportunity = response.getReturnValue().currOpp;
                cmp.set("v.oppId", opportunity["Id"]);
                cmp.set("v.selectedDesiredDeliveryDay", opportunity["Desired_Delivery_Date__c"]);
                cmp.set("v.textOptInCompleted", opportunity.Survey_Opt_In__c || opportunity.Text_Message_Opt_In__c || opportunity.Declined_Survey_and_Text_Opt_In__c);
                
                 cmp.set("v.isRenderForUpdate",true);
                cmp.set("v.RendercomForUpdate",true);
                cmp.set("v.rSubComponent",false);
                cmp.set("v.isrenagainForUpdate",true);
                
                // REQ 444 - Added
                cmp.set("v.formWrapMap",response.getReturnValue().formWrapMap);                
               if(response.getReturnValue().addressList.length !=1) {
                     cmp.set("v.shipAddEditBtn", true);  
                   
               }
                else{
                   cmp.set("v.shipAddEditBtn", false);    
                }
                // REQ 444 - END.
                //                 
                if(response.getReturnValue().addressList1.length !=1){  
                   cmp.set("v.billAddEditBtn", true);
                }
                else{
                   cmp.set("v.billAddEditBtn", false); 
                }
                var listSize = response.getReturnValue().addressList.length;
                var opts=[];
                opts.push({class: "optionClass",
                          label: "",
                            value: ""});
                var lstPhone = response.getReturnValue().lstPhones; 
                
                for(var opt in lstPhone){
                    opts.push({class: "optionClass",
                            label: lstPhone[opt],
                            value: lstPhone[opt]});
                    if(response.getReturnValue().shipPhone==lstPhone[opt]){
                        cmp.set("v.shipPhone", response.getReturnValue().shipPhone);
                        cmp.set("v.formWrap.shipPhone", response.getReturnValue().shipPhone);
                    }
                    if(response.getReturnValue().billPhone==lstPhone[opt]){
                        cmp.set("v.billPhone", response.getReturnValue().billPhone);
                        cmp.set("v.formWrap.billPhone", response.getReturnValue().billPhone);
                    }
                }
                 
                cmp.set("v.lstPhones", opts);
                if(cmp.get("v.lstPhones").length >2){
                  
                  window.setTimeout(
                $A.getCallback( function() {
                    cmp.find("selectShipPhone").set("v.value",lstPhone[0]);
                    cmp.set("v.formWrap.shipPhone",lstPhone[0]);
                    
                    }));
                }
               
                
                var lstPhonesSize = response.getReturnValue().lstPhones.length;
                cmp.set("v.phCount",lstPhonesSize);
                if(listSize <= 1) {
                    cmp.set("v.showShipAddForm",true);
                    cmp.set("v.showBillAddForm",true);                    
                }
                
                if(cmp.get("v.currShipAddr") != '') {
                    cmp.find("shipCheckBox").set("v.value", true);
                    cmp.set("v.currBillAddr",cmp.get("v.currShipAddr"));   
                    cmp.set("v.showBillingInfo",false);
                }
                if(lstPhonesSize <=1){
                    cmp.set("v.isShipManualPhone",true);
                    cmp.set("v.formWrap.shipPhone",response.getReturnValue().shipPhone);
                   
                    cmp.set("v.isBillManualPhone",true);   
                    cmp.set("v.formWrap.billPhone",response.getReturnValue().billPhone);
                   
                    cmp.set("v.isShipPicklistPhone",false);
                    cmp.set("v.isBillPicklistPhone",false);
                    $A.util.addClass(cmp.find("selectShipPhone"), "slds-hide");
                    $A.util.addClass(cmp.find("selectBillPhone"), "slds-hide");
                }else{
                    cmp.set("v.isShipManualPhone",false);
                    cmp.set("v.isBillManualPhone",false);   
                    cmp.set("v.isShipPicklistPhone",true);
                    cmp.set("v.isBillPicklistPhone",true);
                }
                
                helper.initialEmailDropDownList(cmp, helper,response);                

                if (!$A.util.isEmpty(opportunity.StageName)){
                    if (cmp.get("v.OPPORTUNITY_STAGE_PAYMENT") == opportunity.StageName){
                        helper.openPaymentModal(cmp);         
                    }
                }     
              
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
			
        helper.getStoreDetails(cmp, event, helper);
		helper.checkDeliveryInfo(cmp, event, helper);
       var appEvent = $A.get("e.c:NotifyHeaderComponentEvent"); 
       appEvent.fire();
        $A.enqueueAction(action);
        
   },
    
    validateAddressForm : function(cmp,event,helper,shippingOrBilling) {
        if(!$A.util.isEmpty(cmp.get("v.formWrap"))){
            
            if(shippingOrBilling == 'Shipping') {
                // REQ 444 - Commented FirstName and LastName validation
                if(//cmp.get("v.formWrap").shipFirstName == "" ||
                   //cmp.get("v.formWrap").shipLastName == "" ||
                   cmp.get("v.formWrap").shipAddr1 == "" ||
                   cmp.get("v.formWrap").shipCity == "" ||
                   cmp.get("v.formWrap").shipState == "" ||
                   cmp.get("v.formWrap").shipPostalCode == "" ) 
                   
                {
                    if(cmp.get("v.formWrap").shipAddr1 == ""){
                        var shippingStreet = cmp.find('shippingStreet');
                        $A.util.addClass(shippingStreet, "addRequiredBorder");
                    }
                    if(cmp.get("v.formWrap").shipCity == ""){
                        var shippingCity = cmp.find('shippingCity');
                        $A.util.addClass(shippingCity, "addRequiredBorder");
                    } 
                    if(cmp.get("v.formWrap").shipState == ""){
                        var shippingState = cmp.find('shippingState');
                        $A.util.addClass(shippingState, "addRequiredBorder");
                    } 
                    if(cmp.get("v.formWrap").shipPostalCode == ""){
                        var shippingZip = cmp.find('shippingZip');
                        $A.util.addClass(shippingZip, "addRequiredBorder");
                    } 
                    cmp.set("v.isShipFormError",true);
                    helper.toastMessage("Error","",$A.get("$Label.c.Shipping_Form_Error"));
                }else{
                      cmp.set("v.isShipFormError",false);
                }
            }
            else {
				// DEF - 860 - Included this condition to avoid Billing Address form validation when
                // 'My Billing address is same as my shipping address' checkbox is checked by default.
                if(cmp.find("shipCheckBox") != undefined && !cmp.find("shipCheckBox").get("v.value")) {
                
                if(cmp.get("v.formWrap").billAddr1 == "" ||
                   cmp.get("v.formWrap").billCity == "" ||
                   cmp.get("v.formWrap").billState == "" ||                   
                   cmp.get("v.formWrap").billPostalCode == "") 
                   
                {
                    if(cmp.get("v.formWrap").billAddr1 == ""){
                        var billingStreet = cmp.find('billingStreet');
                        $A.util.addClass(billingStreet, "addRequiredBorder");
                    }
                    if(cmp.get("v.formWrap").billCity == ""){
                        var billingCity = cmp.find('billingCity');
                        $A.util.addClass(billingCity, "addRequiredBorder");
                    } 
                    if(cmp.get("v.formWrap").billState == ""){
                        var billingState = cmp.find('billingState');
                        $A.util.addClass(billingState, "addRequiredBorder");
                    } 
                    if(cmp.get("v.formWrap").billPostalCode == ""){
                        var billingZip = cmp.find('billingZip');
                        $A.util.addClass(billingZip, "addRequiredBorder");
                    } 
                    cmp.set("v.isBillFormError",true);
                    helper.toastMessage("Error","",$A.get("$Label.c.Billing_Form_Error"));
                }else{
                      cmp.set("v.isBillFormError",false);
                }
				}
            }
        }else{
            cmp.set("v.isShipFormError",true);
            helper.toastMessage("Error","","Please input Address info");
        }
    },
     // Validate new shipping and billing phone and email values
    validatePhoneAndEmail : function(cmp,event,helper,shippingOrBilling) {
        if(!$A.util.isEmpty(cmp.get("v.formWrap"))){
            
            if(shippingOrBilling == 'Shipping') {
                if($A.util.isEmpty(cmp.get("v.formWrap").shipPhone)  || $A.util.isEmpty(cmp.get("v.formWrap").shipEmail)){
                    if($A.util.isEmpty(cmp.get("v.formWrap").shipPhone))  {
                        cmp.set("v.isShipPhoneAndEmailError",true);
                        helper.toastMessage("Error","","Please input ship phone info.");
                    }   
                    if($A.util.isEmpty(cmp.get("v.formWrap").shipEmail))  {
                        cmp.set("v.isShipPhoneAndEmailError",true);
                        helper.toastMessage("Error","","Please input ship email info.");
                    }  
                }else{
                    
                    var phoneRegExp = /^\(?([0-9]{3})\)?[-. ]?([0-9]{3})[-. ]?([0-9]{4})$/; 
                    var isValidPhone = phoneRegExp.test(cmp.get("v.formWrap").shipPhone);
                    if (!isValidPhone) {
                        cmp.set("v.isShipPhoneAndEmailError",true);
                        helper.toastMessage("Error","",$A.get("$Label.c.Phone_Error"));
                    }
                    var emailRegExp =  /^([A-Za-z0-9_\-\.])+\@([A-Za-z0-9_\-\.])+\.([A-Za-z]{2,4})$/; 
                    
                    var isValidEmail = emailRegExp.test(cmp.get("v.formWrap").shipEmail);
                    if (!isValidEmail) {
                        cmp.set("v.isShipPhoneAndEmailError",true);
                        helper.toastMessage("Error","","Invalid format Shipping Email");
                    }

                    if(isValidPhone && isValidEmail){
                      cmp.set("v.isShipPhoneAndEmailError",false);
                    }
                }
            }
            else {
                if(!cmp.get("v.showBillingInfo"))
                {
                   cmp.set("v.formWrap.billPhone",cmp.get("v.formWrap.shipPhone"));
                   cmp.set("v.formWrap.billEmail",cmp.get("v.formWrap.shipEmail"));
                   console.log("----------------------showBillingInfo-------------------"+cmp.get("v.showBillingInfo"));
                }
                if($A.util.isEmpty(cmp.get("v.formWrap").billPhone)  || $A.util.isEmpty(cmp.get("v.formWrap").billEmail) ){
                    if($A.util.isEmpty(cmp.get("v.formWrap").billPhone))  {
                        cmp.set("v.isBillPhoneAndEmailError",true);
                        helper.toastMessage("Error","","Please input bill phone info.");
                    }   
                    if($A.util.isEmpty(cmp.get("v.formWrap").billEmail))  {
                        cmp.set("v.isBillPhoneAndEmailError",true);
                        helper.toastMessage("Error","","Please input bill email info.");
                    }  
                }else{
                    
                    var phoneRegExp = /^\(?([0-9]{3})\)?[-. ]?([0-9]{3})[-. ]?([0-9]{4})$/; 
                    var isValidPhone = phoneRegExp.test(cmp.get("v.formWrap").billPhone);
                    if (!isValidPhone) {
                        cmp.set("v.isBillPhoneAndEmailError",true);
                        helper.toastMessage("Error","",$A.get("$Label.c.Phone_Error"));
                    }
                    var emailRegExp =  /^([A-Za-z0-9_\-\.])+\@([A-Za-z0-9_\-\.])+\.([A-Za-z]{2,4})$/; 
                    
                    var isValidEmail = emailRegExp.test(cmp.get("v.formWrap").shipEmail);
                    if (!isValidEmail) {
                        cmp.set("v.isBillPhoneAndEmailError",true);
                        helper.toastMessage("Error","","Invalid format Billing Email");
                    }

                    if(isValidPhone && isValidEmail){
                      cmp.set("v.isBillPhoneAndEmailError",false);
                    }
                }
            }
        }else{
            cmp.set("v.isShipPhoneAndEmailError",true);
            helper.toastMessage("Error","","Please input Phone and Email info");
        }
    },
	closeModal : function(component,containerName){
        console.log("----in cancelI");
         
        var popUp = component.find(containerName);
        console.log(popUp);
        $A.util.removeClass(popUp, 'slds-fade-in-open');
        $A.util.addClass(popUp, 'slds-fade-in-close');
        var backdrop = component.find("backdropContainer");
        console.log(backdrop);
        $A.util.removeClass(backdrop, 'slds-modal-backdrop--open');
        $A.util.addClass(backdrop, 'slds-modal-backdrop--close');
    },
    
    checkDeliveryInfo: function(cmp, event, helper) {
        console.log(cmp.get('v.guestId'));
        var action = cmp.get("c.getShoppingCartLineItems");
        action.setParams({ "accountId"  :  cmp.get('v.guestId')});       
  
        action.setCallback(this, function(response) {
            var state = response.getState();
            var rtnValue  = response.getReturnValue();
            if (state === "SUCCESS") {
                if (!$A.util.isEmpty(rtnValue)){
                    var isDesiredDeliveryDateRequired = false;
                    var isDeliveryDatesChosen = true;
                    var showCalendar = false;
                    for (var deliveryMethod in rtnValue) {
                        //DEF-958 Desired Delivery Date Rquired for all Shipping types
                        isDesiredDeliveryDateRequired = true;
                        if(!showCalendar){
                            if(['HD', 'CPW', 'CPS', 'DS'].indexOf(deliveryMethod) > -1){
                                showCalendar = true;
                            }
                        }
                        //DEF-958 End
                        var lineItems = rtnValue[deliveryMethod];
                        if (!$A.util.isEmpty(lineItems)){
                            for (var i = 0; i < lineItems.length; i++) {
                                if ($A.util.isEmpty(lineItems[i].DeliveryDate__c)){
                                    isDeliveryDatesChosen = false;
                                }
                            }
                        }
                    }
                    cmp.set("v.isDesiredDeliveryDateRequired", isDesiredDeliveryDateRequired);
                    cmp.set("v.isDeliveryDatesChosen", isDeliveryDatesChosen);
                    //DEF-958 Desired Delivery Date Rquired for all Shipping types
                    cmp.set("v.showCalendar", showCalendar);
                    //DEF-958 End
                }
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
		$A.enqueueAction(action);
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
    
    doSuspendSales : function(cmp, success, failure){
        var self = this;
        var toastErrorHandler = cmp.find('toastErrorHandler');
        var action = cmp.get("c.suspendSales");
        action.setParams({ 
            "formWrapStr" : JSON.stringify(cmp.get("v.formWrap")),
            "personAccId"  : cmp.get("v.guestId"),
            "billAddr"   : ( !$A.util.isEmpty(cmp.get("v.currBillAddr")) ? cmp.get("v.currBillAddr") : cmp.get("v.newBillAddr") ), 
            "shipAddr" : ( !$A.util.isEmpty(cmp.get("v.currShipAddr")) ? cmp.get("v.currShipAddr") : cmp.get("v.newShipAddr") ) 
        });       
     
        action.setCallback(this, function(response) {
            toastErrorHandler.handleResponse(
                response, // handle failure
                function(response){ // navigate to contact record
                    var spinner = cmp.find("largeSpinner");
        			$A.util.toggleClass(spinner, "slds-hide");
                    self.toastMessage("success","","Suspended Sales Successfully!");
                    if (success) {
                        success.call(this);
                    }
                },
                function(response, message){ // report failure
                    var spinner = cmp.find("largeSpinner");
        			$A.util.toggleClass(spinner, "slds-hide");
                    self.toastMessage("error", "ERROR : ", message);
                    if (failure) {
                        failure.call(this);
                    }                     
                }
            )
        });
		$A.enqueueAction(action);
    },
    
    loadDeliveryModal: function(cmp, event, helper){
        $A.createComponent(
            "c:PickDeliveryDate",
          {
                "GuestId": cmp.get('v.guestId'),
                "shipAddr" :  ( !$A.util.isEmpty(cmp.get("v.currShipAddr")) ? cmp.get("v.currShipAddr") : cmp.get("v.newShipAddr") )
            },
            function(newcomponent){
                if (cmp.isValid()) {
                    var body = cmp.get("v.body");
                    body.push(newcomponent);
                    cmp.set("v.body", body);             
                }
            }            
        );
	},
    
    sendOrderToHome: function(cmp, success, failure){
        var self = this;
        var toastErrorHandler = cmp.find('toastErrorHandler');
        var action = cmp.get("c.sendOrderToHome");
        action.setParams({"formWrapStr" : JSON.stringify(cmp.get("v.formWrap")),
                          "accountId"  :  cmp.get('v.guestId'),
                          "billAddr"   : ( !$A.util.isEmpty(cmp.get("v.currBillAddr")) ? cmp.get("v.currBillAddr") : cmp.get("v.newBillAddr") ), 
                          "shipAddr" : ( !$A.util.isEmpty(cmp.get("v.currShipAddr")) ? cmp.get("v.currShipAddr") : cmp.get("v.newShipAddr") ) } );       
        action.setCallback(this, function(response) {
            toastErrorHandler.handleResponse(
                response, // handle failure
                function(response){ // navigate to contact record
                    var rtnValue  = response.getReturnValue();
                    if(rtnValue){
                        var spinner = cmp.find("largeSpinner");
                        $A.util.toggleClass(spinner, "slds-hide");
                        self.toastMessage("success","","Sales Order Created Successfully!");
                        cmp.set("v.receiptUrl",rtnValue.eReceiptBlobStorageUri);
                        cmp.set("v.SONumber",rtnValue.salesOrderResult[0].SalesOrderNumber);
                        if (success) {
                            success.call(this);
                        }
                    }
                },
                function(response, message){ // report failure
                    var spinner = cmp.find("largeSpinner");
        			$A.util.toggleClass(spinner, "slds-hide");
                    self.toastMessage("error", "ERROR : ", message);
                    if (failure) {
                        failure.call(this);
                    }                    
                }
            )
        });
        action.setBackground();
		$A.enqueueAction(action);
    },
    
    initialEmailDropDownList: function(cmp, helper,response){
        
         var opts=[];
               opts.push({class: "optionClass",
                           label: "",
                            value: ""});
                var lstEmails = response.getReturnValue().lstEmails; 
                for(var opt in lstEmails){
                    opts.push({class: "optionClass",
                            label: lstEmails[opt],
                            value: lstEmails[opt]});
                     if(response.getReturnValue().shipEmail==lstEmails[opt]){
                        cmp.set("v.shipEmail", response.getReturnValue().shipEmail);
                         cmp.set("v.formWrap.shipEmail", response.getReturnValue().shipEmail);
                    }
                     if(response.getReturnValue().billEmail==lstEmails[opt]){
                        cmp.set("v.billEmail", response.getReturnValue().billEmail);
                         cmp.set("v.formWrap.billEmail", response.getReturnValue().billEmail);
                    }
                }
                cmp.set("v.lstEmails", opts);
                if(cmp.get("v.lstEmails").length >2){
                  window.setTimeout(
                $A.getCallback( function() {
                    cmp.find("selectShipEmail").set("v.value",lstEmails[0]);
                    cmp.set("v.formWrap.shipEmail",lstEmails[0]);
                     
                    }));
                }
        
                var lstEmailsSize = response.getReturnValue().lstEmails.length;
                cmp.set("v.emailCount",lstEmailsSize);
        
                console.log("email size-->"+lstEmailsSize);
                if(lstEmailsSize <=1){
                    console.log("within if emails");
                    cmp.set("v.isShipManualEmail",true);
                    cmp.set("v.isBillManualEmail",true);   
                    cmp.set("v.isShipPicklistEmail",false);
                    cmp.set("v.isBillPicklistEmail",false);
                    $A.util.addClass(cmp.find("selectShipEmail"), "slds-hide");
                    $A.util.addClass(cmp.find("selectBillEmail"), "slds-hide");
                }else{
                    console.log("within else emails");
                    cmp.set("v.isShipManualEmail",false);
                    cmp.set("v.isBillManualEmail",false);   
                    cmp.set("v.isShipPicklistEmail",true);
                    cmp.set("v.isBillPicklistEmail",true);
                }
    },
    
    // Performance issue fix - perform single update on opportunity instead of multiple updates
    updateDetailsOnOpty : function(cmp, event, helper, success) {
        var action = cmp.get("c.updateAddressOnOpty");
        action.setParams({ 
            "formWrapStr" : JSON.stringify(cmp.get("v.formWrap")),
            "personAccId" : cmp.get("v.guestId"), 
            "billAddr" 	  : ( !$A.util.isEmpty(cmp.get("v.currBillAddr")) ? cmp.get("v.currBillAddr") : cmp.get("v.newBillAddr") ), 
            "shipAddr" 	  : ( !$A.util.isEmpty(cmp.get("v.currShipAddr")) ? cmp.get("v.currShipAddr") : cmp.get("v.newShipAddr") )
        });       
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            //alert('state'+state);
            if (state === "SUCCESS") {
                if (success) {
                    success.call(this);
                }
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        action.setBackground();
        $A.enqueueAction(action);	    
    },
	
    isDeliveryDatesChosen: function(cmp, event, helper,containerName) {
        var action = cmp.get("c.isDeliveryDatesChosen");
        action.setParams({ "oppId"  :  cmp.get('v.oppId'),
                           "notes":cmp.find('deliveryNotes').get('v.value')});       
        action.setCallback(this, function(response) {
            var state = response.getState();
            var rtnValue  = response.getReturnValue();
            if (state === "SUCCESS") {
                console.log('rtnValue-->'+rtnValue);
                cmp.set('v.isDeliveryDatesChosen',rtnValue);
                if(cmp.get("v.isDeliveryDatesChosen") == true)
                {
                    helper.closeModal(cmp,containerName);
                }
                else{
                    helper.toastMessage("Error","","Pick Delivery Dates for all items in the cart");
                }
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                        
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
		$A.enqueueAction(action);
    },
    // Validation logic
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
                auraId : 'shippingStreet',
                fieldName : 'shipAddr1'
            },
            // Second street's auraId and the field name of the object containing the value
            apartmentNumber : {
                auraId : 'shippingStreet2',
                fieldName : 'shipAddr2'
            },
            // City's auraId and the field name of the object containing the value
            city : {
                auraId : 'shippingCity',
                fieldName : 'shipCity'
            },
            // State's auraId and the field name of the object containing the value
            state : {
                auraId : 'shippingState',
                fieldName : 'shipState'
            },
            // Zip's auraId and the field name of the object containing the value
            zip : {
                auraId : 'shippingZip',
                fieldName : 'shipPostalCode'
            },
            // Validation status's auraId and the field name of the object containing the value
            status : {
                auraId : 'shippingValStatus',
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
            addressObjectPropertyName : 'formWrap',
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
                auraId : 'billingStreet',
                fieldName : 'billAddr1'
            },
            // Second street's auraId and the field name of the object containing the value
            apartmentNumber : {
                auraId : 'billingStreet2',
                fieldName : 'billAddr2'
            },
            // City's auraId and the field name of the object containing the value
            city : {
                auraId : 'billingCity',
                fieldName : 'billCity'
            },
            // State's auraId and the field name of the object containing the value
            state : {
                auraId : 'billingState',
                fieldName : 'billState'
            },
            // Zip's auraId and the field name of the object containing the value
            zip : {
                auraId : 'billingZip',
                fieldName : 'billPostalCode'
            },
            // Validation status's auraId and the field name of the object containing the value
            status : {
                auraId : 'billingValStatus',
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
            addressObjectPropertyName : 'formWrap',
            // The property name of the object containing the address snapshot
            addressObjectSnapshotPropertyName : 'ShippingAddressObjectSnapshot',

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

        if("undefined" === typeof searchTermValue || searchTermValue.length < 2 ){return;}

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
    // EDQ added Validation logic
    cleanupAddressFields : function(component, settings) {
        for(var addressMap in settings.addressMapping) {
            if(!settings.addressMapping.hasOwnProperty(addressMap)) continue;
            var settingsProperty = settings.addressMapping[addressMap];
            if(settings.hasOwnProperty(settingsProperty) && settings[settingsProperty] && settings[settingsProperty].auraId) {
                component.find(settings[settingsProperty].auraId).set('v.value', "");
            }
    	}
    },
    isValidForm : function(cmp, event, helper){
        // Set the boolean attribute to false
       // alert('enter 2');
        var valid = false;
        // Validate shipping information
        this.validatePhoneAndEmail(cmp,event,this,'Shipping');
        if(cmp.get("v.showShipAddForm")){
            this.validateAddressForm(cmp,event,this,'Shipping');
        }
        // Validate billing information
        this.validatePhoneAndEmail(cmp,event,this,'Billing');
        if(!cmp.get("v.showBillingInfo")){
            this.validatePhoneAndEmail(cmp,event,this,'Billing');
        }
        if(cmp.get("v.showBillAddForm")) {
            this.validateAddressForm(cmp,event,this,'Billing');
        }
        if(!cmp.get("v.isShipFormError")  
            && !cmp.get("v.isBillFormError") 
            && !cmp.get("v.isShipPhoneAndEmailError")  
            && !cmp.get("v.isBillPhoneAndEmailError")){ 
            valid = true;
        }
       // alert('valid'+valid);
        return valid;
    },    
    openPaymentModal: function(component) {
       //  alert('entered helper');
        var overlay = component.find('overlay');
        $A.util.addClass(overlay, 'slds-backdrop--open');
        var targetCmp = component.find("paymentModal");
        if ( ($A.util.isEmpty(targetCmp.get("v.body"))) ) {
            $A.createComponent(
                "c:PaymentModal",
                {
                    "aura:id" : "paymentModalId",
                    "guestId" : component.getReference("v.guestId"),
                    "opportunityId" : component.getReference("v.oppId"),
                    "paymentMethods" : component.getReference("v.payments"),
                    "targetAmount" : component.getReference("v.orderTotal"),
                    "legalEntityName" : component.getReference("v.legalEntityName")
                },
                function(newPaymentModal, status, errorMessage){
                    if (newPaymentModal.isValid() && status === "SUCCESS") {
                        targetCmp.set("v.body", newPaymentModal);
                    }
                }
            );
        }        
    },
    closePaymentModal: function(component) {
        var targetCmp = component.find("paymentModal");
        if ( !($A.util.isEmpty(targetCmp.get("v.body"))) ) {
            targetCmp.set("v.body", []);
        }
        var overlay = component.find('overlay');
        $A.util.removeClass(overlay, 'slds-backdrop--open');                
    },
    suspendToPosSuccess: function(component) {
        var appEvent = $A.get("e.c:NotifyHeaderComponentEvent"); 
           				appEvent.fire();
                    var appEvent = $A.get("e.c:NavigateToWrapperComponentAppEvent");
                    appEvent.setParams({
                        "targetCmpName" : 'SuspendSaleCompleteWrapperCmp',
                        "targetCmpParameters" : {}
                    });
                    appEvent.fire();
       // window.location.reload();
       
    },    
    placeOrderSuccess: function(component) {
        //REQ 472 - Sale Complete Page
        this.orderComplete(component);
    },    
    
    // REQ 472 - Sale Complete Page
    orderComplete: function(component) {
        // Req 486 - Print Receipt
        var appEvent = $A.get("e.c:NavigateToWrapperComponentAppEvent");
        appEvent.setParams({
            "targetCmpName" : 'CustomerOrderCompleteWrapperCmp',
            "targetCmpParameters" : {"receiptUrl": component.get("v.receiptUrl"), "SONumber": component.get("v.SONumber")}
        });
        appEvent.fire();
        // End of Req 486 - Print Receipt      
    },
    //End of REQ 472
 

    navigateToURL: function(url) {
        var evt  = $A.get("e.force:navigateToURL");
        evt.setParams({"url": url})
        evt.fire();        
    },
    getOpportunity: function(cmp, success, failure){
        var self = this;
        var toastErrorHandler = cmp.find('toastErrorHandler');
        var action = cmp.get("c.getOpportunity");
        action.setParams({"personAccId" : cmp.get('v.guestId')});       
        action.setCallback(this, function(response) {
            toastErrorHandler.handleResponse(
                response, // handle failure
                function(response){ // navigate to contact record
                    var rtnValue  = response.getReturnValue();
                    if(!($A.util.isEmpty(rtnValue))){
                        if (success) {
                            success.call(this, rtnValue);
                        }
                    }
                },
                function(response, message){ // report failure
                    self.toastMessage("error", "ERROR : " + message);
                    if (failure) {
                        failure.call(this);
                    }                    
                }
            )
        });
        action.setBackground();
        $A.enqueueAction(action);
    },  
    
    getStoreDetails : function(cmp, success, failure){
        var self = this;
        var toastErrorHandler = cmp.find('toastErrorHandler');
        var action = cmp.get("c.getStoreInfo");
        
        action.setCallback(this, function(response) {
            toastErrorHandler.handleResponse(
                response, // handle failure
                function(response){ // navigate to contact record
                    var rtnValue  = response.getReturnValue();
                    if(!($A.util.isEmpty(rtnValue))){
                        cmp.set("v.legalEntityName",rtnValue.entityName);
                    }
                },
                function(response, message){ // report failure
                    self.toastMessage("error", "ERROR : " + message);
                    if (failure) {
                        failure.call(this);
                    }                    
                }
            )
        });
        action.setBackground();
        $A.enqueueAction(action);
    },
    reInitializeAddressFields : function(formWrap, formWrapMapRow, currId, billingOrShipping) {
        if(billingOrShipping == 'shipping') {
            formWrap.shipAddr1 = formWrapMapRow.shipAddr1;
            formWrap.shipAddr2 = formWrapMapRow.shipAddr2;
            formWrap.shipCity = formWrapMapRow.shipCity;
            formWrap.shipState = formWrapMapRow.shipState;
            formWrap.shipPostalCode = formWrapMapRow.shipPostalCode;            
            formWrap.oldAddrId = (currId != null && currId != '') ? currId : formWrapMapRow.oldAddrId;
        }
        else if(billingOrShipping == 'billing') {
            formWrap.billAddr1 = formWrapMapRow.billAddr1;
            formWrap.billAddr2 = formWrapMapRow.billAddr2;
            formWrap.billCity = formWrapMapRow.billCity;
            formWrap.billState = formWrapMapRow.billState;
            formWrap.billPostalCode = formWrapMapRow.billPostalCode;
            formWrap.oldAddrId = (currId != null && currId != '') ? currId : formWrapMapRow.oldAddrId;
        }
        return formWrap;
    }
    
     
})