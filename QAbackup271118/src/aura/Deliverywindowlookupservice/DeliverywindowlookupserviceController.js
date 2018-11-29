({
	init : function(component, event, helper) {
     // alert('enterd in DeliveryWindowLookupserviceController');
       // alert('ordernumber isin1 '+component.get("v.orderNumber"));
       	var deliveryMode = component.get('v.deliveryMode');
        var today = new Date();
        var dayDigit = today.getDate();
		var dwProcessingStartDate = ((['DS','TW'].indexOf(deliveryMode) > -1) ? moment().tz($A.get("$Locale.timezone")).startOf('day') : moment().tz($A.get("$Locale.timezone")).startOf('day').clone().add(-dayDigit+1, 'days'));
		//alert('dwProcessingStartDate-->'+dwProcessingStartDate);
        var lineItemDeliveryDate = !$A.util.isEmpty(component.get("v.lineItemDeliveryDate")) ? moment(component.get("v.lineItemDeliveryDate")).startOf('day') : null;
		//alert('lineItemDeliveryDate-->'+lineItemDeliveryDate);
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
    
    currentMonth : function(component, event, helper) {
      
	 	var deliveryMode = component.get('v.deliveryMode');
        var today = new Date();
        var dayDigit = today.getDate();
		var dwProcessingStartDate = ((['DS','TW'].indexOf(deliveryMode) > -1) ? moment().tz($A.get("$Locale.timezone")).startOf('day') : moment().tz($A.get("$Locale.timezone")).startOf('day').clone().add(-dayDigit+1, 'days'));
		//alert('dwProcessingStartDate-->'+dwProcessingStartDate);
        var lineItemDeliveryDate = !$A.util.isEmpty(component.get("v.lineItemDeliveryDate")) ? moment(component.get("v.lineItemDeliveryDate")).startOf('day') : null;
		//alert('lineItemDeliveryDate-->'+lineItemDeliveryDate.month());
        component.set("v.dwProcessingStartDate", dwProcessingStartDate);
		//alert('dwProcessingStartDate1-->'+dwProcessingStartDate.month());
		component.set("v.isLoading", true);
		var isValidLineItemDeliveryDate = false;  

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
    
   futureMonth : function(component, event, helper) {
      // alert('enterd future');
 	  var deliveryMode = component.get('v.deliveryMode');
		var dwProcessingStartDate = ((['DS','TW'].indexOf(deliveryMode) > -1) ? moment().tz($A.get("$Locale.timezone")).startOf('day') : moment().tz($A.get("$Locale.timezone")).startOf('day').clone().add(1, 'days'));
		//alert('dwProcessingStartDate-->'+dwProcessingStartDate);
       var lineItemDeliveryDate = !$A.util.isEmpty(component.get("v.lineItemDeliveryDate")) ? moment(component.get("v.lineItemDeliveryDate")).startOf('day') : null;
		//alert('lineItemDeliveryDate-->'+lineItemDeliveryDate);
       component.set("v.dwProcessingStartDate", dwProcessingStartDate);
		//alert('enterd future1');
		component.set("v.isLoading", true);
		var isValidLineItemDeliveryDate = false;  

    	if (!$A.util.isEmpty(lineItemDeliveryDate) && (lineItemDeliveryDate.month() != dwProcessingStartDate.month())){
     		isValidLineItemDeliveryDate = true;
    		helper.changeFutureMonth(component, lineItemDeliveryDate.clone().startOf('month').format('YYYY-MM-DD'), function(calendar){
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

	    helper.changeFutureMonth(component, dwProcessingStartDate.format('YYYY-MM-DD'), function(calendar){
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
    
	previousMonth : function(component, event, helper) {
	 	helper.changeSelectedMonth(component, -1);	    
	},
    
	defaultCloseAction : function(component, event, helper) {  
        component.destroy();
    },
    
 
    displaySection1 : function(component, event, helper) {
       var selectedDateString= event.currentTarget.dataset.date;   
       component.set("v.displayedSe",selectedDateString);
        //var userRoleId = component.get("v.userProfileid");
        var userProfileIdrep = component.get("v.calendarData");
     	 //alert('userProfileIdrep'+userProfileIdrep);
         if(userProfileIdrep==='true'){
       component.set("v.displayedSection2","true");
         }
        else{
        component.set("v.displayedSection2","false");
        document.getElementById('error').innerHTML="Only Managers with override authority can schedule this date";
        return;
        }
    },
    
    
    confirmUserProfile : function(component, event, helper) {        
        var selectedDateString=component.get("v.displayedSe");
		var currentOrderId = component.get("v.orderId");
		var currentOrderLineId = component.get("v.orderLineId");
		var deliveryDateSelectedEvent = $A.get("e.c:DeliveryDateSelected");   
		deliveryDateSelectedEvent.setParams({
		    "deliveryDate": selectedDateString, 
		    "orderID": currentOrderId,
		    "orderLineId": currentOrderLineId 
		}).fire();
		component.destroy();
        component.set("v.displayedSection2","false");
        
       
    },
    
    
   returnDeliveryDate : function(component, event, helper) {
       
      
		var selectedDateString= event.currentTarget.dataset.date;
		var currentOrderId = component.get("v.orderId");
		var currentOrderLineId = component.get("v.orderLineId");
		var deliveryDateSelectedEvent = $A.get("e.c:DeliveryDateSelected");
		deliveryDateSelectedEvent.setParams({
		    "deliveryDate": selectedDateString, 
		    "orderID": currentOrderId,
		    "orderLineId": currentOrderLineId 
		}).fire();
		component.destroy();
      
    },
    
	 openPop : function(component, event, helper) {
         var selectedDateStrings= event.currentTarget.dataset.date;
        // alert('selectedDateStrings--'+selectedDateStrings);
         component.set("v.popupDate",selectedDateStrings);
		 var cmpTarget = component.find('pop');
         $A.util.addClass(cmpTarget, 'slds-show');
       	 $A.util.removeClass(cmpTarget, 'slds-hide');
       	//	var orderNumber= component.get("v.orderNumber");
      		var selectedDateStrings= event.currentTarget.dataset.date;
        	 //alert('selectedDateStrings-->'+selectedDateStrings);	
        	/*var actiondata = component.get("c.getApiResponse1");
            	actiondata.setParams({
               		orderNumber:orderNumber,
               		selectedDateStrings:selectedDateStrings
                         			});
        		 actiondata.setCallback(this, function(response){ 
                //  component.find("Id_spinner").set("v.class" , 'slds-hide');
                    var state = response.getState();
                    // alert('state is '+state);
                  		 if (state === "SUCCESS") {
                             var callResponse = JSON.parse(response.getReturnValue());
                        	//alert('callResponse'+JSON.stringify(callResponse));
                             console.log('callResponse'+JSON.stringify(callResponse));
                             component.set("v.PopuprResponse", callResponse);
                         }
                      	else{
                   		 var errorToast = $A.get("e.force:showToast");
                    		errorToast.setParams({"message": response.getError()[0].message, "type":"error", "mode":"sticky"});
                    		errorToast.fire();
                			}
                        	});
                    
           $A.enqueueAction(actiondata); */
        
},

closePop : function(component, event, helper) {
        var cmpTarget = component.find('pop');
        $A.util.addClass(cmpTarget, 'slds-hide');
        $A.util.removeClass(cmpTarget, 'slds-show');
       // var selectedItem = event.currentTarget;
       // var Id = selectedItem.dataset.record;
},
    
closeSec : function(component, event, helper) {
     component.set("v.displayedSection2",false);
}

  
})