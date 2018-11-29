({
	getStoreInfo : function(component, event, helper) {
		var action = component.get("c.getStoreInfo");  
        action.setCallback(this, function(a) {
            
            var rtnValue  = a.getReturnValue();
            var state = a.getState();
            
            if (component.isValid() && state === "SUCCESS") 
            {
               
                component.set('v.accountNumber',rtnValue.acctNo);
                component.set('v.rdcId',rtnValue.RDC);
                
            }
        });
        $A.enqueueAction(action);
	}
})