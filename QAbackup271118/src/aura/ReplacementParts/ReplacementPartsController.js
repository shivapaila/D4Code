({
    myAction : function(component, event, helper) {
        component.set('v.isSerialNumValid',false);
        var isSerNum = component.get('v.isSerialNumValid');
        var itemSerialNumber = component.find('itemSerialNumber');
        console.log('isSerNum-isSerialNumValid-->',+isSerNum);
        console.log('isSerNum-itemSerialNumber-->',+itemSerialNumber);
        if(isSerNum==true){
            console.log('isSerNum-->',+isSerNum);
          //  itemSerialNumber.set("v.errors", [{message: "Please Enter a Valid Serial Number"}]);
        }
        else if(isSerNum==false){
            console.log('isSerNum-->',+isSerNum);
         //   itemSerialNumber.set("v.errors", [{message: null}]);
        } 
    },
	onSave : function(component, event, helper) {
		console.log("recordLoader-->"+component.find("recordLoader").get("v.value"));
	    // Ask Lightning Data Service to save the record
	    var getId = component.get("v.recordId");
        var result = '1';
	   var isSave = component.get("c.getSerialNumber");
        var isError = false;
        var result = '1';
        isSave.setParams({
            ProductLineItemId : getId,
            plsrNum : component.find('itemSerialNumber').get('v.value'),
        });
        isSave.setCallback(this,function(res){
             console.log('selectedItems::::res.getReturnValue-->',+res.getReturnValue());
             result = res.getReturnValue();
             console.log('isSavemySN--->',+result);
            if(result== '0')
        	{
                console.log('isSerialNumValid--->',+result);
            	component.set('v.isSerialNumValid',true);
            	isError = true;
                console.log('isSerialNumValid122--->',+component.get('v.isSerialNumValid'));
            }
            else
            {
              console.log('isSerialNumValid--->',+result);
              component.set('v.isSerialNumValid',false);
              console.log('isSerialNumValid122--->',+component.get('v.isSerialNumValid'));
            }
         });
        $A.enqueueAction(isSave);
       
        //----TRACKING NUMBER----START----//
    /*    var isTracking = component.get('c.getTrackingNumber');
        isTracking.setParams({
            mynum : getId,
            FulfillerId : component.find('fulfillerID').get('v.value'),
            PoNum : component.find('POnumber').get('v.value'),
        });
        isTracking.setCallback(this,function(res){
             console.log('selectedItems::::res.getReturnValue-->',+res.getReturnValue());
             result = res.getReturnValue();
             console.log('isSavemySN--->',+result);
            if(result== '0')
        	{
                console.log('isSerialNumValid--->',+result);
            	component.set('v.isSerialNumValid',true);
            //	isError = true;
                console.log('isSerialNumValid122--->',+component.get('v.isSerialNumValid'));
            }
            else
            {
              console.log('isSerialNumValid--->',+result);
              component.set('v.isSerialNumValid',false);
              console.log('isSerialNumValid122--->',+component.get('v.isSerialNumValid'));
            }
         }); 
        $A.enqueueAction(isTracking);
       */
        //----TRACKING NUMBER----END----//
        
        var check = component.get('c.check');
        check.setParams({
            
        });
        check.setCallback(this,function(res){
             console.log('isSerialNumValidcheck--->',+component.get('v.isSerialNumValid'));
            if(component.get('v.isSerialNumValid') == false){
            component.find("recordLoader").saveRecord($A.getCallback(function(saveResult) {
            if (saveResult.state === "SUCCESS") {

                // Display popup confirmation to the user
                var resultsToast = $A.get("e.force:showToast");
                resultsToast.setParams({
                    "title": "Saved",
                    "message": "The record was updated.",
                	 type: "success",
                });
                resultsToast.fire();
                
                // Navigate back to the record view
                var navigateEvent = $A.get("e.force:navigateToSObject");
                navigateEvent.setParams({ "recordId": component.get('v.recordId') });
                navigateEvent.fire();
            }
            else {
                // Basic error handling
                component.set('v.recordError', 
                    'Error: ' + saveResult.state + ', message: ' + JSON.stringify(saveResult.error));
            }
        }));
        }
            else{
                component.find('itemSerialNumber').focus();
                component.find('itemSerialNumber').set('v.validity', {valid:false, badInput :true});
                var toastEvent = $A.get("e.force:showToast");
				toastEvent.setParams({
                    "title": "Error!",
                    "message": "Invalid Serial Number",
                    type: "error"
                });
                
                toastEvent.fire();
             //   var itemSerialNumber = component.find('itemSerialNumber');
   			//	var value = itemSerialNumber.get('v.value');
            /*    console.log('Invalid Serial number');
                component.find('itemSerialNumber').showHelpMessageIfInvalid();
                component.find('itemSerialNumber').focus();
                component.find('itemSerialNumber').set('v.validity', {valid:false, badInput :true});
                */
               }
        });
        $A.enqueueAction(check);
        
	},
    onCancel : function(component, event, helper) {
    
        // Navigate back to the record view
        var navigateEvent = $A.get("e.force:navigateToSObject");
        navigateEvent.setParams({ "recordId": component.get('v.recordId') });
        navigateEvent.fire();
    }
})