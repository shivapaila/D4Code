({
	getDetails : function(component) {
        var action = component.get("c.getDetails");
        action.setParams({
    	objectID: component.get("v.recordId")
		});
		
        action.setCallback(this, function(a){
            var res = a.getReturnValue();
            component.set("v.salesOrder", res);            
        });
        $A.enqueueAction(action);
	}
})