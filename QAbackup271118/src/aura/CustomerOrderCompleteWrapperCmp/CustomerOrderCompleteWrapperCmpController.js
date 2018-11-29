({
	init : function(component, event, helper) {
        //Read pageReference
        var pageReference = component.get("v.pageReference");
        // If navigation from another location
        if (!$A.util.isUndefinedOrNull(pageReference)){
            //Read parameters from pageReference state
            var receivedParams = pageReference.state;
            
            //Set component attributes to pameters received from state
            if(!$A.util.isUndefinedOrNull(receivedParams.c__receiptUrl)){
                var orders = receivedParams.c__receiptUrl.split('/');
                var SONums = orders[orders.length-1].split('_');
                var SONumsStr = '';
                for (var i = 0; i < SONums.length-1; i++) { 
                  SONumsStr += (SONumsStr.length > 0) ? ','+SONums[i] : SONums[i];
                }
                component.set("v.receiptUrl",receivedParams.c__receiptUrl);
                component.set("v.SONumber", SONumsStr);
                
                component.set("v.renderSubComponent",true);
            }
        }
	
	}

})