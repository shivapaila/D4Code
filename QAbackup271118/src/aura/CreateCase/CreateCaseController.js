({
	myAction : function(component, event, helper) {
		//   helper.fetchPicklistValues(component, 'Type__c', 'Sub_Type__c');

		var getId = component.get("v.recordId");
		console.log('my record id',+getId);
		var AccId = component.get("v.AccId");
		component.set("v.salesOrderObj.Account__c", AccId);
		var AddId = component.get("v.AddId");
		component.set("v.addressObj.Id", AddId);

		var actionSalesOrder = component.get("c.getSalesOrderInfo");
		actionSalesOrder.setParams({
			"recordId":getId
		});
		actionSalesOrder.setCallback(this, function(response) {
			if (component.isValid() && response.getState() === "SUCCESS") {
				component.set("v.salesOrderObj" , response.getReturnValue());
				console.log('sales' + JSON.stringify(response.getReturnValue()));
			} else {
				console.log('failed');
			}
		});

		var getAddr = component.get("v.recordId");
		var actionaddr = component.get("c.getAddr");
		actionaddr.setParams({
			"recordId":getAddr
		});
		actionaddr.setCallback(this, function(response) {
			if (component.isValid() && response.getState() === "SUCCESS") {
				component.set("v.addressObj" , response.getReturnValue());
				console.log('addrobj' + JSON.stringify(response.getReturnValue()));
			} else {
				console.log('failed');
			}
		});

		var getCon = component.get("v.recordId");
		var actionCon = component.get("c.getConName");
		actionCon.setParams({
			"recordId":getCon
		});
		actionCon.setCallback(this, function(response) {
			if (component.isValid() && response.getState() === "SUCCESS") {
				component.set("v.contactnameId" , response.getReturnValue());
				console.log('Conobj' + JSON.stringify(response.getReturnValue()));
			} else {
			console.log('failed');
			}
		});

		var actionContact = component.get("c.getConNameId");
		actionContact.setParams({
			"recordId":getCon
		});
		actionContact.setCallback(this, function(response) {
			if (component.isValid() && response.getState() === "SUCCESS") {
				component.set("v.contactnameIds" , response.getReturnValue());
				console.log('ConobjId' + JSON.stringify(response.getReturnValue()));
			} else {
				console.log('failed');
			}
		});

		var actionSalesLine = component.get("c.getSoLineItemsBySoExternalId");
		actionSalesLine.setParams({
			"recordId":getId
		});
		actionSalesLine.setCallback(this, function(response) {
			if (component.isValid() && response.getState() === "SUCCESS") {
				component.set("v.lineItem" , response.getReturnValue());
				component.set('v.mydata', response.getReturnValue());
				component.set('v.options', [
					{label: 'Item Sku', fieldName: 'phdItemSKU__c', type: 'text'},
					{label: 'Description', fieldName: 'phdItemDesc__c', type: 'text'},
					{label: 'Quantity', fieldName: 'phdQuantity__c', type: 'number'},
					{label: 'Delivery Type', fieldName: 'phdDeliveryType__c', type: 'text'},
					{label: 'Ship Zip', fieldName: 'phdShipZip__c', type: 'text'},
					{label: 'Delivered Date', fieldName: 'phdPurchaseDate__c', type: 'Datetime'},
					{label: 'Sales Status', fieldName: 'phdSaleType__c', type: 'text'},
					{label: 'Id', fieldName: 'Id', type: 'Id'},
				]);
			}
			else{
				console.log('failed');
			}
		});

		$A.enqueueAction(actionSalesOrder);
		$A.enqueueAction(actionCon);
		$A.enqueueAction(actionContact);
		$A.enqueueAction(actionaddr);
		$A.enqueueAction(actionSalesLine);
	},

	sectionOne : function(component, event, helper) {
		helper.helperFun(component,event,'articleOne');
	},

	dosave : function(component, event, helper) {
		var selectedItems =component.get("v.selectedvals");
		var checkvalue = component.find("quoteField");
		var selectid = component.get("v.lineItem.Id");

		var statusval = component.find('Status').get('v.value');
		var subjectval = component.find('Subject').get('v.value');
		var typeval = component.find('Type').get('v.value');
		var descriptionval = component.find('Description').get('v.value');
		var subtypeval = component.find('Sub-Type').get('v.value');
		var flag = new Boolean(true);

		console.log('statusval::::',+statusval);
		console.log('subjectval::::',+subjectval);
		console.log('typeval::::',+typeval);
		console.log('descriptionval::::',+descriptionval);
		console.log('subtypeval::::',+subtypeval);
		console.log('selectedItems::::',+selectedItems);
		console.log('order' + component.find('Sales_Order_id').get('v.value'));
		console.log('address',component.find('addressid').get('v.value'));

		if(typeval == 0 || statusval == 0 || subtypeval == 0 || $A.util.isEmpty(subjectval) || $A.util.isEmpty(descriptionval) || subjectval == 0){
			flag = false;
		}

		var isError = false;
		if(flag == true){
			var isValidEmail = true; 
			var emailField = component.find("leadEMail");
			var emailFieldValue = emailField.get("v.value");
			var regExpEmailformat = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;  
			console.log("email check start");
			if(!$A.util.isEmpty(emailFieldValue)){
				if(emailFieldValue.match(regExpEmailformat)){
					console.log("email check");
					emailField.set("v.errors", [{message: null}]);
					$A.util.removeClass(emailField, 'slds-has-error');
					isValidEmail = true;
				}else{
					console.log("email error");
					$A.util.addClass(emailField, 'slds-has-error');
					emailField.set("v.errors", [{message: "Please Enter a Valid Email Address"}]);
					isError = true; 
					isValidEmail = false;
				}
			}
			var inputCmp = component.find("inputCmp");
			var value = inputCmp.get("v.value");
			console.log("value-->"+value);

			if(component.get("v.caseIs.SuppliedPhone") != undefined && value!=''){
				var isValidPhone = true; 
				var phoneField = component.find("inputCmp");
				var phoneFieldValue = phoneField.get("v.value");
				var phoneformat = /^\(?(\d{3})\)?[- ]?(\d{3})[- ]?(\d{4})$/;  
				console.log("phone check start");
				if(!$A.util.isEmpty(phoneFieldValue)){
					if(phoneFieldValue.match(phoneformat)){
						console.log("phone check");
						phoneField.set("v.errors", [{message: null}]);
						$A.util.removeClass(emailField, 'slds-has-error');
						isValidPhone = true;
					}else{
						console.log("email error");
						$A.util.addClass(phoneField, 'slds-has-error');
						phoneField.set("v.errors", [{message: "Please Enter a Valid Phone Number"}]);
						isError = true; 
						isValidPhone = false;
					}
				}
			}

			if(isError== true){
				component.set("v.isError3", true);
				//	document.getElementById('error').innerHTML="Review all Errors";
				window.setTimeout(
					$A.getCallback(function() {
						component.set("v.isError3", false);
					}), 3000
				);
				return;
			}

			if(selectedItems!=null && selectedItems!='') {
				console.log('selected items');
				//show loading spinner
				component.set("v.isLoading", true);

				var action1 = component.get('c.create_case');
				action1.setParams({
					'caseis':component.get('v.caseIs') ,
					'salesorder':component.find('Sales_Order_id').get('v.value'),
					'contactname':component.get('v.contactnameIds'),
					'casetype':typeval,
					'casesubtype':component.find('Sub-Type').get('v.value'),
				});
				console.log('selectedItems::::action1',+action1);
				action1.setCallback(this,function(res){
					console.log('selectedItems::::res.getReturnValu',+res.getReturnValue());
					var caseId =  res.getReturnValue();
					console.log('selectedItems::::caseId',+caseId);
					var action2 = component.get('c.newProductLineItemRecord');
					action2.setParams({
						'caseId':caseId,
						"ProductId": selectedItems,
						'salesorder':component.find('Sales_Order_id').get('v.value'),
						//   "caseId": selectedCaseId
					});
					console.log('selectedItems::::action2',+action2);
					if(action2){
						var toastEvent = $A.get("e.force:showToast");
						toastEvent.setParams({
							title: "Success!",
							message: "Successfully created Case and Product Line Items!",
							type: "success"
						});
						toastEvent.fire();

						var navEvt = $A.get("e.force:navigateToSObject");
						navEvt.setParams({
							"recordId": caseId,
							"slideDevName": "detail"
						});
						navEvt.fire();
					}
					$A.enqueueAction(action2);
					//	$A.get("e.force:closeQuickAction").fire(); 
					//hide loading spinner
					component.set("v.isLoading", false);
				});

				$A.enqueueAction(action1); 
			}
			else {
				//show loading spinner
				component.set("v.isLoading", true);
				console.log('No selected line item');
				var createCaseaction = component.get('c.create_case');
				createCaseaction.setParams({
					'caseis':component.get('v.caseIs') ,
					'salesorder':component.find('Sales_Order_id').get('v.value'),
					'contactname':component.get('v.contactnameIds'),
					'casetype':typeval,
					'casesubtype':component.find('Sub-Type').get('v.value'),
				});
				createCaseaction.setCallback(this,function(res){
					// alert(res.getReturnValue());
					var caseId =  res.getReturnValue();
					console.log("my caseId-->",caseId);
					var toastEvent = $A.get("e.force:showToast");
					toastEvent.setParams({
						title: "Success!",
						message: "Successfully submitted Case!",
						type: "success"
					});
					toastEvent.fire();
					var navEvt = $A.get("e.force:navigateToSObject");
					navEvt.setParams({
						"recordId": caseId,
						"slideDevName": "detail"
					});
					navEvt.fire();
					//show loading spinner
					component.set("v.isLoading", false);
				});

				$A.enqueueAction(createCaseaction);
			}
		}
		else{
			component.set("v.isError2", true);
			//  document.getElementById('error').innerHTML="Enter all the mandatory Fields";
			window.setTimeout(
				$A.getCallback(function() {
					component.set("v.isError2", false);
				}), 3000
			);
			return;
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

	doCancel :function(component, event) {
		console.log("Cancel");
		var navEvt = $A.get("e.force:navigateToSObject");
		navEvt.setParams({
			"recordId": component.get("v.recordId"),
			"slideDevName": "detail"
		});
		navEvt.fire();
	},

	onControllerFieldChange: function(component, event, helper) {
		alert(event.getSource().get("v.value"));
		// get the selected value
		var controllerValueKey = event.getSource().get("v.value");

		// get the map values   
		var Map = component.get("v.depnedentFieldMap");

		// check if selected value is not equal to None then call the helper function.
		// if controller field value is none then make dependent field value is none and disable field
		if (controllerValueKey != '--None--') {
			// get dependent values for controller field by using map[key].  
			// for i.e "India" is controllerValueKey so in the map give key Name for get map values like 
			// map['India'] = its return all dependent picklist values.
			var ListOfDependentFields = Map[controllerValueKey];
			helper.fetchDepValues(component, ListOfDependentFields);
		} else {
			var defaultVal = [{
				class: "optionClass",
				label: '--None--',
				value: '--None--'
			}];
			component.find('conState').set("v.options", defaultVal);
			component.set("v.isDependentDisable", true);
		}
	},

	// function call on change the Dependent field    
	onDependentFieldChange: function(component, event, helper) {
		alert(event.getSource().get("v.value"));
	}

});