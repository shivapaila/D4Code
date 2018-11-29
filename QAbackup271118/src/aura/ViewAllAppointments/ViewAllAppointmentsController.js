({
    Init : function(component, event, helper) {
        
        var action = component.get("c.getAllUpcomingEvents");
        
        action.setCallback(this, function(a) {
            
            var rtnValue  = a.getReturnValue();
        
            if (rtnValue !== null) {
                component.set("v.AllEvents",rtnValue.wrapperLst);
                var val=rtnValue.wrapperLst;
                    if(val ==''){
                    component.set('v.pageNumber',0);  
                }
                else{
                    component.set('v.pageNumber',1);
                }
                component.set("v.maxPage", Math.floor((val.length+9)/10));
                helper.renderPage(component, event, helper);
                console.log(component.get('v.AllEvents')[0]);
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
        var RecordId = selectedItem.dataset.record;
        var appEvent = $A.get("e.c:NavigateToWrapperComponentAppEvent");
        appEvent.setParams({
            "targetCmpName" : 'AppointmentDetailViewWrapperCmp',
            "targetCmpParameters" : {"recordId": RecordId}
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
    editClick:function(component, event, helper) {
        var id= event.currentTarget.id;
        var wrapper=component.get('v.currentList');
        
        wrapper[id].isEdit=true;
        component.set('v.currentList',wrapper);
        component.set('v.showEdit',false);
        
    },
    cancelEdit:function(component, event, helper) {
        var id= event.currentTarget.id;
        var wrapper=component.get('v.currentList');
        
        wrapper[id].isEdit=false;
        component.set('v.currentList',wrapper);
        component.set('v.showEdit',true);
    },
    submitEvent:function(component, event, helper) 
    {
        
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
    back:function(component, event, helper) 
    {
        var appEvent = $A.get("e.c:NavigateToWrapperComponentAppEvent");
        appEvent.setParams({
            "targetCmpName" : 'ConciergeWrapperCmp',
            "targetCmpParameters" : {}
        });
        appEvent.fire();
    },
    
    filterByDate:function(component, event, helper) 
    {
        
        if(component.find("filterDate").get("v.value") != '')
        {
            var action = component.get("c.filter");
            action.setParams({ filterDate : component.find("filterDate").get("v.value") });
            action.setCallback(this, function(a) {
                
                var rtnValue  = a.getReturnValue();
                console.log(rtnValue);
                if (rtnValue !== null) {
                    component.set("v.AllEvents",rtnValue.wrapperLst);
                    var val=rtnValue.wrapperLst;
                    if(val ==''){
                    component.set('v.pageNumber',0);  
                }
                else{
                    component.set('v.pageNumber',1);
                }

                    component.set("v.maxPage", Math.floor((val.length+9)/10));
                    helper.renderPage(component, event, helper);
                }
                
                // if AllEvents size is 0 ,display no record found message on screen.
                if (component.get('v.AllEvents').length == 0) {
                    
                    component.set("v.Message", true);
                } else {
                    
                    component.set("v.Message", false);
                }
                
                
            });
            
            $A.enqueueAction(action);
            
        }
        else
        {
            $A.get('e.force:refreshView').fire();
            
        }
    },
    renderPage: function(component, event, helper) {
        helper.renderPage(component);
    },
    /*
    createEvent : function(component, event, helper) {
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
     },*/
     createEvent : function(component, event, helper) {
          
        console.log('New Create Event');
		
       $A.createComponent(
            "c:ConciergeAppointmentNew",
           
            {
                "aura:id": "findableAuraId1"
            },
            function(newButton, status, errorMessage){
                
                if (status === "SUCCESS") {
                    var body = component.get("v.body");
                    body.push(newButton);
                    component.set("v.body", body);
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
    },

    sortBySub: function(component, event, helper) {
        helper.sortBy(component, "eventSub");
    },
    sortByCustomer: function(component, event, helper) {
        helper.sortBy(component, "eventWhatName");
    },
    sortBystartdateTime: function(component, event, helper) {
        helper.sortBy(component, "eventstartDate");
    },
    sortByenddateTime: function(component, event, helper) {
        helper.sortBy(component, "eventendDate");
    },
})