({
    Init: function(component, event, helper) {
      	helper.getStoreInfo(component, event, helper);        
        var action = component.get("c.getShoppingCartLineItems");  
        action.setParams({
            "accountId" 	: component.get('v.GuestId')            
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
             //  alert('items'+JSON.stringify(items));
            }
        });
        $A.enqueueAction(action);
    },
  
    updateLineItems: function(component, event, helper) {
        var selectedItem = event.currentTarget; 
        var selectedkey = selectedItem.dataset.record;
        var items=[];
        var bool=false;
        var map=component.get('v.lineItemMap');
        
        for(var key in map){
            
            if(map[key].key == selectedkey){
                items=map[key].value;                
            }            
        }
        
        var action = component.get("c.updateAsFutureDatedSale");  
            action.setParams({
                "selectedItems": items,
                "accId":component.get('v.GuestId'),
                "bool":true
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
                    
                    //$A.get('e.force:refreshView').fire();
                }
            });
            $A.enqueueAction(action);
    },
    unMark: function(component, event, helper) {
        var selectedItem = event.currentTarget; 
        var selectedkey = selectedItem.dataset.record;
        var items=[];
        var bool=false;
        var map=component.get('v.lineItemMap');        
        for(var key in map){            
            if(map[key].key == selectedkey){
                items=map[key].value;
                
            }
            
        }
        
        var action = component.get("c.updateAsFutureDatedSale");  
            action.setParams({
                "selectedItems": items,
                "accId":component.get('v.GuestId'),
                "bool":false
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
                    
                    
                }
            });
            $A.enqueueAction(action);
    }
    
})