({
	getDeliveryDate : function(component, event, helper) {
	
         component.set("v.newSelectedDeliveryDate",  component.get("v.selectedDeliveryDate"));	
	 	var action = component.get("c.getDesiredDeliveryCalendarDays");  
        action.setParams({"currentSelectedDate":component.get("v.selectedDeliveryDate")});
	    action.setCallback(this, function(response) {
			var state = response.getState();
			if (state === "SUCCESS") {
				var callResponse = response.getReturnValue(); 
				if(callResponse.isSuccess == true){	
					if(callResponse.calendar != null){					
						component.set("v.deliveryCalendar", callResponse.calendar); 
                        var hasSelectedMonth = false;
                        callResponse.calendar.months.forEach(function(item){
                            if(item["isCurrentSeletedDateMonth"]==true){
                                component.set("v.selectedMonth", item);  
								hasSelectedMonth = true;
                            }
                        });
                        
                        if(!hasSelectedMonth){
                             component.set("v.selectedMonth", callResponse.calendar.months[0]);  
                        }
					}
					else{
						component.set("v.selectedMonth", null);  
						component.set("v.deliveryCalendar", null); 
					}
					if(callResponse.message != null){
                        var deliveryDateSelectedEvent = $A.get("e.c:DeliveryDateSelected");
                        deliveryDateSelectedEvent.setParams({
                            "msg": callResponse.message 
                        }).fire();
						var warningToast = $A.get("e.force:showToast");
						warningToast.setParams({"message": callResponse.message, "type":"warning"});
						warningToast.fire();
					}
				}
				else{
					var errorToast = $A.get("e.force:showToast");
					errorToast.setParams({"message": callResponse.message, "type":"error", "mode":"sticky"});
					errorToast.fire();
				}				
			}
			else{
				var errorToast = $A.get("e.force:showToast");
				errorToast.setParams({"message":"Error in displaying calendar for selecting desired delivery date. Please contact system administrator with following error message" + response.getError(0).message, "type":"error", "mode":"sticky"});
				errorToast.fire();
			}

			//hide loading spinner
	 		component.set("v.isLoading", false);

		});

		$A.enqueueAction(action);
	},
	nextMonth : function(component, event, helper) {
	 	helper.changeSelectedMonth(component, 1);	    
	},
	previousMonth : function(component, event, helper) {
	 	helper.changeSelectedMonth(component, -1);	    
	},
    returnDeliveryDate : function(component, event, helper) {	
		var selectedDateString= event.currentTarget.dataset.date;
        component.set("v.newSelectedDeliveryDate",selectedDateString)
		var deliveryDateSelectedEvent =component.getEvent("DesiredDeliveryDateSelected");
		deliveryDateSelectedEvent.setParams({
		    "deliveryDate": selectedDateString
		}).fire();

    }
})