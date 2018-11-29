({
    doInit : function(component, event, helper) {
        component.set("v.isLoading", true);
        helper.initialCategoryBreadCrumb(component, component.get("v.parentCategoryId"), function(){
            helper.initialListInfo(component
                            , component.get("v.parentCategoryId")
                            , component.get("v.productDetailId")
                            , component.get("v.searchKey")                
                            , function(){
                                component.set("v.isLoading", false);
                            }
                           );
            

        });        
    },
    refreshView : function(component, event, helper) {
        var params = event.getParam('arguments');

        if (params) {
            var parentCategoryId= params.parentCategoryId;
            var productDetailId= params.productDetailId;
            var searchKey= params.searchKey;
            //alert('product id inhome '+productDetailId);
			//alert('search keyword is '+searchKey);
           
            component.set("v.productDetailTitle", null); 
            component.set("v.noCategoryDropdownList", false);
            component.set("v.categoryBreadCrumbLink", null);
            component.set("v.body", []);
            component.set("v.isLoading", true);

            helper.initialCategoryBreadCrumb(component, parentCategoryId, function(){
                helper.initialListInfo(component, parentCategoryId, productDetailId, searchKey, function(){
                    component.set("v.isLoading", false);
                });
            });
        }       
    },    
    switchCategoryBySelect : function(component, event, helper){
        var productEvent = component.getEvent('productEvent');
        productEvent.setParams({
            parentCategoryId : event.getSource().get("v.value")
        });
        productEvent.fire();
    },
    switchCategory : function(component, event, helper){
        var selectedItem = event.currentTarget; // Get the target object
        var clickedCategoryId = selectedItem.dataset.record; // Get its binding value

        var productEvent = component.getEvent('productEvent');
        productEvent.setParams({
            parentCategoryId : clickedCategoryId
        });
        productEvent.fire();        
    },
    handleLoadProductDetail : function(component, event, helper) {
        //alert('here Event');
        // console.log("notifyParam:"+event.getParam("notifyParam"));
        var productDetailTitle = event.getParam("notifyParam");
        component.set("v.productDetailTitle",productDetailTitle); 
        component.set("v.noCategoryDropdownList", true);
    }
})