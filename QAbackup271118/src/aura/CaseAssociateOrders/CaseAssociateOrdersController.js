({
	initSO : function(component, event, helper) {
        //alert('Test--');
		var actionSalesOrderList = component.get("c.getSalesOrders"); 
        //alert('rec--'+component.get("v.recordId"));
        actionSalesOrderList.setParams({"caseId": component.get("v.recordId")});
        //alert('test----set');
        actionSalesOrderList.setCallback(this, function(response){
            //alert('test----cb'+response.getState())
        	if (component.isValid() && response.getState() === "SUCCESS") {
                //alert('res-----'+response.getReturnValue());
                component.set("v.salesOrders" , response.getReturnValue());
                console.log('lines' + JSON.stringify(response.getReturnValue()));
            } else {
                console.log('failed');
            }
        })
        
        $A.enqueueAction(actionSalesOrderList);
	},
    
    updateSalesOrder:function(component, event, helper){
    	//alert('test');
        var selectedSOEId=  component.find("mySelect").get("v.value");
    	//alert('selectSOID-1--'+selectedSOEId);
        var caseId = component.get("v.recordId");
        //alert('caseId---'+caseId);
       if(selectedSOEId != '' )
        {
            //alert('test in side');
            var actionUpdate = component.get('c.updateSalesOrderRecord');
            actionUpdate.setParams({
                      "SOId": selectedSOEId,
                      "caseId": caseId
                  });
            //alert('selectedSOEId--1--'+selectedSOEId)
        
            //alert('selectedSOEId--in--'+selectedSOEId)
            actionUpdate.setCallback(this, function(response){
                //alert('test----ss'+response.getState())
                if(component.isValid() && response.getState() === "SUCCESS")
                  {
                      var caseId = component.get("v.recordId");
                      //alert('caseId----ss'+caseId)
					  var navEvt = $A.get("e.force:navigateToSObject");
					  navEvt.setParams({ "recordId": caseId , "slideDevName": "detail" }); 
                      navEvt.fire(); 
                      var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                        title: "Success!",
                        message: "Successfully submitted Sales Orders!",
                        type: "success"
                        });
                        toastEvent.fire();
                      $A.get('e.force:refreshView').fire();
                  }
            })
            
            $A.enqueueAction(actionUpdate);
        }      
        else if(selectedSOEId == '' || selectedSOEId == null)
        { 
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title: "Error",
                message: "Please choose the Sales Order.",
                type: "Error"
            });
            toastEvent.fire();
        }
        //console.log('save ran');    
	}
})