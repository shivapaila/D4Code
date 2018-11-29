({
    doInit : function(component, event, helper) {
        helper.getSignatureList(component, event, helper);
    },
    saveRecords : function(component, event, helper) {
        var selectedItem = event.currentTarget; 
        var picId = selectedItem.dataset.record;
        helper.saveSignature(component, event, helper,picId);
	}, 

    cancelDialog : function(component, helper) {
        var inConsole = component.get("v.inSvcConsole");
        if (!inConsole) {
            component.getEvent("NotifyParentCloseModal").fire();
        } else {
            window.history.go(-1);
        }
    }
})