({
    setFocusedTabLabel : function(component, event, helper) {
        //Use getSalesOrderNumber to get the value of field sales order number 
        var currentOrderId = component.get("v.recordId");

		var action = component.get("c.getSalesOrderNumber");
 			
		action.setParams({
	        salesOrderSalesforceId : currentOrderId
	    });

	    action.setCallback(this, function(response) {
			var state = response.getState();
			if (state === "SUCCESS") {
				var callResponse = response.getReturnValue(); 																					
				var workspaceAPI = component.find("workspace");
        		workspaceAPI.getFocusedTabInfo().then(function(response) {
            		var focusedTabId = response.tabId;
                    workspaceAPI.setTabLabel({
                        tabId: focusedTabId,
                        label: callResponse
                    });
        		})
                .catch(function(error) {
                    console.log(error);
                });	
			}
			else{
                console.log('error in setting tab title: ' + response.getError()[0].message);
			}

		});

		$A.enqueueAction(action);
        
        helper.setFocusedTabIcon(component, event, helper);
     }
})