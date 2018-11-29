({
	doInit : function(component, event, helper) {
        //getting record id from url parameter - theyagu 18/12 
        var url=location.href.split('/n/');
        if(url != null && url[1] != null){
            var splitUrl=url[1].split('?');
            if(splitUrl != null && splitUrl[1] != null){
                var Id=splitUrl[1].split('=');
                if(Id != null && Id[1] != null){
                    component.set('v.recordId',Id[1]);
                }
                
            }
        }
        var action= component.get("c.isConciergeProfile");
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('response.getReturnValue(): ' + response.getReturnValue());
                component.set("v.isConciergeUser", response.getReturnValue());
                console.log("isConciergeUser: " + component.get("v.isConciergeUser"));
            }
            else{
                console.log('Error in setting isConciergeUser: ' + response.getError()[0].message);
            }
        });
        $A.enqueueAction(action);
	}
})