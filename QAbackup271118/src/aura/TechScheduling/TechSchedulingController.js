({
    myAction : function(component, event, helper) {

        var caseId = component.get("v.caseId");

        //get case details starts
        var actionCaseObj = component.get("c.getCaseObj");
        actionCaseObj.setParams({
            "recordId":caseId
        });
        actionCaseObj.setCallback(this, function(response) {
            if (component.isValid() && response.getState() === "SUCCESS") {
            	console.log('case: ' + JSON.stringify(response.getReturnValue()));
                component.set("v.caseObj", response.getReturnValue());
                component.set("v.salesOrder", response.getReturnValue().Sales_Order__c);

				//set ship to address if the case address is not null
				if(response.getReturnValue().Address__c != null){
					component.set("v.shipToAdd1", response.getReturnValue().Address__r.Address_Line_1__c);
					component.set("v.shipToAdd2", response.getReturnValue().Address__r.Address_Line_2__c);
					component.set("v.shipToCity", response.getReturnValue().Address__r.City__c);
					component.set("v.shipToState", response.getReturnValue().Address__r.StatePL__c);
					component.set("v.shipToZip", response.getReturnValue().Address__r.Zip_Code__c);
				}

		        //get sales order fullfiller detail starts
		        var actionSalesOrderObj = component.get("c.getSalesOrderInfo");
		        actionSalesOrderObj.setParams({
		            "recordId":caseId
		        });
		        actionSalesOrderObj.setCallback(this, function(response1) {
		            if (component.isValid() && response1.getState() === "SUCCESS") {
						console.log('salesorder: ' + JSON.stringify(response1.getReturnValue()));
						var ffid = '';
						var customerid = '';
		                component.set("v.salesOrderObj", response1.getReturnValue());
						if((response1.getReturnValue().fulfillerID__c != null) && (response1.getReturnValue().fulfillerID__c != '')){
							ffid = response1.getReturnValue().fulfillerID__c;
							customerid = response1.getReturnValue().phhCustomerID__c;
						} else {
							ffid = response1.getReturnValue().phhERPAccounShipTo__c;
							customerid = response1.getReturnValue().phhERPCustomerID__c;
						}
						component.set("v.fulfillID", ffid);
						component.set("v.CustId", customerid);

				        //get service technicians schedule duration detail starts
				        var actionScheduleDurationObj = component.get("c.getTechScheduleDuration");
				        actionScheduleDurationObj.setParams({
				            "fulfillerId" : ffid
				        });
				        actionScheduleDurationObj.setCallback(this, function(response2) {
				            if (component.isValid() && response2.getState() === "SUCCESS") {
				            	console.log('tech duration: ' + JSON.stringify(response2.getReturnValue()));
				                component.set("v.techScheduleHours", response2.getReturnValue().hours);
				                component.set("v.techScheduleMins", response2.getReturnValue().mins);
				                console.log(component.get("v.techScheduleHours"));
				                console.log(component.get("v.techScheduleMins"));
				            }
				            else {
				                var errorToast = $A.get("e.force:showToast");
				                errorToast.setParams({"message": response2.getError()[0].message, "type":"error"});
				                errorToast.fire();
				            }
				        });
				        $A.enqueueAction(actionScheduleDurationObj);
				        //get service technicians schedule duration detail ends

		                //get salesorder item zip code starts
		                var actionZipcode = component.get("c.getZipCode");
		                actionZipcode.setParams({
		                    "extId":component.get("v.salesOrder")
		                });
		                actionZipcode.setCallback(this, function(response3) {
		                    if (component.isValid() && response3.getState() === "SUCCESS") {
		                    	console.log('soi zip code: ' + JSON.stringify(response3.getReturnValue()));
		                        if(component.get("v.caseObj").Address__c == null){
		                            component.set("v.zipcode", response3.getReturnValue());
		                        }
		                        else{
		                            component.set("v.zipcode", component.get("v.shipToZip"));
		                        }

		                        // Call API Response
		                        helper.getAPIResponse(component);
		                    }
		                    else {
		                        var errorToast = $A.get("e.force:showToast");
		                        errorToast.setParams({"message": response3.getError()[0].message, "type":"error"});
		                        errorToast.fire();
		                    }
		                });
		                $A.enqueueAction(actionZipcode);
		                //get salesorder item zip code ends
		            }
		            else {
		                var errorToast = $A.get("e.force:showToast");
		                errorToast.setParams({"message": response1.getError()[0].message, "type":"error"});
		                errorToast.fire();
		            }
		        });
		        $A.enqueueAction(actionSalesOrderObj);
		        //get sales order fullfiller detail ends
            }
            else {
                var errorToast = $A.get("e.force:showToast");
                errorToast.setParams({"message": response.getError()[0].message, "type":"error"});
                errorToast.fire();
            }
        });
        $A.enqueueAction(actionCaseObj);
        //get case details ends

        //get case line item detail starts
        /*
        var actionCaseLineItem = component.get("c.getLineItemcase");
        actionCaseLineItem.setParams({
            "recordId":caseId
        });
        actionCaseLineItem.setCallback(this, function(response) {
            if (component.isValid() && response.getState() === "SUCCESS") {
                component.set("v.caseItemObj", response.getReturnValue());
                console.log('lineitem..' + JSON.stringify(response.getReturnValue()));
            }
            else {
                var errorToast = $A.get("e.force:showToast");
                errorToast.setParams({"message": response.getError()[0].message, "type":"error"});
                errorToast.fire();
            }
        });
        $A.enqueueAction(actionCaseLineItem);
        */
		//get case line item detail ends

		//get sales order item detail starts
        var actionSalesOrderObj1 = component.get("c.getSalesOrderLineInfo");
        actionSalesOrderObj1.setParams({
            "recordId":caseId
        });
        actionSalesOrderObj1.setCallback(this, function(response4) {
            if (component.isValid() && response4.getState() === "SUCCESS") {
            	console.log('so line: ' + JSON.stringify(response4.getReturnValue()));
                component.set("v.saleslineitem", response4.getReturnValue());

				//set ship to address if the case address is null
				if((component.get("v.caseObj").Address__c == null) || (component.get("v.caseObj").Address__c == "")){
					component.set("v.shipToAdd1", response4.getReturnValue().phdShipAddress1__c);
					component.set("v.shipToAdd2", response4.getReturnValue().phdShipAddress2__c);
					component.set("v.shipToCity", response4.getReturnValue().phdShipCity__c);
					component.set("v.shipToState", response4.getReturnValue().phdShipState__c);
					component.set("v.shipToZip", response4.getReturnValue().phdShipZip__c);
				}
				component.set("v.shipToState", response4.getReturnValue().phdShipState__c);
            }
            else {
                var errorToast = $A.get("e.force:showToast");
                errorToast.setParams({"message": response4.getError()[0].message, "type":"error"});
                errorToast.fire();
            }
        });
        $A.enqueueAction(actionSalesOrderObj1);
        //get sales order item detail ends

		//get pli associated to the case starts
		var actionCasePli = component.get("c.getCasePli");
        actionCasePli.setParams({
            "caseId" : caseId
        });
        actionCasePli.setCallback(this, function(response5) {
            if (component.isValid() && response5.getState() === "SUCCESS") {
                component.set("v.pliList", response5.getReturnValue());
                console.log('pliList: ' + JSON.stringify(response5.getReturnValue()));
            }
            else {
                var errorToast = $A.get("e.force:showToast");
                errorToast.setParams({"message": response5.getError()[0].message, "type":"error"});
                errorToast.fire();
            }
        });
        $A.enqueueAction(actionCasePli);
        //get pli associated to the case ends

		//get state picklist value starts
		var actionStatePl = component.get("c.getStateVal");
        actionStatePl.setCallback(this, function(response6) {
            if (component.isValid() && response6.getState() === "SUCCESS") {
                console.log('Picklist: ' + JSON.stringify(response6.getReturnValue()));
                var opts = [];
                opts.push({ class: "optionClass", label: "State", value: "State", disabled: "true" });
                response6.getReturnValue().forEach(function(key){
                	if((component.get("v.shipToState") != null) && (component.get("v.shipToState") == key)) {
	                    opts.push({ class: "optionClass", label: key, value: key, selected: "true" });
                	} else {
	                    opts.push({ class: "optionClass", label: key, value: key });
                	}
                });
                console.log('opts: ' + JSON.stringify(opts));

		        component.find("state").set("v.options", opts);
            }
            else {
                var errorToast = $A.get("e.force:showToast");
                errorToast.setParams({"message": response6.getError()[0].message, "type":"error"});
                errorToast.fire();
            }
        });
        $A.enqueueAction(actionStatePl);
        //get state picklist value ends
    },

    refreshAPI: function(component, event, helper) {
    	//called when shipping address is changed
        var zipVar = component.find("zip").get("v.value").trim();
        component.set("v.zipcode", zipVar);

        component.set("v.selectedCompany", '');
        component.set("v.ListOfCompanies", '');
        component.set("v.selectedEmployee", '');
        component.set("v.ListOfEmployees", null);
        component.set("v.selectedTechnician", '');

        //call helper method to reset tech schedule common attributes
    	helper.resetScheduleAttr(component);
    	helper.resetCalendarAttr(component);

        // Call API Response
        helper.getAPIResponse(component);
    },

    onCompanyChange : function (component, event, helper) {
        component.set("v.caseObj.Tech_Scheduled_Company__c",'');
        component.set("v.selectedTechnician", '');
        component.set("v.ListOfEmployees", null);
        //call helper method to reset tech schedule common attributes
    	helper.resetScheduleAttr(component);
    	helper.resetCalendarAttr(component);

        var fulfillerId = component.get("v.fulfillID");
        var zipcode = component.get("v.zipcode");
        var selectedCompany = component.find("myCompany").get("v.value").trim();
        console.log('fulfillerId: ' + fulfillerId + ' zipcode: ' + zipcode + ' selectedCompany: ' + selectedCompany);

        var actionHTTPReq = component.get("c.getTechnicians");
        actionHTTPReq.setParams({
            "fulfillerId"  : fulfillerId,
            "companyvalue" : selectedCompany,
            "zipcode"      : zipcode
        });
        actionHTTPReq.setCallback(this, function(response) {
            if (component.isValid() && response.getState() === "SUCCESS") {
                var employeeList = [];
                response.getReturnValue().forEach(function(key){
                    employeeList.push(key);
                });
                component.set("v.ListOfEmployees", employeeList);
                console.log(JSON.stringify(response.getReturnValue()));
            }
            else {
                console.log('Tech');
            }
        });
        $A.enqueueAction(actionHTTPReq);
    },

    onEmployeeChange : function (component, event, helper) {
    	//call helper method to reset tech schedule common attributes
    	helper.resetScheduleAttr(component);
    	helper.resetCalendarAttr(component);

        component.set("v.Spinner", true);

        var fulfillerId = component.get("v.fulfillID");
        var employeeTechId = component.find("technician").get("v.value");
        var maxHours  = 0;
        var maxRepair = 0;
        var maxPieces = 0;
        var upHostery = 0;
        var casegoods = 0;
        var leather   = 0;
        var workingHoursprogvalue = 0;
        var RepairStopsprogvalue  = 0;
        var PiecesRepairprogvalue = 0;
        var CurrentWorkingHoursProgValue = 0;
        var CurrentRepairStopsprogvalue  = 0;
        var CurrentPiecesRepairprogvalue = 0;
        var WeeklyScheduleVar  = '';
        var leaveDates = [];

        var actionHttpWorkLoad = component.get("c.getWorkloadInfo");
        actionHttpWorkLoad.setParams({
            "fulfillerId" : fulfillerId,
            "resourceId"  : employeeTechId
        });
        actionHttpWorkLoad.setCallback(this, function(response) {
            console.log(actionHttpWorkLoad);
            if (component.isValid() && response.getState() === "SUCCESS") {
                console.log('workloaddetails' + response.getReturnValue());

				var crYear = new Date().getFullYear();
				var crMonth = new Date().getMonth() + 1;

                response.getReturnValue().forEach(function(key){
                    if(key.TechId == employeeTechId){
                        maxHours = key.MaxHoursPerDay;
                        maxRepair = key.MaxRepairPerDay;
                        maxPieces = key.MaxPiecesPerDay;
                        upHostery = key.UpholsterySkillLevel;
                        casegoods = key.CasegoodsSkillLevel;
                        leather = key.LeatherSkillLevel;
                        WeeklyScheduleVar = key.WeeklySchedule;

						var tmpLeaveSplt = key.LeaveDate.split('T')[0];
						var ipYear = tmpLeaveSplt.split('-')[0];
						var ipMonth = tmpLeaveSplt.split('-')[1];
						console.log('ipYear:' + ipYear);
						console.log('ipMonth:' + ipMonth);

						if(ipYear == crYear) {
							//same year
						    if(ipMonth >= crMonth) {
						    	//push it to leave array
						        //console.log('Yes');
						        leaveDates.push(key.LeaveDate.split('T')[0]);
						    }
						} else if(ipYear > crYear) {
							// push it to leave array
						    //console.log('Yes 1');
						    leaveDates.push(key.LeaveDate.split('T')[0]);
						}
                    }
                });
                console.log('leaveDates: ' + leaveDates);

                component.set("v.cLeaveDates", leaveDates);
                component.set("v.maxHours", maxHours);
                component.set("v.maxRepair",maxRepair);
                component.set("v.maxPieces",maxPieces);
                component.set("v.upHostery",upHostery);
                component.set("v.casegoods",casegoods);
                component.set("v.leather",leather);
                component.set("v.weeklyScheduleVar",WeeklyScheduleVar);
                component.set("v.workingHoursprogvalue",workingHoursprogvalue);
                component.set("v.RepairStopsprogvalue",RepairStopsprogvalue);
                component.set("v.PiecesRepairprogvalue",PiecesRepairprogvalue);
                component.set("v.CurrentWorkingHoursProgValue", CurrentWorkingHoursProgValue);
                component.set("v.CurrentRepairStopsprogvalue", CurrentRepairStopsprogvalue);
                component.set("v.CurrentPiecesRepairprogvalue", CurrentPiecesRepairprogvalue);

		        if(!$A.util.isEmpty(component.get("v.estimatedtimeforstopwithminutes"))){
		        	console.log('Calendar trigger after employee change');
			        helper.resetCalendarAttr(component);

		    		var dt = new Date();
					var tYr = dt.getFullYear();
					var tmth = dt.getMonth() + 1;

					component.set("v.cYear", tYr);
					component.set("v.cMonth", tmth);
					component.set("v.cMonthInc", 0);

					helper.techCalendarLoad(component);
				}
            }
            else {
                var errorToast = $A.get("e.force:showToast");
                errorToast.setParams({"message": 'There might be some issue with your selection \n OR an issue with the system. Please contact your administrator.', "type":"error"});
                errorToast.fire();
            }
        });
		$A.enqueueAction(actionHttpWorkLoad);
    },

    onMonthChange : function(component, event , helper) {
        helper.techCalendarLoad(component);
    },

    GobackToRecord : function (component, event, helper) {
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": component.get("v.caseId"),
            "slideDevName": "related"
        });
        navEvt.fire();

		//while cancelling close the sub tab
		var workspaceAPI = component.find("workspace");
		console.log('workspaceAPI: ' + workspaceAPI);
		if(workspaceAPI != undefined){
	        workspaceAPI.getFocusedTabInfo().then(function(response) {
		        console.log('response: ' + JSON.stringify(response));
	            var focusedTabId = response.tabId;
	            if(response.isSubtab == true){
	            	workspaceAPI.refreshTab({
						tabId: response.parentTabId,
						includeAllSubtabs: true
					});
	            }
	            workspaceAPI.closeTab({tabId: focusedTabId});
	        })
	        .catch(function(error) {
	            console.log(error);
	        });
		}
    },

    openLineItem : function(component , event, helper) {
        component.set("v.isOpenForLine",true);
        component.set("v.conferror", '');

        var actionlinevalue = component.get("c.getApiResponse1");
        actionlinevalue.setParams({
            "recordId" : component.get("v.caseObj").AccountId
        });
        actionlinevalue.setCallback(this, function(response) {
            if (component.isValid() && response.getState() === "SUCCESS") {
                var callResponse = response.getReturnValue();
                component.set("v.orders", callResponse); 
                component.set("v.totalSize", callResponse.length);
                var jsonData = JSON.parse(response.getReturnValue());
                var descripvals = [];
                var sonumber = [];
                var deldate = [];
                var rows = [];
                var errorrows = [];
                var isSelectedFlag;
                var serialnumber;

                if(callResponse.length ==67 ){
                    component.set("v.isOpenForLine",false);  

                    var errorToast = $A.get("e.force:showToast");
                    errorToast.setParams({"message": 'No Line items found for this Customer', "type":"error"});
                    errorToast.fire();
                } else {

					console.log('O Draft Items: ' + JSON.stringify(component.get('v.draftItems')));
					console.log('O Confirm Items: ' + JSON.stringify(component.get('v.confirmItems')));
					console.log('O Selected Associate Items: ' + JSON.stringify(component.get('v.selectedAssociateItems')));

                    for(var i=0;i<jsonData.value.length;i++){
                        var snNumber = jsonData.value[i].SalesOrderNumber;

                        for(var j=0;j<jsonData.value[i].TechSchedulingItems.length;j++){
                        	if(jsonData.value[i].TechSchedulingItems[j].Quantity >= 0){
                            	var deliverdate = jsonData.value[i].TechSchedulingItems[j].DeliveredDate;

								var keyVal = snNumber + '|' + jsonData.value[i].TechSchedulingItems[j].ItemSKU + '|' + jsonData.value[i].TechSchedulingItems[j].ItemSequence;

	                            isSelectedFlag = false;
	                            serialnumber = '';
	                            //populating serial number & selected values based on the values stored in selectedAssociateItems attribute
	                            var selAssociateItems = component.get('v.selectedAssociateItems');
	                            for(var ci=0; ci<selAssociateItems.length; ci++){
	                                if(selAssociateItems[ci].keyId == keyVal){
	                                    isSelectedFlag = true;
	                                    serialnumber = selAssociateItems[ci].serialNo;
	                                }
	                            }

	                            //populating serial number based on the values stored in draftItems attribute
	                            var draftItem = component.get('v.draftItems');
	                            //alert('draftItem controller: ' + JSON.stringify(draftItem));
	                            for(var di=0; di<draftItem.length; di++){
	                                if(draftItem[di].keyId == keyVal){
	                                    serialnumber = draftItem[di].serialNo;
	                                }
	                            }

								console.log('Associate Items: salesorder_number: ' + snNumber + ' sku: ' + jsonData.value[i].TechSchedulingItems[j].ItemSKU + ' seqNumber: ' + jsonData.value[i].TechSchedulingItems[j].ItemSequence + ' UniqueID: ' + jsonData.value[i].TechSchedulingItems[j].UniqueID + ' Key: ' + keyVal);

	                            if(deliverdate != null  && deliverdate == undefined) {
	                                var eachRow  = {
	                                    isSelected:isSelectedFlag,
	                                    PersonAccountID:false,
	                                    UniqueID:false,
	                                    salesorder_number:snNumber,
	                                    serialNo:serialnumber,
	                                    seqNumber:jsonData.value[i].TechSchedulingItems[j].ItemSequence,
	                                    desc:jsonData.value[i].TechSchedulingItems[j].ItemDescription,
	                                    deldate:jsonData.value[i].TechSchedulingItems[j].DeliveredDate.substring(0,10),
	                                    wardate:jsonData.value[i].TechSchedulingItems[j].WarrantyEndDate.substring(0,10),
	                                    sku:jsonData.value[i].TechSchedulingItems[j].ItemSKU,
	                                    qty:jsonData.value[i].TechSchedulingItems[j].Quantity,
	                                    uniqueid:jsonData.value[i].TechSchedulingItems[j].UniqueID,
	                                    orderstatus:jsonData.value[i].TechSchedulingItems[j].SalesOrderStatus,
	                                    keyId:keyVal
	                                }
								} else {
	                                    var eachRow  = {
	                                        isSelected:isSelectedFlag,
	                                        salesorder_number:snNumber,
	                                        serialNo:serialnumber,
	                                        seqNumber :jsonData.value[i].TechSchedulingItems[j].ItemSequence,
	                                        desc:jsonData.value[i].TechSchedulingItems[j].ItemDescription,
	                                        deldate:jsonData.value[i].TechSchedulingItems[j].DeliveredDate,
	                                        wardate:jsonData.value[i].TechSchedulingItems[j].WarrantyEndDate.substring(0,10),
	                                        sku:jsonData.value[i].TechSchedulingItems[j].ItemSKU,
	                                        qty:jsonData.value[i].TechSchedulingItems[j].Quantity,
	                                        uniqueid:jsonData.value[i].TechSchedulingItems[j].UniqueID,
	                                        orderstatus:jsonData.value[i].TechSchedulingItems[j].SalesOrderStatus,
	                                    	keyId:keyVal
	                                    }
								};

	                            var rowjson = JSON.stringify(eachRow);
	                            rows.push(eachRow);
	                            //console.log('sekar: '+rowjson);
	                            var itDesc = jsonData.value[i].TechSchedulingItems[j].ItemDescription;
	                            var itdeldate = jsonData.value[i].TechSchedulingItems[j].DeliveredDate;
	                            var descVal = itDesc;
	                            var delivval = itdeldate;
	                            descripvals.push(descVal);
	                            sonumber.push(snNumber);
	                            deldate.push(delivval);
                            }
                        }
                    }
                } 
                component.set('v.allrows',rows);
                component.set('v.democolumns', [
                    {
                        fieldName: 'isSelected', type: "boolean", initialWidth: 50,
                        cellAttributes: {
                            iconName: { fieldName: "isSelected_chk" }
                        }},
                    {label: 'Seq NUMBER', fieldName: 'seqNumber', type: 'number', initialWidth: 50},
                    {label: 'SALESORDER NUMBER', fieldName: 'salesorder_number', type: 'text', initialWidth: 100},
                    {label: 'DESCRIPTION', fieldName: 'desc', type: 'text', initialWidth: 150},
                    {label: 'DELIVERY DATE', fieldName: 'deldate', type: 'text', initialWidth: 100},
                    {label: 'WARRANTY DATE', fieldName: 'wardate', type: 'text', initialWidth: 100},
                    {label: 'SKU', fieldName: 'sku', type: 'text', initialWidth: 100},
                    {label: 'Status', fieldName: 'orderstatus', type: 'text', initialWidth: 100},
                    {label: 'Quantity', fieldName: 'qty', type: 'number', initialWidth: 50},
                    {label: 'Serial Number', fieldName: 'serialNo',editable:'true', type: 'text', initialWidth: 100},
                    {type: 'button', initialWidth: 100, typeAttributes: {label: 'Confirm', name:'confirmRecord', disabled: {fieldName: 'actionDisabled'}, class: 'btn_next'} }
                    
                ]);

                component.set('v.datajsonstringify',eachRow);
            } else {
                var errorToast = $A.get("e.force:showToast");
                errorToast.setParams({"message": "Address has been updated"});
                errorToast.fire();
            }
            component.set("v.Spinner", false); 
        });

        var actionsku = component.get("c.getApiResponseforlinesku");
        actionsku.setParams({
            "recordId" : component.get("v.caseObj").AccountId
        });
        actionsku.setCallback(this,function(response)	{
            if (component.isValid() && response.getState() === "SUCCESS") {
                var callResponse = response.getReturnValue();
                console.log('length'+callResponse.length);
                component.set("v.orderssku", callResponse); 
                component.set("v.totalSizesku", callResponse.length);
                var jsonDatasku = JSON.parse(response.getReturnValue());
                var descripvalssku = [];
                var sonumbersku = [];
                var deldatesku = [];
                var rowssku = [];
                var errorrowssku = [];
                if(callResponse.length ==67 ){
                    component.set("v.isOpenForLine",false); 
                    var errorToast = $A.get("e.force:showToast");
                    errorToast.setParams({"message": 'No Star Sku Items Found for this Customer', "type":"error"});
                    errorToast.fire();
                } else { 
                    for(var i=0;i<jsonDatasku.value.length;i++){
                        var snNumber = jsonDatasku.value[i].SalesOrderNumber;
                        for(var j=0;j<jsonDatasku.value[i].TechSchedulingItems.length;j++){
                            var deliverdatesku = jsonDatasku.value[i].TechSchedulingItems[j].DeliveredDate;	
                            if(deliverdatesku != null  && deliverdatesku == undefined) {
                                var eachRow  = {
                                    isSelected:false,
                                    PersonAccountID:false,
                                    UniqueID:false,
                                    salesorder_number:snNumber,
                                    desc:jsonDatasku.value[i].TechSchedulingItems[j].ItemDescription,
                                    deldate:jsonDatasku.value[i].TechSchedulingItems[j].DeliveredDate.substring(0,10),                        
                                    wardate:jsonDatasku.value[i].TechSchedulingItems[j].WarrantyEndDate.substring(0,10),
                                    sku:jsonDatasku.value[i].TechSchedulingItems[j].ItemSKU,
                                    qty:jsonDatasku.value[i].TechSchedulingItems[j].Quantity,
                                    uniqueid:jsonDatasku.value[i].TechSchedulingItems[j].UniqueID,
                                    orderstatus:jsonDatasku.value[i].TechSchedulingItems[j].SalesOrderStatus
                                }	
                                } else {
                                    var eachRow  = {
                                        isSelected:false,
                                        salesorder_number:snNumber,
                                        desc:jsonDatasku.value[i].TechSchedulingItems[j].ItemDescription,
                                        deldate:jsonDatasku.value[i].TechSchedulingItems[j].DeliveredDate,                          
                                        wardate:jsonDatasku.value[i].TechSchedulingItems[j].WarrantyEndDate.substring(0,10),
                                        sku:jsonDatasku.value[i].TechSchedulingItems[j].ItemSKU,
                                        qty:jsonDatasku.value[i].TechSchedulingItems[j].Quantity,
                                        uniqueid:jsonDatasku.value[i].TechSchedulingItems[j].UniqueID,
                                        orderstatus:jsonDatasku.value[i].TechSchedulingItems[j].SalesOrderStatus
                                    }
                                    };
                            var rowjson = JSON.stringify(eachRow);
                            rowssku.push(eachRow);
                            
                            var itDesc = jsonDatasku.value[i].TechSchedulingItems[j].ItemDescription;
                            var itdeldate = jsonDatasku.value[i].TechSchedulingItems[j].DeliveredDate;
                            var descVal = itDesc;
                            var delivval = itdeldate;
                            descripvalssku.push(descVal);
                            sonumbersku.push(snNumber);
                            deldatesku.push(delivval);
                        }
                    } 
                }
                component.set('v.allrowssku',rowssku);
                component.set('v.democolumnssku', [
                    {label: 'SALESORDER NUMBER', fieldName: 'salesorder_number', type: 'text'},
                    {label: 'DESCRIPTION', fieldName: 'desc', type: 'text'},
                    {label: 'DELIVERY DATE', fieldName: 'deldate', type: 'text'},
                    {label: 'WARRANTY DATE', fieldName: 'wardate', type: 'text'},
                    {label: 'SKU', fieldName: 'sku', type: 'text'},
                    {label: 'Status', fieldName: 'orderstatus', type: 'text'},
                    {label: 'Quantity', fieldName: 'qty', type: 'number'}
                    
                ]);
                
                component.set('v.datajsonstringify',eachRow); 
            } else {
                console.log('erros' + response.getState());
            }
            
        });
        $A.enqueueAction(actionsku);

        $A.enqueueAction(actionlinevalue);
    },

    handleRowAction: function (component, event, helper) {
        //var action = event.getParam('button');
        var row = event.getParam('row');

		console.log('C Draft Items: ' + JSON.stringify(component.get('v.draftItems')));
		console.log('C Confirm Items: ' + JSON.stringify(component.get('v.confirmItems')));
		console.log('C Selected Associate Items: ' + JSON.stringify(component.get('v.selectedAssociateItems')));

        //validate if this item is already confirmed
        var confirmed = false;
        var confirmedItems = component.get('v.confirmItems');
        for(var z=0; z<confirmedItems.length; z++){
            if(confirmedItems[z].keyId == row.keyId){
                confirmed = true;
            }
        }

        //if the confirm is not triggered then call the helper method
        if(confirmed == false){
            //alert('Call replacement API');
            helper.selectrowvalues(component, event);
        }
    },

    handleSaveEdition: function (cmp, event, helper){
        var draftValues = event.getParam('draftValues');
        //alert(JSON.stringify(draftValues));
        helper.saveChanges(cmp, draftValues);
    },

    closeLineItem: function(component, event, helper) {
        component.set("v.isOpenForLine",false);

		if(!$A.util.isEmpty(component.get("v.weeklyScheduleVar")) && !$A.util.isEmpty(component.get("v.estimatedtimeforstopwithminutes"))){
	        //have to reset the Tech Scheduled Date and reset calendar
	        console.log('Calendar trigger after selecting associate line item');
	        helper.resetCalendarAttr(component);

			var dt = new Date();
			var tYr = dt.getFullYear();
			var tmth = dt.getMonth() + 1;

			component.set("v.cYear", tYr);
			component.set("v.cMonth", tmth);
			component.set("v.cMonthInc", 0);

			helper.techCalendarLoad(component);
		}
    },
    
    openCommentSection : function(component, event,helper) {
        component.set("v.isOpenForComments",true);
    },
    
    closeCommentSection : function(component,event,helper) {
        component.set("v.isOpenForComments",false);
    },
    
    openModel: function(component, event, helper) {
        component.set("v.isOpen", true);
    },
    
    closeModel: function(component, event, helper) { 
        component.set("v.isOpen", false);
    },
    
    saveMeetingTime: function(component, event, helper) {
        if(helper.getValidationOnValues(component)) {
	        var incrementalconversion;
	        if( component.get("v.incrementValue") == null || component.get("v.incrementValue") == undefined)  {
	            incrementalconversion = 0;
	        }
	        if (component.get("v.incrementValue") ==5){
	            incrementalconversion = 8;
	        }
	        if (component.get("v.incrementValue") ==10){
	            incrementalconversion = 17;
	        }
	        if (component.get("v.incrementValue") ==15){
	            incrementalconversion = 25;
	        }
	        if (component.get("v.incrementValue") ==20){
	            incrementalconversion = 33;
	        }
	        if (component.get("v.incrementValue") ==25){
	            incrementalconversion = 42;
	        }
	        if (component.get("v.incrementValue") ==30){
	            incrementalconversion = 50;
	        }
	        if (component.get("v.incrementValue") ==35){
	            incrementalconversion = 58;
	        }
	        if (component.get("v.incrementValue") ==40){
	            incrementalconversion = 67;
	        }
	        if (component.get("v.incrementValue") ==45){
	            incrementalconversion = 75;
	        }
	        if (component.get("v.incrementValue") ==50){
	            incrementalconversion = 83;
	        }
	        if (component.get("v.incrementValue") ==55){
	            incrementalconversion = 92;
	        }

	        var finalincrementalmeetingval;
	        if (incrementalconversion == undefined) {
	            finalincrementalmeetingval = component.get("v.minValue") +  'Hour0';
	        } else if (incrementalconversion == 8) {
	            finalincrementalmeetingval = component.get("v.minValue") +  'Hour08';
	        } else {
	            finalincrementalmeetingval = component.get("v.minValue") +  'Hour'  + incrementalconversion; 
	        }

	        var meetingValue = component.get("v.minValue") +  'Hour'  + component.get("v.incrementValue") ;
	        component.set("v.estimatedtimeforstopwithminutes" , finalincrementalmeetingval);
	        component.set("v.meetingRoomValue", meetingValue);

	        console.log('estimatedtimeforstopwithminutes: ' + component.get("v.estimatedtimeforstopwithminutes"));
	        console.log('meetingRoomValue: ' + component.get("v.meetingRoomValue"));

        	var hrsList = component.get("v.techScheduleHours");
        	var techMaxHrs = hrsList[hrsList.length-1];
        	var estimateTime = component.get("v.estimatedtimeforstopwithminutes").replace("Hour",".");
        	if(Number(estimateTime) > Number(techMaxHrs)){
        		var errorToast = $A.get("e.force:showToast");
            	errorToast.setParams({"message": "Maximum Value for Estimated Time should not be greater than " + techMaxHrs + " hours", "type":"error"});
            	errorToast.fire();
        	} else {
		        component.set("v.isOpen", false);

		        //have to call the calendar here instead of company change method
	    	    if(!$A.util.isEmpty(component.get("v.weeklyScheduleVar"))){
	    	    	console.log('Calendar trigger after estimate time to stop');
		    	    helper.resetCalendarAttr(component);

	    			var dt = new Date();
					var tYr = dt.getFullYear();
					var tmth = dt.getMonth() + 1;

					component.set("v.cYear", tYr);
					component.set("v.cMonth", tmth);
					component.set("v.cMonthInc", 0);

					helper.techCalendarLoad(component);
				}
			}
        }
    },
    
    onDatePickerValue: function(component, event, helper) {
        if(component.get("v.cSelectedDate") == "") {
            //alert("no date selected");
            var errorToast = $A.get("e.force:showToast");
        	errorToast.setParams({"message": "Select a date to schedule a Technician", "type":"error"});
        	errorToast.fire();
        } else{
            var datePick1 = $( "#datepicker" ).val();
            var date = new Date(datePick1);
            var newdate = new Date(date);
            newdate.setDate(newdate.getDate() + 1);
            
            var dd = newdate.getDate();
            var mm = newdate.getMonth() + 1;
            var y = newdate.getFullYear();
            
            var someFormattedDate = mm + '/' + dd + '/' + y;
            var datescheduledvalue = $( "#datepicker" ).val().split("/").reverse().join("-");
            var datePick = moment(datePick1).format('dddd MMMM D Y');
            component.set("v.datevalue", datePick);
            component.set("v.isopenfortech", false);
        }
    },
    
    showSpinner: function(component, event, helper) {
        component.set("v.Spinner", true); 
    },
    
    hideSpinner : function(component,event,helper){   
        component.set("v.Spinner", false);
    },
    
    validate : function(component, event, helper) {
        
        var nameField = component.find("testCmp");//.get("v.value");
        var nameValue = nameField.get("v.value");
        
        if($A.util.isEmpty(nameValue) || $A.util.isUndefined(nameValue)){
            nameField.set("v.errors", [{message:"Enter a Name"}]);
        }         
        else {
            nameField.set("v.errors",null);
        }
    },
    
    openModal : function(component,event,helper) {

        var timestop = component.find("myTimeEstimated");
        var meetingRoomValue1= timestop.get("v.value");

        if( component.get("v.selectedCompany") === undefined || component.get("v.caseObj.Tech_Scheduled_Company__c") === undefined || component.get("v.selectedCompany").length === 0 ||  component.get("v.caseObj.Tech_Scheduled_Company__c").length === 0 || $A.util.isEmpty(meetingRoomValue1) || meetingRoomValue1 == '--SELECT--' || meetingRoomValue1 == undefined ){
            //alert("You must Select Company and Technician before scheduling a Technician");
            var errorToast = $A.get("e.force:showToast");
        	errorToast.setParams({"message": "You must Select Company, Technician and Estimated time for stop before scheduling a Technician", "type":"error"});
        	errorToast.fire();
        }else{
            component.set("v.isopenfortech",true);
        } 
    },
    
    closeModal : function(component,event,helper) {
        component.set("v.isopenfortech",false);
    },

    generatePostCall : function(component, event, helper) {
        var isAddressChanged = false;
        if(component.find("billAddress1").get("v.value") != component.find("address1").get("v.value")){
            isAddressChanged = true;
        }

        if(component.find("billAddress2").get("v.value") != component.find("address2").get("v.value")){
            isAddressChanged = true;
        }

        if(component.find("billCity").get("v.value") != component.find("city").get("v.value")){
            isAddressChanged = true;
        }

        if(component.find("billState").get("v.value") != component.find("state").get("v.value")){
            isAddressChanged = true;
        }

        if(component.find("billZipCode").get("v.value") != component.find("zip").get("v.value")){
            isAddressChanged = true;
        }

        var selItem = component.get('v.selectedAssociateItems');
        console.log('selectedlineitesm..' + JSON.stringify(selItem));
        //alert(JSON.stringify(selItem));
        //alert(JSON.stringify(component.get('v.salesOrderObj')));
        //var soObj = component.get('v.salesOrderObj');
        //if((soObj.phhSaleType__c == 'Invoiced') && (selItem.length == 0)){
            //component.set("v.conferror", 'Please confirm Associate Items serial number to Schedule');
        //}
        //else{

            //component validation starts
            if(helper.validate(component)) {

                var SelectedAssigneeName = ' ';
                var isTechResource = 'Y';
                var RequestStatusText = 'TechScheduled';  
                var techName = ' ';
                var RequestActivityFlag = 'Y';
                var createdTime = ' ';
                var lastTime = ' ';
                var lastUserId = ' ';
                var ReasonCodetext = ' ';
                var TechnicianName = ' ';

				var addressConfirmed = true;

                if(isAddressChanged === true){
                    if(window.confirm("Are you sure you want to update Shipping Address"))
                    {
                        
                    }
					else {
                    	addressConfirmed = false;
                    }
                } else {
                    console.log('shipp');
                }

				//address change confirmed starts
				if(addressConfirmed === true){
	                component.get("v.ListOfEmployees").forEach(function(key){
	                    if( key.ResourceId == component.find("technician").get("v.value") ){
	                        TechnicianName = key.Name;
	                    }
	                });

	                if(component.find("address2").get("v.value")!=undefined) {
	                    var techAddr  = component.find("address1").get("v.value") +','+ component.find("address2").get("v.value") + ',' + component.find("city").get("v.value") +','+
	                        component.find("state").get("v.value") + ',' + component.find("zip").get("v.value");
	                } else {
	                    var techAddr  = component.find("address1").get("v.value") + ',' + component.find("city").get("v.value") +','+
	                        component.find("state").get("v.value") + ',' + component.find("zip").get("v.value");
	                }
	                component.set("v.caseObj.Technician_Address__c",  techAddr);  

	                component.set("v.caseObj.Technician_Schedule_Date__c", $( "#datepicker" ).val());
	                component.set("v.caseObj.TechnicianNameScheduled__c",  TechnicianName);
	                component.set("v.caseObj.Technician_Company__c",  component.find("myCompany").get("v.value"));
	                component.set("v.caseObj.followup_Priority_EstimatedTime__c", component.find("myTimeEstimated").get("v.value"));

	                var caseId = component.get("v.caseId");
	                var fulfillerId = component.get("v.fulfillID");
	                var ignoreEstimatedstops = component.get("v.estimatedtimeforstopwithminutes").replace("Hour",".");

	                //var finalignoreEstimatedStops = ignoreEstimatedstops.replace("Minutes","");
	                /*
	                var actionSalesOrderObj = component.get("c.getSalesOrderInfo");
	                actionSalesOrderObj.setParams({
	                    "recordId":caseId
	                });
	                */

	                var datePick1 = $( "#datepicker" ).val();
	                var date = new Date(datePick1);
	                var newdate = new Date(date);
	                newdate.setDate(newdate.getDate() + 2);

	                var dd = newdate.getDate();
	                var mm = newdate.getMonth() + 1;
	                var y = newdate.getFullYear();

	                var someFormattedDate = mm + '/' + dd + '/' + y;

					var add1 = component.find("address1").get("v.value");
					var add2 = component.find("address2").get("v.value");
					if(component.get("v.salesOrderObj").phhCustomerType__c == 'AFC'){
						add1 = component.get("v.salesOrderObj").phhShipToName__c;
						add2 = component.find("address1").get("v.value");
					}

	                var ServiceTechDtovar = {
	                    ScheduledDate           : $( "#datepicker" ).val(),
	                    OpenDate                : component.find("dateopened").get("v.value"),
	                    ReopenDate              : component.find("dateopened").get("v.value"),
	                    createdTime             : component.find("dateopened").get("v.value"),
	                    lastTime                : component.find("dateopened").get("v.value"),
	                    ReopenDate              : component.find("dateopened").get("v.value"),
	                    FollowUpDate            : someFormattedDate,
	                    RequestActivityFlag     : RequestActivityFlag,
	                    lastUserId              : lastUserId,
	                    VendId                  : component.find("myCompany").get("v.value").trim(),
	                    RequestSalesOrderNumber : component.find("Salesorder").get("v.value"),
	                    Address1                : add1,
	                    Address2                : add2,
	                    CityName                : component.find("city").get("v.value"),
	                    StateCode               : component.find("state").get("v.value"),
	                    ZipCode                 : component.find("zip").get("v.value"),
	                    CreatedUserId           : '0',
	                    ServiceTechId           : component.find("technician").get("v.value"),
	                    TechName                : TechnicianName,
	                    VendName                : '',
	                    VpcName                 : '',
	                    PcKey                   : '',
	                    CustomerPhone1          : component.find("phone1").get("v.value"),
	                    CustomerPhone2          : component.find("phone2").get("v.value"),
	                    CustomerPhone3          : '',
	                    CustomerEmail           : component.find("email1").get("v.value"),
	                    EstimatedTimeForStop    : ignoreEstimatedstops,
	                    ProfitCenterCode        : component.get("v.salesOrderObj").phhProfitcenter__c,
	                    CustomerId              : component.get("v.CustId")
	                };

	                var ItemsDtovar = [];
	                for(var si=0;si<selItem.length;si++){
	                    var ItemsLineDtovar = {};
	                    ItemsLineDtovar.IsNewItemRequest = "1";
	                    if(selItem[si].salesorder_number != undefined){
	                        ItemsLineDtovar.ItemSaleNumber = selItem[si].salesorder_number;
	                    }
	                    else{
	                        ItemsLineDtovar.ItemSaleNumber = "";
	                    }
	                    
	                    if(selItem[si].seqNumber != undefined){
	                        ItemsLineDtovar.ItemSaleSequenceNumber = selItem[si].seqNumber;
	                    }
	                    else{
	                        ItemsLineDtovar.ItemSaleSequenceNumber = "";
	                    }
	                    
	                    if(selItem[si].sku != undefined){
	                        ItemsLineDtovar.ItemSKUNumber = selItem[si].sku;
	                    }
	                    else{
	                        ItemsLineDtovar.ItemSKUNumber = "";
	                    }
	                    
	                    if(selItem[si].serialNo != undefined){
	                        ItemsLineDtovar.ItemSerialNumber = selItem[si].serialNo;
	                    }
	                    else{
	                        ItemsLineDtovar.ItemSerialNumber = "";
	                    }

	                    ItemsLineDtovar.ItemInvoiceNumber = "";
	                    ItemsLineDtovar.ItemDefect = "BURNT";
	                    ItemsLineDtovar.PartOrderTrackNumber = "";
	                    ItemsLineDtovar.OrderNumber = "";
	                    ItemsLineDtovar.PieceExchangedFixed = "";
	                    ItemsLineDtovar.PartNumber = "";
	                    ItemsLineDtovar.PartDesc = "";

	                    if(selItem[si].deldate != undefined){
	                        ItemsLineDtovar.DeliveryDate = selItem[si].deldate;
	                    }
	                    else{
	                        ItemsLineDtovar.DeliveryDate = "";
	                    }

	                    ItemsLineDtovar.SignedBy = "";
	                    ItemsLineDtovar.RowState = "A";
	                    ItemsLineDtovar.Select = 0;

	                    if(selItem[si].uniqueid != undefined){
	                        ItemsLineDtovar.ItemQuniqueId = selItem[si].uniqueid;
	                    }
	                    else{
	                        ItemsLineDtovar.ItemQuniqueId = 0;
	                    }

	                    ItemsLineDtovar.OrderStatus = "";
	                    ItemsLineDtovar.OrderShipInformation = "";
	                    ItemsLineDtovar.ShipDate = "";
	                    ItemsLineDtovar.Qty = selItem[si].Quantity;
	                    ItemsDtovar.push(ItemsLineDtovar);
	                }

	                //alert(JSON.stringify(ItemsDtovar));
	                var jsonvar = {
	                    ServiceTechDto : ServiceTechDtovar,
	                    ItemsDto : ItemsDtovar
	                };

	                //alert('jsonvar: ' + JSON.stringify(jsonvar));
	                console.log('jsonvar ',JSON.stringify(jsonvar));

	                var actionHTTPReq = component.get("c.POSTCallout");
	                actionHTTPReq.setParams({
	                    "recordId"   : caseId,
	                    "jsonData"   : JSON.stringify(jsonvar),
	                    "caseIs"     : component.get("v.caseObj"),
	                    "fulfillerId": fulfillerId,
	                    "sAdd1"		 : component.get("v.shipToAdd1"), 
	                    "sAdd2"		 : component.get("v.shipToAdd2"), 
	                    "sCity"		 : component.get("v.shipToCity"), 
	                    "sState"	 : component.find("state").get("v.value"), 
	                    "sZip"		 : component.get("v.shipToZip") 
	                });
	                actionHTTPReq.setCallback(this, function(response) {
	                    if (component.isValid() && response.getState() === "SUCCESS") {
	                    	console.log('response: ' + response.getReturnValue());
	                    	if(response.getReturnValue() == "error1"){
		                        var errorToast = $A.get("e.force:showToast");
		                        errorToast.setParams({"message": "Scheduling a Technician requires at least 1 PLI on the case. Please add one by clicking the 'Click Here to Schedule for Items' button", "type":"error"});
		                        errorToast.fire();
	                    	} else if(response.getReturnValue() == "error2"){
		                        var errorToast = $A.get("e.force:showToast");
		                        errorToast.setParams({"message": "To schedule a technician every PLI on this case must have a serial number. It cannot be blank. Please populate the serial number before continuing", "type":"error"});
		                        errorToast.fire();
	                    	} else {

								//Product line item insert starts
				                var customernumber = component.get("v.CustId");
				                var ship1 = component.find("address1").get("v.value");
				                var ship2 = component.find("address2").get("v.value");
				                var city = component.find("city").get("v.value");
				                var state = component.find("state").get("v.value");
				                var zip = component.find("zip").get("v.value");
				                var fulfiller = component.find("soextid").get("v.value");
				                var jsonlineval = component.get("v.selectedAssociateItems");

				                var actionlineitemsel = component.get("c.lineiteminsert");
				                actionlineitemsel.setParams({
				                    "recordId" : caseId,
				                    "jsonData" : JSON.stringify(jsonlineval),
				                    "cusNo"    : customernumber,
				                    "ship1"    : ship1,
				                    "ship2"    : ship2,
				                    "city"     : city,
				                    "state"    : state,
				                    "zip"      : zip,
				                    "fulfiller": fulfiller
				                });
				                actionlineitemsel.setCallback(this, function(response) {
				                    if (component.isValid() && response.getState() === "SUCCESS") {
				                    }
				                });
				                $A.enqueueAction(actionlineitemsel);
				                //Product line item insert ends

		                        var navEvt = $A.get("e.force:navigateToSObject");
		                        navEvt.setParams({
		                            "recordId": component.get("v.caseId"),
		                            "slideDevName": "detail"
		                        });
		                        navEvt.fire();

								//after successfull schedule close tech schedule console sub tab
								var workspaceAPI = component.find("workspace");
								console.log('workspaceAPI: ' + workspaceAPI);
								if(workspaceAPI != undefined){
							        workspaceAPI.getFocusedTabInfo().then(function(response) {
								        console.log('response: ' + JSON.stringify(response));
							            var focusedTabId = response.tabId;
							            if(response.isSubtab == true){
							            	workspaceAPI.refreshTab({
												tabId: response.parentTabId,
												includeAllSubtabs: true
											});
							            }
							            workspaceAPI.closeTab({tabId: focusedTabId});
							        })
							        .catch(function(error) {
							            console.log(error);
							        });
								}
	                    	}

	                        //var jsonresponsefrompost =  JSON.parse(response.getReturnValue());
	                        //var jsonresponsefrompostsrval = jsonresponsefrompost.RequestId;
	                        //component.set("v.jsonresponsefrompostsrval",jsonresponsefrompost);
	                        //console.log('jsonresponsefrompostsrval' + component.get("v.jsonresponsefrompostsrval"));
	                        //console.log('jsonsrvaliue' + JSON.stringify(jsonresponsefrompost));
	                        //console.log('jsonvaluescoming' + JSON.stringify(response.getReturnValue()));
	                    } else {
	                        var errorToast = $A.get("e.force:showToast");
	                        errorToast.setParams({"message": response.getError()[0].message, "type":"error"});
	                        errorToast.fire();
	                    }
	                });
	                $A.enqueueAction(actionHTTPReq);
				}
				//address change confirmed  ends
            }
            //component validation ends
        //}

    },
    
    scriptsLoaded : function(component, event, helper) {
    },
    
    init : function(component, event, helper) {
        var today = new Date();
        component.set('v.today', currDate.getFullYear() + "-" + (currDate.getMonth() + 1) + "-" + currDate.getDate());
    },
    
    Next : function(component, event, helper) {
        var today = new Date(component.get('v.today'));
    },
    
    changeState : function changeState (component){ 
        component.set('v.isexpanded',!component.get('v.isexpanded'));
    },
    
    toggleShippingAddress: function(component, event, helper) {
        var checkCmp = component.find("checkbox");
        component.set("v.displayShipAddress", checkCmp.get("v.value"));
    },
    
    nullify : function(comp, ev, hel) {
        var dp = comp.find('dateopened');
        dp.set('v.value', '');
    },
    
    ONWorkingHours : function(component,event,helper) {
        var workingHours = component.get("v.workingHoursprogvalue") + '/' + component.get("v.maxHours");
        component.set("v.workingHoursProgValueNew" , workingHours);
    },

    getProgressVal :function(component,event,helper) {
        var progressVal = 0;
        component.get("v.responseObj").forEach(function(key){
            if(key.TechId == employeeTechId){
                progressVal = key.MaxHoursPerDay;
            }
        });
        component.set("v.progressValue", progressVal);
    },

    onPicklistChange: function(component, event, helper) {
        var selectedPicklist = component.find("InputAccountIndustry");
    },

    dateUpdate : function(component, event, helper) {
        var today = new Date();
        var dd = today.getDate();
        var mm = today.getMonth() + 1; //January is 0!
        var yyyy = today.getFullYear();
        if(dd < 10){
            dd = '0' + dd;
        }
        if(mm < 10){
            mm = '0' + mm;
        }

        var todayFormattedDate = yyyy+'-'+mm+'-'+dd;
        if(component.get("v.myDate") != '' && component.get("v.myDate") < todayFormattedDate){
            component.set("v.dateValidationError" , true);
        }else{
            component.set("v.dateValidationError" , false);
        }
    },
    
    onChecklines: function(component,event,helper) {
        
        var selectedRec = event.getSource().get("v.value");
        var getSelectedNumber = component.get("v.selectedCount");
        if (selectedRec == true) {
            getSelectedNumber++;
        } else {
            getSelectedNumber--;
        }
        component.set("v.selectedCount", getSelectedNumber);
        
    },

    validateval  : function(component, event, helper) {
        var inp = component.get('v.minValue');
        if(inp.length > 2)
        {
            component.set('v.minValue', parseFloat(inp.substring(0, 2)));
        }
    }, 
    
    handleError: function(cmp,event,helper){
        var comp = event.getSource();
        $A.util.addClass(comp, "error");   
    },
    
    handleClearError: function(cmp,event,helper){
        var comp = event.getSource();
        $A.util.removeClass(comp, "error");   
    },

    visibleToUser : function(component, event, helper) {
        var elem = component.get("getLineItemcase");
        var selected = elem.textContent;
        resultCmp = component.find("visibleT");        
        resultCmp.set("v.value", selected);
    }
})