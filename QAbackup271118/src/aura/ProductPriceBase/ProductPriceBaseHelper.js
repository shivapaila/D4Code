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
    getProductPrice: function(component, helper) {   
        var action = component.get("c.getProductPrice");
        var toastErrorHandler = component.find('toastErrorHandler');
        action.setParams({"productSKUId" : component.get('v.productDetailId')});
        action.setCallback(this, function(response){
            toastErrorHandler.handleResponse(
                response, // handle failure
                function(response){ // report success and navigate to contact record
                    var rtnValue = response.getReturnValue();
                    if (rtnValue !== null) {
                        component.set("v.productPrice", rtnValue);
                        //setting the value to event to get it from the main detail component
                        var priceEvent = $A.get("e.c:getProductPricesEvent");
                        priceEvent.setParams({
                            "productPrice" :component.get('v.productPrice') 
                             });
                        priceEvent.fire();
                    } else {
                        helper.showToast("error", 'Product price not found', component,
                                         'Could not find product.');                        
                    }
                },
                function(response, message){ // report failure
                    //keep this console.log to log apex error info.Show intuitive message in Toaster
                    console.log(message);
                    helper.showToast("error", 'Product price not found', component,
                                     'This product is not available as it is not found in Source System, please contact System Administrator');
  
                }
            )            
        });        
        action.setBackground();
        $A.enqueueAction(action); 
    }
})