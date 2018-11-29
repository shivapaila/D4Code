({
    init : function(component, event, helper) {
        helper.getRecordId(component, event, helper);
    }, 
	continue : function(component, event, helper) {
    	var recId = component.get("v.guestId");
    	var oppId = component.get("v.oppId");
        var appEvent = $A.get("e.c:NavigateToWrapperComponentAppEvent");
        appEvent.setParams({
            "targetCmpName" : 'ConciergeWrapperCmp',
    		"targetCmpParameters" : {"recordId": recId, "oppId" : oppId}
        });
        appEvent.fire();
    }
})