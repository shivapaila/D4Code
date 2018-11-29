({
	doInit : function(component, event, helper) {

		//show loading spinner
	 	component.set("v.isLoading", true);

		var currentRecordId = component.get("v.recordId");
		if(currentRecordId != null){

			var action = component.get("c.getMobilePhoneNumber");
	 			
			action.setParams({
		        recordId : currentRecordId
		    });

		    action.setCallback(this, function(response) {
				var state = response.getState();
				if (state === "SUCCESS") {
					var callResponse = response.getReturnValue(); 																					
					component.set("v.toNumber", callResponse); 	 				
				}
				else{
					var errorToast = $A.get("e.force:showToast");
					errorToast.setParams({"message": response.getError()[0].message, "type":"error",  "mode":"dismissible", "duration":10000});
					errorToast.fire();
				}
				//hide loading spinner
		 		component.set("v.isLoading", false);

			});

			$A.enqueueAction(action);
		}
	},
	sendMessage : function(component, event, helper) {
		//show loading spinner
	 	component.set("v.isLoading", true);

	 	var currentRecordId = component.get("v.recordId");
	 	var toNumber = component.get("v.toNumber");
	 	var txtMessage = component.get("v.txtMessage");

	 	if(toNumber != null && txtMessage != null){
	 		var action = component.get("c.sendTextMessageViaTwilio");
	 			
			action.setParams({
		        recordId : currentRecordId,
		        toPhoneNumber : toNumber,
		        message : txtMessage
		    });

		    action.setCallback(this, function(response) {
				var state = response.getState();
				if (state === "SUCCESS") {
					var callResponse = response.getReturnValue();
					console.log(callResponse);
					if(callResponse.isSuccess){ 																					
						component.set("v.toNumber", ""); 
						component.set("v.txtMessage", ""); 
						var successToast = $A.get("e.force:showToast");
						successToast.setParams({"message": $A.get("$Label.c.Twilio_Send_SMS_Success_Message"), "type":"success",  "mode":"dismissible", "duration":5000});
						successToast.fire();
						$A.get("e.force:closeQuickAction").fire();
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
				//hide loading spinner
		 		component.set("v.isLoading", false);

			});

			$A.enqueueAction(action);
	 	}
	 	else{
	 		var errorToast = $A.get("e.force:showToast");
			errorToast.setParams({"message": $A.get("$Label.c.Twilio_Send_SMS_Required_Fields_Missing_Message"), "type":"error",  "mode":"dismissible", "duration":10000});
			errorToast.fire();	

			//hide loading spinner
		 	component.set("v.isLoading", false);
	 	}

	}
})