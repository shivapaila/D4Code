({
	init : function(component, event, helper) {
      //  alert('date entered ');
     // var itemss= component.get("v.lineItemMap");
       
      // alert('test'+JSON.stringify(itemss));
       // helper.tresholdAvailableDays(component, event, helper);
        helper.DeliveryHelperMethod(component, event, helper);
		var deliveryMode = component.get('v.deliveryMode');
		var dwProcessingStartDate = ((['DS','TW'].indexOf(deliveryMode) > -1) ? moment().tz($A.get("$Locale.timezone")).startOf('day') : moment().tz($A.get("$Locale.timezone")).startOf('day').clone().add(1, 'days'));
		var lineItemDeliveryDate = !$A.util.isEmpty(component.get("v.lineItemDeliveryDate")) ? moment(component.get("v.lineItemDeliveryDate")).startOf('day') : null;
		component.set("v.dwProcessingStartDate", dwProcessingStartDate);

		component.set("v.isLoading", true);
		var isValidLineItemDeliveryDate = false;  

    	if (!$A.util.isEmpty(lineItemDeliveryDate) && (lineItemDeliveryDate.month() != dwProcessingStartDate.month())){
     		isValidLineItemDeliveryDate = true;
    		helper.getDeliveryWindow(component, lineItemDeliveryDate.clone().startOf('month').format('YYYY-MM-DD'), function(calendar){
    			var mostDistantDateAvailForDelivery = helper.getMostDistantDateAvailForDelivery(calendar.months[0]);
    			component.set("v.dwCurrentMonthStartDate", mostDistantDateAvailForDelivery.clone().startOf('month').format('YYYY-MM-DD'));
				component.set("v.selectedMonth", calendar.months[0]);  
                component.set("v.TselectedMonth", calendar.Tmonths[0]);
               // alert('treshold Days'+JSON.stringify(calendar.Tmonths[0]));
				component.set("v.deliveryCalendar", calendar);	    		
    			component.set("v.isLoading", false);
                
    		},
			function(message){
				component.set("v.isLoading", false);
			});	 
           
    	}
        

	    helper.getDeliveryWindow(component, dwProcessingStartDate.format('YYYY-MM-DD'), function(calendar){
	    	var mostDistantDateAvailForDelivery = helper.getMostDistantDateAvailForDelivery(calendar.months[0]);
	    	component.set("v.dwEarliestMonthStartDate", mostDistantDateAvailForDelivery.clone().startOf('month').format('YYYY-MM-DD'));
	    	if (!isValidLineItemDeliveryDate){
		    	component.set("v.dwCurrentMonthStartDate", mostDistantDateAvailForDelivery.clone().startOf('month').format('YYYY-MM-DD'));
				component.set("v.selectedMonth", calendar.months[0]);
                component.set("v.TselectedMonth", calendar.Tmonths[0]);
              //  alert('treshold Days'+JSON.stringify(calendar.Tmonths[0]));
				component.set("v.deliveryCalendar", calendar);
				component.set("v.isLoading", false);
			}	    		
	    }, function(message){
	    	component.set("v.isLoading", false);
	    });
      //   alert('deliveryCalendar'+component.get("v.deliveryCalendar"));
	},
	nextMonth : function(component, event, helper) {
	 	helper.changeSelectedMonth(component, 1);	    
	},
	previousMonth : function(component, event, helper) {
	 	helper.changeSelectedMonth(component, -1);	    
	},
	defaultCloseAction : function(component, event, helper) {  
        component.destroy();
    },
    alertmessage : function(component, event, helper) {
        
    var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : 'Warning',
            message: 'Selected Day Is not Available For Threshold Delivery.Threshold Delivery Days Are Marked on The Calander With green color.To select a delivery day not flagged for threshold the delivery service level must be updated First',
            duration:' 5000',
            key: 'info_alt',
            type: 'warning',
            mode: 'sticky'
        });
        toastEvent.fire();          
    },
    returnDeliveryDate : function(component, event, helper) {	
		var deliveryDate= event.currentTarget.dataset.date;
       // alert('deliveryDate'+deliveryDate);
		var deliveryMode = component.get("v.deliveryMode");
        //REQ-451
		component.set('v.lineItemDeliveryDate', deliveryDate);
		//Fire Delivery Window Event
		helper.fireDeliveryWindowEvent(component, deliveryDate);
        //REQ-451
        if(!component.get("v.isConciergeApp")){
			component.destroy();
		}

    }
})