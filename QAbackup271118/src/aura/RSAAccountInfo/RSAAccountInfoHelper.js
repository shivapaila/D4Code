({
   /*
	*	Initialize method 
	*	- Retrieve the RSA Account Information by invoking the corresponding method in Concierge Service
	*	- On success, populate the local 'rsaAccountInfo' variable with the response from the callout 
	*/	
	init: function(component) {
        var self = this;
        var conciergeService = component.find("conciergeService");
        if (conciergeService){
            conciergeService.getRSAAccountInfo( 
                    function(rsaAccountInfo){
                        component.set("v.rsaAccountInfo", rsaAccountInfo);
                      //  self.showToast("value", component.get("v.rsaAccountInfo"));
                    }
                    , function(response, message){
                        //alert('errro' + response.getError()[0].message);
                        self.showToast("error", 'Unable to retrieve RSA Account Info', message);
                    }
                );
        }
	},
   /*
	*	Callout to Apex Lightning Controller
	*/	
    callout: function(component, name, params, success, failure) {   
        var action = component.get('c.' + name);
        var toastErrorHandler = component.find('toastErrorHandler');
        if (params) {
            action.setParams(params);
        }
        action.setCallback(this, function(response){
        	toastErrorHandler.handleResponse(response, success, failure);	
        });        
        action.setBackground();
        $A.enqueueAction(action);
    },
   /*
	*	Display the error message 
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