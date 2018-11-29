({
    doInit : function(component, event, helper){
        
    },
    redirect : function(component, event, helper) {
    },
    editRecord : function(component, event, helper) {
        var editRecordEvent = $A.get("e.force:editRecord");
        editRecordEvent.setParams({
            "recordId": component.get("v.recordId")
        });
        editRecordEvent.fire();
    },
    deleteRecord : function(component, event, helper) {
        var deleteRecordEvent = $A.get("e.force:deleteRecord");
        deleteRecordEvent.setParams({
            "recordId": component.get("v.recordId")
        });
        deleteRecordEvent.fire();
    },
    navigateToHome : function(component, event, helper) {
        var appEvent = $A.get("e.c:NavigateToWrapperComponentAppEvent");
        appEvent.setParams({
            "targetCmpName" : 'ConciergeWrapperCmp',
            "targetCmpParameters" : {}
        });
        appEvent.fire(); 
    }
})