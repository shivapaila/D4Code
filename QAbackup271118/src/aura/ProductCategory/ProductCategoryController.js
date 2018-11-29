({
    doInit : function(component, event, helper) {
        component.set("v.cursorIndex",0);
        helper.initialCategory(component,helper);
       
    },
    switchCategory : function(component, event, helper){
        var element = event.target;
        while (element && (element.tagName !== 'A')) {
            element = element.parentNode;
        }
        if (element) {
            event.stopPropagation();
            event.preventDefault();

            var categoryId = element.getAttribute('data-record');
            var productEvent = component.getEvent('productEvent');
            productEvent.setParams({
                parentCategoryId : categoryId
            });
            productEvent.fire();            
        }
    },
    loadMore : function(component, event, helper) {
         helper.moveCursor(component);
    }
})