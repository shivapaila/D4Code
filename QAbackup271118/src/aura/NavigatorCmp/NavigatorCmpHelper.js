({
	handleNavigation : function(component) {
       
		var self = this;
		var pageReference = component.get("v.pageReference");
       // alert('pageReference--------'+pageReference);
		if (!$A.util.isEmpty(pageReference) && !$A.util.isEmpty(pageReference.attributes)){
			if (pageReference.attributes['componentName'] == 'c__CustomersCartWrapperCmp') {
				var conciergeService = component.find("conciergeService");
				if (conciergeService){
				    conciergeService.isPaymentStage( 
				                    pageReference.state["c__recordId"]
				                    , function(payment){
				                    	if ($A.util.getBooleanValue(payment)){
				                    		pageReference.attributes['componentName'] = 'c__CheckoutWrapperCmp';
				                    		component.set("v.pageReference", pageReference);
				                    	}
				                    	self.navigateToPageReference(component);	
				                    }
				                    , function(response, message){
				                    	self.showToast("error", 'Navigation error', message);
				                    }
				            );
				}
               
			} else {
				this.navigateToPageReference(component);				
			}
		}
        
        
	},
	navigateToPageReference : function(component){
        var navService = component.find("navService");
        navService.navigate(component.get("v.pageReference"), true);		
	},
   /*
    * 
    *   Display the error message 
    */
    showToast : function(type, title, message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            type: type,
            title: title,
            message: message,
        });
        toastEvent.fire();
    },		
})