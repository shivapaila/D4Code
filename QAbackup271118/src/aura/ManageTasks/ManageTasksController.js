({
    Init : function(component, event, helper) {
        var action = component.get("c.getTodaysTasks");  
        action.setCallback(this, function(a) {
            
            var rtnValue  = a.getReturnValue();
            console.log(rtnValue.wrapperLst.length);
            if (rtnValue !== null) {
                component.set("v.TodaysTasksLst",rtnValue.wrapperLst);
                component.set("v.statusOpts",rtnValue.statusLst);
                component.set("v.typeOpts",rtnValue.typeLst);
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
                 // if TodaysTasksLst size is 0 ,display no record found message on screen.
                component.set("v.Message", true);
            }
        });
        
        $A.enqueueAction(action);
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
     },*/

     // DEF-0151 - to load custom new task component
    createTask : function(component, event, helper) {
        console.log('New Create Task');

        $A.createComponent(
            "c:ConciergeTaskNew",
            {
                "aura:id": "findableAuraId"
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
    },

    openDetails:function(component, event, helper) {
        var selectedItem = event.currentTarget; 
        var recordId = selectedItem.dataset.record;
        /*var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/one/one.app#/n/TaskDetailView?recordId="+RecordId
        });
        urlEvent.fire();*/
        var appEvent = $A.get("e.c:NavigateToWrapperComponentAppEvent");
        appEvent.setParams({
            "targetCmpName"	: 'TaskDetailViewWrapperCmp',
            "targetCmpParameters" : {"recordId": recordId}
        });
        appEvent.fire();
    },
    editClick:function(component, event, helper) {
        var selectedItem = event.currentTarget; 
        var id = selectedItem.dataset.record;
        var wrapper=component.get('v.currentList');
        console.log(wrapper[id]);
        wrapper[id].isEdit=true;
        component.set('v.currentList',wrapper);
        component.set('v.showEdit',false);
        
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
    cancelEdit:function(component, event, helper) {
        var id= event.currentTarget.id;
        var wrapper=component.get('v.currentList');
        wrapper[id].isEdit=false;
        component.set('v.currentList',wrapper);
        component.set('v.showEdit',true);
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
    openTaskLst:function(component, event, helper) 
    {
        /*
        var evt  = $A.get("e.force:navigateToURL");
        evt.setParams({
            "url": '/one/one.app#/n/MyTasks' 
        })
        evt.fire();*/
        // Navigation Fix
        var appEvent = $A.get("e.c:NavigateToWrapperComponentAppEvent");
        appEvent.setParams({
            "targetCmpName" : 'MyTasksWrapperCmp',
            "targetCmpParameters" : {}
        });
        appEvent.fire();
		window.location.reload(true);
    },
    renderPage: function(component, event, helper) {
        helper.renderPage(component);
    }
})