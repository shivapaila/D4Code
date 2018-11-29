({
	doinit : function(component, event, helper) {
        alert();
    var evt = $A.get("e.force:navigateToComponent");
    evt.setParams({
        componentDef : "c:TechScheduling"
        
    });
    evt.fire();
}
})