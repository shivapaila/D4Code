({
    doInit : function(component, event, helper) {
        helper.getPaymentTermOptions(component, helper);
    },
    closeDialog : function(component, event, helper) {
        var cmpEvent = component.getEvent("notifyTermsSelected");
        cmpEvent.setParams({"selectedTermCode" : ""});
        cmpEvent.setParams({"selectedTermDescription" : ""});
        cmpEvent.setParams({"selectedThirdPartyTermCode" : ""});
        cmpEvent.fire();
    },
    closeDialogSuccess : function(component, event, helper) {
        var cmpEvent = component.getEvent("notifyTermsSelected");
        if(component.get("v.selectedTermCode") != null && component.get("v.selectedTermCode") != ''){
            var termOptions = component.get("v.termOptions");
            for(var i=0; i<termOptions.length; i++) {
                if(termOptions[i].Code == component.get("v.selectedTermCode")) {
                    cmpEvent.setParams({"selectedTermCode" : termOptions[i].Code});
                    cmpEvent.setParams({"selectedTermDescription" : termOptions[i].Description});
                    cmpEvent.setParams({"selectedThirdPartyTermCode" : termOptions[i].ThirdPartyTermCode});
                }
            }
        }
        cmpEvent.fire();
    },
    // finance API defect fix
    setThirdPartyTermsCode : function(component, helper) {
        var fTerms = component.get("v.termOptions");
        for(var i=0; i<fTerms.length; i++){
            if(fTerms[i].Code == component.get("v.paymentInfo.FINterms")){
                component.set("v.paymentInfo.FINThirdPartyTerms", fTerms[i].ThirdPartyTermCode);
            }
        }
    }
})