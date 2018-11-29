({
	getDeliveryWindow : function(component, preferredDeliveryDate, success, failure) {
		
	 	var accountNumber = component.get("v.accountNumber");
	 	var rdcId = component.get("v.rdcId");
	 	var orderId = component.get("v.orderId");
       // alert('orderIdLine id'+component.get('v.orderLineId'));
	 	var orderLineId = component.get("v.orderLineId");
       
	 	var action = component.get("c.getDeliveryCalendarDays");  
 			
		action.setParams({
	        preferredDeliveryDate : preferredDeliveryDate,
	        orderId : orderId,
	        orderLineID : orderLineId,
	        accountNumber : accountNumber,
	        rdcId : rdcId,
            shipToAddr:component.get("v.shipToAddr")
	    });

	    action.setCallback(this, function(response) {
			var state = response.getState();
			if (state === "SUCCESS") {
				var callResponse = response.getReturnValue();
             	console.log('callResponse'+JSON.stringify(callResponse));
				if(callResponse.isSuccess == true){	
					if (!$A.util.isEmpty(callResponse.calendar)){					
			            if (success) {
			                success.call(this, callResponse.calendar);
			            }						 
					}
					if (callResponse.message != null){
						//REQ-488
                        //Fire Delivery Window Event
						this.fireDeliveryWindowEvent(component, null);
						//Display call response message
						var warningToast = $A.get("e.force:showToast");
						warningToast.setParams({"message": callResponse.message, "type":"warning"});
						warningToast.fire();
			            if (failure) {
			                failure.call(this, callResponse.message);
			            }						
					}
				} else {
					var errorToast = $A.get("e.force:showToast");
					errorToast.setParams({"message": callResponse.message, "type":"error", "mode":"sticky"});
					errorToast.fire();
		            if (failure) {
		                failure.call(this, callResponse.message);
		            }					
				}				
			} else {
				var errorToast = $A.get("e.force:showToast");
				errorToast.setParams({"message": response.getError()[0].message, "type":"error", "mode":"sticky"});
				errorToast.fire();
	            if (failure) {
	                failure.call(this, response.getError()[0].message);
	            }				
			}

		});

		action.setBackground();
		$A.enqueueAction(action);

	},	
	changeSelectedMonth : function(component, movementDirection) {
		var self = this;
	 	var newMonthIndex = component.get("v.selectedMonth").index + movementDirection;
	 	if (this.isDeliveryWindowCalloutRequired(component, newMonthIndex)){
	 		var newStartDate = this.getStartDateForMonthIndex(component, newMonthIndex);

			component.set("v.isLoading", true);
		 	component.set("v.deliveryCalendar", null);
		 	component.set("v.selectedMonth", null);
            component.set("v.TselectedMonth", null);

			this.getDeliveryWindow(component, 
				( (newStartDate.month() == component.get("v.dwProcessingStartDate").month()) ? component.get("v.dwProcessingStartDate") : newStartDate).format('YYYY-MM-DD'), 
				function(calendar){
					var mostDistantDateAvailForDelivery = self.getMostDistantDateAvailForDelivery(calendar.months[0]);
					component.set("v.dwCurrentMonthStartDate", mostDistantDateAvailForDelivery.clone().startOf('month').format('YYYY-MM-DD'));
					component.set("v.selectedMonth", calendar.months[0]); 
                    component.set("v.TselectedMonth", calendar.Tmonths[0]);
					component.set("v.deliveryCalendar", calendar);	    		
					component.set("v.isLoading", false);	    			
				},
				function(message){
					component.set("v.isLoading", false);
				});

	 	} else {
			var newSelectedMonth = component.get("v.deliveryCalendar").months[newMonthIndex];
			var mostDistantDateAvailForDelivery = self.getMostDistantDateAvailForDelivery(newSelectedMonth);
			component.set("v.dwCurrentMonthStartDate", mostDistantDateAvailForDelivery.clone().startOf('month').format('YYYY-MM-DD'));	 		
			component.set("v.selectedMonth", newSelectedMonth);
	 	}
	},
	getStartDateForMonthIndex : function(component, monthIndex){
		var startDateForMonthIndex = null;
		if (monthIndex < 0){	// request for start date of previous month	that doesnt exist within the current delivery calendar	
			var currentSelectedMonth = component.get("v.deliveryCalendar").months[0];
			var mostDistantDateAvailForDelivery = this.getMostDistantDateAvailForDelivery(currentSelectedMonth);
			startDateForMonthIndex = mostDistantDateAvailForDelivery.clone().subtract(1, 'months').startOf('month');
		} else if (monthIndex >= component.get("v.deliveryCalendar").months.length){	// request for start date of next month not within the current delivery calendar
			var currentSelectedMonth = component.get("v.deliveryCalendar").months[component.get("v.deliveryCalendar").months.length - 1];
			var mostDistantDateAvailForDelivery = this.getMostDistantDateAvailForDelivery(currentSelectedMonth);
			startDateForMonthIndex = mostDistantDateAvailForDelivery.clone().add(1, 'months').startOf('month');
		} else {
		 	var newSelectedMonth = component.get("v.deliveryCalendar").months[monthIndex];
	 		var mostDistantDateAvailForDelivery = this.getMostDistantDateAvailForDelivery(newSelectedMonth);
	 		startDateForMonthIndex = mostDistantDateAvailForDelivery.clone().startOf('month');
	 	}
	 	return startDateForMonthIndex;
	},	
	isDeliveryWindowCalloutRequired : function(component, monthIndex){
		var isCalloutRequired = false;
		if (monthIndex < 0){	// request for start date of previous month	that doesnt exist within the current delivery calendar	
			isCalloutRequired = true;
		} else if (monthIndex >= component.get("v.deliveryCalendar").months.length){	// request for start date of next month not within the current delivery calendar
			isCalloutRequired = true;
		} else {
			var newSelectedMonth = component.get("v.deliveryCalendar").months[monthIndex];
			var mostDistantDateAvailForDelivery = this.getMostDistantDateAvailForDelivery(newSelectedMonth);
			var lastDateOfMonth = mostDistantDateAvailForDelivery.clone().endOf('month');
			isCalloutRequired = mostDistantDateAvailForDelivery.isBefore(lastDateOfMonth);
		}
		return isCalloutRequired;
	},
	getMostDistantDateAvailForDelivery : function(selectedMonth){
		var availableDeliveryDatesInCurrentMonth = [];
		for (var i=0; i<selectedMonth.weeks.length; i++){
			var processingWeek = selectedMonth.weeks[i];
			for (var j=0; j<processingWeek.length; j++){
				var processingDay = processingWeek[j];
				if (processingDay.dateIsInCurrentMonth && processingDay.availableForDelivery){
					availableDeliveryDatesInCurrentMonth.push(moment(processingDay.d, 'YYYY-MM-DD').startOf('day'));
				}
			}
		}
		var retVal = (!$A.util.isEmpty(availableDeliveryDatesInCurrentMonth) ? moment.max(availableDeliveryDatesInCurrentMonth) : null);
		return retVal;						
	},
	fireDeliveryWindowEvent : function(component, deliveryDate){
		var deliveryWindowEvent = component.getEvent("deliveryWindowEvent");
		if (deliveryWindowEvent){
			deliveryWindowEvent.setParams({
			    "deliveryDate": deliveryDate, 
			    "deliveryMode": component.get("v.deliveryMode")				
			});
			deliveryWindowEvent.fire();
		}
	},
       /* tresholdAvailableDays : function(component, event, helper) {
         var orderLineId = component.get("v.orderLineId");
         var action = component.get("c.TresholdAvlbDays");
        action.setParams({
            orderLineId:orderLineId 
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
           // alert('state'+state);
            if (state === "SUCCESS") {
                if(response.getReturnValue() == null)
                {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        type: "error",
                        message:" No Available dates Available for RSA Account",
                    });
                    toastEvent.fire();
                }else{
                    component.set("v.Enabletesholdcal",true);
                    var callResponse = response.getReturnValue();
                    console.log('callResponse'+JSON.stringify(callResponse));
                    component.set("v.TresholdWrap",callResponse);
                }
            }
            else if(state === "ERROR")
            {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    type: "error",
                    message:"Error in API",
                });
                toastEvent.fire();
            } 
        });
        $A.enqueueAction(action); 
    }*/
    DeliveryHelperMethod:function(component, event, helper) {
     var orderLineIds = component.get("v.orderLineId");
         var action = component.get("c.DeliveryTypeLine");
        action.setParams({
            orderLineId:orderLineIds 
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
           // alert('state'+state);
            if (state === "SUCCESS") {
                 var callResponse = response.getReturnValue();
                
                   // alert('callResponse'+JSON.stringify(callResponse));
                    component.set("v.TdeliveryType",callResponse);
                }
        
        });
        $A.enqueueAction(action); 
    }
    

})