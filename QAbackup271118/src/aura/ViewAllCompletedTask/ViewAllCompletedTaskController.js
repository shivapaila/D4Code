({
	Init : function(component, event, helper) {
		var action = component.get("c.getAllCompletedTasks");  
        action.setCallback(this, function(a) {
            
            var rtnValue  = a.getReturnValue();
            console.log(rtnValue);
            if (rtnValue !== null) {
                component.set("v.allTasks",rtnValue.wrapperLst);
             
                component.set("v.statusOpts",rtnValue.statusLst);
                component.set("v.typeOpts",rtnValue.typeLst);
                var val=rtnValue.wrapperLst;
                component.set("v.maxPage", Math.floor((val.length+9)/10));
                helper.renderPage(component, event, helper);
            }
            else
            {
                 // if allTasks size is 0 ,display no record found message on screen.
                if (component.get('v.allTasks').length == 0) {
                    component.set("v.Message", true);
                } else {
                    component.set("v.Message", false);
                }
            }
        });

        $A.enqueueAction(action);
	},
    
    renderPage: function(component, event, helper) {
        helper.renderPage(component);
    },
    
})