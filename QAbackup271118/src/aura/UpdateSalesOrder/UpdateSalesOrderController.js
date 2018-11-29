({
    doInit : function(component, event, helper) {
        //show loading spinner
        component.set("v.isLoading", true);
        var currentOrderId = component.get("v.recordId");
        var action = component.get("c.getOrderData");
            action.setParams({
            salesforceOrderId : currentOrderId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var callResponse = response.getReturnValue();	
                var vip = callResponse.vip;
                var lib = callResponse.lib;
                //var WindowEndPM
               // alert(' call response ---'+callResponse.WindowEnd);
               // var sLevel = callResponse.servicelevel;
                
             //   console.log("sLevel-->", sLevel);
               /* if(sLevel == "THD"){
                    component.set("v.LevelTHD",true);
               component.set("v.serLevel",true);
                    console.log("sLevelThreshold-->", sLevel);
                }
                else if(sLevel == "PDI"){
                    component.set("v.LevelPDI",true);
                 component.set("v.serLevel",true);
                    console.log("sLevelPDI-->", sLevel);
                } 
                    else{
                      component.set("v.isGetDates",false);
                    }*/
                component.set("v.salesOrder", callResponse);
                component.set("v.vip", vip);
                component.set("v.lib", lib);
                //console.log("deliveryDate11-->", component.get("v.deliveryDate"));
                //alert(callResponse.WindowBegin);
               
                if(callResponse.WindowBegin != null && callResponse.WindowBegin.includes("AM") ){
					var StartTime= callResponse.WindowBegin.split(' ');
         			var StartTimeinx= StartTime[0];
                    var StartTimeSplit= StartTimeinx.split(':'); 
                    var StartTimeSplitInxOne= StartTimeSplit[1];
                    var StartTimeSplitInx = StartTimeSplit[0];   
					var StartTimeAM = (StartTimeSplitInx ) + ':' + (StartTimeSplitInxOne) ;
                    component.set("v.salesOrder.WindowBegin", StartTimeAM);
                   }
                if(callResponse.WindowEnd != null && callResponse.WindowEnd.includes("AM") ){
                    var EndTime= callResponse.WindowEnd.split(' ');
         			var EndTimeinx=EndTime[0];
                    var EndTimeSplit= EndTimeinx.split(':'); 
                    var EndTimeSplitInxOne= EndTimeSplit[1];
                    var EndTimeSplitInx = EndTimeSplit[0];   
                    var EndTimeAM = (EndTimeSplitInx) + ':' + (EndTimeSplitInxOne) ;
                    component.set("v.salesOrder.WindowEnd", EndTimeAM);
                   }
               if(callResponse.WindowBegin != null && callResponse.WindowBegin.includes("PM"))
               {
                    var StartTime= callResponse.WindowBegin.split(' ');
                    var StartTimeinx=StartTime[0];
                    var StartTimeSplit= StartTimeinx.split(':'); 
                    var StartTimeSplitInxOne= StartTimeSplit[1];
                    var StartTimeSplitInx = StartTimeSplit[0];   
                     
                    var StartTimePM = (+StartTimeSplitInx + 12 ) + ':' + (StartTimeSplitInxOne) ;
                    component.set("v.salesOrder.WindowBegin", StartTimePM);
                   }
                if(callResponse.WindowEnd != null && callResponse.WindowEnd.includes("PM") ){
                    
                    
                    var EndTime= callResponse.WindowEnd.split(' ');
         			
                    var EndTimeinx=EndTime[0];
                    var EndTimeSplit= EndTimeinx.split(':'); 
                    var EndTimeSplitInxOne= EndTimeSplit[1];
                    var EndTimeSplitInx = EndTimeSplit[0];   

                    var EndTimePM = (+EndTimeSplitInx + 12 ) + ':' + (EndTimeSplitInxOne) ;
                     //alert('EndTimePM is --'+EndTimePM);
                    component.set("v.salesOrder.WindowEnd", EndTimePM);
                }
                
                //alert('test');
                //if(component.find("deliveryDate").get("v.value")=="1990-01-01")
                if(component.get("v.salesOrder.currentDeliverydate") == "1990-01-01")
                {
                    console.log("deliveryDate-->", component.get("v.deliveryDate"));
                    component.set("v.salesOrder.asap",true);
                }
                if(component.get("v.salesOrder.asap") == true)
                {
                    component.set("v.isGetDates", false);
                    component.set("v.isTime", true);
                    component.set("v.isDelDate", true);
                }
                if(component.get("v.salesOrder.hot") ==true)
                {
                    component.set("v.isTime", false);
                    component.set("v.isDelDate", false);
                    component.set("v.isGetDates", true);
                }
                else if(component.get("v.salesOrder.hot") ==false)
                {
                    component.set("v.isTime", true);
                    component.set("v.salesOrder.WindowBegin", "7:00");
            		component.set("v.salesOrder.WindowEnd", "19:00");
                }
                console.log("salesorder" , JSON.stringify(response.getReturnValue()));
            }
            else{
                var errorToast = $A.get("e.force:showToast");
                errorToast.setParams({"message": response.getError()[0].message, "type":"error",  "mode":"dismissible", "duration":10000});
                errorToast.fire();
            }
            //hide loading spinner
            component.set("v.isLoading", false);
        });
        
        $A.enqueueAction(action);
    },
    checkASAP : function(component, event, helper) {
        var asp = component.get("v.salesOrder.asap");
        //alert('asp----'+component.get("v.salesOrder.asap"));
        if(asp==true)
        {
            component.set("v.salesOrder.hot", false);
            var tst= component.set("v.isGetDates", false);
            //alert('tst----'+tst);
            component.set("v.isTime", true);
            component.set("v.deliveryDate","1990-01-01");
            component.set("v.salesOrder.currentDeliverydate","1990-01-01");
            component.set("v.deliveryDateUpdated",true);
            component.set("v.isDelDate", true);
            component.set("v.isResch",false);
            component.set("v.salesOrder.WindowBegin", '');
            component.set("v.salesOrder.WindowEnd", '');
            //var changeElement = component.find("gadID");
            // by using $A.util.toggleClass add-remove slds-hide class
            //$A.util.toggleClass(changeElement, "slds-hide");
            console.log('deldate' + component.get("v.salesOrder.currentDeliverydate"));
        } 
        else if(asp==false)
        {
            component.set("v.isGetDates", true);
            component.set("v.isTime", false);
            component.set("v.salesOrder.WindowBegin", '');
            component.set("v.salesOrder.WindowEnd", '');
            component.set("v.isDelDate", false);
        }
    },
    checkHot : function(component, event, helper) {
        var soHot = component.get("v.salesOrder.hot");
        if(soHot==true)
        {
            component.set("v.salesOrder.asap", false);
            component.set("v.isGetDates", true);
            component.set("v.isTime", false);
            component.set("v.isDelDate", false);
            //component.find("deliveryDate").set("v.value","01-01-1900");
            //var changeElement = component.find("gadID");
            // by using $A.util.toggleClass add-remove slds-hide class
            //$A.util.toggleClass(changeElement, "slds-hide");
        } 
        else if(soHot==false)
        {
           component.set("v.salesOrder.WindowBegin", "7:00");
            component.set("v.salesOrder.WindowEnd", "19:00");
            component.set("v.isTime", true);
            component.set("v.isGetDates", true);
            //component.set("v.salesOrder.isHOTReset", false);
        }
    },
    checkDeliveryDate : function(component, event, helper) {
          console.log("isResch", component.get("v.isResch"));
        component.set("v.deliveryDateUpdated",true); 
        component.set("v.isResch",false);
              console.log("isResch", component.get("v.isResch"));
    },
    validateStartTime : function(component, event, helper) {
        var sTime = component.get("v.salesOrder.WindowBegin");
        var eTime = component.get("v.salesOrder.WindowEnd");
         if((sTime != null || sTime != '') && (eTime != null || eTime != '') && sTime > eTime)
        {
            document.getElementById('error').innerHTML="Start Time Should be Lessthan End time.";
            return;
        }
    },
    validateEndTime : function(component, event, helper) {
        var sTime = component.get("v.salesOrder.WindowBegin");
		var eTime = component.get("v.salesOrder.WindowEnd");
        
     	var StartTime;
        var StartTimeInxOne;
        var StartTimeInx;
        var EndTime;
        var EndTimeinxOne;
        var EndTimeinx;
        var StartTimeSplit;
        var EndTimeSplit;
        var StartTimeSplitInxOne;
        var StartTimeSplitInx;
        var EndTimeSplitInxOne;
        var EndTimeSplitInx;
        
        if(sTime != null)
        {
            
             StartTime= sTime.split(' ');
             StartTimeInxOne=StartTime[1];
             StartTimeInx=StartTime[0];
             StartTimeSplit= StartTimeInx.split(':');
             StartTimeSplitInxOne= StartTimeSplit[1]; 
        	 StartTimeSplitInx = StartTimeSplit[0];
        }
       if(eTime != null)
       {
           
         	EndTime= eTime.split(' ');
         	EndTimeinxOne=EndTime[1];
    	 	EndTimeinx=EndTime[0];
         	EndTimeSplit= EndTimeinx.split(':'); 
    	 	EndTimeSplitInxOne= EndTimeSplit[1];
		 	EndTimeSplitInx = EndTimeSplit[0]; 
       }
        
        if(EndTimeSplitInx != null && EndTimeSplitInxOne != null && StartTimeSplitInx != null && StartTimeSplitInxOne != null)
        {
            result = (+(EndTimeSplitInx*60) + (+EndTimeSplitInxOne)) - (+(StartTimeSplitInx*60) + (+StartTimeSplitInxOne));
            //alert('result------  '+result);
            
             if(result < 0 ) {
              
                document.getElementById('error').innerHTML="End Time Should be Greaterthan Start time.";
                
                 return;
             }
             else if(result < 30 && result > 0) {
              
                document.getElementById('error').innerHTML="Please save with a longer time window.";
                
                 return;
             }
            /* else if((sTime != null || sTime != '') && (eTime != null || eTime != '') && sTime > eTime)
           //  else if( sTime > eTime && sTime == null && eTime == null)
            {
                document.getElementById('error').innerHTML="End Time Should be Greater than Start time.";
                return;
            } */
        }
    },
    updateDeliveryDate : function(component, event, helper) {
        var order = component.get("v.salesOrder"); 		
        var orderIdFromEvent = event.getParam("orderID");
        var selectedDeliveryDateFromEvent = event.getParam("deliveryDate");
        var orderLineIdFromEvent = event.getParam("orderLineId");
        if(orderIdFromEvent == order.externalId){
            if(orderLineIdFromEvent == null){
                order.currentDeliverydate = selectedDeliveryDateFromEvent;
                component.set("v.salesOrder", order); 
                component.set("v.deliveryDateUpdated", true); 
                component.set("v.isResch",false);
                console.log("isResch", component.get("v.isResch"));
            }else if(order.lineItems != null){
                var arrayLength = order.lineItems.length;
                for (var i = 0; i < arrayLength; i++) {
                    if(order.lineItems[i].externalId == orderLineIdFromEvent){
                        order.lineItems[i].deliverydate = selectedDeliveryDateFromEvent;
                        component.set("v.salesOrder", order); 
                        break;
                    }
                }
            }			
        }
    },
    launchDeliveryDateLookup : function(component, event, helper) {
       //alert('launchDeliveryDateLookup1');
        
        var deliverydatefromorder = component.find("deliveryDate").get("v.value");
        //alert('deliverydatefromorder'+deliverydatefromorder);
        var isDate = component.get("v.isGetDates");
        var curDate = new Date().toISOString().slice(0, 10);
        //alert('curDate: ');
        console.log("curDate--->",curDate);
        //alert('isDate'+isDate);
        console.log("isDate--->",isDate);
        //	var desiredDeliveryDate = component.get("v.selectedDesiredDeliveryDate"); 
        if(deliverydatefromorder <= curDate){
            var order = component.get("v.salesOrder"); 
            var currentOrderId = order.externalId;
            var accountNumber = order.accountNumber;
            var rdcId = order.rdcId;
            var orderNumber = order.orderNumber;
            var profitCenter = order.profitCenter;
           // alert('salesorder number-->'+orderNumber);
            $A.createComponent(
                "c:Deliverywindowlookupservice",
                {
                    "orderId": currentOrderId,
                    "selectedDeliveryDate": curDate,
                    "lineItemDeliveryDate": curDate,
                    "accountNumber": accountNumber,
                    "isdate": isDate,
                    "rdcId": rdcId,
                    "orderNumber":orderNumber,
                    "profitCenter":profitCenter
                },
                function(msgBox){                
                    if (component.isValid()) {
                        var popupPlaceholder = component.find('deliveryWindowLookupPlaceHolder');
                        popupPlaceholder.set("v.body", msgBox); 
                    }
                }
            );
      }
        
       if(deliverydatefromorder > curDate){
            var order = component.get("v.salesOrder"); 
            var currentOrderId = order.externalId;
            var accountNumber = order.accountNumber;
            var rdcId = order.rdcId;
            var orderNumber = order.orderNumber;
            var profitCenter = order.profitCenter;
            //alert('salesorder number-->'+orderNumber);
            $A.createComponent(
                "c:Deliverywindowlookupservice",
                {
                    "orderId": currentOrderId,
                    "selectedDeliveryDate": deliverydatefromorder,
                    "lineItemDeliveryDate": deliverydatefromorder,
                    "accountNumber": accountNumber,
                    "isdate": isDate,
                    "rdcId": rdcId,
                    "orderNumber":orderNumber,
                    "profitCenter":profitCenter
                },
                function(msgBox){                
                    if (component.isValid()) {
                        var popupPlaceholder = component.find('deliveryWindowLookupPlaceHolder');
                        popupPlaceholder.set("v.body", msgBox); 
                    }
                }
            );
        }
            
        else{
            var errorToast = $A.get("e.force:showToast");
            errorToast.setParams({"message": $A.get("$Label.c.Update_Sales_Order_Missing_Desired_Delivery_Date"), "type":"error", "mode":"dismissible", "duration":10000});
            errorToast.fire();
        }
    },
    saveChanges : function(component, event, helper) {
        var salesOrder = component.get("v.salesOrder"); 
        var vip = component.get("v.vip");
        var lib = component.get("v.lib");
        
        var sTime = component.get("v.salesOrder.WindowBegin");
        var eTime = component.get("v.salesOrder.WindowEnd");
      
        console.log("val"+ JSON.stringify(vip));
        console.log("value"+ JSON.stringify(lib));
        console.log("valu"+ JSON.stringify(salesOrder));
        var slvl = component.get('v.radio4');
        console.log("slvl",slvl);
        var deliveryDateChanged = component.get("v.deliveryDateUpdated"); 
       // var deliverydate = component.find("deliveryDate").set("v.value","1990-01-01");
        var deliverydate = component.get("v.salesOrder.currentDeliverydate");
        //alert('deliveryDateChanged-----' + deliveryDateChanged);
        var asp = component.get("v.salesOrder.asap");
        var hot = component.get("v.salesOrder.hot");
        
        var sTime = component.get("v.salesOrder.WindowBegin");
        var eTime = component.get("v.salesOrder.WindowEnd");
     	var StartTime;
        var StartTimeInxOne;
        var StartTimeInx;
        var EndTime;
        var EndTimeinxOne;
        var EndTimeinx;
        var StartTimeSplit;
        var EndTimeSplit;
        var StartTimeSplitInxOne;
        var StartTimeSplitInx;
        var EndTimeSplitInxOne;
        var EndTimeSplitInx;
        var AfterMeridian ='AM';
		var PostMeridian='PM';
		var FixedTime = '420';
       	var EndFixedTime = '1140';
        
        if(sTime != null)
        {
             StartTime= sTime.split(' ');
             StartTimeInxOne=StartTime[1];
             StartTimeInx=StartTime[0];
             StartTimeSplit= StartTimeInx.split(':');
             StartTimeSplitInxOne= StartTimeSplit[1]; 
        	 StartTimeSplitInx = StartTimeSplit[0];
        }
       if(eTime != null)
       {
         	EndTime= eTime.split(' ');
         	EndTimeinxOne=EndTime[1];
            EndTimeinx=EndTime[0];
         	EndTimeSplit= EndTimeinx.split(':'); 
    	 	EndTimeSplitInxOne= EndTimeSplit[1];
		 	EndTimeSplitInx = EndTimeSplit[0]; 
       }
        
        if(EndTimeSplitInx != null && EndTimeSplitInxOne != null && StartTimeSplitInx != null && StartTimeSplitInxOne != null)
        {
            result = (+(EndTimeSplitInx*60) + (+EndTimeSplitInxOne)) - (+(StartTimeSplitInx*60) + (+StartTimeSplitInxOne));
            
             if(result < 0 ) {
              
                document.getElementById('error').innerHTML="End Time Should be Greaterthan Start time.";
                
                 return;
             }
            else if(result < 30 && result > 0) {
              
                document.getElementById('error').innerHTML="Please save with a longer time window.";
                
                 return;
             }
            
          /* else if((sTime != null || sTime != '') && (eTime != null || eTime != '') && sTime < eTime)
          //else if( sTime > eTime && sTime == null && eTime == null)
            {
                document.getElementById('error').innerHTML="End Time Should be Greaterthan Start time.";
                return;
            } */
        }
        //Start Time greater than 7 AM
        
    	 StartFixTime =  (+(StartTimeSplitInx*60) + (+StartTimeSplitInxOne));
        
        if( FixedTime > StartFixTime) {
		
            document.getElementById('error').innerHTML="Time Should Be Greater than 7AM"; 
            return;
		}
        
		 //End Time Lesser than 7 PM
		 
       EndFixTime = (+(EndTimeSplitInx*60) + (+EndTimeSplitInxOne));
       
    	if( EndFixedTime < EndFixTime) {
            
			document.getElementById('error').innerHTML="Time Should Be Lesser than 7PM"; 
            return;
		}
        
        //validate reason code is provided when delivery date is changed
        if(deliveryDateChanged == true && (salesOrder.rescheduleReasonCodeId == '' || salesOrder.rescheduleReasonCodeId == null)){
            /*	var errorToast = $A.get("e.force:showToast");
			errorToast.setParams({"message": "Reschedule reason must be selected.", "type":"error",  "mode":"dismissible", "duration":10000});
			errorToast.fire();
            */
            document.getElementById('error').innerHTML="Reschedule reason must be selected.";
            return;
        }
        else if(asp == true && deliveryDateChanged == true &&(salesOrder.rescheduleReasonCodeId == '' || salesOrder.rescheduleReasonCodeId == null))
        {
            document.getElementById('error').innerHTML="Reschedule reason must be selected.";
            return;
        }
        else if(asp == false && deliverydate == "1990-01-01")
        {
            document.getElementById('error').innerHTML="Delivery Date must be selected or ASAP must be select.";
            return;
        }
        else if(hot == true && (deliverydate == "1990-01-01" || deliverydate == null))
        {
            document.getElementById('error').innerHTML="Delivery Date must be selected.";
            return;
        }
        else if(hot == true && (sTime == null || sTime == ''))
        {
            document.getElementById('error').innerHTML="Window beign Time must be selected.";
            return;
        }
        else if(hot == true && sTime != null && (eTime == null || eTime == ''))
        {
            document.getElementById('error').innerHTML="Window end Time must be selected.";
            return;
        }
        //show loading spinner
        component.set("v.isLoading", true);
        var deserializedSalesOrder = JSON.stringify(salesOrder);
        console.log('json' +deserializedSalesOrder);
        var action = component.get("c.updateSalesOrder");
        action.setParams({
            salesOrderInfo : deserializedSalesOrder
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var callResponse = response.getReturnValue();
                if(callResponse.errorMessages != null){
                    var errorToast = $A.get("e.force:showToast");
                    errorToast.setParams({"message": callResponse.errorMessages, "type":"error",  "mode":"dismissible", "duration":10000});
                    errorToast.fire();
                }	
                if(callResponse.successMessages != null){
                    if(asp == true)
                    {
                        component.set("v.salesOrder.asap",true);
                    }
                    var successToast = $A.get("e.force:showToast");
                    successToast.setParams({"message": callResponse.successMessages, "type":"success", "mode":"dismissible", "duration":5000});
                    successToast.fire();
                }	
                if(callResponse.hasErrors == false){
                    $A.get("e.force:closeQuickAction").fire();																	
                }
            }
            else{
                var errorToast = $A.get("e.force:showToast");
                errorToast.setParams({"message": response.getError()[0].message, "type":"error",  "mode":"dismissible", "duration":10000});
                errorToast.fire();
            }
            //hide loading spinner
            component.set("v.isLoading", false);
        });
        $A.enqueueAction(action);		 
    },
    // EDQ added Validation logic
    handleSearchChange : function(component, event, helper) {
        var settings = helper.getSettings();
        helper.handleSearchChange(component, event, settings);
        helper.handleValidationStatus(component, settings);
    },
    // EDQ added Validation logic
    handleSuggestionNavigation :  function(component, event, helper) {
        var settings = helper.getSettings();
        var keyCode = event.which;
        if(keyCode == 13) { // Enter
            helper.acceptFirstSuggestion(component, settings);
        } else if(keyCode == 40) { //Arrow down
            helper.selectNextSuggestion(component, null, settings);
        } else if(keyCode == 38) { //Arrow up
            helper.hideAndRemoveSuggestions(component, settings);
        }
    },
    // EDQ event listener
    onSuggestionKeyUp : function(component, event, helper) {
        var settings = helper.getSettings();
        helper.onSuggestionKeyUp(component, event, settings);
    },
    // EDQ event listener
    handleResultSelect : function(component, event, helper) {
        var settings = helper.getSettings();
        helper.handleResultSelect(component, event, settings);
    },
    // EDQ event listener
    onAddressChanged : function(component, event, helper) {
        var settings = helper.getSettings();
        helper.handleValidationStatus(component, settings);
    },
    // EDQ event listener
    onElementFocusedOut : function (component, event, helper) {
        var settings = helper.getSettings();
        var useHasNotSelectedASuggestion = helper.isNull(event.relatedTarget) || event.relatedTarget.id.indexOf(settings.suggestionIndexClassPrefix) === -1;
        if (useHasNotSelectedASuggestion) {
            helper.hideAndRemoveSuggestions(component, settings);
        }
    }
})