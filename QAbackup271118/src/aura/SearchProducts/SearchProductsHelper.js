({
    callSearchProducts : function(component,event,helper) {
        //alert('search');
        var isUnDefined = $A.util.isUndefined(component.find("searchInput").get("v.value"));
        if(isUnDefined) {
            helper.toastMessage("Error","",$A.get("$Label.c.Search_Products_Error"));    
        }
        else {
            var key = component.find("searchInput").get("v.value");
            //alert('search key'+key);
            var appEvent = $A.get("e.c:NavigateToWrapperComponentAppEvent");
            appEvent.setParams({
                "targetCmpName" : 'ProductCategoryWrapperCmp',
                "targetCmpParameters" : {"parentCategoryId": null, "productDetailId": null, "searchKey": key}
            });             
            appEvent.fire(); 
          
        }    
    },
    
    toastMessage : function(type,title,message){
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            type: type,
            title: title, 
            message: message,
        });
        toastEvent.fire();
    },
    
})