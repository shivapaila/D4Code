({
    myAction : function(component, event, helper) {
        
    },
	getStatus : function(component, event, helper) {
		console.log("recordLoader-->"+component.find("recordLoader").get("v.value"));
	    // Ask Lightning Data Service to save the record
	    var getId = component.get("v.recordId");
        var result = '1';
	  
        var isError = false;
        var result = '1';
        //----TRACKING NUMBER----START----//
        var isTracking = component.get('c.getTrackingNumber');
        isTracking.setParams({
            mynum : getId,
            FulfillerId : component.find('fulfillerID').get('v.value'),
            PoNum : component.find('POnumber').get('v.value'),
        });
        isTracking.setCallback(this,function(res){
             console.log('selectedItems::::res.getReturnValue-->',+res.getReturnValue());
             result = res.getReturnValue();
             console.log('isSavemySN--->',+result);
            if(result== '1')
        	{
                console.log('CHANGES MADE');
                var resultsToast = $A.get("e.force:showToast");
                resultsToast.setParams({
                    "title": "UPDATED TRACKING NUMBER",
                    "message": "Tracking Number Updated.",
                	 type: "success",
                });
                resultsToast.fire();
            }
            else
            {
              var resultsToast = $A.get("e.force:showToast");
                resultsToast.setParams({
                    "title": "Warning",
                    "message": "Part Order Number Not Found",
                	 type: "warning",
                });
                resultsToast.fire();
              console.log('NO CHANGE');
            }
            var navEvt = $A.get("e.force:navigateToSObject");
                navEvt.setParams({
                    "recordId": getId,
                    "slideDevName": "detail"
                });
                navEvt.fire();
         }); 
        
        $A.enqueueAction(isTracking);
       
        //----TRACKING NUMBER----END----//   
     },
    onCancel : function(component, event, helper) {
    
        // Navigate back to the record view
        var navigateEvent = $A.get("e.force:navigateToSObject");
        navigateEvent.setParams({ "recordId": component.get('v.recordId') });
        navigateEvent.fire();
    }
})