({
    doInit : function(component, event, helper) {
        component.set("v.newEvent.Appointment_Status__c", "Scheduled");
        var EventObj=component.get('v.newEvent');
        var custId=component.get('v.customerId');
        //alert('EventObj: '+EventObj);
        //alert('custId: '+custId);
        if(custId != null && custId != undefined)
        {
            var action = component.get("c.getCustomer");  
            action.setParams({
                "customerId" : custId
            });
            action.setCallback(this, function(a) {
                
                var rtnValue  = a.getReturnValue();
                console.log('acc-->'+rtnValue);
                if (rtnValue !== null) {
                     EventObj.What=rtnValue;
                     EventObj.WhatId=rtnValue.Id;
            		component.set('v.newEvent',EventObj);
                }
            });
            $A.enqueueAction(action); 
        }
    },

    close : function(component) {
        var compEvent = component.getEvent("ConciergeDestroyNewTask");
        compEvent.setParams({
            "comp" : component
        });
        compEvent.fire();
    },

    addEvent : function(component, event, helper) {
        helper.addEvent(component);
    }
})