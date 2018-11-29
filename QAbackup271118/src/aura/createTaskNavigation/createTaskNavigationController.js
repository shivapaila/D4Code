({
	Init : function(component, event, helper) {
		var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/00T/e"
        });
        urlEvent.fire();
	}
})