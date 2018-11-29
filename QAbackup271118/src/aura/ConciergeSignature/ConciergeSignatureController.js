({
	lookupContact : function(component, event, helper) {
	//	console.log('PersonAccount Name ' + component.get("v.newPersonAccount.FirstName"));
      helper.checkSignatureSaved(component, event,helper);
        //component.getEvent("NotifyParentSignatureModal").fire();
        /*var signatureModalEvent = component.getEvent("NotifyParentSignatureModal");
        //var signatureModalEvent = $A.get("e.c:SignatureModalEvent");
                    signatureModalEvent.setParams({
                        "eventType" : "SUBMIT",
                        "ContactId" : ""
                    });
                    signatureModalEvent.fire();*/
	},
    cancelDialog : function(component, event, helper) {
        //fire event to close modal
        
        var signatureModalEvent = component.getEvent("NotifyParentSignatureModal");
        signatureModalEvent.setParams({
            "eventType" : "CLOSE",
            "ContactId" : ""
        });
        signatureModalEvent.fire();
        helper.Reset(component, event);
    }
})