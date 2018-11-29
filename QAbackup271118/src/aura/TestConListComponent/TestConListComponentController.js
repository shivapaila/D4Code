({
	myAction : function(component, event, helper) {
		var action = component.get("c.getContacts");
        action.setCallback(this, function(data) {
		component.set("v.contacts", data.getReturnValue());
});
		$A.enqueueAction(action);

	},
    reInit : function(component, event, helper) {
        console.log('re-init');
        myAction();
    },
    refreshview : function(component, event, helper) {
        $A.get('e.force:refreshView').fire();
    }

})