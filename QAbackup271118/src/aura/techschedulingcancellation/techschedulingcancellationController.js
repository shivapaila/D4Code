({
	doInit : function(component, event, helper) {
		//check sibling cases
        var recordId = component.get("v.recordId");
        var actionCaseObj = component.get("c.getRelatedServiceRequestsforcancelling");
        actionCaseObj.setParams({
            "recordId":recordId
        });
        
        // Add callback behavior for when response is received
    	actionCaseObj.setCallback(this, function(response) {

        	if (component.isValid() && response.getState() === "SUCCESS") {
                        component.set('v.SiblingsExist',true);
				var res= response.getReturnValue();
                
                if(res!= null && res.includes("Allow") ){
                    //records exist
                    //component.set("v.casesAre",'Are you sure that you want to cancel the technician');
                    var sch = confirm('Are you sure that you want to cancel the technician');
                    if(sch == true)
                    {
                        //alert('yes');
                        var reqNoArray = res.split(':');
                        var reqNo = reqNoArray[1];
                        component.set("v.isSchDisable",false);
                        var unSch = 'You are ready to unschedule the Service Request :'+reqNo;
                        component.set("v.casesAre",unSch);
                    }
                    else {
                        //txt = "You pressed Cancel!";
                    }
                    //console.log(response.getReturnValue());
                }else{
                    component.set("v.casesAre",'Scheduled Technician was not found in HOMES.\n Note: Salesforce is unable to unscheduled a Technician originally scheduled in HOMES');
	
                }
        	}
        	else {
            	console.log("Failed with state: " + state);
        	}
    	}); 
        $A.enqueueAction(actionCaseObj);
    },

	GobackToRecord : function (component, event, helper) {
		component.set('v.SiblingsExist',false);
        $A.get('e.force:refreshView').fire();
    },
    
    unschedule: function (component, event, helper){
		component.set("v.isSchDisable", true);
		var recordId = component.get("v.recordId");
        var actionTechSch = component.get("c.getApiResponse");
		actionTechSch.setParams({
			"recordId":recordId
		});
		console.log('here');    
		actionTechSch.setCallback(this, function(response) {
			console.log('here1');  
            if (component.isValid() && response.getState() === "SUCCESS") {
				//console.log('action'+ esponse.getState());
				var toastEvent = $A.get("e.force:showToast");
				toastEvent.setParams({
					"title": "Success!",
					"type": "success",
					"message": "Successfully Unscheduled."
				});
				toastEvent.fire();
				component.set('v.SiblingsExist',false);
			}
        });
        $A.enqueueAction(actionTechSch);
        //$A.get('e.force:refreshView').fire();
    },
      
})