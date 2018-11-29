({
    openModal : function(component, event, helper) {
    	component.set("v.isLoading", true);
        component.set("v.openModal", true);
        var saleserr = component.get("v.isSalesOrder");
        console.log('saleserr-->'+saleserr);
        if(!saleserr){
        	component.set("v.isLoading", false);
            document.getElementById('saleserror').innerHTML="No Sales Order Associated with this Case";
            return;
        }
        else{
            component.set("v.openLineList",true);
	        var getId = component.get("v.recordId");
	        console.log('my record id',+getId);
	        var actionSalesOrder = component.get("c.getSalesOrderInfo");
	        console.log('my EXrecord id', actionSalesOrder);
	        //	component.find('v.Sales_Order_id').set('v.value', actionSalesOrder);
	        actionSalesOrder.setParams({
	            "recordId":getId
	        });
	        actionSalesOrder.setCallback(this, function(response) {
	            if (component.isValid() && response.getState() == "SUCCESS") {
	                component.set("v.salesOrderObj" , response.getReturnValue());
	                console.log('sales' + JSON.stringify(response.getReturnValue()));
	            } else {
	                console.log("Failed with state: " + JSON.stringify(response.getError()));
	                component.set("v.isSalesOrder",false);
	            }
	        });
	        var actionSalesLine = component.get("c.getSoLineItemsBySoExternalId");
	        actionSalesLine.setParams({
	            "recordId":getId
	        });
	        actionSalesLine.setCallback(this, function(response) {
	        	component.set("v.isLoading", false);
	            if (component.isValid() && response.getState() == "SUCCESS") {
	                component.set("v.lineItem" , response.getReturnValue());
	                component.set('v.mydata', response.getReturnValue());
	                component.set('v.options', [
	                    {label: 'Item Sku', fieldName: 'phdItemSKU__c', type: 'text'},
	                    {label: 'Description', fieldName: 'phdItemDesc__c', type: 'text'},
	                    {label: 'Quantity', fieldName: 'phdQuantity__c', type: 'number'},
	                    {label: 'Delivered Date', fieldName: 'phdPurchaseDate__c', type: 'Datetime'},
	                ]);
				} else {
	            	console.log("Failed with state: " + JSON.stringify(response.getError()));
	            }
			});

	        $A.enqueueAction(actionSalesLine);
			$A.enqueueAction(actionSalesOrder);
        }
    },

	//Get selected product line item
    getSelectedVal:function(component,event) {
    	var selectedRows = event.getParam('selectedRows');
        console.log('My selected selectedRows',+selectedRows);
        var selectedListlength = selectedRows.length;
        var selectedDesc = [];
        var selectedvals = [];
        var finallist = [];
        var flag = 0;
        for (var i = 0; i < selectedRows.length; i++){
        	component.set("v.selectedzip"+ selectedRows[i].phdShipZip__c);
            console.log("v.selectedzip",+ selectedRows[i].phdShipZip__c);
            var selctedzip = selectedRows[i].phdShipZip__c;
            var selectDescription = selectedRows[i].phdItemDesc__c;
            var selectedvals = selectedRows[i].Id;
            component.set("v.selectedvals" , selectedvals);
            console.log('My selected rowvalueee',+selectedvals);
            console.log('My selected id',+selectedvals[i]);
            finallist.push(selectedvals);
		}
        component.set("v.selectedvals" , finallist);
        console.log('list lenght',+selectedvals.length);
        for (var i = 0; i < selectedvals.length; i++){
        	console.log('My selected vals',+selectedvals[i]);
		}
	},

	dosave : function(component, event, helper) {
		var selectedItems =component.get("v.selectedvals");
        var checkvalue = component.find("quoteField");
        var selectid = component.get("v.lineItem.Id");
        var caseeId = component.get("v.recordId");
        console.log('caseeId::::',+caseeId);
        if(selectedItems!=null && selectedItems!='') {
        	console.log('selected items------'+selectedItems);
            var action2 = component.get('c.newProductLineItemRecord');
            action2.setParams({
            	'caseId':caseeId,
                "ProductId": selectedItems,
			});
			action2.setCallback(this, function(response) {
            	var state = response.getState();
                if (state === "SUCCESS") {
                    $A.get('e.force:refreshView').fire();
                }
                else {
                    console.log("Failed with state: " + JSON.stringify(response.getError()));
                }
                component.set("v.openLineList",false);
			});
			console.log('selectedItems::::action2',+action2);
			if(action2){
				var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title: "Success!",
                    message: "Successfully submitted Product Line Items!",
                    type: "success"
                });
                toastEvent.fire();
			}
			$A.enqueueAction(action2);
		}
		else{
        	document.getElementById('error').innerHTML="Select Line Item";
        	return;
		}
	},

    launchNewCaseLineScreen : function(component, event, helper) {
        component.set("v.isLoading", true);
        var currentCaseId = component.get("v.recordId");
        var action = component.get("c.getInitializationData");
        action.setParams({
            caseId : currentCaseId
        });
        action.setCallback(this, function(response) {
            component.set("v.isLoading", false);
            var state = response.getState();
            if (state === "SUCCESS") {
                var callResponse = response.getReturnValue();
                console.log(response.getReturnValue());
                if(callResponse.isSuccess){
                    component.set("v.initializationData", callResponse);
                    var createCaseLineEvent = $A.get("e.force:createRecord");
                    createCaseLineEvent.setParams({
                        "entityApiName": "ProductLineItem__c",
                        "defaultFieldValues": {
                            'Case__c' : callResponse.caseId,
                            'Sales_Order_Number__c' : callResponse.salesOrderNumber,
                            'Fulfiller_ID__c' : callResponse.fulfillerID
                        }
                    });
                    createCaseLineEvent.fire();
                }
                else{
                    var errorToast = $A.get("e.force:showToast");
                    errorToast.setParams({"message": callResponse.errorMessage, "type":"error",  "mode":"dismissible", "duration":10000});
                    errorToast.fire();
                }
            }
            else{
                var errorToast = $A.get("e.force:showToast");
                errorToast.setParams({"message": response.getError()[0].message, "type":"error",  "mode":"dismissible", "duration":10000});
                errorToast.fire();
            }
        });
        $A.enqueueAction(action);
    },

	sectionOne : function(component, event, helper) {
    	helper.helperFun(component,event,'articleOne');
	}
})