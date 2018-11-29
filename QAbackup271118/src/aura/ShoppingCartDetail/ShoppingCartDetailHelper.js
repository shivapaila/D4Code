({
    cmpdoInit :function (component, event, helper){
       component.set("v.spinner", true);
        //helper.getRecId(component);
        helper.getCartStateList(component,helper);   
        helper.getCustomerInfo(component,helper);
        //REQ-438, comment below getShoppingCartLineItems to avoid cart page load twice.
        //In helper.getCustomerInfo, getShoppingCartTax will be called, it make sure lineItem get data up to date, 
        // and then in getShoppingCartTax, getShoppingCartLineItems will be called - JoToTheyagu
        //this the method call that get shoppingcart list wrapper for REQ-431- theyagu
        //helper.getShoppingCartLineItems(component,helper);
        helper.getShippingWayList(component,helper);
        helper.getDiscountReasonList(component,helper);
        
        helper.getMarketDiscountCriteria(component,helper);        
        helper.getAccountStoreInfo(component,helper);
		helper.getFppTypes(component,helper);   
        
        helper.getCanViewCheckout(component,helper);
        	//var appEvent = $A.get("e.c:NotifyHeaderComponentEvent"); 
            //appEvent.fire();
        component.set("v.isShowPosModal",false);
        component.set("v.SubComponent",false);
       
          var overlay = component.find('overlay');
        $A.util.removeClass(overlay, 'slds-backdrop--open');
       
        
    },
    getRecId : function(component) {
      
        var url=location.href.split('/n/');
        if(url != null && url[1] != null){
            var splitUrl=url[1].split('?');
            if(splitUrl != null && splitUrl[1] != null){
              /*  var Id=splitUrl[1].split('=');
                if(Id != null && Id[1] != null){
                    component.set('v.recordId',Id[1]);
                    console.log('@@@..'+component.get('v.recordId'));
                }else{
                    helper.showToast("error", 'No Customer', component,
                                         'Please choose a customer.');   
                    
                }*/
                
                if(splitUrl != null && splitUrl[1] != null){
                    var paraList =splitUrl[1].split('&');
                    for(var i=0; i<paraList.length; i++){
                        var Id=paraList[i].split('=');
                        if(Id != null && Id[1] != null && Id[1] !=undefined){
                            //component.set('v.'+Id[0],unescape(Id[1]));
                            component.set('v.recordId',unescape(Id[1]));
                        }
                    }
                }
                
                if( $A.util.isEmpty(component.get('v.recordId'))){
                      helper.showToast("error", 'No Customer', component,
                                         'Please choose a customer.');   
                }
                
            }
        }
         
        
     /*   var pageReference = component.get("v.pageReference");
            
        // If navigation from another location
        if(!$A.util.isUndefinedOrNull(pageReference)) {
            //Read parameters from pageReference state
            var receivedParams = pageReference.state;
            
            //Set component attributes to parameters received from state
            if(!$A.util.isUndefinedOrNull(receivedParams.c__recordId)) {
                component.set("v.recordId", receivedParams.c__recordId);
            }
            
            if(!$A.util.isEmpty(component.get("v.recordId"))) {
            	helper.showToast("error", 'No Customer', component, 'Please choose a customer.');   
            }
        }
        */
    },
    
    // to avoid multiple spinners issue
    pushToListOfCompletedEvents : function(component, nameOfEvent) {
        var lstOfEvents = component.get("v.listofEventsCompleted");
        if(lstOfEvents == null) {
            lstOfEvents = [];
        }
        lstOfEvents.push(nameOfEvent);
        component.set("v.listofEventsCompleted", lstOfEvents);
    },

    getShoppingCartTax : function(component, success) {
        console.log('getShoppingCartTax Called');
        var self = this;
        var action = component.get("c.getShoppingCartTaxInfo");
        console.log(component.get('v.recordId'));
        action.setParams({"accountId" : component.get('v.recordId')});
        
        var toastErrorHandler = component.find('toastErrorHandler');
        action.setCallback(this, function(response){
            toastErrorHandler.handleResponse(
                response,
                function(response){
                    var rtnValue = response.getReturnValue();
                    console.log(rtnValue);
                    if (rtnValue !== null) {    
                        component.set("v.shoppingCartDeliveryFee", rtnValue["TotalDeliveryAmount"]);
                        component.set("v.shoppingCartTotal", rtnValue["SalesGrandTotal"]);
                        component.set("v.shoppingCartTotalBeforeTax", rtnValue["TotalProductLastAmount"]);  
                        component.set("v.shoppingCartEstimatedTax", rtnValue["TotalTaxAmount"]);
                        component.set("v.shoppingCartWarrantyFee", rtnValue["TotalWarrantyAmount"]);  
                        component.set("v.shoppingCartRecycleFee", rtnValue["TotalRecycleAmount"]);
                       	component.set("v.shoppingCartNextDayCharge", rtnValue["TotalNextDayCharge"]);
                       	component.set("v.shoppingCartWarrantyItemFee", rtnValue["WarrantyItemAmount"]);
                       
                               
                    }else {
                        self.showToast("error", 'Tax Info is empty', component,
                                         'Could not get Tax Info.');                        
                    }
                    //REQ-438, move getShoppingCartLineItems to here to fix cart page load twice.
                    //helper.getShoppingCartLineItems(component,helper);
                    if (success) {
                        success.call(this);
                    }                      
                },
                function(response, message){ // report failure
                    // DEF-0777 fix
                    self.showToast("error", '', component, message);
                    //REQ-438, add getShoppingCartLineItems to here in case not show cart item when get exception, so to fix cart page load twice.
                    //helper.getShoppingCartLineItems(component,helper); 
                    if (success) {
                        success.call(this);
                    }                     
                }
            )
        });            
        action.setBackground();
        $A.enqueueAction(action); 
    },
    
    getCustomerInfo: function(component,helper) {
        var action = component.get("c.getShoppingCart");
        console.log(component.get('v.recordId'));
   		action.setParams({"accountId" : component.get('v.recordId')});
             
        var toastErrorHandler = component.find('toastErrorHandler');
        action.setCallback(this, function(response){
            // to avoid multiple spinners issue
            this.pushToListOfCompletedEvents(component, "getCustomerInfo");
            toastErrorHandler.handleResponse(
                response,
                function(response){
                    var rtnValue = response.getReturnValue();
                    if (!$A.util.isEmpty(rtnValue) && !$A.util.isEmpty(rtnValue.Id)) {  
                        component.set("v.opp", rtnValue);
                        // call getShoppingCartTax (which will call getShoppingCartLineitems) only when getCustomerInfo
                        // call is success and zip/state are not empty
                        // will also be called after a zip/state is added
                        var opportunity = component.get("v.opp");
                        console.log(opportunity["Cart_ZipCode__c"]);
                        console.log(opportunity["Cart_State__c"]);
                       
                        if (!$A.util.isEmpty(opportunity["Cart_ZipCode__c"]) && !$A.util.isEmpty(opportunity["Cart_State__c"])) {
                            helper.getShoppingCartTax(component, function(){
                                component.set("v.spinner", true);
                                helper.getShoppingCartLineItems(component, null, function(){
                                    component.set("v.spinner", false);
                                },
                                function(){
                                    component.set("v.spinner", false);
                                });
                            });
                        }
                        // DEF-0780 fix
                        else {
                            component.set("v.spinner", false);
                        }
                    }else {
                        helper.showToast("error", 'Could not find this cart', component,
                                         'Couldn not find this cart, please confirm this cart is valid!');                        
                    }
                    //REQ-438, move getShoppingCartTax to here to fix cart page load twice.
                    //helper.getShoppingCartTax(component,helper);
                },
                function(response, message){ // report failure
                    helper.showToast("error", 'Could not find this cart', component,
                                     message);
                    // commented out - at getShoppingCartTax (which will call getShoppingCartLineItems) only when getCustomerInfo
                    // call is success and zip/state are not empty
                    // will also be called after a zip/state is added
                    //REQ-438, add getShoppingCartTax to here in case not show cart item when get exception, so to fix cart page load twice.
                    //helper.getShoppingCartTax(component,helper);
                }
            )
        });            
        action.setBackground();
        $A.enqueueAction(action); 
    },
	getCanViewCheckout : function(component,helper) {
        var action = component.get("c.canViewCheckout");
        var toastErrorHandler = component.find('toastErrorHandler');
        action.setParams({"accountId" : component.get('v.recordId')});
      
        action.setCallback(this, function(response){
            // to avoid multiple spinners issue
            this.pushToListOfCompletedEvents(component, "getCanViewCheckout");
            toastErrorHandler.handleResponse(
                response,
                function(response){
                    var str = response.getReturnValue();
                    if(str.includes('viewCheckout')){
                        // Proceed To Review
                        component.set("v.canViewCheckout", true);
                    }else{
                        component.set("v.canViewCheckout", false);
                    }
                    // UAT Testing Issue - change it to suspend POS so it wont conflict with viewcheckout
                    if(str.includes('viewSuspendPOS')){
                        component.set("v.canViewCheckoutPOS", true); 
                    }else{
                        component.set("v.canViewCheckoutPOS", false);
                    }
                },
                function(response, message){ // report failure
                    helper.showToast("error", 'Permissions query failed', component,
                                     message);
                }
            )
        });            
        action.setBackground();
        $A.enqueueAction(action); 
    },
    getShoppingCartLineItems : function(component, lineItemIds, success, failure) {
      // alert('getShoppingCartLineItems Called');
        var self = this;
        //REQ-438, instead of getShoppingCartLineItems by using getShoppingCartLineItemsWrapper
        var action = component.get("c.getShoppingCartLineItemsWrapper");
        action.setParams({"accountId" : component.get('v.recordId'), "lineItemIds" : lineItemIds});
        
        var toastErrorHandler = component.find('toastErrorHandler');
        action.setCallback(this, function(response){
            // DEF-0780 fix
            this.pushToListOfCompletedEvents(component, "getShoppingCartLineItems");
            toastErrorHandler.handleResponse(
                response,
                function(response){
                    var rtnValue = response.getReturnValue();
                    if (rtnValue !== null) {    
                        console.log('wrapper-->'+JSON.stringify(rtnValue));
                        if (!$A.util.isEmpty(lineItemIds)){
                            // DEF-0780 - Manually add product performance fix
                            var retShoppingCartLineItems = rtnValue;
                            var shoppingCartLineItems = component.get("v.shoppingCartLineItems");                            
                            var mergedShoppingCartLineItems = [];
                            var retObj = {};
                            var originalObj = {};
                            var mergedObj = {};
                            for (var i=0; i < shoppingCartLineItems.length; i++){
                                if(shoppingCartLineItems[i].item != null 
                                    && shoppingCartLineItems[i].item.Id != null) {
                                    originalObj[shoppingCartLineItems[i].item.Id] = shoppingCartLineItems[i];
                                }
                            }
                            for (var i=0; i < retShoppingCartLineItems.length; i++){
                                if(retShoppingCartLineItems[i].item != null 
                                    && retShoppingCartLineItems[i].item.Id != null) {
                                    retObj[retShoppingCartLineItems[i].item.Id] = retShoppingCartLineItems[i];
                                }
                            }
                            mergedObj = self.extend(originalObj, retObj);
                            for(var key in mergedObj) {
                                mergedShoppingCartLineItems.push(mergedObj[key]);
                            }
                            component.set("v.shoppingCartLineItems", mergedShoppingCartLineItems);

                        } else {
                            component.set("v.shoppingCartLineItems", rtnValue);
                        }
                        //REQ-489 item 7
                        if(rtnValue.length==0){
                            self.showToast("error", 'Cart is empty', component,
                                         'Please add at least 1 item to the cart to proceed.');       
                        }
                    }else {
                        self.showToast("error", 'Cart is empty', component,
                                         'Could not find Cart Line Items.');                        
                    }
                    if (success) {
                        success.call(this);
                    }                    
                },
                function(response, message){ // report failure
                    self.showToast("error", 'Cart query failed', component,
                                     message);
                    // alert('getShoppingCartLineItems report failure');
                    if (failure) {
                        failure.call(this);
                    }                    
                }
            )
        });            
        action.setBackground();
        $A.enqueueAction(action); 
    },
    // DEF-0780 - Manually add product performance fix - method to compare and merge line items
    // if an item is common, src will be used
    extend: function(obj, src) {
        var mergedShoppingCartLineItems = [];
       for (var key in src) {
           if (src.hasOwnProperty(key)) obj[key] = src[key];
       }
       return obj;
    },
    getShippingWayList: function(component,helper) {
		 var action = component.get("c.getShippingWayList");
        var toastErrorHandler = component.find('toastErrorHandler');
        action.setCallback(this, function(response){
            // to avoid multiple spinners issue
            this.pushToListOfCompletedEvents(component, "getShippingWayList");
            toastErrorHandler.handleResponse(
                response,
                function(response){
                    var rtnValue = response.getReturnValue();
                    console.log(rtnValue);
                    if (rtnValue !== null) {    
                        console.log(rtnValue);
                        component.set("v.shippingWayList", rtnValue);
                    }else {
                        helper.showToast("error", 'Shipping way are empty', component,
                                         'Could not find Shipping way .');                        
                    }
                },
                function(response, message){ // report failure
                    helper.showToast("error", 'Shipping way are empty', component,
                                     message);
                }
            )
        });            
        action.setBackground();
        $A.enqueueAction(action); 
    },
    getDiscountReasonList: function(component,helper) {
		 var action = component.get("c.getDiscountReasonList");
        var toastErrorHandler = component.find('toastErrorHandler');
        action.setCallback(this, function(response){
            // to avoid multiple spinners issue
            this.pushToListOfCompletedEvents(component, "getDiscountReasonList");
            toastErrorHandler.handleResponse(
                response,
                function(response){
                    var rtnValue = response.getReturnValue();
                    console.log(rtnValue);
                    if (rtnValue !== null) {    
                        console.log(rtnValue);
                        component.set("v.discountReasonList", rtnValue);
                    }else {
                        helper.showToast("error", 'Discount Reason are empty', component,
                                         'Could not find Discount Reason  .');                        
                    }
                },
                function(response, message){ // report failure
                    helper.showToast("error", 'Discount Reason  are empty', component,
                                     message);
                }
            )
        });            
        action.setBackground();
        $A.enqueueAction(action); 
    },
    getMarketDiscountCriteria: function(component,helper) {
        var action = component.get("c.getRSAMarketDiscountThreshholds");
        var toastErrorHandler = component.find('toastErrorHandler');
        action.setCallback(this, function(response){
            // to avoid multiple spinners issue
            this.pushToListOfCompletedEvents(component, "getMarketDiscountCriteria");
            toastErrorHandler.handleResponse(
                response,
                function(response){
                    var rtnValue = response.getReturnValue();
                    console.log(rtnValue);
                    if (rtnValue !== null) {    
                        console.log(rtnValue);
                        component.set("v.marketDiscountCriteria", rtnValue);
                    }else {
                        helper.showToast("error", 'Market Discount Criteria are empty', component,
                                         'Could not find Market Discount Criteria.');                        
                    }
                },
                function(response, message){ // report failure
                    helper.showToast("error", 'Market Discount Criteria are empty', component,
                                     message);
                }
            )
        });            
        action.setBackground();
        $A.enqueueAction(action); 
    },
    getAccountStoreInfo: function(component,helper) {
		 var action = component.get("c.getRSAOneSourceId");
        var toastErrorHandler = component.find('toastErrorHandler');
        action.setCallback(this, function(response){
            // to avoid multiple spinners issue
            this.pushToListOfCompletedEvents(component, "getAccountStoreInfo");
            toastErrorHandler.handleResponse(
                response,
                function(response){
                    var rtnValue = response.getReturnValue();
                    console.log(rtnValue);
                    if (rtnValue !== null) {    
                        console.log(rtnValue);
                        component.set("v.accountStoreInfo", rtnValue);
                    }else {
                        helper.showToast("error", 'RSA One Source Id Info are empty', component,
                                         'Could not find RSA One Source Id Info.');                        
                    }
                },
                function(response, message){ // report failure
                    helper.showToast("error", 'RSA One Source Id Info are empty', component,
                                     message);
                }
            )
        });            
        action.setBackground();
        $A.enqueueAction(action); 
    },
   /* navigateToTab : function (tabName) {      
        var appEvent = $A.get("e.c:NavigateToTabAppEvent");
        appEvent.setParams({
            "targetTabName" : tabName
        });
        appEvent.fire();
    }, */
    showToast : function(type, title, component, message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            type: type,
            title: title,
            message: message,
        });
        toastEvent.fire();
    },
    getFppTypes : function(component, event, helper) {
        //console.log('lineItemId-->'+component.get('v.lineItemId'));
        console.log('accountId-->'+component.get('v.recordId'));
		 var action = component.get("c.getFPPTypes");
        action.setCallback(this, function(response) {
            // to avoid multiple spinners issue
            this.pushToListOfCompletedEvents(component, "getFppTypes");
            var state = response.getState();
            if (state === "SUCCESS") {
                var val=response.getReturnValue();
                component.set("v.fppTypes",val);
            }

        });
         $A.enqueueAction(action);
	},
    getCartStateList: function(component,helper) {
		 var action = component.get("c.getCartStateList");
        var toastErrorHandler = component.find('toastErrorHandler');
        action.setCallback(this, function(response){
            // to avoid multiple spinners issue
            this.pushToListOfCompletedEvents(component, "getCartStateList");
            toastErrorHandler.handleResponse(
                response,
                function(response){
                    var rtnValue = response.getReturnValue();
                    console.log(rtnValue);
                    if (rtnValue !== null) {    
                        component.set("v.cartStateList", rtnValue);
                    }else {
                        helper.showToast("error", 'Cart State are empty', component,
                                         'Could not find Cart State.');                        
                    }
                },
                function(response, message){ // report failure
                    helper.showToast("error", 'Cart State are empty', component,
                                     message);
                }
            )
        });            
        action.setBackground();
        $A.enqueueAction(action); 
    },
    updateLineItem : function(component,helper) {
        // to avoid multiple spinners issue
        component.set("v.spinner", true);
        var action = component.get("c.updateLineItemWithSKU");
        action.setParams({"recordId" : component.get('v.recordId'),
            "lineItem" : component.get('v.manualShoppingCartLineItem')});
        
        var toastErrorHandler = component.find('toastErrorHandler');
        action.setCallback(this, function(response){
            // to avoid multiple spinners issue
            component.set("v.spinner", false);
            toastErrorHandler.handleResponse(
                response,
                function(response){
                    var rtnValue = response.getReturnValue();
                    // DEF-0780 - Manually add product performance fix
                    if (rtnValue.status == 'Success') {  
                        if(rtnValue.msg == 'Updated') {
                            helper.showToast("success", 'Item addition to cart is successful', component,
                                     'Existing item has been updated'); 
                            component.set("v.isManualPricing", false);
                            var overlay = component.find('overlay');
                            $A.util.removeClass(overlay, 'slds-backdrop--open');
                            helper.getShoppingCartTax(component, function(){
                                component.set("v.spinner", true);
                                helper.getShoppingCartLineItems(component, rtnValue.lineItemIds, 
                                                                function(){
                                                                    component.set("v.spinner", false);
                                                                },
                                                                function(){
                                                                    component.set("v.spinner", false);
                                                                });
                            });
                        }
                        else if(rtnValue.msg == 'Inserted'){
                            helper.showToast("success", 'Item addition to cart is successful', component,
                                     'New item has been created');   
                            component.set("v.isManualPricing", false);
                            var overlay = component.find('overlay');
                            $A.util.removeClass(overlay, 'slds-backdrop--open');
                            helper.getShoppingCartTax(component, function(){
                                component.set("v.spinner", true);
                                helper.getShoppingCartLineItems(component, rtnValue.lineItemIds, 
                                                                function(){
                                                                    component.set("v.spinner", false);
                                                                },
                                                                function(){
                                                                    component.set("v.spinner", false);
                                                                });
                            });
                        }
                    }
                    else if(rtnValue.status == 'Error' && rtnValue.msg == 'ItemDetailsAPIError'){
                        helper.showToast("error", 'Error while creating/updating LineItem', component,
                                 'This Product could not be added as it is not found in Source System. Please contact administrator.');
                    }
                    else {
                        helper.showToast("error", 'Error while creating/updating LineItem', component,
                                         'Error while creating/updating LineItem.');                        
                    }
                },
                function(response, message){ // report failure
                    helper.showToast("error", 'Error while creating/updating LineItem', component,
                                         'Error while creating/updating LineItem.'); 
                }
            )
        });            
        action.setBackground();
        $A.enqueueAction(action); 
    }, 
    hideTsAndCs : function(component) {
        component.set("v.showTsAndCs", false);
        var backdrop = component.find("backdropContainer");
        $A.util.removeClass(backdrop, 'slds-backdrop--open');
        $A.util.addClass(backdrop, 'slds-modal-backdrop--close');
    },
    
    // REQ-433 - Add Suspend Functionality on Cart Page
    getCurrGuestDetails : function(component, helper) {
        // to avoid multiple spinners issue
        component.set("v.spinner", true);
        var action = component.get("c.getGuestDetails");
        action.setParams({"accountId" : component.get('v.recordId')});
             
        var toastErrorHandler = component.find('toastErrorHandler');
        action.setCallback(this, function(response){
            // to avoid multiple spinners issue
            component.set("v.spinner", false);
            toastErrorHandler.handleResponse(
                response,
                function(response){
                    var rtnValue = response.getReturnValue();
                    if (rtnValue !== null) {  
                        component.set("v.acc", rtnValue);
                        if(rtnValue.Addresses__r != undefined) {
                        	component.set("v.addr", rtnValue.Addresses__r[0]);
                        }
                    } else {
                        helper.showToast("error", 'Customer Address info empty', component,
                                         'Could not find Customer Address info empty.');                        
                    }
                },
                function(response, message){ // report failure
                    helper.showToast("error", 'Could not find Customer Address info', component,
                                     message);
                }
            )
        });            
        action.setBackground();
        $A.enqueueAction(action);	    
    },
    
    validateMainForm : function(component, helper) {
        var email = component.find('posEmail').get("v.value");
        var phone = component.find('posPhone').get("v.value");
        component.set("v.isFormError",false);
        var errMsg = '';
        var emailCmp = component.find('posEmail');
        if(email == undefined || email == "") {
            component.set("v.isFormError",true);
            $A.util.addClass(emailCmp, 'required');
            errMsg += 'Email';
        }
        else {
            $A.util.removeClass(emailCmp, 'required');
        }
            
        
        var phoneCmp = component.find('posPhone');
        if(phone == undefined || phone == "") {
            component.set("v.isFormError",true);
            $A.util.addClass(phoneCmp, 'required');
            errMsg += (errMsg.length > 0) ? ', Phone' : 'Phone';
            errMsg += 'Phone';
        }
        else {
            $A.util.removeClass(phoneCmp, 'required');
        }
        
        if(component.get("v.isFormError")) {
            helper.showToast("Error","",component,$A.get("$Label.c.Address_Form_Mandatory_Fields_Error")+'. Enter: '+errMsg);    
        }
        else {
            var phoneRegExp = /^\(?([0-9]{3})\)?[-. ]?([0-9]{3})[-. ]?([0-9]{4})$/; 
            var isValidPhone = phoneRegExp.test(phone);
            if (!isValidPhone) {
                $A.util.addClass(phoneCmp, 'required');
                helper.showToast("Error","",component,"Please enter a valid Phone");
            }
            else {
                $A.util.removeClass(phoneCmp, 'required');
            }
            
            var emailRegExp =  /^([A-Za-z0-9_\-\.])+\@([A-Za-z0-9_\-\.])+\.([A-Za-z]{2,4})$/; 
            var isValidEmail = emailRegExp.test(email);
            if (!isValidEmail) {
                $A.util.addClass(emailCmp, 'required');
                helper.showToast("Error","",component,"Please enter a valid Email");
            }   
            else {
                $A.util.removeClass(emailCmp, 'required');
            }
        }            
    },
    
    // Method to Suspend to POS
    suspendToPos : function(component, helper) {
        component.set("v.formWrap.shipEmail",component.find('posEmail').get("v.value"));
        component.set("v.formWrap.billEmail",component.find('posEmail').get("v.value"));
        component.set("v.formWrap.shipPhone",component.find('posPhone').get("v.value"));
        component.set("v.formWrap.billPhone",component.find('posPhone').get("v.value"));
        component.set("v.formWrap.shipFirstName",'');
        component.set("v.formWrap.shipLastName",'');
        component.set("v.formWrap.billFirstName",'');
        component.set("v.formWrap.billLastName",'');
        
        var action = component.get("c.suspendToPosCart");
 		
        action.setParams({ 
            "formWrapStr"	: JSON.stringify(component.get("v.formWrap")),
            "personAccId"   : component.get('v.recordId'),
            "billAddr"      : component.get("v.addrId"), 
            "shipAddr"      : component.get("v.addrId")
        });
        
        var toastErrorHandler = component.find('toastErrorHandler');  
        action.setCallback(this, function(response) {
            toastErrorHandler.handleResponse(
                response, // handle failure
                function(response){ // navigate to SuspendSaleComplete page
                    var spinner = component.find("largeSpinner");
        			$A.util.toggleClass(spinner, "slds-hide");
                    helper.showToast("success","",component,"Suspended to POS Successfully!");
                    	var appEvent = $A.get("e.c:NotifyHeaderComponentEvent"); 
           				appEvent.fire();
                    var appEvent = $A.get("e.c:NavigateToWrapperComponentAppEvent");
                    appEvent.setParams({
                        "targetCmpName" : 'SuspendSaleCompleteWrapperCmp',
                        "targetCmpParameters" : {}
                    });
                    appEvent.fire();
                },
                function(response, message){ // report failure
                    var spinner = component.find("largeSpinner");
        			$A.util.toggleClass(spinner, "slds-hide");
                    helper.showToast("Error","",component,"ERROR : " + message);
                }
            )
        });
		$A.enqueueAction(action);
    },
    
    // Method to create new address if there is no matching address
    checkAddress : function(component, helper) {
        var action = component.get("c.createNewAddress");        
 		
        action.setParams({ 
            accId 	: component.get("v.recordId"),
            addr    : component.get("v.addr")
        });
        
        var toastErrorHandler = component.find('toastErrorHandler');  
        action.setCallback(this, function(response) {
            toastErrorHandler.handleResponse(
                response, // handle failure
                function(response){ 
                    var spinner = component.find("largeSpinner");
        			$A.util.toggleClass(spinner, "slds-hide");
                    var rtnValue = response.getReturnValue();
                    component.set("v.addrId",rtnValue); 
                    
                    // Suspend to POS
                    helper.suspendToPos(component,helper);
                },
                function(response, message){ // report failure
                    var spinner = component.find("largeSpinner");
        			$A.util.toggleClass(spinner, "slds-hide");
                    helper.showToast("error", "ERROR : " + message);
                }
            )
        });
		$A.enqueueAction(action);
	},
    // End of REQ-433 - Add Suspend Functionality on Cart Page
    
    
    checkProduct : function(component, helper){
        var action = component.get('c.checkSKUPresent'); 
        action.setParams({
            "enteredSKU" : component.get('v.manualShoppingCartLineItem.Product_SKU__c') 
        });
        
        var toastErrorHandler = component.find('toastErrorHandler');  
        action.setCallback(this, function(response) {
            toastErrorHandler.handleResponse(
                response,
                function(response, message){ 
                    var skuNotPresent = response.getReturnValue();
                    if(skuNotPresent){
                        helper.showToast("error", 'Please enter valid values for all available fields', component,
                                             'Invalid data'); 
                    }
                    else{
                        helper.checkDisplayError(component, helper);
                    }
                }
            )
        });
        
        $A.enqueueAction(action);
    },
    
    checkDisplayError : function(component, helper){
        var Quantity__c=component.get("v.manualShoppingCartLineItem.Quantity__c");
        if($A.util.isEmpty(component.get("v.manualShoppingCartLineItem.Product_SKU__c")) ||
           $A.util.isEmpty(component.get("v.manualShoppingCartLineItem.Quantity__c")) ||
           isNaN(Quantity__c)){
                helper.showToast("error", 'Please enter valid values for all available fields', component,
                                         'Invalid data'); 
        }else{
            helper.updateLineItem(component,helper);  
           
        }
    }
})