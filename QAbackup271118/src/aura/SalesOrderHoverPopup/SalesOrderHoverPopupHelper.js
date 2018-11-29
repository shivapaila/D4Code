({
	loadSalesOrder : function(component, event, helper) {
     component.find("Id_spinner").set("v.class" , 'slds-show');
    	var testid = component.get("v.recordId");
        var action = component.get("c.getAccounts");
 		action.setParams({
	        "salesforceOrderId" : testid
	    });
		
        action.setCallback(this,function(response) {
          component.find("Id_spinner").set("v.class" , 'slds-hide');
            var state = response.getState();
         	 if (state === "SUCCESS") {
            var succesData = response.getReturnValue();
                
                component.set("v.data", succesData);
                component.set("v.datalenght",succesData.length);
                
                           }
        				   }); 
        $A.enqueueAction(action);
    
		
	}
})