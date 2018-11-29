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
    initialCategory : function(component,helper) {
      var action = component.get("c.getCategoryTree");
         action.setParams({"parentCategoryId" : component.get('v.parentCategoryId')});
         var toastErrorHandler = component.find('toastErrorHandler');
      
        action.setCallback(this, function(response){
            toastErrorHandler.handleResponse(
                response,
                function(response){
                    var rtnValue = response.getReturnValue();
                    if (rtnValue !== null) {   
                        component.set("v.categoryTree", rtnValue);                    
                        helper.moveCursor(component);
                    }else {
                        helper.showToast("error", 'Product category not found', component,
                                         'Could not find product category.');                        
                    }
                },
                function(response, message){ // report failure
                    helper.showToast("error", 'Product category not found', component,
                                     message);
                }
            )
        });            
        action.setBackground();
        $A.enqueueAction(action); 
    },
    moveCursor: function(component) {
        var categoryTree = component.get("v.categoryTree");
        var subCategoryAllList = categoryTree.categoriesWithImage;
        var currentIndex = component.get("v.cursorIndex");
        var depth=component.get("v.loadMoreDepth");
        var categoryTreeToShow;
        if(subCategoryAllList.length > currentIndex+depth){
            categoryTreeToShow = subCategoryAllList.slice(0, currentIndex+depth);
            component.set("v.hasMore", true);
        }else{
            categoryTreeToShow = subCategoryAllList.slice(0, subCategoryAllList.length);
            component.set("v.hasMore", false);
        } 
		component.set("v.categoryTreeToShow", categoryTreeToShow);   
        component.set("v.cursorIndex",component.get("v.cursorIndex")+depth); 
    }
})