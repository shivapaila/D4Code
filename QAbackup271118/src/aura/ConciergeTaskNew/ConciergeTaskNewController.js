({
    doInit : function(component, event, helper) {
        var tskObj=component.get('v.newTask');
        var custId=component.get('v.customerId');
        if(custId != null && custId != undefined)
        {
            var action = component.get("c.getCustomer");  
            action.setParams({
                "customerId" : custId
            });
            action.setCallback(this, function(a) {
                
                var rtnValue  = a.getReturnValue();
                if (rtnValue !== null) {
                     tskObj.What=rtnValue;
                     tskObj.WhatId=rtnValue.Id;
            		component.set('v.newTask',tskObj);
                }
            });
            $A.enqueueAction(action); 
            
        }
        helper.loadInterval(component, event, helper);
        helper.defaultValues(component);
    },

    close : function(component) {
        var compEvent = component.getEvent("ConciergeDestroyNewTask");
        compEvent.setParams({
            "comp" : component
        });
        compEvent.fire();
    },

    addTask : function(component, event, helper) {
        helper.addTask(component);
    },

    handleWeekDaySelect : function(component, event, helper) {

    },

    addtoWeekMask : function(component, event, helper) {
        helper.addtoRecurrenceWeekMask(component, event);
    }
})