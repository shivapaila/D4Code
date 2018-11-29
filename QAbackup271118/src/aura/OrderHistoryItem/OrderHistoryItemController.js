({
	showOrder : function(component, event, helper) {

        $A.createComponent("c:ViewOrderDetails",
                           { "order": component.get("v.order") },
                           function(content, status) {
                               //alert('status is '+status);
                               if (status === "SUCCESS") {
                                   component.find('overlayLib').showCustomModal({
                                       header: "Sales Order: " + component.get("v.order.phhSalesOrder__c") + " - " + "$" + component.get("v.order.phhPurchaseValue__c"),
                                       body: content,
                                       showCloseButton: true,
                                       cssClass: "mymodal",
                                   })
                                   
                               }
                               
                           });
                        
	}
})