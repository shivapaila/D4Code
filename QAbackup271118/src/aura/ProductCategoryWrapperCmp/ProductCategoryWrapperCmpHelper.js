({
	refreshProductHome: function(component){
        var productHome = component.find("productHomeId");
        if (productHome){
	        productHome.refreshView( 
	                        component.get("v.parentCategoryId")
	                        , component.get("v.productDetailId")
	                        , component.get("v.searchKey") 
	                );
	    }
	},
	navigateToProductHome: function(component) {
        var appEvent = $A.get("e.c:NavigateToWrapperComponentAppEvent");
        appEvent.setParams({
            "targetCmpName" : 'ProductCategoryWrapperCmp',
            "targetCmpParameters" : {	"parentCategoryId": component.get("v.parentCategoryId")
            							, "productDetailId": component.get("v.productDetailId")
            							, "searchKey": component.get("v.searchKey")
            						}
        });             
        appEvent.fire();		
	}
})