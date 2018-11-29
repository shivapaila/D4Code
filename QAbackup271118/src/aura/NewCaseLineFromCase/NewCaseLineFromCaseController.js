({
	launchNewCaseLineScreen : function(component, event, helper) {
		component.set("v.isLoading", true);
		var currentCaseId = component.get("v.recordId");
		var action = component.get("c.getInitializationData");
 			
		action.setParams({
	        caseId : currentCaseId
	    });

	    action.setCallback(this, function(response) {
	    	component.set("v.isLoading", false);
			var state = response.getState();
			if (state === "SUCCESS") {
				var callResponse = response.getReturnValue(); 
				console.log(response.getReturnValue());																					
				if(callResponse.isSuccess){
					component.set("v.initializationData", callResponse);
					
					var createCaseLineEvent = $A.get("e.force:createRecord");
					createCaseLineEvent.setParams({
					    "entityApiName": "Case_Line_Item__c",
					    "defaultFieldValues": {
					        'Case__c' : callResponse.caseId,
					        'Sales_Order_Number__c' : callResponse.salesOrderNumber,
					        'Fulfiller_ID__c' : callResponse.fulfillerID
					    }
					});
					createCaseLineEvent.fire();
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