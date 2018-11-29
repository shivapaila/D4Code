({
init : function(component, event, helper) {
 //  alert('getDeliveryWindow');
  
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
				component.set("v.deliveryCalendar", calendar);
				component.set("v.isLoading", false);
			}	    		
	    }, function(message){
	    	component.set("v.isLoading", false);
	    });
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
})