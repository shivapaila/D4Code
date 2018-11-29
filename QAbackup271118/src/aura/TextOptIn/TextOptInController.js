({
    Init : function(component, event, helper) {      	
        var action = component.get("c.getOpty");
        action.setParams({
            "personAccountId" : component.get("v.recordId"),
            "opportunityId" : component.get("v.oppId")
        });
		action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var obj = response.getReturnValue();
                component.set('v.guestObj',obj.guestRecord);
                component.set("v.oppty", obj.optyRecord);
                component.set('v.SigObjId',obj.signId);
                component.set("v.showSignature", obj.optyRecord.Text_Message_Opt_In__c);
                //REQ-455 - Text Opt In
                component.set("v.entityFullName", obj.entityFullName);
            }
            else if (state === "INCOMPLETE") {
                helper.handleError(null, true);
            }
            else if (state === "ERROR") {
                helper.handleError(response.getError(), false);
            }
        });
        $A.enqueueAction(action);
	},

	onCheckTextOptIn: function(component, event, helper) {
		var promotionalEmailsCmp = component.get("v.oppty.Survey_Opt_In__c");
        var textMessagesCmp = component.get("v.oppty.Text_Message_Opt_In__c");
        if(textMessagesCmp == true) {
            var action = component.get("c.getOrCreateESignature");
            	action.setParams({
                    "personAccountId" : component.get("v.recordId"),
                    "opportunityId" : component.get("v.oppId"),
                    "eSignId" : component.get("v.SigObjId")
                });
            	action.setCallback(this, function(response) {
                
                var state = response.getState();
                if (state === "SUCCESS") {
                    var obj = response.getReturnValue();     
                    component.set('v.SigObjId',obj.signId);
                    component.set("v.checkedTime", obj.checkedTime);
                    component.set('v.showSignature',true);
                }
                else if (state === "INCOMPLETE") {
                    helper.handleError(null, true);
                }
                else if (state === "ERROR") {
                    helper.handleError(response.getError(), false);
                }
            });
            $A.enqueueAction(action);
        }
        else {
            component.set('v.showSignature',false);
        }
		
	},
	accept : function(component, event, helper) {   
        var legalContent = $(".legalVerbiage" ).html();
        var action = component.get("c.acceptOptions");
        action.setParams({ 
            "personAccountId"  : component.get("v.recordId"),
            "opportunityId" : component.get("v.oppId"),
            "eSignId" : component.get("v.SigObjId"),
            "promotionalEmails" : component.get("v.oppty.Survey_Opt_In__c"),
            "textOptIn" : component.get("v.oppty.Text_Message_Opt_In__c"),
            "timeWhenCheckedTextOptIn" : component.get("v.checkedTime"),
            //"legalContent":component.find("legalContent").getElement().innerHTML
            "legalContent": legalContent
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                if (response.getReturnValue() == 'Success') {
                    component.getEvent("NotifyParentTextOptInComplete").fire();
                }
            }
            else if (state === "INCOMPLETE") {
                helper.handleError(null, true);
            }
            else if (state === "ERROR") {
                helper.handleError(response.getError(), false);
            }
        });
        $A.enqueueAction(action);
        
	},
    
    decline : function(component, event, helper) {
        var action = component.get("c.declineOptions");
        action.setParams({
            "personAccountId" : component.get("v.recordId"),
            "opportunityId" : component.get("v.oppId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.getEvent("NotifyParentTextOptInDecline").fire();
            }
            else if (state === "INCOMPLETE") {
                helper.handleError(null, true);
            }
            else if (state === "ERROR") {
                helper.handleError(response.getError(), false);
            }
        });
        $A.enqueueAction(action);
    }
})