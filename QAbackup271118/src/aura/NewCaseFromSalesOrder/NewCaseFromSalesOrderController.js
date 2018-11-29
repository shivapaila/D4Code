({
	doInit : function(component, event, helper) {
		var currentOrderId = component.get("v.recordId");

		var action = component.get("c.getOrderData");
 			
		action.setParams({
	        salesforceOrderId : currentOrderId
	    });

	    action.setCallback(this, function(response) {
			var state = response.getState();
			if (state === "SUCCESS") {
				var callResponse = response.getReturnValue(); 																					
				if(callResponse.isSuccess){
					var createCaseEvent = $A.get("e.force:createRecord");
					createCaseEvent.setParams({
					    "entityApiName": "Case",
					    "defaultFieldValues": {
					        'ContactId' : callResponse.contactId,
					        'AccountId' : callResponse.accountId,
                            'Temp_Sales_Order__c' : callResponse.orderExternalId
					    }
					});
					createCaseEvent.fire();
				}	
				else{
					var errorToast = $A.get("e.force:showToast");
					errorToast.setParams({"message": callResponse.errorMessage, "type":"error",  "mode":"dismissible", "duration":10000});
					errorToast.fire();
				}		
			}
			else{
				var errorToast = $A.get("e.force:showToast");
				errorToast.setParams({"message": response.getError()[0].message, "type":"error",  "mode":"dismissible", "duration":10000});
				errorToast.fire();
			}

		});

		$A.enqueueAction(action);
	}
})