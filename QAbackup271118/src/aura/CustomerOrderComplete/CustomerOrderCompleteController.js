({
    doInit : function(component, event, helper) {
        var url = component.get("v.receiptUrl");  
        if(!$A.util.isUndefinedOrNull(url)) {
            helper.navigateToURL(component, url, '_blank', '', false);
        }       
	},
	navigateToHome : function(component, event, helper) { 
        var appEvent = $A.get("e.c:NavigateToWrapperComponentAppEvent");
        appEvent.setParams({
            "targetCmpName" : 'ConciergeWrapperCmp',
            "targetCmpParameters" : {}
        });
        appEvent.fire(); 
	},
})