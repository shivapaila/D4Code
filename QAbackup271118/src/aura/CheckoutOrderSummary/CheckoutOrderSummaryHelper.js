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
    getCheckoutSummary : function(component,helper) {
       // alert('entered');
        var shipAddr = component.get("v.shipToAddress");
        var action = component.get("c.getCheckoutSummaryInfo");
        console.log(component.get('v.recordId'));
        action.setParams({"accountId" : component.get('v.recordId'),
                          "shipAddr" :shipAddr
                         });
        
        var toastErrorHandler = component.find('toastErrorHandler');
        action.setCallback(this, function(response){
            toastErrorHandler.handleResponse(
                response,
                function(response){
                    var rtnValue = response.getReturnValue();
                    console.log(rtnValue);
                    if (rtnValue !== null) {    
                        component.set("v.shoppingCartDeliveryFee", rtnValue["TotalDeliveryAmount"]);
                        component.set("v.shoppingCartTotal", rtnValue["SalesGrandTotal"]);
                        component.set("v.shoppingCartTotalBeforeTax", rtnValue["TotalProductLastAmount"]);  
                        component.set("v.shoppingCartEstimatedTax", rtnValue["TotalTaxAmount"]);
                        component.set("v.shoppingCartWarrantyFee", rtnValue["TotalWarrantyAmount"]);  
                        component.set("v.shoppingCartRecycleFee", rtnValue["TotalRecycleAmount"]);
                       	component.set("v.shoppingCartNextDayCharge", rtnValue["TotalNextDayCharge"]);
                        component.set("v.shoppingCartWarrantyItemFee", rtnValue["WarrantyItemAmount"]);
                        component.set("v.isRenderForUpdate",false);
                       
                    }else {
                        helper.showToast("error", 'Tax Info is empty', component,
                                         'Could not get Tax Info.');                        
                    }
                },
                function(response, message){ // report failure
                    // DEF-0777 fix
                    helper.showToast("error", '', component,
                                     message);
                }
            )
        });            
        action.setBackground();
        $A.enqueueAction(action); 
    }
})