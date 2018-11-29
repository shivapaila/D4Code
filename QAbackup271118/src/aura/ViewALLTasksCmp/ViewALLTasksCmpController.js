({
	Init : function(component, event, helper) {
		var action = component.get("c.getAllOpenTasks");  
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
    back:function(component, event, helper) 
    {
       
        /*var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/one/one.app#/n/Concierge"
        });
        urlEvent.fire();*/
        var appEvent = $A.get("e.c:NavigateToWrapperComponentAppEvent");
                    appEvent.setParams({
                        "targetCmpName" : 'ConciergeWrapperCmp',
                    });
                    appEvent.fire();
        
    },
    
    renderPage: function(component, event, helper) {
        helper.renderPage(component);
    },

    /*
    createTask : function(component, event, helper) {
        
        var createRecordEvent = $A.get("e.force:createRecord");
        createRecordEvent.setParams({
            "entityApiName": "Task"
        });
        createRecordEvent.fire();
    }

    // DEF-0151 - to load custom new task component
    createTask : function(component, event, helper) {
        var evt  = $A.get("e.force:navigateToURL");
        evt.setParams({
            "url": '/one/one.app#/n/New_Task'
        })
        evt.fire();
     }*/

     // DEF-0151 - to load custom new task component
    createTask : function(component, event, helper) {
        console.log('New Create Task');

        $A.createComponent(
            "c:ConciergeTaskNew",
            {
                "aura:id": "findableAuraId"
            },
            function(newButton, status, errorMessage){
                if (status === "SUCCESS") {
                    var body = component.get("v.body");
                    body.push(newButton);
                    component.set("v.body", body);
                }
                else if (status === "INCOMPLETE") {
                    console.log("No response from server or client is offline.");
                }
                else if (status === "ERROR") {
                    console.log("Error: " + errorMessage);
                }
            }
        );

    },

    closeComponent : function(component, event){
        var comp = event.getParam("comp");
        comp.destroy();
    }
})