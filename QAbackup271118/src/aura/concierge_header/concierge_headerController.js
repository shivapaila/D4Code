({
    Init : function(cmp, event, helper) {
       // alert('refresh1'+cmp.get("v.refresh"));
        cmp.set("v.refresh",false);
        
        // Load all cart data
        var action = cmp.get("c.getCustomerwithActiveCarts");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                 var val=response.getReturnValue();
                console.log('length of active carts-->'+val.length);
                cmp.set("v.customerwithActiveCartLst", val);
                console.log(val);
                cmp.set("v.activeCartTotal",val.length);
                //$A.get('e.force:refreshView').fire();
                //alert('val----'+cmp.get("v.activeCartTotal"));
            }

        });
         $A.enqueueAction(action);
    },
	navigateToHome : function(component, event, helper) {
       
        var appEvent = $A.get("e.c:NavigateToWrapperComponentAppEvent");
        appEvent.setParams({
            "targetCmpName" : 'ConciergeWrapperCmp',
            "targetCmpParameters" : {}
        });
         appEvent.fire();
        window.location.reload(true);
		//window.location.href = "/lightning/cmp/c__ConciergeWrapperCmp";       
	},
    cartClick : function(component, event, helper) {
         component.set("v.showModal", true);
        var overlay = component.find('cartModal');
        $A.util.addClass(overlay, 'slds-backdrop--open');
  
    },
	 removecss : function(component, event, helper) {
        component.set("v.showModal", false);
        var overlay = component.find('cartModal');
        $A.util.removeClass(overlay, 'slds-backdrop--open');
	},
 
})