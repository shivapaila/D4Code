({
    init: function(component, event, helper) {
        var deliveryMode = component.get('v.deliveryMode');
        var selectedDesiredDeliveryDate = ((['DS','TW'].indexOf(deliveryMode) > -1) ? moment().tz($A.get("$Locale.timezone")).startOf('day') : moment().tz($A.get("$Locale.timezone")).startOf('day').clone().add(1, 'days'));
        component.set('v.selectedDesiredDeliveryDate', selectedDesiredDeliveryDate);
    },
    handleDeliveryWindowEvent:function(component, event, helper) {
        // Set up the UI flags
        component.set("v.buttonClicked",false);
        component.set("v.showdatepicker",false);        
        component.set("v.isExecuting", true);
        // Handle delivery date
        var deliveryDate = event.getParam("deliveryDate");
        var deliveryMode = event.getParam("deliveryMode");
        if(component.get('v.selectedLineItems').length > 0){
            if ($A.util.isEmpty(deliveryDate)){
                helper.callItemCheck(component, function(response){
                    component.set("v.isExecuting", false);
                    var lineItemMap = response.getReturnValue();
                    // Extract delivery date for call item
                    var lineItems = lineItemMap[deliveryMode];
                    if (!$A.util.isEmpty(lineItems) && $A.util.isArray(lineItems) && lineItems.length>0){
                        deliveryDate = lineItems[0].DeliveryDate__c;
                    }
                    helper.postDeliveryDateUpdate(component, lineItemMap, deliveryDate);
                },
                function(response, message){
                    component.set("v.isExecuting", false);
                    helper.showToast("error", 'Unable to process delivery date', message);            
                });                

            } else {
                helper.updateDeliveryDate(component, deliveryDate, function(response){
                    component.set("v.isExecuting", false);
                    var lineItemMap = response.getReturnValue();
                    helper.postDeliveryDateUpdate(component, lineItemMap, deliveryDate);
                },
                function(response, message){
                    component.set("v.isExecuting", false);
                    helper.showToast("error", 'Unable to process delivery date', message);
                });   
            }
        }
    },
    pickdate: function(component, event, helper) {
        
        var selectedItem = event.currentTarget;
        var RecordId = selectedItem.dataset.record;
        var map = component.get('v.lineItemMap');
        for(var index in map){
            if(map[index].key == component.get('v.deliveryMode')){
                map[index].selected=true;
            }
            
        }
        component.set("v.buttonClicked",true);
        
        component.set('v.lineItemMap',map);
        
        if(component.get('v.lineItem').length > 0){
            component.set('v.selectedLineItems',component.get('v.lineItem'));
        }
        var selectedDate = component.get('v.selectedDesiredDeliveryDate');
    
        component.set("v.body", []); 
        helper.getCalendar(component, helper,selectedDate);
        
    },
    goBack: function(component, event, helper) {
        component.set("v.buttonClicked",false);
        component.set("v.showdatepicker",false);
        component.set('v.selectedLineItems',[]);
    }
})