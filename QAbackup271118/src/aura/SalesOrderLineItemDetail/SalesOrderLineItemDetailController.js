({
	doInit : function(component, event, helper) {

		var currentLineItemId = component.get("v.lineItemId");
		var currentOrderSfdcId = component.get("v.orderSfdcId");
		console.log('orderid' + currentOrderSfdcId);
        console.log('lineid' + currentLineItemId);
		var action = component.get("c.getLineItem");
 			
		action.setParams({
	        lineItemExternalId : currentLineItemId,
	        OrderId : currentOrderSfdcId
	    });

	    action.setCallback(this, function(response) {
			var state = response.getState();
			if (state === "SUCCESS") {
				var callResponse = response.getReturnValue(); 	
                console.log('ca;;' + JSON.stringify(callResponse));
				component.set("v.lineItemWrapper", callResponse); 	 				
			}
			else{
				var errorToast = $A.get("e.force:showToast");
				errorToast.setParams({"message": response.getError()[0].message, "type":"error", "mode":"sticky"});
				errorToast.fire();
			}

		});
        	var actionquantity = component.get("c.getQuantity");
        	actionquantity.setParams({
	        lineItemExternalId : currentLineItemId,
	        OrderId : currentOrderSfdcId
	    });

	    actionquantity.setCallback(this, function(response) {
			var state = response.getState();
            
			if (state === "SUCCESS") {
				var callResponse = response.getReturnValue();
          	    console.log('callrespo' + JSON.stringify(callResponse)); 
                if(callResponse !== 'No records founds--' ) {
                var jsonData = JSON.parse(response.getReturnValue());
					
                for(var i=0;i<jsonData.lineItems.length;i++) {
                    var qtynum =jsonData.lineItems[i].inStore;
                    var warehouseqty = jsonData.lineItems[i].inWarehouse;
                }
			    component.set("v.quantityval",qtynum);
                component.set("v.warehouseqty",warehouseqty);
                } else if(callResponse === 'No records founds--') {
                    var qtyval = '0';
                    var warehouseqty = '0';
                       component.set("v.quantityval",qtyval);
                		component.set("v.warehouseqty",warehouseqty);
                }
            }
          
			else{
				var errorToast = $A.get("e.force:showToast");
				errorToast.setParams({"message": response.getError()[0].message, "type":"error", "mode":"sticky"});
				errorToast.fire();
			}

		});
      
/*	var actionLOC = component.get("c.getLOC");
        	actionLOC.setParams({
	        lineItemExternalId : currentLineItemId,
	        OrderId : currentOrderSfdcId
	    });

	    actionLOC.setCallback(this, function(response) {
			var state = response.getState();
            
			if (state === "SUCCESS") {
				var callResponse = response.getReturnValue();
                //var jsondata = JSON.parse(response.getReturnValue());
          	    console.log('callrespo' + JSON.stringify(callResponse)); 
               // console.log('jsondata' + jsondata);
                  if(callResponse !== 'No records founds--' ) {
                      var jsonData = JSON.parse(response.getReturnValue());
                      console.log('json' + JSON.stringify(jsonData));
                    var locationPO = jsonData.locationPo;
                    var estArrival = jsonData.estimatedArrival;
                    var ackNo = jsonData.acknowledgementNumber;
                        component.set("v.locationPO",locationPO);
                        component.set("v.estArrival",estArrival);
                        component.set("v.ackNo",ackNo);
                  } else if(callResponse === 'No records founds--') {
                    var locationPO = '';
                    var estArrival = '';
                    var ackNo 	   = '';
                        component.set("v.locationPO",locationPO);
                        component.set("v.estArrival",estArrival);
                        component.set("v.ackNo",ackNo);
                  }
				}
			else{
				var errorToast = $A.get("e.force:showToast");
				errorToast.setParams({"message": response.getError()[0].message, "type":"error", "mode":"sticky"});
				errorToast.fire();
			}

		});
      */
		$A.enqueueAction(action);
        $A.enqueueAction(actionquantity);
    //    $A.enqueueAction(actionLOC);
	},
	defaultCloseAction : function(component, event, helper) {  
        component.destroy();
    },
	setToEditMode : function(component, event, helper) {  
        component.set("v.inEditMode", true); 
    },
    setToDetailMode : function(component, event, helper) {  
        component.set("v.inEditMode", false); 
    },
    saveChanges : function(component, event, helper) {  
        console.log('TODO with availability of order update API')
    },
    launchDeliveryDateLookup : function(component, event, helper) {
		var desiredDeliveryDate = component.get("v.selectedDesiredDeliveryDate"); 
		
		if(desiredDeliveryDate != null){
			var orderLine = component.get("v.lineItemWrapper");
			var currentOrderId = orderLine.orderExternalId;
			var orderLineId = orderLine.lineItem.ExternalId;

			var accountNumber = orderLine.orderAccountNumber;
			var rdcId = orderLine.orderRdcId;			

			$A.createComponent(
	            "c:DeliveryWindowLookup",
	            {
	                "orderId": currentOrderId,
	                "orderLineId": orderLineId,
	                "selectedDesiredDeliveryDate": desiredDeliveryDate,
	                "accountNumber": accountNumber,
	                "rdcId": rdcId
	            },
	            function(msgBox){                
	                if (component.isValid()) {
	                    var popupPlaceholder = component.find('deliveryWindowLookupPlaceHolder');
	                    popupPlaceholder.set("v.body", msgBox); 
	                }
	            }
	        );
		}else{
			console.log("no delivery date selected");
			var errorToast = $A.get("e.force:showToast");
			errorToast.setParams({"message": "Select a Desired Delivery Date", "type":"error", "mode":"dismissible", "duration":10000});
			errorToast.fire();
		}
	},
	updateDeliveryDate : function(component, event, helper) {		
		var orderLine = component.get("v.lineItemWrapper");
		var orderLineId = orderLine.lineItem.ExternalId;
		var orderLineIdFromEvent = event.getParam("orderLineId");
		var selectedDeliveryDateFromEvent = event.getParam("deliveryDate");

		if(orderLineId == orderLineIdFromEvent){
			orderLine.lineItem.phdDeliveryDueDate__c = selectedDeliveryDateFromEvent;
			component.set("v.lineItemWrapper", orderLine); 	
		}
	}
})