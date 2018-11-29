({
	init : function(component, event, helper) {
        var action = component.get("c.getCases");
        action.setParams({
            "accountId":component.get('v.recordId')
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var val=response.getReturnValue();
                if(val != null){
                   component.set("v.caseLst", val);
                 if (val.length != 0) {
                    component.set("v.Message", false);
                    
                } 
                }
                else {
                    component.set("v.Message", true);
                    
                } 
                
            }

        });
         $A.enqueueAction(action);
	}
})