({
    init : function(component, event, helper) {
        //Read pageReference
        var pageReference = component.get("v.pageReference");
        // If navigation from another location
        if (!$A.util.isUndefinedOrNull(pageReference)){
            //Read parameters from pageReference state
            var receivedParams = pageReference.state;
            //Set component attributes to paameters received from state
            if (!$A.util.isUndefinedOrNull(receivedParams.c__recordId)){
                component.set("v.recordId", receivedParams.c__recordId);
                component.set("v.renderRecordView", true);
            }
        } 
    },  
})