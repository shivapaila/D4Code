({
	doInit : function(component, event, helper) {
        //alert('test');
		var currentLineItemId = component.get("v.lineItemId");
		var currentOrderSfdcId = component.get("v.orderSfdcId");
        var HisData = component.get("v.typeOfData");
        
        //alert('currentLineItemId------'+currentLineItemId);
        //alert('currentOrderSfdcId------'+currentOrderSfdcId);
        //alert('HistoryData------'+HisData);
		
        var action;
        
        if(HisData == 'History')
        {
        	action = component.get("c.soLineItemHistoryData");
            action.setParams({
                soHNumber : currentOrderSfdcId
            });
        }
        else if(HisData == 'NoHistory')
        {
            action = component.get("c.soLineItemsData");
            action.setParams({
                soNumber : currentOrderSfdcId
            });
        }
		

	    action.setCallback(this, function(response) {
			var state = response.getState();
            //alert('state------'+state);
			if (state === "SUCCESS") { 
				var callResponse = response.getReturnValue(); 	
                //alert('ca-----' + callResponse);        
				component.set("v.itemsList", callResponse); 	 				
			}
			else{
				var errorToast = $A.get("e.force:showToast");
				errorToast.setParams({"message": response.getError()[0].message, "type":"error", "mode":"sticky"});
				errorToast.fire();
			}

		});
        
        $A.enqueueAction(action);
	},
    
       
    defaultCloseAction : function(component, event, helper) {  
        component.destroy();
    }
})