({
	init : function(component, event, helper) {
        		
                //Read pageReference
                var pageReference = component.get("v.pageReference");
                // If navigation from another location
                if (!$A.util.isUndefinedOrNull(pageReference)){
                        //Read parameters from pageReference state
                        var receivedParams = pageReference.state;
                        //Set component attributes to paameters received from state
                        if (!$A.util.isUndefinedOrNull(receivedParams['c__' + 'parentCategoryId'])){
                                component.set("v.parentCategoryId", receivedParams['c__' + 'parentCategoryId']);
                        }
                        if (!$A.util.isUndefinedOrNull(receivedParams['c__' + 'productDetailId'])){
                                component.set("v.productDetailId", receivedParams['c__' + 'productDetailId']);
                        }
                        if (!$A.util.isUndefinedOrNull(receivedParams['c__' + 'searchKey'])){
                            	
                                component.set("v.searchKey", receivedParams['c__' + 'searchKey']);
                        }
                }
                component.set("v.renderProduct", true); 
	},
        handleProductEvent : function(component, event, helper) {
                component.set("v.parentCategoryId", null);
                component.set("v.productDetailId", null);
                component.set("v.searchKey", null);

                var parentCategoryId = event.getParam("parentCategoryId");
                var productDetailId = event.getParam("productDetailId");
                var searchKey = event.getParam("searchKey");

                if (!$A.util.isUndefinedOrNull(parentCategoryId)){
                        component.set("v.parentCategoryId", parentCategoryId);
                }
                if (!$A.util.isUndefinedOrNull(productDetailId)){
                        component.set("v.productDetailId", productDetailId);
                }
                if (!$A.util.isUndefinedOrNull(searchKey)){
                        component.set("v.searchKey", searchKey);
                }
                helper.refreshProductHome(component);                        
        }        
})