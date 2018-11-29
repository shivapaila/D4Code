({
    
	doInit : function(component, event, helper) {
       
    	helper.loadSalesOrder(component, event, helper);
    	
    },
    
     openPop : function(component, event, helper) {
    
            var cmpTarget = component.find('pop');
            
            $A.util.addClass(cmpTarget, 'slds-show');
            $A.util.removeClass(cmpTarget, 'slds-hide');
            var ctarget = event.currentTarget;
            var id_str = ctarget.dataset.value;
            component.set('v.PopupsoId',id_str);   
            var actiondata = component.get("c.getSalesOrderLineItem");
                
                  actiondata.setParams({
                   "salesOrderId" : id_str
                                         });
            
                      actiondata.setCallback(this, function(response){    
                        var state = response.getState();
                      
                        if (state === "SUCCESS") {
                            var callResponse = response.getReturnValue();
                            //alert('callResponse'+JSON.stringify(callResponse));
                            component.set("v.SalesOrdLineItemData", callResponse);
                             }
                        else{
                        var errorToast = $A.get("e.force:showToast");
                        errorToast.setParams({"message": response.getError()[0].message, "type":"error", "mode":"sticky"});
                        errorToast.fire();
                    }
                            });
                        
                         $A.enqueueAction(actiondata);
            
    },

    closePop : function(component, event, helper) {
            var cmpTarget = component.find('pop');
            $A.util.addClass(cmpTarget, 'slds-hide');
            $A.util.removeClass(cmpTarget, 'slds-show');
           // var selectedItem = event.currentTarget;
           // var Id = selectedItem.dataset.record;
    
    },
	navigateToRecord : function (component, event, helper) {
        
        //window.location='/'+component.get("v.data").Id+'';
        var navEvt = $A.get("e.force:navigateToURL");
        //alert('navEvt');
        console.log('navEvt===>'+navEvt);
        navEvt.setParams({
            "url": '/lightning/r/SalesOrder__x/' + component.get("v.PopupsoId") + '/view'
        });
        navEvt.fire();
    }	
})