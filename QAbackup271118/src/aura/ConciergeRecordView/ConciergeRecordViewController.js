({
    doInit : function(component, event, helper) {
    },
    editRecord : function(component, event, helper) {
        
       /* var editRecordEvent = $A.get("e.force:editRecord");
        editRecordEvent.setParams({
            "recordId": component.get("v.recordId")
        });
        editRecordEvent.fire();*/
         component.set("v.showEditrecordModal", true);
        var overlay = component.find('recordEditModal');
        $A.util.addClass(overlay, 'slds-backdrop--open');
  
    },
    
    removecss : function(component, event, helper) {
        component.set("v.showEditrecordModal", false);
        var overlay = component.find('recordEditModal');
        $A.util.removeClass(overlay, 'slds-backdrop--open');
	},
    updateRecord : function(component, event) {
        
     component.find("edit").get("e.recordSave").fire();   
    },
    
     viewRefreshed : function(component, event) {
        // get called once save is done
        $A.get('e.force:refreshView').fire();
        
         
    },
    
    navigateToHome : function(component, event, helper) {
        var appEvent = $A.get("e.c:NavigateToWrapperComponentAppEvent");
        appEvent.setParams({
            "targetCmpName" : 'ConciergeWrapperCmp',
            "targetCmpParameters" : {}
        });
        appEvent.fire();
        window.location.reload(true);
        
        
    },
    
    deleteRecord : function(component, event, helper) 
    {
        var Id=component.get('v.recordId');
        var action = component.get("c.deleteCurrentRecord");
        action.setParams({
            "Id":component.get('v.recordId')
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                alert('Record Deleted');
                var val=response.getReturnValue();
				var appEvent = $A.get("e.c:NavigateToWrapperComponentAppEvent");
                appEvent.setParams({
                    "targetCmpName" : 'ConciergeWrapperCmp',
                    "targetCmpParameters" : {}
                });
                appEvent.fire();
            }
            
        });
        $A.enqueueAction(action);
    }
})