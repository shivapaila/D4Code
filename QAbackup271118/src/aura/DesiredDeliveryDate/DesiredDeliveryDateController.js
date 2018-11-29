({
    doInit : function(component, event, helper) {
         component.set("v.newSelectedDeliveryDate",  component.get("v.selectedDeliveryDate"));
         //DEF-958 Desired Delivery Date Rquired for all Shipping types
         if(component.get("v.showCalendar")){
             component.set("v.newSelectedDeliveryDate",  component.get("v.selectedDeliveryDate"));
         }
         else{
             var today = new Date();
             var desiredDeliveryDate = moment(today).format('YYYY-MM-DD');
             component.set("v.newSelectedDeliveryDate",  desiredDeliveryDate);
         }
         //DEF-958 End
    }, 
    cancelDialog : function(component, helper) {
		component.getEvent("NotifyParentFinishedDesiredDate").setParams({"notifyParam":component.get("v.selectedDeliveryDate")}).fire();
              
    }, 
    goToNext : function(component, event, helper) {
        helper.goForward(component, helper);
    },
    setDesiredDeliveryDate: function(component, event, helper) {
       var deliveryDate = event.getParam("deliveryDate");
        component.set("v.newSelectedDeliveryDate", deliveryDate);
    }
})