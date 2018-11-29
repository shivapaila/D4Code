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
    getSignatureList: function(component, event, helper) {      
        var action = component.get("c.getCaliforniaSignatureList");
        var toastErrorHandler = component.find('toastErrorHandler');
        
        action.setCallback(this, function(response){
            toastErrorHandler.handleResponse(
                response, // handle failure
                function(response){ 
                    
                    var rtnValue = response.getReturnValue();
                    
                    
                    console.log(rtnValue);
                    if (rtnValue !== null) {   
                        component.set("v.signaturePics", rtnValue);
                        
                    } else {
                        helper.showToast("error", 'No Signature Pics', component,
                                         'Could not find Signature.');                        
                    }
                },
                function(response, message){ // report failure
                    helper.showToast("error", 'Could not find Signature', component,
                                     message);
                }
            )            
        });        
        action.setBackground();
        $A.enqueueAction(action); 
    },
    
    saveSignature: function(component, event, helper,picId) {      
        var action = component.get("c.saveSignatureToCustomer");
        var toastErrorHandler = component.find('toastErrorHandler');
        console.log('saveSignature:'+component.get("v.customerId"));
        action.setParams({
            'picId': picId,
            'customerId': component.get("v.customerId")
        });
        action.setCallback(this, function(response){
            toastErrorHandler.handleResponse(
                response, // handle failure
                function(response){ 
                    var rtnValue = response.getReturnValue();
                    
                    
                    console.log(rtnValue);
                    if (rtnValue !== null) {   
                        var appEvent = $A.get("e.c:NavigateToWrapperComponentAppEvent");
                        appEvent.setParams({
                            "targetCmpName" : 'CustomerDetailViewWrapperCmp',
                            "targetCmpParameters" : {"recordId": component.get("v.customerId")}
                        });
                        appEvent.fire();
                    } else {
                        helper.showToast("error", 'Fail to save Signature to customer', component,
                                         'Could not save Signature to customer.');                        
                    }
                },
                function(response, message){ // report failure
                    helper.showToast("error", 'Could not save Signature to customer', component,
                                     message);
                }
            )            
        });        
        action.setBackground();
        $A.enqueueAction(action); 
    }
})