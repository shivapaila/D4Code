({
	handleGetRSAAccountInfo : function(component, event, helper) {
        var params = event.getParam('arguments');
        if (params) {
            helper.getRSAAccountInfo(component, params.success, params.failure);
        } 
	},	
	handleIsPaymentStage : function(component, event, helper) {
        var params = event.getParam('arguments');
        if (params) {
            helper.isPaymentStage(component, params.guestId, params.success, params.failure);
        } 
	}
})