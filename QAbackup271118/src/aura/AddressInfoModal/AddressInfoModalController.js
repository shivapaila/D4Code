({
    doInit :function(component, event, helper) {
         var opp = component.get("v.opp");
        console.log('opp'+opp);
       if(!$A.util.isEmpty(opp["Cart_ZipCode__c"])){
            
            component.find("zipCode").set("v.value",  opp["Cart_ZipCode__c"]);
        }
        if(!$A.util.isEmpty(opp["Cart_State__c"])){
            
            component.find("stateOption").set("v.value", opp["Cart_State__c"]);
        }
    },
    updateAddressInfo: function(component, event, helper) {
        var opp = component.get("v.opp");
        opp["Cart_ZipCode__c"]= component.find("zipCode").get("v.value");
        
         opp["Cart_State__c"]= component.find("stateOption").get("v.value");
        if($A.util.isEmpty(opp["Cart_ZipCode__c"]) || $A.util.isEmpty( opp["Cart_State__c"])){
        
		    helper.showToast("error", 'Customer Address Info are missed', component,
                                         'Please input both zipcode and state for customer.');     
            return;
        }
       var action = component.get("c.saveCartAddressInfo");
        action.setParams({"opp" : opp});
        
        action.setCallback(this, function(response){
                    var rtnValue = response.getReturnValue();
            if(rtnValue=='Success'){
                component.getEvent("NotifyParentAddressInfoCloseModal").fire();
                   // $A.get("e.force:refreshView").fire();
                var event = component.getEvent("shoppingCartLineItemEvent");
                event.setParams({"action" :  component.get("v.CART_ACTION_UPDATE_ADDRESS") });
                event.fire();
            }
           
        });            
        action.setBackground();
        $A.enqueueAction(action); 
        
    }
   
})