({
     showToast : function(type, title, component, message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            type: type,
            title: title,
            message: message,
        });
        toastEvent.fire();
    },
    checkSignatureSaved :function(component, event,helper) {
        var action = component.get("c.checkSignatureSaved");
       // action.setParams({ acc : accRec});
        var toastErrorHandler = component.find('toastErrorHandler');
        
         action.setCallback(this, function(response){
                toastErrorHandler.handleResponse(
                    response, // handle failure
                    function(response){ 
                        
                        console.log(response);
                        var rtnValue = response.getReturnValue();
                        if (rtnValue !== null && rtnValue) {   
                            helper.captureSignature(component, event,helper);

                        } else {
                            helper.showToast("error", 'Please Capture and Save a Signature before Submit', component,
                                             'Please Capture and Save a Signature before Submit');                        
                        }
                    },
                    function(response, message){ // report failure
                        helper.showToast("error", 'Could not find or saved signature', component,
                                         message);
                    }
                )            
            }); 
         $A.enqueueAction(action);
    },
    captureSignature : function(component, event,helper) {
         var action = component.get("c.saveCapturedSignature");
       // action.setParams({ acc : accRec});
        var toastErrorHandler = component.find('toastErrorHandler');
        
         action.setCallback(this, function(response){
                toastErrorHandler.handleResponse(
                    response, // handle failure
                    function(response){ 
                        
                        console.log(response);
                        var rtnValue = response.getReturnValue();
                        if (rtnValue !== null) {   
                            console.log('firing modal event');
                            //fire event so modal closes and redirects to contact page
                            //var signatureModalEvent = $A.get("e.c:SignatureModalEvent");
                            var signatureModalEvent = component.getEvent("NotifyParentSignatureModal");
                            signatureModalEvent.setParams({
                                "eventType" : "SUBMIT",
                                "recordId" : rtnValue
                            });
                            signatureModalEvent.fire();
                            helper.Reset(component, event);

                        } else {
                            helper.showToast("error", 'Could not find or create customer', component,
                                             'no id was passed = error!');                        
                        }
                    },
                    function(response, message){ // report failure
                        helper.showToast("error", 'Could not find or create customer', component,
                                         message);
                    }
                )            
            }); 
         $A.enqueueAction(action);
	},
    Reset : function(component, event) {
        $A.get('e.force:refreshView').fire();
    }
})