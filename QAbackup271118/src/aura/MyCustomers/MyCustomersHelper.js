({
    getRSAAccountInfo: function(component, success, failure) {
        var self = this;
        var conciergeService = component.find("conciergeService");
        if (conciergeService){
            conciergeService.getRSAAccountInfo( 
                    function(rsaAccountInfo){
                        component.set("v.rsaAccountInfo", rsaAccountInfo);
                        if (success) {
                            success.call(this);
                        }
                    }
                    , function(response, message){
                        if (failure) {
                            failure.call(this, message);
                        }                        
                    }
                );
        }
    },    
    addToCart: function (component, recordId, subComponentName) {

        //var overlay = component.find('overlay');
        //$A.util.addClass(overlay, 'slds-backdrop--open');

        var action = component.get("c.addToCart");
        action.setParams({
            "accountId": recordId,
            "prod": JSON.stringify(component.get('v.productDetail')),
            "prodPrice": JSON.stringify(component.get('v.productPrice')),
            "qty": component.get('v.quantity')
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var val = response.getReturnValue();
                    
            }else{
                this.showToast("error", 'Error Product', component,
                                 'This Product is not found in Tax API, could not be added. Please contact administrator.');
            }
            var evt = component.getEvent("FinishedAddToCart");
            evt.setParams({ "notifyParam1": subComponentName });
            evt.fire();
            //Close AddCustomer Modal
            component.set("v.showModal", false);
            var overlay = component.find('overlay');
            $A.util.removeClass(overlay, 'slds-backdrop--open');
            //Fix CR Work Needed Updates Item 28, remain within the context of what the RSA was searching for.
            //The handler FinishedAddToCart will fire NotifyHeaderComponentEvent to update concierge_header active cart number.
            // $A.get('e.force:refreshView').fire();
            
        });
        action.setBackground();
        $A.enqueueAction(action);
    }, 
    navigateToPayment : function(component, recordId){
        var appEvent = $A.get("e.c:NavigateToWrapperComponentAppEvent");
        appEvent.setParams({
            "targetCmpName" : 'CheckoutWrapperCmp',
            "targetCmpParameters" : {"recordId": recordId}
        });
        appEvent.fire();
    },   
     showToast : function(type, title, component, message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            type: type,
            title: title,
            message: message,
        });
        toastEvent.fire();
    },
    createFindCustomerCmp :function(component, event, helper) {
        $A.createComponent("c:FindCustomer",  
                           {"showView":component.get('v.showView'),
                            "showSelectButton":  component.get('v.showSelectButton')}, 
                           function(newCmp) {
                               var body = component.get("v.body");
                               body = [];
                               // newCmp is a reference to another component
                               body.push(newCmp);
                               component.set("v.body", body);
                           }); 
    },
    isCaliforniaStore : function(component, event, helper, RecordId) {
        var action = component.get("c.isCaliforniaStore");
        action.setCallback(this, function(response) {
            
            var state = response.getState();
            if (state === "SUCCESS") {
                var showSignatureCapture = response.getReturnValue();
                console.log('showSignatureCapture-->'+showSignatureCapture);
                
                var hasSigedInLastDay = false;
                if(showSignatureCapture == true && !hasSigedInLastDay){
                    helper.showSignature(component, event, helper, RecordId);
                }else{
                    /*var evt  = $A.get("e.force:navigateToURL");
                    evt.setParams({
                        "url": '/one/one.app#/n/CustomerDetailView?recordId=' + RecordId
                    })
                    evt.fire();*/
                    var appEvent = $A.get("e.c:NavigateToWrapperComponentAppEvent");
                    appEvent.setParams({
                        "targetCmpName" : 'CustomerDetailViewWrapperCmp',
                        "targetCmpParameters" : {"recordId": RecordId}
                    });
                    appEvent.fire();
                }
            }
        });
        $A.enqueueAction(action);
    },
  	showSignature : function(component, event, helper, RecordId){      
            component.set("v.signatureForCustomer", RecordId);
            //open signature list modal
            component.set("v.showSignatureListModal", true);
            
            var overlay = component.find('overlay');
            $A.util.addClass(overlay, 'slds-backdrop--open');
    }
})