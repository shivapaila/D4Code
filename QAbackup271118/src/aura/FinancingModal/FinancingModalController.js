({
    cancelDialog : function(component, helper) {
        component.getEvent("NotifyParentCloseModal").fire();
    }
})