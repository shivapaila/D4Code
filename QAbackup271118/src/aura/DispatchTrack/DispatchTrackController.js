({
	doInit : function(component, event, helper) {        
		var action = component.get("c.formDispatchTrackUrl"); 
        action.setParam("recId", component.get("v.recordId")); 
        
        action.setCallback(this, function(a){
            var rtnValue = a.getReturnValue();
            if (a.getState() == 'SUCCESS') {
                if (rtnValue != null){
                    component.set("v.dispatchTrackUrl", rtnValue);
                    console.log("dispatchtrackurl" + rtnValue);
                    console.log("url" + $A.get("$Label.c.DispatchTestUrl"));
                }
            } else {
               var errors = a.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.error(errors[0].message);
                    }
                    if (errors[0] && errors[0].pageErrors && errors[0].pageErrors[0]) {
                        console.error(errors[0].pageErrors[0].message);
                    }
                } else {
                    console.error("Unknown error");
                }  
            }
        });
    	$A.enqueueAction(action);
	},
    
})