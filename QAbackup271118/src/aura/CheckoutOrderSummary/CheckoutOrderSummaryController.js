({
    doInit : function(component, event, helper) {
        console.log(component.get("v.shipToAddress"));
        helper.getCheckoutSummary(component, helper);
    },
    reloadSummary : function(component, event, helper){
        console.log('--in reload Summary-- JoJo test');
        console.log(component.get("v.shipToAddress"));
        helper.getCheckoutSummary(component, helper);
      //  window.location.reload(true);
    },
    reloadSummaryForDeliveryDateUpdated: function(component, event, helper){
        if(component.get("v.isRenderForUpdate")){
        	helper.getCheckoutSummary(component, helper);
	    	//event to notify Checkout when refresh finished, then update isRenderForUpdate back to false
		    var eventComponent = component.getEvent("DeliveryDateChangeNotifyToCheckoutSummary");
		    eventComponent.setParams({ "notifyParam":  false});
		    eventComponent.fire(); 
        }
        
    }
})