({
    Init: function(component, event, helper) {
        
        var today = new Date();
        var dd = today.getDate();
        var mm = today.getMonth()+1; //January is 0!
        var yyyy = today.getFullYear();
        
        if(dd<10) {
            dd = '0'+dd
        } 
        
        if(mm<10) {
            mm = '0'+mm
        } 
        
        //today = mm + '/' + dd + '/' + yyyy;
        var todayDate = yyyy + '-' + mm + '-' + dd ;
        dd = today.getDate()+1;
        
        var tomorrow = yyyy + '-' + mm + '-' + dd ;
        component.set('v.selectedDesiredDeliveryDate',tomorrow);
        if(component.get('v.deliveryMode') == 'DS' || component.get('v.deliveryMode') == 'TW'){
            component.set('v.selectedDesiredDeliveryDate',todayDate);
            
        }
       
    },
    getDeliveryDate : function(component, event, helper) {
        var selectedItem = event.currentTarget; 
        var RecordId = selectedItem.dataset.record;
        
        if(component.get('v.lineItem').length > 0){
            component.set('v.selectedLineItems',component.get('v.lineItem'));
        }
        var id=event.currentTarget.id;
       
        var selectedDate = document.getElementById(RecordId).value;
        component.set('v.selectedDeliveryDate',selectedDate);
        
        component.set("v.body", []); 
        helper.getCalendar(component, helper,selectedDate);
        
    },
    handleDeliveryDateSelected:function(component, event, helper) 
    {
        
        if(component.get('v.selectedLineItems').length > 0)
        {
            
            var action = component.get("c.updateShoppingCartLineItems");  
            action.setParams({
                "selectedDate" 	: event.getParam("deliveryDate"),
                "selectedItems": component.get('v.selectedLineItems'),
                "accId":component.get('v.GuestId')
            });
            action.setCallback(this, function(a) {
                
                var rtnValue  = a.getReturnValue();
                var state = a.getState();
                
                if (component.isValid() && state === "SUCCESS") 
                {
                    
                    var items = [];
                    var map = rtnValue;
                    for(var key in map){
                        items.push({value:map[key], key:key,selected: false});
                    }
                    component.set('v.lineItemMap',items);
                    
                    component.set('v.selectedDesiredDeliveryDate',event.getParam("deliveryDate"));
                    
                    component.set("v.showdatepicker",false);
                    component.set("v.buttonClicked",false);
                    //event to notify CheckoutSummary refresh when DeliveryDate is updated
                    var eventComponent = component.getEvent("DeliveryDateChangeNotifyToCheckoutSummary");
                    eventComponent.setParams({ "notifyParam":  true});
                    eventComponent.fire(); 
                }
            });
            $A.enqueueAction(action);
            
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
        
        var selectedDate = component.get('v.selectedDeliveryDate');
       
        component.set("v.body", []); 
        helper.getCalendar(component, helper,selectedDate);
        
    },
    goBack: function(component, event, helper) {
        component.set("v.buttonClicked",false);
        component.set("v.showdatepicker",false);
		component.set('v.selectedLineItems',[]);
        
    }
})