({
    Init : function(component, event, helper) {
        
        var action = component.get("c.getTodaysEvents");
        
        action.setCallback(this, function(a) {
            
            var rtnValue  = a.getReturnValue();
            console.log('Initial response---->'+rtnValue.wrapperLst.length);
            if (rtnValue !== null) {
                component.set("v.TodaysEvents",rtnValue.wrapperLst);
                var val=rtnValue.wrapperLst;
                if(val != '')
                {
                component.set('v.pageNumber',1);
                }
                component.set("v.maxPage", Math.floor((val.length+9)/10));
                helper.renderPage(component, event, helper);
                
            }
            if(rtnValue.wrapperLst.length <= 0)
            {
                 // if TodaysEvents size is 0 ,display no record found message on screen.
                
                    component.set("v.Message", true);
                
            }
        });
        
        $A.enqueueAction(action);
    },
    /*
    createEvent : function(component, event, helper) {
        var createRecordEvent = $A.get("e.force:createRecord");
        createRecordEvent.setParams({
            "entityApiName": "Event"
        });
        createRecordEvent.fire();
    },*/
    
    createEvent : function(component, event, helper) {
        //alert('beforecomponent');
        console.log('New Create Event');
		
      $A.createComponent(
          
            "c:ConciergeAppointmentNew",
            {
                "aura:id": "findableAuraId1"
                
            },
          
            function(newButton, status, errorMessage){
              /*  alert('newButton: '+newButton)
                alert('status: '+status);
                alert('errorMessage: '+errorMessage);*/
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
    
                               /*
     createEvent : function(component, event, helper) {
        var evt  = $A.get("e.force:navigateToURL");
        evt.setParams({
            "url": '/one/one.app#/n/New_Appointment'
        })
        evt.fire();
     },*/

     closeComponent : function(component, event){
        var comp = event.getParam("comp");
        comp.destroy();
    },

    editClick:function(component, event, helper) {
        var id= event.currentTarget.id;
        var wrapper=component.get('v.currentList');
        console.log(wrapper[id]);
        wrapper[id].isEdit=true;
        component.set('v.currentList',wrapper);
        component.set('v.showEdit',false);
        
    },
    cancelEdit:function(component, event, helper) {
        var id= event.currentTarget.id;
        var wrapper=component.get('v.currentList');
        console.log(wrapper[id]);
        wrapper[id].isEdit=false;
        component.set('v.currentList',wrapper);
        component.set('v.showEdit',true);
    },
     submitEvent:function(component, event, helper) 
    {
        console.log(JSON.stringify(component.get('v.currentList')));
        var action = component.get("c.updateEvent");  
            action.setParams({
                "wrapper" 	: JSON.stringify(component.get('v.currentList')),
                "index"	:event.currentTarget.id
            });
            action.setCallback(this, function(a) {
                
                var rtnValue  = a.getReturnValue();
                var state = a.getState();
                console.log(rtnValue);
                if (component.isValid() && state === "SUCCESS") 
                {
                    $A.get('e.force:refreshView').fire();
                }
            });
            
            $A.enqueueAction(action);
        
    },
     openAppointmentDetail:function(component, event, helper) {
        var selectedItem = event.currentTarget; 
        var recordId = selectedItem.dataset.record;
        var appEvent = $A.get("e.c:NavigateToWrapperComponentAppEvent");
        appEvent.setParams({
            "targetCmpName"	: 'AppointmentDetailViewWrapperCmp',
            "targetCmpParameters" : {"recordId": recordId}
        });
        appEvent.fire();
    },
    openCustomerDetail:function(component, event, helper) {
        var selectedItem = event.currentTarget; 
        var recordId = selectedItem.dataset.record;
        var appEvent = $A.get("e.c:NavigateToWrapperComponentAppEvent");
        appEvent.setParams({
            "targetCmpName"	: 'CustomerDetailViewWrapperCmp',
            "targetCmpParameters" : {"recordId": recordId}
        });
        appEvent.fire();
    },
    openEventLst:function(component, event, helper) 
    {
        var appEvent = $A.get("e.c:NavigateToWrapperComponentAppEvent");
        appEvent.setParams({
            "targetCmpName" : 'MyAppointmentsWrapperCmp'
        })
        appEvent.fire();
        window.location.reload(true);
    },
    renderPage: function(component, event, helper) {
        helper.renderPage(component);
    }
})