({
    doInit : function(component, event, helper) {
        
        component.set("v.cursorIndex",0);
        //Comment initialProductList line if use Filter API
        //helper.initialProductList(component,helper);
        //UnComment initialProductFilter line if use Filter API
        
        helper.initialPriceZone(component,helper);
    },
    loadMore : function(component, event, helper) {
        //Comment moveCursor line if use Filter API
       // helper.moveCursor(component,helper);
        //UnComment moveCursorForFilter line if use Filter API

        helper.moveCursorForFilter(component,helper);
    },
    switchFilter: function(component, event, helper) {
        console.log('switchFilter');
        
        helper.filterProductListBase(component,helper, false);
    },
    updateProductPriceValidFlag : function(component, event, helper) {
        var productDetailId = event.getParam("notifyParam");
        var allPList = component.get("v.categoryProductList");
        var operateAllPList = allPList;
        allPList.forEach(function(currentValue, index, arr){
            if(currentValue.id==productDetailId){
                operateAllPList.splice(index,1);
            }
        });
        component.set("v.categoryProductList",operateAllPList);
        helper.refreshForInvalidPriceProduct(component,helper);
    },
    openCustomModal : function(component, event, helper) {
        var productDetail = event.getParam("notifyParam");
        var productPrice = event.getParam("notifyParam1");
        component.set("v.selectedProductDetail", productDetail);
        component.set("v.selectedProductPrice", productPrice);
        component.set("v.showcustomerModal", true);
        var overlay = component.find('backdrop');
        $A.util.addClass(overlay, 'slds-backdrop--open');
    },
    closeCustomerModal: function(component, event, helper) {
        component.set("v.showcustomerModal", false);
        var overlay = component.find('backdrop');
        $A.util.removeClass(overlay, 'slds-backdrop--open');
    },
    closeCustomerModalAndRefresh: function(component, event, helper) {
        component.set("v.showcustomerModal", false);
        var overlay = component.find('backdrop');
        $A.util.removeClass(overlay, 'slds-backdrop--open');
        //In case add to cart for new guest, refresh concierge_head active cart numbers,so refresh whole page
        // var subComponentName =  event.getParam("notifyParam1");        
        //  if(subComponentName=='AddCustomer'){
        //Both FindCustomer and AddCustomer addToCart action need to refresh header component to refresh the active cart number
            var appEvent = $A.get("e.c:NotifyHeaderComponentEvent"); 
            appEvent.fire();
        // }
    }
})