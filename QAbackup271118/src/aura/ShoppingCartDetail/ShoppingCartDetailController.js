({
    doInit : function(component, event, helper) {
    
    helper.cmpdoInit(component, event, helper);
    
    },
    // to avoid multiple spinners issue
    reloadcart: function(component, event, helper){
      helper.cmpdoInit(component, event, helper);  
    },
    checkSpinner : function(component, event, helper) {
        var completedEvnts = component.get("v.listofEventsCompleted");
        var allEvnts = component.get("v.allEventsList");
        if(completedEvnts.length == allEvnts.length) {
            component.set("v.spinner", false);
        }
    },
    
    showCartModal : function(component, event, helper) {
        component.set("v.showSaveCartModal", true);
        var overlay = component.find('overlay');
        $A.util.addClass(overlay, 'slds-backdrop--open');
    }, 
    goToProducts : function(component, event, helper) {
		//helper.navigateToTab('Product_Category');
        var appEvent = $A.get("e.c:NavigateToWrapperComponentAppEvent");
        appEvent.setParams({
            "targetCmpName" : 'ProductCategoryWrapperCmp',
            "targetCmpParameters" : {"parentCategoryId": null, "productDetailId": null, "searchKey": null}
        });             
        appEvent.fire();  
    }, 
    goHome : function(component, event, helper) {
		//helper.navigateToTab('Concierge');
		var appEvent = $A.get("e.c:NavigateToWrapperComponentAppEvent");
        appEvent.setParams({
            "targetCmpName" : 'ConciergeWrapperCmp',
            "targetCmpParameters" : {}
        });
        appEvent.fire(); 
    }, 
    hideCartModal : function(component, event, helper) {
        component.set("v.showSaveCartModal", false);
        var overlay = component.find('overlay');
        $A.util.removeClass(overlay, 'slds-backdrop--open');
    }, 
    showManualModal : function(component, event, helper) {
        component.set("v.isManualPricing", true);
        var overlay = component.find('overlay');
        $A.util.addClass(overlay, 'slds-backdrop--open');
    }, 
    hideManualModal : function(component, event, helper) {
        component.set("v.isManualPricing", false);
        var overlay = component.find('overlay');
        $A.util.removeClass(overlay, 'slds-backdrop--open');
        component.set("v.manualShoppingCartLineItem.Product_SKU__c","");
        component.set("v.manualShoppingCartLineItem.List_Price__c","");
        component.set("v.manualShoppingCartLineItem.Quantity__c","");
    }, 
    showFinancing : function(component, event, helper) {
        component.set("v.showFinancingModal", true);
        var overlay = component.find('overlay');
        $A.util.addClass(overlay, 'slds-backdrop--open');
    },
    hideFinancing : function(component, event, helper) {
        component.set("v.showFinancingModal", false);
        var overlay = component.find('overlay');
        $A.util.removeClass(overlay, 'slds-backdrop--open');
    },
    closeAddressInfoModal : function(component, event, helper) {
        component.set("v.showAddressModal", false);
        var overlay = component.find('overlay');
        $A.util.removeClass(overlay, 'slds-backdrop--open');
        // call getShoppingCartTax which will also call getShoppingCartLineItems when zipcode or state is updated
        /*var opportunity = component.get("v.opp");
        if (!$A.util.isEmpty(opportunity["Cart_ZipCode__c"]) && !$A.util.isEmpty(opportunity["Cart_State__c"])) {
            helper.getShoppingCartTax(component,helper);
        }*/
    }, 
    updateAddressInfo: function(component, event, helper) {
         var opp = component.get("v.opp");
        opp["Cart_ZipCode__c"]= component.find("zipCodeInCart").get("v.value");
        opp["Cart_State__c"]= component.find("stateOptionInCart").get("v.value");
        if($A.util.isEmpty(opp["Cart_ZipCode__c"]) || $A.util.isEmpty( opp["Cart_State__c"])){
        
		    helper.showToast("error", 'Customer Address Info are missed', component,
                                         'Please input both zipcode and state for customer.');     
            return;
        }
       var action = component.get("c.saveCartAddressInfo");
        action.setParams({"opp" : opp});
        
        action.setCallback(this, function(response){
                    var rtnValue = response.getReturnValue();
            if(rtnValue=='Success'){
                    //$A.get("e.force:refreshView").fire();
                helper.getShoppingCartTax(component, function(){
                    component.set("v.spinner", true);
                    helper.getShoppingCartLineItems(component, [], 
                                                    function(){
                                                        component.set("v.spinner", false);
                                                    },
                                                    function(){
                                                        component.set("v.spinner", false);
                                                    });
                });
            }
           
        });            
        action.setBackground();
        $A.enqueueAction(action); 
    },
    updateLineItem: function(component, event, helper) {
        //var price=component.get("v.manualShoppingCartLineItem.List_Price__c");
        //DEF-0824, remove checkProduct function, go to checkDisplayError directly.
        helper.checkDisplayError(component, helper);
        /*var Quantity__c=component.get("v.manualShoppingCartLineItem.Quantity__c");
        if($A.util.isEmpty(component.get("v.manualShoppingCartLineItem.Product_SKU__c")) ||
           //$A.util.isEmpty(component.get("v.manualShoppingCartLineItem.List_Price__c"))||
           $A.util.isEmpty(component.get("v.manualShoppingCartLineItem.Quantity__c")) ||
           isNaN(Quantity__c)){
                helper.showToast("error", 'Please enter valid values for all available fields', component,
                                         'Invalid data'); 
        }else{
            helper.updateLineItem(component,helper);  
            component.set("v.isManualPricing", false);
            var overlay = component.find('overlay');
            $A.util.removeClass(overlay, 'slds-backdrop--open');
        }*/
    },
    showTsAndCs : function (component, event, helper) {
        console.log('show ts and cs');
        var backdrop = component.find("backdropContainer");
        $A.util.removeClass(backdrop, 'slds-modal-backdrop--close');
        $A.util.addClass(backdrop, 'slds-modal-backdrop--open');
        component.set("v.showTsAndCs", true);
    },    
    cancelTsAndCs : function (component, event, helper) {
        helper.hideTsAndCs(component)
    },
    proceedToCheckout: function(component, event, helper) {
         console.log('v.recordId 1-->'+component.get('v.recordId'));
        helper.hideTsAndCs(component)
        /*var evt  = $A.get("e.force:navigateToURL");
        evt.setParams({
            "url": '/one/one.app#/n/Checkout?guestId=' + component.get('v.recordId')
        })
        evt.fire();*/
        console.log('v.recordId 2-->'+component.get('v.recordId'));
        var appEvent = $A.get("e.c:NavigateToWrapperComponentAppEvent");
        appEvent.setParams({
            "targetCmpName" : 'CheckoutWrapperCmp',
            "targetCmpParameters" : {"recordId": component.get('v.recordId')}
        });
        appEvent.fire();
    },
    //REQ-438, add cart level discount modal
    openDiscountModal: function(component, event, helper) {
        var lineItem = event.getParam("notifyParam");
        var productDetail = event.getParam("notifyParam1");
        component.set("v.selectedToDiscountItem",lineItem);
        component.set("v.selectedItemProductDetail",productDetail);
        
        component.set("v.showDiscountModal",true);
        var overlay = component.find('overlay');
        $A.util.addClass(overlay, 'slds-backdrop--open');
    },
    closeDiscountModal: function(component, event, helper) {
            component.set("v.showDiscountModal", false);
        
        var overlay = component.find('overlay');
        $A.util.removeClass(overlay, 'slds-backdrop--open');
      
    },
    //End REQ-438, add cart level discount modal
    
    // REQ-433 - Add Suspend Functionality on Cart Page
    openPosModal : function(component, event, helper) {
        helper.getCurrGuestDetails(component,helper);
        component.set("v.isShowPosModal",true);	    
        var overlay = component.find('overlay');
        $A.util.addClass(overlay, 'slds-backdrop--open');
    },
    
    closePosModal : function(component, event, helper) {
		if(component.find('posPhone').get("v.value") != undefined) {
           component.find('posPhone').set("v.value",""); 
        }
    	component.set("v.isShowPosModal",false);    
        var overlay = component.find('overlay');
        $A.util.removeClass(overlay, 'slds-backdrop--open');
    },
    
    suspendToPos : function(component, event, helper) {
        helper.validateMainForm(component,helper);
        
        // Validate address fields
        var childCmp = component.find("addrComp");
        var auraMethodResult = childCmp.validateAddressForm();
        if(!component.get("v.isFormError") && auraMethodResult == "Success") {
            // Create new address if there is no matching address
            helper.checkAddress(component,helper);
        }
    },
    // End of REQ-433 - Add Suspend Functionality on Cart Page
    
    handleOpportunityChange : function(component, event, helper) {
        console.log('handleOpportunityChange called');
        var opportunity = component.get("v.opp");
        component.set("v.oppId", opportunity.Id);
        if (component.find("stateOptionInCart")){
            component.find("stateOptionInCart").set("v.value", opportunity["Cart_State__c"]);
        }
        if ($A.util.isEmpty(opportunity["Cart_ZipCode__c"]) || $A.util.isEmpty(opportunity["Cart_State__c"])) {
            component.set("v.showAddressModal", true);                            
        }
    },
    
    // this function automatic calnavigateToTabl by aura:waiting event  
    showSpinner: function(component, event, helper) {
       // make Spinner attribute true for display loading spinner 
        component.set("v.spinner", true); 
    },
    
 	// this function automatic call by aura:doneWaiting event 
    hideSpinner : function(component,event,helper){
     // make Spinner attribute to false for hide loading spinner    
       component.set("v.spinner", false);
    },

    refreshShoppingCart : function(component, event, helper){
        var action = event.getParam("action");
        var lineItemId = event.getParam("lineItemId");
        var lineItemIds = event.getParam("lineItemIds");
        // local variables for storing action strings read from constants
        var actionDelete = component.get("v.CART_ACTION_DELETE_ITEM");
        var actionUpdateAddress = component.get("v.CART_ACTION_UPDATE_ADDRESS");
        var actionDiscount = component.get("v.CART_ACTION_APPLY_DISCOUNT");

        helper.getShoppingCartTax(component, function(){
            switch (action) {
                case actionDelete:
                    var shoppingCartLineItems = component.get("v.shoppingCartLineItems");                            
                    var newShoppingCartLineItems = [];
                    for (var i=0; i < shoppingCartLineItems.length; i++){
                        if (shoppingCartLineItems[i].item.Id != lineItemId){
                            newShoppingCartLineItems.push(shoppingCartLineItems[i]);
                        }
                    }
                    component.set("v.shoppingCartLineItems", newShoppingCartLineItems);                
                    break;
                case actionUpdateAddress:
                    component.set("v.spinner", true);
                    helper.getShoppingCartLineItems(component, [], function(){
                        component.set("v.spinner", false);
                    },
                    function(){
                        component.set("v.spinner", false);
                    });                
                    break;
                case actionDiscount:
                    component.set("v.spinner", true);
                    helper.getShoppingCartLineItems(component, lineItemIds, function(){
                        component.set("v.spinner", false);
                    },
                    function(){
                        component.set("v.spinner", false);
                    });                
                    break;
                default:
                    component.set("v.spinner", true);
                    helper.getShoppingCartLineItems(component, [lineItemId], function(){
                        component.set("v.spinner", false);
                    },
                    function(){
                        component.set("v.spinner", false);
                    });                 
                    break;
            }
            helper.getCanViewCheckout(component,helper);
        }); 
    }
})