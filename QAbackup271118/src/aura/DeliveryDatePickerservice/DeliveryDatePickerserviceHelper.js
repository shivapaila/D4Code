({
    getCalendar : function(component, helper,selectedDate) {
        
        if(selectedDate != ''){
             component.set("v.showCalender",true);
        $A.createComponent(
            "c:DeliveryWindowLookup",
            {
              
                "accountNumber": component.get('v.accountNumber'),
                "rdcId": component.get('v.rdcId'),
                "selectedDeliveryDate": selectedDate,
                "orderLineId":component.get('v.lineItem')[0].Id
            },
            function(newcomponent){
                if (component.isValid()) {
                    var body = component.get("v.body");
                    body.push(newcomponent);
                    component.set("v.body", body);   
                    
                    
                }
               
            }            
        );
        
    }
        else{
            alert('Select a Desired Delivery Date');
        }
    }
})