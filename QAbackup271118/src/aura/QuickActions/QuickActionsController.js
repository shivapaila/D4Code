({
    openProducts:function(component, event, helper) 
    {
        var appEvent = $A.get("e.c:NavigateToWrapperComponentAppEvent");
        //appEvent.setStorable();
        appEvent.setParams({
            "targetCmpName" : 'ProductCategoryWrapperCmp',
            "targetCmpParameters" : {}
        });
		appEvent.fire();
        window.location.reload(true);
       
  },
    addCustomer:function(component, event, helper) 
    {
        
        component.set("v.showGuestModal", true);
        var overlay = component.find('overlay');
        $A.util.addClass(overlay, 'slds-backdrop--open');
    },
    closeGuestModal: function(component, event, helper) {
        
        component.set("v.showGuestModal", false);
        var overlay = component.find('overlay');
        $A.util.removeClass(overlay, 'slds-backdrop--open');
    },
    openMyCustomers:function(component, event, helper) 
    {
        var action = component.get("c.isCaliforniaStore");
        action.setCallback(this, function(response) {
           
			 var state = response.getState();
            //alert('state is'+state);
            if (state === "SUCCESS") {
                var showSignatureCapture = response.getReturnValue();
                console.log('showSignatureCapture-->'+showSignatureCapture);
                if(showSignatureCapture == true){
                    //UNCOMMENT to put Signature modal back 
                    var userId = $A.get("$SObjectType.CurrentUser.Id");
                    component.set("v.userId", userId);
                    // show signature
                    var cmpBack = component.find('Modalbackdrop');
                    $A.util.addClass(cmpBack, 'slds-backdrop--open'); 
                    component.set("v.showSignature", true);
                }
                else{
                    var appEvent = $A.get("e.c:NavigateToWrapperComponentAppEvent");
                    appEvent.setParams({
                        "targetCmpName" : 'MyCustomersWrapperCmp',
                        "targetCmpParameters" : {}
                    });
                    appEvent.fire();
                    window.location.reload(true);
                }
            }
        });
        $A.enqueueAction(action);
       
        /* SIGNATURE MODAL OUT FOR NOW 1/11/2018 */
        /*var evt  = $A.get("e.force:navigateToURL");
                                    evt.setParams({
                                        "url": '/one/one.app#/n/My_Customers1' 
                                    })
                                    evt.fire();*/
    
    },
    closeSignatureModal: function(component, event, helper){
        var eType = event.getParam("eventType");
        var rtnId = event.getParam("recordId");
        
        // hide signature
		helper.hideSigModal(component);
        
        if(eType != 'CLOSE'){
            var appEvent = $A.get("e.c:NavigateToWrapperComponentAppEvent");
            appEvent.setParams({
                "targetCmpName" : 'MyCustomersWrapperCmp',
                "targetCmpParameters" : {}
            });
            appEvent.fire();
            $A.get('e.force:refreshView').fire()
        }
        
        
    },
    closeModal:function(component,event,helper){    
		helper.hideSigModal(component);
       /*  REQ-299 Enhancement, For Find A Guest, RSA must collect a signature.
        var evt  = $A.get("e.force:navigateToURL");
        evt.setParams({
            "url": '/one/one.app#/n/My_Customers1' 
        })
        evt.fire();
        */
    },
    
    
})