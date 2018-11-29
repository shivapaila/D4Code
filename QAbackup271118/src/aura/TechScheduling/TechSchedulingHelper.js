({
    validate : function(component) {

        var validateData = true;
        try{
            var company = component.find("myCompany");
            var companyValue = company.get("v.value");
            if ( $A.util.isEmpty(companyValue) || companyValue == '--SELECT--' || companyValue == undefined ) {
                validateData = false;
                company.set("v.errors", [{message:"company should not be null:" }]);
            } else {
                company.set("v.errors", null);
            }

            var address1 = component.find("address1");
            var address1upd = address1.get("v.value");
            if ( $A.util.isEmpty(address1upd) || address1upd == '--SELECT--' || address1upd == undefined ) {
                validateData = false;
                address1.set("v.errors", [{message:"Address fields are mandatory"}]);
            } else {
                address1.set("v.errors", null);
            }

            var city = component.find("city");
            var cityup = city.get("v.value");
            if ( $A.util.isEmpty(cityup) || cityup == '--SELECT--' || cityup == undefined ) {
                validateData = false;
                city.set("v.errors", [{message:"City is required"}]);
            } else {
                city.set("v.errors", null);
            }

            var techdate = component.find("techscheduleddate");
            var techdateup = techdate.get("v.value");
            if ( $A.util.isEmpty(techdateup) || techdateup == undefined ) {
                validateData = false;
                techdate.set("v.errors", [{message:"Technician date is required"}]);
            } else {
                techdate.set("v.errors", null);
            }

            var state = component.find("state");
            var stateup = state.get("v.value");
            if ( $A.util.isEmpty(stateup) || stateup == '--SELECT--' || stateup == undefined ) {
                validateData = false;
                state.set("v.errors", [{message:"State is required"}]);
            } else if (stateup.length != 2) {
                validateData = false;
                state.set("v.errors", [{message:"State should be of 2 character length"}]);
            } else {
            	console.log('length: ' + stateup.length);
                state.set("v.errors", null);
            }

            var zip = component.find("zip");
            var zipup = zip.get("v.value");
            if ( $A.util.isEmpty(zipup) || zipup == '--SELECT--' || zipup == undefined ) {
                validateData = false;
                zip.set("v.errors", [{message:"Zip is required"}]);
            }  else {
                zip.set("v.errors", null);
            }

            var phone1 = component.find("phone1");
            var phoneValue1= phone1.get("v.value");
            if (!$A.util.isEmpty(phoneValue1)) {
                var phoneno = /^\(?([0-9]{3})\)?[-. ]?([0-9]{3})[-. ]?([0-9]{4})$/;
                if(!phoneValue1.match(phoneno)) {
                    phone1.set("v.errors", [{message:"entry is an invalid phone number."}]);
                } else {
                    phone1.set("v.errors", null);
                }
            }

            var phone2 = component.find("phone2");
            var phoneValue2= phone2.get("v.value");
            if (!$A.util.isEmpty(phoneValue2)) {
                var phoneno = /^\(?([0-9]{3})\)?[-. ]?([0-9]{3})[-. ]?([0-9]{4})$/;
                if(!phoneValue2.match(phoneno)) {
                    phone2.set("v.errors", [{message:"entry is an invalid phone number."}]);
                } else {
                    phone2.set("v.errors", null);
                }
            }

            var email1 = component.find("email1");
            var emailValue1= email1.get("v.value");
            if (!$A.util.isEmpty(emailValue1)) {
                var phoneno = /(\w+)\@(\w+)\.[a-zA-Z]/g;
                if(!emailValue1.match(phoneno)) {
                    validateData = false;
                    email1.set("v.errors", [{message:"entry is an invalid email"}]);
                } else if (emailValue1.length > 40) {
					validateData = false;
                	email1.set("v.errors", [{message:"email length should not be greater than 40"}]);
                } else {
                    email1.set("v.errors", null);
                }
            }

            var email2 = component.find("email2");
            var emailValue2= email2.get("v.value");
            if (!$A.util.isEmpty(emailValue2)) {
                var phoneno = /(\w+)\@(\w+)\.[a-zA-Z]/g;
                if(!emailValue2.match(phoneno)) {
                    email2.set("v.errors", [{message:"entry is an invalid email"}]);
                } else {
                    email2.set("v.errors", null);
                }
            }

            var timestop = component.find("myTimeEstimated");
            var meetingRoomValue1= timestop.get("v.value");
            if ( $A.util.isEmpty(meetingRoomValue1) || meetingRoomValue1 == '--SELECT--' || meetingRoomValue1 == undefined ) {
                validateData = false;
                timestop.set("v.errors", [{message:"Estimated time is required"}]);
            } else {
                timestop.set("v.errors", null);
            }

            var tech = component.find("technician");
            var techValue1= tech.get("v.value");
            if ( $A.util.isEmpty(techValue1) || techValue1 == '--SELECT--' || techValue1 == undefined ) {
                validateData = false;
                tech.set("v.errors", [{message:"Technician is required"}]);
            } else {
                tech.set("v.errors", null);
            }

            var ignoreEstimatedstops = component.find("myTimeEstimated");
            var ignoreEstimatedstops1 = ignoreEstimatedstops.get("v.value");
            console.log('va2'+ignoreEstimatedstops1);
            //var ignoreEstimatedstops2 = ignoreEstimatedstops1.replace("Hour","")
            //console.log('va'+ignoreEstimatedstops2);
            if(parseInt(ignoreEstimatedstops1) > 24 ) {
                validateData = false;
                ignoreEstimatedstops.set("v.errors", [{message:"The Hours for Estimated Stop should not be greater than 24."}]);
            } else {
                ignoreEstimatedstops.set("v.errors", null);
            }

            return(validateData);  
        } catch(e) {
            console.log("issue" ,e)
        }
    },

    getValidationOnValues :function(component) {
        var validateData = true;
        try{
        	var minVal = component.find("minValTechSch");
            var minDateValid = minVal.get("v.value");
            console.log(minDateValid);
            if ( $A.util.isEmpty(minDateValid) || minDateValid == '' || minDateValid == undefined ) {
                validateData = false;
                var errorToast = $A.get("e.force:showToast");
            	errorToast.setParams({"message": "Minimum Value is required", "type":"error"});
            	errorToast.fire();
            }

	        var maxVal = component.find("customer_po1");
	        var maxDateValid = maxVal.get("v.value");
	        console.log(maxDateValid);
			if ( $A.util.isEmpty(minDateValid) || minDateValid == '' || minDateValid == undefined ) {
			}
			else{
				if(parseInt(minDateValid) > parseInt(maxDateValid))
		        {
		        	validateData = false;
		            var errorToast = $A.get("e.force:showToast");
		            errorToast.setParams({"message": "Maximum Value should be greater than Minimum", "type":"error"});
		            errorToast.fire();
		        }
			}
        } catch(e) {
            console.log("issue" ,e)
        }

        return validateData;
    },

    getAPIResponse: function(component) {
        var fulfillerId = component.get("v.fulfillID");
        var zipcode = component.get("v.zipcode");
        console.log('getApiResponse: ' + zipcode + ':' + fulfillerId);
        var actionHTTPReq = component.get("c.getApiResponse");
        actionHTTPReq.setParams({
            "fulfillerId": fulfillerId,
            "zipcode" : component.get("v.zipcode")
        });
        actionHTTPReq.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                console.log('getApiResponse1: ' + response.getReturnValue());
                component.set("v.ListOfCompanies", response.getReturnValue());
            }
            else {
                console.log("Failed with state: " + state );
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(actionHTTPReq);
    },

    saveChanges: function(component, draftValues) {
        component.set('v.draftItems', draftValues);

		console.log('S Draft Items: ' + JSON.stringify(component.get('v.draftItems')));
		console.log('B Confirm Items: ' + JSON.stringify(component.get('v.confirmItems')));

		//logic starts to remove newly entered serial number reference from confirm items array
        //upon saving, remove saved item from confirm items [example if the user re-enter serial number then again they can confirm with new serial no]
        //if the draft unique id present in the confirm item then delete it from confirm item variable
        var newConfirmItems = [];
        var confirmItems = component.get('v.confirmItems');

		for(var uci=0; uci<confirmItems.length; uci++){
			for(var di=0; di<draftValues.length; di++){
	            if(confirmItems[uci].keyId != draftValues[di].keyId){
	                newConfirmItems.push(confirmItems[uci]);
	            }
	        }
		}
		component.set('v.confirmItems', newConfirmItems);
		//logic ends to remove newly entered serial number reference from confirm items array

		console.log('A Confirm Items: ' + JSON.stringify(component.get('v.confirmItems')));

        var rerendSch = component.get('c.openLineItem');
		$A.enqueueAction(rerendSch);
    },

    selectrowvalues : function(component, event) {
        var row = event.getParam('row');

        var jsondata= JSON.stringify(row);
        //alert('jsondata: '+jsondata);
        //alert('selected sku: ' + row.sku);
        //var draftValues = component.find("AssociateItems").get("v.draftValues");

        component.set("v.dterror", "");
        //alert(JSON.stringify(component.get('v.draftItems')));

        if(row.serialNo == ''){
            component.set("v.dterror", "Enter Serial Number to confirm");
            //As per Alan request if the serialno is null then setting 99999 by default
            //row.serialNo = '999999';
        }
        else{
            var actionConfHttpReq = component.get("c.confirmProductLineItem");
            actionConfHttpReq.setParams({
                "sku" : row.sku,
                "serialNo" : row.serialNo
            });
            //alert('selected sku: ' + row.sku);
            actionConfHttpReq.setCallback(this, function(response) {
                //alert(response.getState());
                if(component.isValid() && response.getState() === "SUCCESS"){
                    //alert(response.getReturnValue());
                    if(response.getReturnValue() == true){
                        row.isSelected = true;

                        //var selItem = component.get('v.selectedAssociateItems');
                        //selItem.push(row);

						console.log('Row Items: ' + JSON.stringify(row));
						console.log('B Associate Items: ' + JSON.stringify(component.get('v.selectedAssociateItems')));

						//logic starts to remove newly entered serial number reference from selected associate items array
				        //upon confirm, remove saved item from selected associate items [example if the user re-enter serial number then again they can confirm with new serial no]
				        //if the confirmed row present in the selected associate item then delete it from selected associate item variable
				        var newAssItems = [];
				        var selAssItems = component.get('v.selectedAssociateItems');
				
						for(var sai=0; sai<selAssItems.length; sai++){
				            if(selAssItems[sai].keyId != row.keyId){
				                newAssItems.push(selAssItems[sai]);
				            }
				        }
				        newAssItems.push(row);
						component.set('v.selectedAssociateItems', newAssItems);
						//logic ends to remove newly entered serial number reference from selected associate items array

						console.log('A Associate Items: ' + JSON.stringify(component.get('v.selectedAssociateItems')));

                        var confirmItems = component.get('v.confirmItems');
                        confirmItems.push({'keyId': row.keyId, 'serialNo': row.serialNo});

                        var rerendSch = component.get('c.openLineItem');
                        $A.enqueueAction(rerendSch);
                    }
                    else{
                        component.set("v.dterror","Serial number is not valid");
                    }
                }
                else{
                    console.log("Failed with state: " + JSON.stringify(response.getError()));
                    //component.set("v.errors", "Failed with state: " + JSON.stringify(response.getError()));
                }
            });
            $A.enqueueAction(actionConfHttpReq);
        }
    },

    techCalendarLoad : function(component) {
        var availableDates = [];
        var technicianAvail = [];
        var technicianPartAvail = [];
        var technicianNotAvail = [];
        var workingHours = [];
        var repairStops = [];
        var PiecesRepair = [];

		var WeeklyScheduleVar = component.get("v.weeklyScheduleVar");
		var leaveDates = component.get("v.cLeaveDates");

        var fulfillerId = component.get("v.fulfillID");
        var employeeTechId = component.find("technician").get("v.value");
        var tmth = component.get("v.cMonth");
        var tYr = component.get("v.cYear");
		var tmthinc = component.get("v.cMonthInc");

		var estimateTime = component.get("v.estimatedtimeforstopwithminutes").replace("Hour",".");
		var selectedLineItem = component.get("v.selectedAssociateItems");
		var caseLineItem = component.get("v.pliList");

        console.log('C estimateTime: ' + estimateTime);
        console.log('C selectedLineItem: ' + selectedLineItem);
        console.log('C caseLineItem: ' + JSON.stringify(caseLineItem));

        console.log('C fulfillerId: ' + fulfillerId);
        console.log('C employeeTechId: ' + employeeTechId);
        console.log('C tYr: ' + tYr);
        console.log('C tmth: ' + tmth);
        console.log('C tmthinc: ' + tmthinc);
		console.log('C leaveDates: ' + leaveDates);
		console.log('C WeeklyScheduleVar: ' + WeeklyScheduleVar);

		//calculate line item count based on selected line item and case product line item
		var dupCount = 0;
		caseLineItem.forEach(function (pli){
			console.log(' pli: ' + pli);
			var res = pli.split("|");
			selectedLineItem.forEach(function (sli){
				console.log(' sli: ' + sli);
				if( (res[0] == sli.salesorder_number) && (res[1] == sli.sku) && (res[2] == sli.seqNumber) ){
					//duplicate
					++dupCount;
				}
			});
		});
		console.log('C dupCount: ' + dupCount);

		var totalPli = selectedLineItem.length + caseLineItem.length - dupCount;
		console.log('C totalPli: ' + totalPli + ' time: ' + estimateTime);

        var actionCalHTTPReq = component.get("c.getAvailableDates");
        actionCalHTTPReq.setParams({
            "fulfillerId"   : fulfillerId,
            "resourceId" : employeeTechId,
            "cYear"      : tYr,
            "cMonth"     : tmth
        });
        //var selectedCompany = component.find("myCompany").get("v.value").trim();
        actionCalHTTPReq.setCallback(this, function(response) {
            if (component.isValid() && response.getState() === "SUCCESS") {

                response.getReturnValue().forEach(function(responseObj){
                    console.log('responsetime' + JSON.stringify(response.getReturnValue()));

					WeeklyScheduleVar = responseObj.WeeklySchedule;
					var curHours = Number(responseObj.CurrentWorkingHours) + Number(estimateTime);
					var curRepair = Number(responseObj.CurrentRepairStops) + 1;
					var curPieces = Number(responseObj.CurrentPieces) + Number(totalPli);

					console.log('responseObj.CurrentWorkingHours: ' + responseObj.CurrentWorkingHours);
					console.log('curHours: ' + curHours);
					console.log('responseObj.CurrentRepairStops: ' + responseObj.CurrentRepairStops);
					console.log('curRepair: ' + curRepair);
					console.log('responseObj.CurrentPieces: ' + responseObj.CurrentPieces);
					console.log('curPieces: ' + curPieces);

                    //available dates
                    availableDates.push($A.localizationService.formatDate(responseObj.ScheduleDate, "YYYY-MM-DD"));

                    if((curHours > responseObj.MaxHoursPerDay) || (curRepair > responseObj.MaxRepairPerDay) || (curPieces > responseObj.MaxPiecesPerDay)){
                    	//technician is not available for the day
                    	technicianNotAvail.push($A.localizationService.formatDate(responseObj.ScheduleDate, "YYYY-MM-DD"));

                    	if(curHours > responseObj.MaxHoursPerDay){
                    		workingHours.push($A.localizationService.formatDate(responseObj.ScheduleDate, "YYYY-MM-DD"));
                    	}

						if(curRepair > responseObj.MaxRepairPerDay){
							repairStops.push($A.localizationService.formatDate(responseObj.ScheduleDate, "YYYY-MM-DD"));
						}

						if(curPieces > responseObj.MaxPiecesPerDay){
							PiecesRepair.push($A.localizationService.formatDate(responseObj.ScheduleDate, "YYYY-MM-DD"));
						}
                    }
                    else{
                    	//technician is available for the day
                    	if((curHours == 0) && (curRepair == 0) && (curPieces == 0)){
                    		//technician is fully available for the day
                    		technicianAvail.push($A.localizationService.formatDate(responseObj.ScheduleDate, "YYYY-MM-DD"));
                    	}
                    	else{
                    		//technician is partially available for the day
                    		technicianPartAvail.push($A.localizationService.formatDate(responseObj.ScheduleDate, "YYYY-MM-DD"));
                    	}
                    }
                });

				console.log('C WeeklyScheduleVar1: ' + WeeklyScheduleVar);
				console.log('C availableDates: ' + availableDates);
				console.log('C technicianAvail: ' + technicianAvail);
				console.log('C technicianPartAvail: ' + technicianPartAvail);
				console.log('C technicianNotAvail: ' + technicianNotAvail);
				console.log('C workingHours: ' + workingHours);
				console.log('C repairStops: ' + repairStops);
				console.log('C PiecesRepair: ' + PiecesRepair);

                $("#datepicker").datepicker("destroy");
                jQuery("#datepicker").datepicker({
                    minDate: 0,
                    inline:true,
                    nextText: "",
                    prevText: "",
                    hideIfNoPrevNext: true,
                    defaultDate : '+' + tmthinc + 'm',
                    beforeShowDay: function(date){
	                   	//console.log('date: ' + date);
                    	//console.log('YYYY-MM-DD ' + jQuery.datepicker.formatDate('YYYY-MM-DD', date));
                    	//console.log('yy-mm-dd ' + jQuery.datepicker.formatDate('yy-mm-dd', date));

                        var dateArray = WeeklyScheduleVar;
                        var showdaysArray = [];
                        for (var i = 0; i < dateArray.length; i++) {
                            if(dateArray[i]=='Y'){
                                showdaysArray.push(i);
                            }
                        }
                        //console.log('showdaysArray: ' + showdaysArray);
                        var showdays = date.getDay();

                        var show = false;
                        var css_class = '';
                        var tooltip = '';
                        //console.log('showdays: ' + showdays);
                        if(showdaysArray.indexOf(showdays) != -1 ){
                        	//based on weekly schedule
                            if(leaveDates.indexOf(jQuery.datepicker.formatDate('yy-mm-dd', date)) != -1){
                            	//if the tech is on leave
                                show = false;
                                console.log('leavedates' + leaveDates);

                                css_class = 'tech-leave';
                                //set tooltip
								tooltip = 'Technician is on leave';
                            }else{
                            	//if the tech is not on leave
                                show = true;
                            }
                        }

						/*if(availableDates.indexOf(jQuery.datepicker.formatDate('yy-mm-dd', date)) != -1){
							//if the tech is scheduled for this date
							show = true;
						}*/

						if(show === true){
							if(technicianNotAvail.indexOf(jQuery.datepicker.formatDate('yy-mm-dd', date)) != -1){
								//Technician is not available for the day
								css_class = 'tech-not-avail '+jQuery.datepicker.formatDate('yy-mm-dd', date);

								//set tooltip
								if(workingHours.indexOf(jQuery.datepicker.formatDate('yy-mm-dd', date)) != -1){
									//Working Hours is not available for this tech
									tooltip = 'Technician Working Hours was Scheduled more than 100% for the selected date, kindly selected another date';
								}
	
								if(repairStops.indexOf(jQuery.datepicker.formatDate('yy-mm-dd', date)) != -1){
									//Repair Stops is not available for this tech
									tooltip = 'Technician Repair Stops was Scheduled more than 100% for the selected date, kindly selected another date';
								}
	
								if(PiecesRepair.indexOf(jQuery.datepicker.formatDate('yy-mm-dd', date)) != -1){
									//Pieces Repair is not available for this tech
									tooltip = 'Technician Pieces Repair was Scheduled more than 100% for the selected date, kindly selected another date';
								}
							} else if(technicianPartAvail.indexOf(jQuery.datepicker.formatDate('yy-mm-dd', date)) != -1){
								//Technician is partially available for the day
								css_class = 'tech-partially-avail '+jQuery.datepicker.formatDate('yy-mm-dd', date);
								//set tooltip
								tooltip = 'Technician is partially available for the day';
							} else {
								//Technician is fully available for the day
								css_class = 'tech-avail '+jQuery.datepicker.formatDate('yy-mm-dd', date);
								//set tooltip
								tooltip = 'Technician is fully available for the day';
							}
						}

                        //console.log('show: ' + show);
                        return [show , css_class, tooltip];
                    },
                    
                    onSelect: function(date) {
                        component.set("v.Spinner", true);
                        var selectedDate =   $('#datepicker').datepicker({ dateFormat: 'yy-mm-dd' }).val();

                        var actionProgValue = component.get("c.getProgressValue");
                        actionProgValue.setParams({
                            "fulfillerId"  : fulfillerId,
                            "resourceId"   : component.get("v.caseObj.Tech_Scheduled_Company__c"),
                            "selecteddate" : selectedDate
                        });
                        actionProgValue.setCallback(this, function(response) {
                            if (component.isValid() && response.getState() === "SUCCESS") {
                                component.set('v.progressMap', response.getReturnValue());
                                component.set('v.MaxWorkingHours', component.get('v.progressMap').MaxWorkingHours);
                                component.set('v.MaxRepairStops', component.get('v.progressMap').MaxRepairStops);
                                component.set('v.MaxPiecesDay', component.get('v.progressMap').MaxPiecesDay);

								var curProgressHours = Number(component.get('v.progressMap').CurrentWorkingHours) + Number(estimateTime);
								var curProgressRepair = Number(component.get('v.progressMap').CurrentRepairStops) + 1;
								var curProgressPieces = Number(component.get('v.progressMap').CurrentPieces) + Number(totalPli);

								component.set('v.CurrentWorkingHours', curProgressHours);
								component.set('v.CurrentRepairStops', curProgressRepair);
								component.set('v.CurrentPieces', curProgressPieces);
								component.set("v.workingHoursprogvalue", curProgressHours + '/' + component.get('v.progressMap').MaxWorkingHours);
								component.set("v.RepairStopsprogvalue", curProgressRepair + '/' +  component.get('v.progressMap').MaxRepairStops);
								component.set("v.PiecesRepairprogvalue", curProgressPieces +'/'+component.get('v.progressMap').MaxPiecesDay);
								var cwhpv = ((parseInt(curProgressHours) / parseInt(component.get('v.progressMap').MaxWorkingHours)) * 100);
								var crspv = ((parseInt(curProgressRepair) / parseInt(component.get('v.progressMap').MaxRepairStops)) * 100);
								var cprpv = ((parseInt(curProgressPieces) / parseInt(component.get('v.progressMap').MaxPiecesDay)) * 100);

                                component.set("v.CurrentWorkingHoursProgValue", cwhpv);
                                component.set("v.CurrentRepairStopsprogvalue", crspv);
                                component.set("v.CurrentPiecesRepairprogvalue", cprpv);
                                var errorMsg;
                                if(cwhpv > 100){
                                    errorMsg = 'Technician Working Hours was Scheduled more than 100% for the selected date, kindly selected another date';
                                }
                                else if(crspv > 100){
                                    errorMsg = 'Technician Repair Stops was Scheduled more than 100% for the selected date, kindly selected another date';
                                }
                                else if(cprpv > 100){
                                    errorMsg = 'Technician Pieces Repair was Scheduled more than 100% for the selected date, kindly selected another date';
                                }
                                if(errorMsg != null){
                                    $("#datepicker").val("");
                                    var errorToast = $A.get("e.force:showToast");
                                    errorToast.setParams({"message": errorMsg, "type":"error"});
                                    errorToast.fire();
                            	}
                            	else{
                            		//if there is no error then set the selected date
                            		component.set("v.cSelectedDate", selectedDate);
                            	}
                            }
                            else {
                                var errorToast = $A.get("e.force:showToast");
                                errorToast.setParams({"message": response.getError()[0].message, "type":"error"});
                                errorToast.fire();
                            }
                            component.set("v.Spinner", false);
                        });
                        $A.enqueueAction(actionProgValue);
                    },

                    onChangeMonthYear : function(ntYr, ntmth, inst) {
                    	component.set("v.Spinner", true);
						console.log('Year: ' + ntYr + ' Month: ' + ntmth + ' Instance: ' + inst);
						// before i set the month and year, i have to know whether the user hit previous button or next button

						if(ntYr == tYr){
							//same year increment or decrement based on month
							if(tmth < ntmth){
								++tmthinc;
							}
							else{
								--tmthinc;
							}
						}
						else{
							//either the year is increased or decreased
							if(tYr < ntYr){
								//increased
								++tmthinc;
							}
							else{
								//decreased
								--tmthinc;
							}
						}

						component.set("v.cMonth", ntmth);
						component.set("v.cYear", ntYr);
						component.set("v.cMonthInc", tmthinc);

				        var rerendMon = component.get('c.onMonthChange');
						$A.enqueueAction(rerendMon);
					}
                });
            }
            else {
                var errorToast = $A.get("e.force:showToast");
                errorToast.setParams({"message": 'There might be some issue with your selection \n OR an issue with the system. Please contact your administrator.', "type":"error"});
                errorToast.fire();
            }
        });
        $A.enqueueAction(actionCalHTTPReq);
    },

    resetScheduleAttr : function(component) {
        component.set("v.maxHours", '');
        component.set("v.maxRepair",'');
        component.set("v.maxPieces",'');
        component.set("v.upHostery",'');
        component.set("v.casegoods",'');
        component.set("v.leather",'');
        component.set("v.weeklyScheduleVar",'');
        component.set("v.cLeaveDates",'');
        component.set("v.cMonth", '');
        component.set("v.cYear",'');
        component.set("v.cMonthInc",'0');
    },

    resetCalendarAttr : function(component) {
        component.set("v.workingHoursprogvalue", 0);
        component.set("v.RepairStopsprogvalue", 0);
        component.set("v.PiecesRepairprogvalue", 0);
        component.set("v.CurrentWorkingHoursProgValue", 0);
        component.set("v.CurrentRepairStopsprogvalue", 0);
        component.set("v.CurrentPiecesRepairprogvalue", 0);
        component.set("v.cSelectedDate", "");
        component.set("v.datevalue", "");
        $("#datepicker").val('');
        $( "#datepicker" ).datepicker( "destroy" );
    }
})