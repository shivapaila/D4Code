({
    
	getSalesOrderData : function(component, event, helper) {
        
		var actionSORoutingData = component.get("c.soRoutingData"); 
        actionSORoutingData.setParams({soID : component.get("v.recordId")});
       
        actionSORoutingData.setCallback(this, function(response){
            
            var state = response.getState();
   			//alert('state-----'+state);
			if (state === "SUCCESS") { 
				var callResponse = response.getReturnValue();
               
                //alert('orders------'+callResponse);
                if(callResponse != null)
                {
                    component.set("v.orders", callResponse); 
                    component.set("v.totalSize", component.get("v.orders").length);
                    component.set("v.isError",false);
                    //alert('orders--in----'+callResponse);
                    helper.sortByOrders(component, "BegunTime");  
                }
                else if(callResponse == null || callResponse =='')
                {
                    //alert('orders--in----'+callResponse);
                    //alert('orders--vo----'+component.get("v.orders"));
                    component.set("v.isError",true);
                    component.set("v.errorMsg", 'There are no active passes to display');
                }
            }
            else if (response.getState() === "ERROR") { 
				var errors = response.getError();
				if (errors) {
                    if (errors[0] && errors[0].message) {
                        component.set("v.errorMsg", 'There are no active passes to display');
                    }
				}else {
					component.set("v.errorMsg", 'Request Failed!' );
				}
               component.set("v.totalSize", 'There are no active passes to display--' );  
			}   
         
     	});
        
        var actionSORoutingHisData = component.get("c.soRoutingHistoryData"); 
         	//alert('actionSORouting----HistoryData---'+actionSORoutingHisData); 
            //alert('History-------h--'+component.get("v.recordId"));
       
        var soHSID = component.get("v.recordId");
        //alert('soHSID--HistoryData------'+soHSID);
        
        actionSORoutingHisData.setParams({soHID :soHSID});
           
        actionSORoutingHisData.setCallback(this, function(dataresponse) {  
           
             var state = dataresponse.getState(); 
            
            if (state === "SUCCESS") {	 			               
                    var returnValue = dataresponse.getReturnValue();
                 	//alert('returnValue------Gdtry------'+returnValue);
                   if(returnValue != null)
                    {
                        component.set("v.Hisorders", returnValue )
                   		component.set("v.totalSizeHistory", component.get("v.Hisorders").length);
                    	component.set("v.isHisError",false);
                        
                        component.set("v.sortAsc", true);
            			helper.sortBy(component, "BegunTime"); 
                    }
                    else if(returnValue == null || returnValue =='')
                    {
                        component.set("v.isHisError",true);
                        component.set("v.totalSizeHistory",0);
                        component.set("v.errorMsgHstryData", 'There are no active passes to display');
                    	
                    } 
                   
                   
                }
                else if (dataresponse.getState() === "ERROR") {  
                    var errors = dataresponse.getError();
                    //alert(errors[0].message);     
                    if (errors) {
                        //alert('errors------'+errors[0]);
                        if (errors[0] && errors[0].message) { 
                            //alert('errors---1---'+errors[0]);
                            component.set("v.errorMsgHstryData", 'There are no active passes to display');
                        }
                    }else { 
                        component.set("v.errorMsgHstryData", 'Request Failed!' );
                    }
                 component.set("v.totalSizeHistory", 'There are no active passes to display' );    
               }
         }); 
        
        $A.enqueueAction(actionSORoutingData);    
        $A.enqueueAction(actionSORoutingHisData);
        
    },
     
   /* getSalesHistoryData : function(component, event, helper) {
         
    },*/
    
    showLineItems:function(component, event, helper) {
        
        component.set("v.isOpen", true);
        var action = component.get("c.soLineItemsData");
        //var action = component.get("c.soRoutingData");
        	
        var soNumbr = event.currentTarget.dataset.orderlineid;
        	//alert('soNumbr-----'+soNumbr);  
        
        action.setParams({ soNumber : soNumbr });  
        
        action.setCallback(this, function(response) {  
            
           var state = response.getState();
            //alert('state-----'+state);
            
            if (state === "SUCCESS") {	 
                
                alert("From server: " + JSON.stringify(response.getReturnValue())); 
                
                component.set("v.orders", response.getReturnValue()); 
                var routingItem = response.getReturnValue();
                //alert('routingItem------'+routingItem);
                //alert('routing--LI---'+routingItem.SOLineItems);
                component.set("v.itemsList", routingItem.SOLineItems);    
                //component.set("v.totalSize", component.get("v.itemsList").size);
                component.set("v.errorMsgShowLneItms", ''); 
                
            	//helper.sortBy(component, "RoutingPass");                
            }
             else if (response.getState() === "ERROR") {
				var errors = response.getError();
				if (errors) {
                    if (errors[0] && errors[0].message) {
                        component.set("v.errorMsgShowLneItms", 'No records found' );
                         
                    }
				}else {
					component.set("v.errorMsgShowLneItms", 'Request Failed!' );
				}
               
			}   
        });
        
        
        $A.enqueueAction(action);
    },
   
    showHisLineItems:function(component, event, helper) {
        var action = component.get("c.soRoutingHistoryData"); 
        //alert(component.get("v.recordId"));
        var soNo = event.target.id;
 
        action.setParams({ soID : soNo });
        action.setCallback(this, function(response) { 
            // $A.get('e.force:refreshView').fire(); 
        // alert(soID);
            var state = response.getState();
            if (state === "SUCCESS") {				               
                var returnValue =response.getReturnValue();
                var itemLSt = returnValue;
                component.set("v.Hisitems", itemLSt);                
                component.set("v.errorMsg", ''); 
            	//helper.sortBy(component, "RoutingPass");                 
            }
        });    
        $A.enqueueAction(action);
    },
    
    launchLineItems : function(component, event, helper) {
        //alert('here');
        
        var currentOrderLineId = event.currentTarget.dataset.orderlineid;
		var currentOrderSFDCId = event.currentTarget.dataset.ordersfdcid;
        var dataType = "NoHistory";
        //alert('here----'+dataType);
	    $A.createComponent(
            "c:SORoutingLineItems",
            {
                "lineItemId": currentOrderLineId,
                "orderSfdcId": currentOrderSFDCId,
                "typeOfData": dataType
            },
            function(msgBox){                
                if (component.isValid()) {
                    var popupPlaceholder = component.find('lineItemPlaceHolder');
                    var body = popupPlaceholder.get("v.body");
                    body.push(msgBox);
                    popupPlaceholder.set("v.body", body); 
                }
            }
        );		
	},
    
    launchHisLineItems : function(component, event, helper) {
        console.log('here');
        var currentOrderLineId = event.currentTarget.dataset.orderlineid;
		var currentOrderSFDCId = event.currentTarget.dataset.ordersfdcid;
        var dataType = "History";
	    $A.createComponent(
            "c:SORoutingLineItems",
            {
                "lineItemId": currentOrderLineId,
                "orderSfdcId": currentOrderSFDCId,
                "typeOfData": dataType
            },
            function(msgBox){                
                if (component.isValid()) {
                    var popupPlaceholder = component.find('lineItemPlaceHolder');
                    var body = popupPlaceholder.get("v.body");
                    body.push(msgBox);
                    popupPlaceholder.set("v.body", body);  
                }
            }
        );		
	},
    
     //Orders Sorting Start
    sortByOrdBegunTime: function(component, event, helper) {  
        helper.sortByOrders(component, component.find("v.OrdBT"));  
    },
    sortByOrdCompletedTime: function(component, event, helper) {
        helper.sortByOrders(component, "CompletedTime"); 
    },
    sortByOrdUSERNAME: function(component, event, helper) {
        helper.sortByOrders(component, "USERNAME");
    },
    sortByOrdRoutingPass: function(component, event, helper) {
        helper.sortByOrders(component, "RoutingPass");
    },
    sortByOrdConfirmDT: function(component, event, helper) {
        helper.sortByOrders(component, "TimeChanged"); 
    },
    //Orders Sorting END
    //HisOrders Sorting Start
    sortByBegunTime: function(component, event, helper) {
        helper.sortBy(component, "BegunTime"); 
    },
    sortByCompletedTime: function(component, event, helper) {
        helper.sortBy(component, "CompletedTime");
    },
    sortByUSERNAME: function(component, event, helper) {
        helper.sortBy(component, "USERNAME");
    },
    sortByRoutingPass: function(component, event, helper) {
        helper.sortBy(component, "RoutingPass");
    },
    sortByConfirmDT: function(component, event, helper) {
        helper.sortBy(component, "TimeChanged"); 
    },
    //HisOrders Sorting END
    
    renderPage: function(component, event, helper) {
        helper.renderPage(component);  
    }, 
	
    updateSalesOrder: function(component, event, helper) {
        var currentOrderLineContId = event.currentTarget.dataset.orderlineid;
		//var currentOrderSFDCId = event.currentTarget.dataset.ordersfdcid;
        //alert('OrderLine-----'+currentOrderLineContId);
        var actionConfirm = component.get("c.soConfirmData"); 
        var soData =component.get("v.orders");
        var sOrderData = JSON.stringify(soData);
        
        actionConfirm.setParams({"sOrders" : sOrderData,
                                 "rPass" : currentOrderLineContId
                                });
        
        actionConfirm.setCallback(this, function(response) {  
            
           var state = response.getState();
            //alert('state-----'+state);
            
            if (state === "SUCCESS") {	 
                //component.set("v.isConfirm", true);
                //alert("From server: " + response.getReturnValue()); 
                var callResponse = response.getReturnValue();
               
                //alert('orders------'+callResponse);
                if(callResponse != null)
                {
                    component.set("v.orders", callResponse);
                    component.set("v.isConfirm", false);
                }                
            }
             else if (response.getState() === "ERROR") {
				var errors = response.getError();
				if (errors) {
                    if (errors[0] && errors[0].message) {
                        //component.set("v.errorMsgShowLneItms", 'No records found' );
                         
                    }
				}else {
					component.set("v.errorMsgShowLneItms", 'Request Failed!' );
				}
               
			}   
        });
        
        
        $A.enqueueAction(actionConfirm);
    }
})