({
    Init:function(component, event, helper) {
        var lst=component.get('v.currentList');
        component.set('v.currentList',lst);
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
     cancelEdit:function(component, event, helper) {
        var id= event.currentTarget.id;
        var wrapper=component.get('v.currentList');
        console.log(wrapper[id]);
        wrapper[id].isEdit=false;
        component.set('v.currentList',wrapper);
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
        var recId = selectedItem.dataset.record;
        
        var appEvent = $A.get("e.c:NavigateToWrapperComponentAppEvent");
        appEvent.setParams({
            "targetCmpName" : 'TaskDetailViewWrapperCmp',
            "targetCmpParameters" : {"recordId": recId}
        });
        appEvent.fire();
    },
    sortBySub: function(component, event, helper) {
        helper.sortBy(component, "Subject");
    },
    sortByActivityDate: function(component, event, helper) {
        helper.sortBy(component, "ActivityDate");
    },
    sortByType: function(component, event, helper) {
        helper.sortBy(component, "Type");
    },
})