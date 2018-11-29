({
	changeSelectedMonth : function(component, movementDirection) {
			
	 	var deliveryCalendar = component.get("v.deliveryCalendar");
	 	var selectedMonth = component.get("v.selectedMonth");
	 	var selectedMonthIndex = selectedMonth.index;	 	
	 	selectedMonthIndex = selectedMonthIndex + movementDirection;
	 	component.set("v.selectedMonth", deliveryCalendar.months[selectedMonthIndex]); 
	}
})