({
	doInit : function(component, event, helper) {
       // alert('RendershpForUpdate'+component.get("v.RendershpForUpdate"));
      //  alert('isrenagainForUpdate'+component.get("v.isrenagainForUpdate"));
        component.set("v.RendershpForUpdate",false);
        component.set("v.isrenagainForUpdate",false);
        
		helper.getCustomerInfo(component,helper);
        helper.getShoppingCartLineItems(component,helper);
        
        helper.getShippingWayList(component,helper);
        helper.getDiscountReasonList(component,helper);
        
        helper.getMarketDiscountCriteria(component,helper);        
        helper.getAccountStoreInfo(component,helper);
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
    
    updateLineItem: function(component, event, helper) {
        var Quantity__c=component.get("v.manualShoppingCartLineItem.Quantity__c");
        if($A.util.isEmpty(component.get("v.manualShoppingCartLineItem.Product_SKU__c")) ||
           $A.util.isEmpty(component.get("v.manualShoppingCartLineItem.Quantity__c")) ||
           isNaN(Quantity__c)){
            helper.showToast("error", 'Please enter valid values for all available fields', component,
                                         'Invalid data'); 
        }else{
            helper.updateLineItem(component,helper);  
            component.set("v.isManualPricing", false);
            var overlay = component.find('overlay');
            $A.util.removeClass(overlay, 'slds-backdrop--open');
        }
    },
    
    cartLineItemsSection : function(component, event, helper) {       
        var sections = component.find('CartLineItemsSection');
        for(var cmp in sections) {
        	$A.util.toggleClass(sections[cmp], 'slds-show');  
        	$A.util.toggleClass(sections[cmp], 'slds-hide');  
        }
    }
})