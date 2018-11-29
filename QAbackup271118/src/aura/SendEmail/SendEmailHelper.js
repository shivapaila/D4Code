({
    sendHelper: function(component,event,helper, getEmail, getSubject, getbody,getrecid) {
        console.log('helperrecid'+getrecid);
        // call the server side controller method 	
        var action = component.get("c.sendMailMethod");
        // set the params to sendMailMethod method 
        action.setParams({
            'mMail': getEmail,
            'mSubject': getSubject,
            'mbody': getbody,
            'recid':getrecid
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                component.set("v.mailStatus", true);                
            }
            
        });
        $A.enqueueAction(action);
    }
})