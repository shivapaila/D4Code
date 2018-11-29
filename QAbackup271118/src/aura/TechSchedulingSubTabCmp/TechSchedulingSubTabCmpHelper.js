({
    helperInit : function(component,event,helper) {
        component.set('v.SiblingsExist',false);
		console.log("helperInit");
        var evt = $A.get("e.force:navigateToComponent");
        var recordId = component.get("v.recordId");

        var actionCaseObj = component.get("c.isValidCase");
        actionCaseObj.setParams({
            "recordId":recordId
        });
        // Add callback behavior for when response is received
        actionCaseObj.setCallback(this, function(response) {
            if (component.isValid() && response.getState() === "SUCCESS") {
                if( response.getReturnValue() === true ){
                	console.log("Valid case");
                    evt.setParams({
                        componentDef : "c:TechScheduling",
                        componentAttributes: {
                            caseId : recordId
                        }
                    });
                    evt.fire();
                }else{
                	console.log("Sales order is missing");
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Error Message',
                        message:'Sales Order is Mandatory to process',
                        messageTemplate: 'Sales Order is Mandatory to process',
                        duration:' 5000',
                        key: 'info_alt',
                        type: 'error',
                        mode: 'pester'
                    });
                    toastEvent.fire();
                }
            }
            else {
                console.log("Failed with state: " + state);
            }
        });
        $A.enqueueAction(actionCaseObj);
    }
})