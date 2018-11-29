({
    handleNavigateCmpAppEvent : function(component, event, helper) {
        event.stopPropagation();
        var cmpName = 'c__' + event.getParam("targetCmpName");
        
        var targetCmpParameters = event.getParam("targetCmpParameters");
        var parameters = {};
        if (!$A.util.isUndefinedOrNull(targetCmpParameters)){
            for (var key in targetCmpParameters){
                parameters['c__' + key] = targetCmpParameters[key];
               	//alert('key------'+JSON.stringify(key));
               // alert('parameters------'+JSON.stringify(parameters));
            }
        }
        var pageReference = {
            "type" : "standard__component",
            "attributes" : {
                "componentName" : cmpName
            },
            "state": parameters
        };
        component.set("v.pageReference", pageReference);
        helper.handleNavigation(component);
         
    },
    handleNavigateTabAppEvent : function(component, event, helper) {
        var pageTabName=event.getParam("targetTabName");
        var pageReference = {
            "type" : "standard__navItemPage",
            "attributes" : {
                "apiName" : pageTabName
            }
        }
        
        var navService = component.find("navService");
        navService.navigate(pageReference,true);
    }
})