({
	doInit : function(component, event, helper) {
        var productDetailId = component.get("v.productDetailId");
        if(!$A.util.isEmpty(productDetailId)){
            helper.getProductPrice(component, helper);
        }
        
	}
})