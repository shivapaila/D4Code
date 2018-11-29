({
	doInit : function(component, event, helper) {
		//helper.getProductDetail(component, helper);
        helper.getProductPrice(component, helper);
	},
    goToProductDetail : function(component, event, helper) {
        var selectedItem = event.currentTarget; // Get the target object
        var clickedProductInfo = selectedItem.dataset.record; // Get its binding value
        var parentCategoryId = component.get('v.parentCategoryId');

        var productEvent = component.getEvent('productEvent');
        productEvent.setParams({
            "parentCategoryId" : parentCategoryId, "productDetailId": clickedProductInfo
        });
        productEvent.fire(); 
    },
    addToCart : function(component,event,helper){
         var eventComponent = component.getEvent("NotifyParentOpenCustomerModal");
        eventComponent.setParams({ "notifyParam": component.get('v.productDetail') ,
          
                                  "notifyParam1": component.get('v.productPrice') });
        eventComponent.fire(); 
        

    },
      isRefreshed: function(component, event, helper) {
        location.reload();
      }
})