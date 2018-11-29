({
	doInit : function(component, event, helper) {
		component.set("v.showSpinner", true);
		var currentOrderId = component.get("v.recordId");

    var action = component.get("c.getLineItems");
 			
		action.setParams({
	        salesforceOrderId : currentOrderId
	    });

	    action.setCallback(this, function(response) {
			var state = response.getState();
      if (state === "SUCCESS") {
				var callResponse = response.getReturnValue(); 																					
				component.set("v.lineItems", callResponse);
			}
			else{
				var errorToast = $A.get("e.force:showToast");
				errorToast.setParams({"message": response.getError()[0].message, "type":"error", "mode":"sticky"});
				errorToast.fire();
			}

		});

        //Added by Sudeshna Saha
        var action2 = component.get("c.getval");
 			
		action2.setParams({
	        salesforceOrderId : currentOrderId
	    });

	    action2.setCallback(this, function(response) {
			var state = response.getState();
			if (state === "SUCCESS") {
				var callResponse = response.getReturnValue(); 	
                console.log('Est Arrival res >--->'+callResponse);
				component.set("v.lineItemsEstArrival", callResponse); 	
                 console.log('Est Arrival >--->'+component.get("v.lineItemsEstArrival"));
			}
			else{
				var errorToast = $A.get("e.force:showToast");
				errorToast.setParams({"message": response.getError()[0].message, "type":"error", "mode":"sticky"});
				errorToast.fire();
			}
	  component.set("v.showSpinner", false);
    });  
        //End by Sudeshna Saha
        $A.enqueueAction(action);
        $A.enqueueAction(action2);
  },

    openPop : function(component, event, helper) {
          component.set("v.Spinner", false);
            var cmpTarget = component.find('pop');
            $A.util.addClass(cmpTarget, 'slds-show');
            $A.util.removeClass(cmpTarget, 'slds-hide');
        	var ctarget = event.currentTarget;
            var id_str = ctarget.dataset.value;
            component.set('v.PopupsoId',id_str);   
            var actiondata = component.get("c.getSalesOrderLineItem");
            console.log('id_str-->'+id_str);
              actiondata.setParams({
               "salesOrderItemId" : id_str,
               "salesOrderId" : component.get("v.recordId")
                                     });
        		 actiondata.setCallback(this, function(response){ 
                //  component.find("Id_spinner").set("v.class" , 'slds-hide');
                    var state = response.getState();
                  		 if (state === "SUCCESS") {
                       		 var callResponse = response.getReturnValue();
                        //alert('callResponse'+JSON.stringify(callResponse));
                        		component.set("v.SalesOrdLineItemData", callResponse);
                             console.log('SalesOrdLineItemData >->'+component.get("v.SalesOrdLineItemData"));
                         }
                      	else{
                   		 var errorToast = $A.get("e.force:showToast");
                    		errorToast.setParams({"message": response.getError()[0].message, "type":"error", "mode":"sticky"});
                    		errorToast.fire();
                			}
                        	});
                    
           $A.enqueueAction(actiondata);
              component.set("v.Spinner", false);
    },
    
    closePop : function(component, event, helper) {
            var cmpTarget = component.find('pop');
            $A.util.addClass(cmpTarget, 'slds-hide');
            $A.util.removeClass(cmpTarget, 'slds-show');
           // var selectedItem = event.currentTarget;
           // var Id = selectedItem.dataset.record;
    
    },
	launchLineItemDeatil : function(component, event, helper) {
        console.log('here');
		var currentOrderLineId = event.currentTarget.dataset.orderlineid;
		var currentOrderSFDCId = event.currentTarget.dataset.ordersfdcid;
		//alert('currentOrderLineId-----'+currentOrderLineId);
        //alert('currentOrderSFDCId-----'+currentOrderSFDCId);
	    $A.createComponent(
            "c:SalesOrderLineItemDetail",
            
            {
                "lineItemId": currentOrderLineId,
                "orderSfdcId": currentOrderSFDCId
            },
            function(msgBox){                
                if (component.isValid()) {
                    var popupPlaceholder = component.find('lineItemDetailsPlaceHolder');
                    var body = popupPlaceholder.get("v.body");
                    body.push(msgBox);
                    popupPlaceholder.set("v.body", body); 
                }
            }
        );	
	}
})