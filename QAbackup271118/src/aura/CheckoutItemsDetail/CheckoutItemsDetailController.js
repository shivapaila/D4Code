({
	doInit : function(component, event, helper) {
        
        var appEvent = $A.get("e.c:NotifyHeaderComponentEvent"); 
            appEvent.fire();
		helper.getCustomerInfo(component,helper);
        
		
        helper.getShoppingCartLineItems(component,helper);
	}
})