({
    doInit: function (component, event, helper) {
        helper.getRSAAccountInfo(component, function(){
            helper.createFindCustomerCmp(component, event, helper);
        }, function(message){
            helper.showToast("error", 'Unable to initialize MyCustomer component', component, message);
        });
    },
    changeView: function (component, event, helper) {
        var selectedView = component.find('viewDropDown').get('v.value');
        component.set('v.showView', selectedView);
        helper.createFindCustomerCmp(component, event, helper);
    },
    openSignatureListModal: function (component, event, helper) {
        var recordId = event.getParam("notifyParam");
        var rsaAccountInfo = component.get("v.rsaAccountInfo");
        if(rsaAccountInfo.marketCode == 'SLF'){   //Is it the California Store
            helper.showSignature(component, event, helper, recordId);
        }else{
            var appEvent = $A.get("e.c:NavigateToWrapperComponentAppEvent");
            appEvent.setParams({
                "targetCmpName" : 'CustomerDetailViewWrapperCmp',
                "targetCmpParameters" : {"recordId": recordId}
            });
            appEvent.fire();
        }
    },
    closeModal: function (component, event, helper) {
        component.set("v.showModal", false);
        component.set("v.showSignatureListModal", false);

        var overlay = component.find('overlay');
        $A.util.removeClass(overlay, 'slds-backdrop--open');
    },
    closeCustomerModal: function (component, event, helper) {
        component.set("v.showModal", false);
        component.set("v.showSignatureListModal", false);

        var overlay = component.find('overlay');
        $A.util.removeClass(overlay, 'slds-backdrop--open');

        var evt = component.getEvent("FinishedAddToCart");
        evt.fire();
    },
    addCustomer: function (component, event, helper) {
        component.set("v.showModal", true);
        var overlay = component.find('overlay');
        $A.util.addClass(overlay, 'slds-backdrop--open');
    },
    addtocart: function (component, event, helper) {
        // extract the event parameters
        var recordId = event.getParam("notifyParam");
        var subComponentName = event.getParam("notifyParam1");
        // handle ui overlay
        var overlay = component.find('overlay');
        $A.util.addClass(overlay, 'slds-backdrop--open');
        // check the eligibility to add to cart - cart may be in payment stage
        var conciergeService = component.find("conciergeService");
        if (conciergeService){
            conciergeService.isPaymentStage( 
                            recordId
                            , function(payment){
                                if ($A.util.getBooleanValue(payment)){
                                    helper.navigateToPayment(component, recordId);
                                } else {
                                    helper.addToCart(component, recordId, subComponentName);
                                }
                            }
                            , function(response, message){
                                helper.showToast("error", 'Unable to add to cart', message);
                            }
                    );
        }
    }

})