({
    doInit : function(component, event, helper) {
        //check cases PLI's
        console.log("doInit");
        var casePliObj = component.get("c.getCasePli");
        casePliObj.setParams({
            "caseId" : component.get("v.recordId")
        });
        // Add callback behavior for when response is received
        casePliObj.setCallback(this, function(response) {
            if (component.isValid() && response.getState() === "SUCCESS") {
                if(response.getReturnValue() && response.getReturnValue().length > 0 ){
                    //PLI's exist
                    console.log("PLI's " + response.getReturnValue());
                    var rerendTechSch = component.get('c.validateTechSchedule');
					$A.enqueueAction(rerendTechSch);
                } else {
                    component.set('v.noPliExist',true);
                    console.log("No PLI's");
                }
            }
            else {
                console.log("Failed with state: " + response.getState());
            }
        });
        $A.enqueueAction(casePliObj);
    },

	validateTechSchedule : function(component, event, helper) {
        //check sibling cases
        console.log("validateTechSchedule");
		component.set('v.noPliExist', false);

        var recordId = component.get("v.recordId");
        var actionCaseObj = component.get("c.getRelatedCaseObj");
        actionCaseObj.setParams({
            "recordId" : recordId
        });
        // Add callback behavior for when response is received
        actionCaseObj.setCallback(this, function(response) {
            if (component.isValid() && response.getState() === "SUCCESS") {
                if( response.getReturnValue() && response.getReturnValue().length>0 ){
                    //records exist
                    component.set('v.SiblingsExist',true);
                    /*var data = response.getReturnValue();
                    console.log('data' + JSON.stringify(data));
                    for(var i=0;i<data.length;i++){
                        data[i].Id = '/'+data[i].Id;
                    }*/
                    console.log("Tech Scheduled: " + response.getReturnValue());
                    component.set('v.casesAre',response.getReturnValue());
                } else {
                	console.log("No Tech Scheduled");
                    helper.helperInit(component, event, helper);
                }
            }
            else {
                console.log("Failed with state: " + response.getState());
            }
        });
        $A.enqueueAction(actionCaseObj);
    },

    moveTotab : function(component, event, helper){
    	console.log("moveTotab");
        component.set('v.SiblingsExist',false);
        helper.helperInit(component, event, helper);
    },

    GobackToRecord : function (component, event, helper) {
    	console.log("GobackToRecord");
        component.set('v.SiblingsExist',false);
        component.set('v.noPliExist',false);
        $A.get('e.force:refreshView').fire();
     }
})