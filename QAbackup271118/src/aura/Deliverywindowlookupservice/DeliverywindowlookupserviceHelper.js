({
	getDeliveryWindow : function(component, preferredDeliveryDate, success, failure) {
		
	 	var accountNumber = component.get("v.accountNumber");
	 	var rdcId = component.get("v.rdcId");
	 	var orderId = component.get("v.orderId");
	 	var orderLineId = component.get("v.orderLineId");
        var orderNumber= component.get("v.orderNumber");
        var profitCenter= component.get("v.profitCenter");
        //alert('profitCenter'+profitCenter);
         var futureDate= component.get("v.futureDate");
        
        //alert('preferredDeliveryDate---'+preferredDeliveryDate);
       //alert('futureDate isin1 '+component.get("v.futureDate"));
      // alert('ordernumber isin1 '+component.get("v.orderNumber"));
       	var action = component.get("c.getDeliveryCalendarDays");  
		action.setParams({
	        preferredDeliveryDate : preferredDeliveryDate,
	        orderId : orderId,
	        orderLineID : orderLineId,
	        accountNumber : accountNumber,
	        rdcId : rdcId,
            orderNumber:orderNumber,
            profitCenter:profitCenter,
            shipToAddr:component.get("v.shipToAddr")
            
	    });

	    action.setCallback(this, function(response) {
			var state = response.getState();
            //alert('state'+state);
			if (state === "SUCCESS") {
				var callResponse = response.getReturnValue(); 
             //alert('callResponse in DeliveryWindowLookupserviceController'+JSON.stringify(callResponse));
                console.log('callResponse in DeliveryWindowLookupserviceController'+JSON.stringify(callResponse));
				if(callResponse.isSuccess == true){	
                    
					if (!$A.util.isEmpty(callResponse.calendar)){					
			            if (success) {
			                success.call(this, callResponse.calendar);
                            component.set("v.calendarData", callResponse.UserProfileId);
                            //alert('calendaruser'+callResponse.UserProfileId);
			            
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
       // alert('Entered changeSelectedMonth method');
		var self = this;
	 	var newMonthIndex = component.get("v.selectedMonth").index + movementDirection;
        //alert('newMonthIndex  '+newMonthIndex);
	 	if (this.isDeliveryWindowCalloutRequired(component, newMonthIndex)){
	 		var newStartDate = this.getStartDateForMonthIndex(component, newMonthIndex);
            //alert('newStartDate  '+newStartDate);
			component.set("v.isLoading", true);
		 	component.set("v.deliveryCalendar", null);
		 	component.set("v.selectedMonth", null); 

			this.getDeliveryWindow(component, 
				( (newStartDate.month() == component.get("v.dwProcessingStartDate").month()) ? component.get("v.dwProcessingStartDate") : newStartDate).format('YYYY-MM-DD'), 
				function(calendar){
					var mostDistantDateAvailForDelivery = self.getMostDistantDateAvailForDelivery(calendar.months[0]);
					component.set("v.dwCurrentMonthStartDate", mostDistantDateAvailForDelivery.clone().startOf('month').format('YYYY-MM-DD'));
					component.set("v.selectedMonth", calendar.months[0]);  
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
    changeFutureMonth : function(component, preferredDeliveryDate, success, failure) {
		//alert('futureDate isin3 ');
	 	var accountNumber = component.get("v.accountNumber");
	 	var rdcId = component.get("v.rdcId");
	 	var orderId = component.get("v.orderId");
	 	var orderLineId = component.get("v.orderLineId");
        var orderNumber= component.get("v.orderNumber");
        var futureDate= component.get("v.futureDate");
        var profitCenter= component.get("v.profitCenter");
       //alert('futureDate isin2 '+component.get("v.futureDate"));
       	var action = component.get("c.getDeliveryCalendarDays");  
		action.setParams({
	        preferredDeliveryDate : futureDate,
	        orderId : orderId,
	        orderLineID : orderLineId,
	        accountNumber : accountNumber,
	        rdcId : rdcId,
            orderNumber:orderNumber,
            profitCenter:profitCenter,
           // futureDate:futureDate,
            shipToAddr:component.get("v.shipToAddr")
            
	    });

	    action.setCallback(this, function(response) {
			var state = response.getState();
            //alert('state is --'+state);
			if (state === "SUCCESS") {
				var callResponse = response.getReturnValue(); 
               //alert('callResponse in DeliveryWindowLookupserviceController'+JSON.stringify(callResponse));
                console.log('callResponse in DeliveryWindowLookupserviceController'+JSON.stringify(callResponse));
				if(callResponse.isSuccess == true){	
                    
					if (!$A.util.isEmpty(callResponse.calendar)){					
			            if (success) {
			                success.call(this, callResponse.calendar);
                            component.set("v.calendarData", callResponse);
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
     changeCurrentMonth : function(component,movementDirection) {
         //alert('2');
       /* console.log('movementDirection-->'+movementDirection);
		var deliveryCalendar = component.get("v.deliveryCalendar");
        console.log('deliveryCalendar-->'+JSON.stringify("v.deliveryCalendar"));
	 	component.set("v.selectedMonth", deliveryCalendar.months[0]); 
         //component.set("v.deliveryCalendar", calendar);
        console.log('selected-->'+JSON.stringify("v.selectedMonth"));*/
         var self = this;
	 	var newMonthIndex = component.get("v.selectedMonth").index - component.get("v.selectedMonth").index;
         //alert('newMonthIndex--'+newMonthIndex);
        //alert('newMonthIndex  '+newMonthIndex);
	 	if (this.isDeliveryWindowCalloutRequired(component, newMonthIndex)){
	 		var newStartDate = this.getStartDateForMonthIndex(component, newMonthIndex);
			//alert('newStartDate--'+newStartDate);
			component.set("v.isLoading", true);
		 	component.set("v.deliveryCalendar", null);
		 	component.set("v.selectedMonth", null); 

			this.getDeliveryWindow(component, 
				( (newStartDate.month() == component.get("v.dwProcessingStartDate").month()) ? component.get("v.dwProcessingStartDate") : newStartDate).format('YYYY-MM-DD'), 
				function(calendar){
					var mostDistantDateAvailForDelivery = self.getMostDistantDateAvailForDelivery(calendar.months[0]);
					component.set("v.dwCurrentMonthStartDate", mostDistantDateAvailForDelivery.clone().startOf('month').format('YYYY-MM-DD'));
					component.set("v.selectedMonth", calendar.months[newMonthIndex]);  
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
})