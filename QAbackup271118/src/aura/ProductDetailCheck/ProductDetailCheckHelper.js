({
	 getProductDetail: function(component, helper) {   
        var action = component.get("c.getProductDetail");
            action.setParams({"productSKUId" : component.get('v.productDetailId')});
            action.setCallback(this, function(response){
                var state = response.getState();

                if(state == 'SUCCESS') {   
                    
                    var rtnValue = response.getReturnValue();
                    if (rtnValue !== null) {   

                        component.set("v.productDetail", rtnValue);
                        
                        component.set("v.isValidProduct", true); 
                    } else {
                        component.set("v.isValidProduct", false);                                           
                    }
                }else{
                    component.set("v.isValidProduct", false);
                }      
            });        
           action.setBackground();
            $A.enqueueAction(action); 
    },
    getProductPrice: function(component, helper) {   
        var action = component.get("c.getProductPrice");
        action.setParams({"productSKUId" : component.get('v.productDetailId')});
        action.setCallback(this, function(response){
            var state = response.getState();
 			var isValidProductPrice=true;
               
            if(state == 'SUCCESS') {
                var rtnValue = response.getReturnValue();
                if (rtnValue !== null) {   
                    component.set("v.productPrice", rtnValue);
                    component.set("v.isValidProductPrice", isValidProductPrice);
                } else {
                    isValidProductPrice=false;
                    component.set("v.isValidProductPrice", isValidProductPrice);                                           
                }
            }else{
                isValidProductPrice=false;
                component.set("v.isValidProductPrice", isValidProductPrice);   
            } 
            if(!isValidProductPrice){
                
                //event to notify ProductList, product isValidProductPrice
                var eventComponent = component.getEvent("ProductDetailCheckNotifyToProductList");
                eventComponent.setParams({ "notifyParam": component.get('v.productDetailId') });
                eventComponent.fire(); 

            }
        });        
      action.setBackground();
        $A.enqueueAction(action); 
    }
})