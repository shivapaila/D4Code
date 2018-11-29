({
    Init : function(component, event, helper) {
        
        var action = component.get("c.upcomingCustomersEvents");
        action.setParams({
            "customerId" : component.get('v.recordId')
        });
        action.setCallback(this, function(a) {
            
            var rtnValue  = a.getReturnValue();
            
            if (rtnValue !== null) {
                
                component.set("v.AllEvents",rtnValue.wrapperLst);
                
            }
            
            // if AllEvents size is 0 ,display no record found message on screen.
            if (component.get('v.AllEvents').length == 0) {
                component.set("v.Message", true);
            } else {
                component.set("v.Message", false);
            }
            
        });
        
        $A.enqueueAction(action);
    },
    openAppointmentDetail:function(component, event, helper) {
        var selectedItem = event.currentTarget; 
        var recordId = selectedItem.dataset.record;
        var appEvent = $A.get("e.c:NavigateToWrapperComponentAppEvent");
        appEvent.setParams({
            "targetCmpName" : 'AppointmentDetailViewWrapperCmp',
            "targetCmpParameters" : {"recordId": recordId}
        });
        appEvent.fire();
    },
    openCustomerDetail:function(component, event, helper) {
        var selectedItem = event.currentTarget; 
        var recordId = selectedItem.dataset.record;
        var appEvent = $A.get("e.c:NavigateToWrapperComponentAppEvent");
        appEvent.setParams({
            "targetCmpName" : 'CustomerDetailViewWrapperCmp',
            "targetCmpParameters" : {"recordId": recordId}
        });
        appEvent.fire();
    },
    editClick:function(component, event, helper) {
        var id= event.currentTarget.id;
        var wrapper=component.get('v.AllEvents');
        wrapper[id].isEdit=true;
        component.set('v.AllEvents',wrapper);
        component.set('v.showEdit',false);
        
    },
    cancelEdit:function(component, event, helper) {
        var id= event.currentTarget.id;
        var wrapper=component.get('v.AllEvents');
        wrapper[id].isEdit=false;
        component.set('v.AllEvents',wrapper);
        component.set('v.showEdit',true);
    },
    submitEvent:function(component, event, helper) 
    {
        
        var action = component.get("c.updateEvent");  
        action.setParams({
            "wrapper" 	: JSON.stringify(component.get('v.AllEvents')),
            "index"	:event.currentTarget.id
        });
        action.setCallback(this, function(a) {
            
            var rtnValue  = a.getReturnValue();
            var state = a.getState();
            if (component.isValid() && state === "SUCCESS") 
            {
                $A.get('e.force:refreshView').fire();
                
            }
        });
        $A.enqueueAction(action);
        
    },
    back:function(component, event, helper) 
    {
        var appEvent = $A.get("e.c:NavigateToWrapperComponentAppEvent");
        appEvent.setParams({
            "targetCmpName" : 'ConciergeWrapperCmp',
            "targetCmpParameters" : {}
        });
        appEvent.fire();
    },
    /*createEvent : function(component, event, helper) {
        var createRecordEvent = $A.get("e.force:createRecord");
        createRecordEvent.setParams({
            "entityApiName": "Event"
        });
        createRecordEvent.fire();
    },
    createEvent : function(component, event, helper) {
        var evt  = $A.get("e.force:navigateToURL");
        evt.setParams({
            "url": '/one/one.app#/n/New_Appointment'
        })
        evt.fire();
     }*/
     createEvent : function(component, event, helper) {
        console.log('New Create Event');
		
       $A.createComponent(
            "c:ConciergeAppointmentNew",
            {
                "aura:id": "findableAuraId1",
                "customerId":component.get('v.recordId')
            },
            function(newButton, status, errorMessage){
                if (status === "SUCCESS") {
                    var body = component.get("v.body");
                    body.push(newButton);
                    component.set("v.body", body);
                    scrollTo(top);
                }
                else if (status === "INCOMPLETE") {
                    console.log("No response from server or client is offline.");
                }
                else if (status === "ERROR") {
                    console.log("Error: " + errorMessage);
                }
            }
        );

    },

    closeComponent : function(component, event){
        var comp = event.getParam("comp");
        comp.destroy();
    }
})