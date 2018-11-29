({
	Init : function(cmp, event, helper) {
       	        	
        var val= cmp.get("v.customerwithActiveCartLst");
       
        cmp.set('v.initialLst',val);
        cmp.set("v.maxPage", Math.floor((val.length+9)/10));
                helper.renderPage(cmp, event, helper);
    },
    renderPage: function(component, event, helper) {
        helper.renderPage(component);
    },
	search: function(component, event, helper) {
        var searchKeyFld = component.find("searchId");
        var srcValue = searchKeyFld.get("v.value");
         searchKeyFld.set("v.errors", null);
            // call helper method
            helper.SearchHelper(component, event);
      },    
    goToRecord : function(component, event, helper) {
         var element = event.target;
        while (element && (element.tagName !== 'A')) {
              element = element.parentNode;
                }
        if (element) {
             event.stopPropagation();
           event.preventDefault();
			 var recordId = element.getAttribute('data-record');
            
           var appEvent = $A.get("e.c:NavigateToWrapperComponentAppEvent");
            appEvent.setParams({
                "targetCmpName" : 'CustomersCartWrapperCmp',
                "targetCmpParameters" : {"recordId": recordId}
                
            });
            //alert('CustomersCartWrapperCmp');
            component.set("v.showModal", false);
           appEvent.fire();
            //window.locaion.reload();
           //appEvent.fire(); 
          }
     },
     

    confirm: function(component, event, helper) {
        var id= event.currentTarget.id;
        var wrapper=component.get('v.currentList');
        wrapper[id].selected=true;
        component.set('v.currentList',wrapper);

    },
    cancel: function(component, event, helper) {
         var id= event.currentTarget.id;
        var wrapper=component.get('v.currentList');
        wrapper[id].selected=false;
        component.set('v.currentList',wrapper);
    },
    removeOpp: function(component, event, helper) {
         var id= event.currentTarget.id;
        var wrapper=component.get('v.currentList');
        var opp=wrapper[id].oppRecord;
        var action = component.get("c.closeOpp");
        action.setParams({
            'opp': wrapper[id].oppRecord
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var val = response.getReturnValue();   
                $A.get('e.force:refreshView').fire();
            }
 
        });
        $A.enqueueAction(action);
    }
})