({
	doInit : function(component, event, helper) {
        //Read pageReference
        
        var pageReference = component.get("v.pageReference");
        console.log('ref-->'+JSON.stringify(pageReference));
        if(pageReference != null){
            //Read parameters from pageReference state
            var receivedParams = pageReference.state;
            
            //Set component attributes to paameters received from state
            component.set("v.recordId",receivedParams.c__recordId);
        }
        var action= component.get("c.isConciergeProfile");
         
        action.setCallback(this, function(response) {
           
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.isConciergeUser", response.getReturnValue());
            }
            else{
                console.log('Error in setting isConciergeUser: ' + response.getError()[0].message);
            }
        });
        $A.enqueueAction(action);
	}
})