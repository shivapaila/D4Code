({
	doInit : function(component, event, helper) {
        helper.getCurrentRSA(component, function(){
            helper.getCommissionEntries(component);
            component.set("v.RendercomForUpdate",false);
        });
    }, 
    addCommissionEntry : function(component, event, helper) {
        var splits = component.get("v.commissionSplits");
        splits.push({
            'id' : null,
            'user' : null, 
            'percentage' : 0
        });
        component.set("v.commissionSplits", splits);         
    },
    handleCommissionSection : function(component, event, helper) {       
        component.set("v.isCollapsed", !component.get("v.isCollapsed"));
    },
    save: function (component, event, helper) {
        if (helper.isValidFormEntry(component) && helper.isValidCommissionEntries(component)){
            helper.saveCommissionEntries(component, helper.getAdjustedCommissionEntries(component), function(){
                helper.toastMessage("success", "Success", "Split saved.");
            });            
        }
    }    
})