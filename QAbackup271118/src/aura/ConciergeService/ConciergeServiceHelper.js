({
    getRSAAccountInfo : function(component, success, failure) {
        var params = {};
        var action = component.get("c.getRSAAccountInfo");
        if (params) {
            action.setParams(params);
        }
        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                success(response.getReturnValue());
                //$A.get('e.force:refreshView').fire();
            } else {
                failure(response, response.getError());
            }
        });
        $A.enqueueAction(action);
    },    
    isPaymentStage : function(component, guestId, success, failure) {
        var params = {"guestId" : guestId};
        var action = component.get("c.isPaymentStage");
        if (params) {
            action.setParams(params);
        }
        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                success(response.getReturnValue());
                //$A.get('e.force:refreshView').fire();
            } else {
                failure(response, response.getError());
            }
        });
        $A.enqueueAction(action);
    },    
})