({
	Init : function(component, event, helper) {
		var action = component.get("c.getAllUpcomingTasks");  
        action.setParams({
            "customerId" : component.get('v.recordId')
        });
        action.setCallback(this, function(a) {
            
            var rtnValue  = a.getReturnValue();
            console.log(rtnValue);
            if (rtnValue !== null) {
                component.set("v.allTasks",rtnValue.wrapperLst);
                component.set("v.statusOpts",rtnValue.statusLst);
                component.set("v.typeOpts",rtnValue.typeLst);
            }
            else
            {
                 // if allTasks size is 0 ,display no record found message on screen.
                if (component.get('v.allTasks').length == 0) {
                    component.set("v.Message", true);
                } else {
                    component.set("v.Message", false);
                }
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
    editClick:function(component, event, helper) {
        var selectedItem = event.currentTarget; 
        var id = selectedItem.dataset.record;
        var wrapper=component.get('v.allTasks');
        console.log(wrapper[id]);
        wrapper[id].isEdit=true;
        component.set('v.allTasks',wrapper);
        component.set('v.showEdit',false);
        
    },
     cancelEdit:function(component, event, helper) {
        var id= event.currentTarget.id;
        var wrapper=component.get('v.allTasks');
        console.log(wrapper[id]);
        wrapper[id].isEdit=false;
        component.set('v.allTasks',wrapper);
        component.set('v.showEdit',true);
    },
    deleteClick:function(component, event, helper) 
    {
        var selectedItem = event.currentTarget; 
        var RecordId = selectedItem.dataset.record;
        if (confirm('Are you sure you want to delete this Task?')) {
            // delete task!
            var action = component.get("c.deleteTask");
            action.setParams({
                "Id" : RecordId
            });
            action.setCallback(this, function(a) {
                
                var rtnValue  = a.getReturnValue();
                var state = a.getState();
                console.log(rtnValue);
                if (component.isValid() && state === "SUCCESS") {
                    
                    $A.get('e.force:refreshView').fire();              
                }
            });
            
            $A.enqueueAction(action);
            
        } else {
            // Do nothing!
        }
    },
    setComplete:function(component, event, helper) 
    {
        var selectedItem = event.currentTarget; 
        var RecordId = selectedItem.dataset.record;
            // set complete
            var action = component.get("c.statusComplete");
            action.setParams({
                "Id" : RecordId
            });
            action.setCallback(this, function(a) {
                
                var rtnValue  = a.getReturnValue();
                var state = a.getState();
                console.log(rtnValue);
                if (component.isValid() && state === "SUCCESS") {
                    
                    $A.get('e.force:refreshView').fire();              
                }
            });
            
            $A.enqueueAction(action);
        
    },
    submitTask:function(component, event, helper) 
    {
        var id=event.currentTarget.id;
        console.log('id-->'+id);
        var selectedItem = event.currentTarget; 
        var RecordId = selectedItem.dataset.record;
        var subTag='sub'+id;
        var duedateTag='date'+id;
        var typeOptsTag='typeOptions'+id;
        console.log('date: ' + document.getElementById(duedateTag).value);
        if(document.getElementById(id).value == ''){
            
            alert('Please enter subject');
        }
        else{
            var action = component.get("c.updateTask");  
            action.setParams({
                "Id" 	: RecordId,
                "sub" 	: document.getElementById(subTag).value,
                "duedate" 	: document.getElementById(duedateTag).value,
                "type" 	: document.getElementById(typeOptsTag).value
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
        }
        
    },
    openDetails:function(component, event, helper) {
        var selectedItem = event.currentTarget; 
        var RecordId = selectedItem.dataset.record;
        var appEvent = $A.get("e.c:NavigateToWrapperComponentAppEvent");
        appEvent.setParams({
            "targetCmpName" : 'TaskDetailViewWrapperCmp',
            "targetCmpParameters" : {"recordId": RecordId}
        });
        appEvent.fire();
    },
    /*createTask : function(component, event, helper) {
        
        var createRecordEvent = $A.get("e.force:createRecord");
        createRecordEvent.setParams({
            "entityApiName": "Task"
        });
        createRecordEvent.fire();
    },

    createTask : function(component, event, helper) {
        var evt  = $A.get("e.force:navigateToURL");
        evt.setParams({
            "url": '/one/one.app#/n/New_Task'
        })
        evt.fire();
     }*/

     // DEF-0151 - to load custom new task component
    createTask : function(component, event, helper) {
        console.log('New Create Task');

        $A.createComponent(
            "c:ConciergeTaskNew",
            {
                "aura:id": "findableAuraId",
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