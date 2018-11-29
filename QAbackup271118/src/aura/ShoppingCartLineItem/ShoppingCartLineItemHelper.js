({
    showToast : function(type, title, component, message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            type: type,
            title: title,
            message: message,
        });
        toastEvent.fire();
    },
    initialLineItem: function(component, helper) {   
        var action = component.get("c.getLineItemDetail");
        var toastErrorHandler = component.find('toastErrorHandler');
        //alert('line id'+component.get('v.lineItemId'));
        
            action.setParams({"lineItemId" : component.get('v.lineItemId')});
            action.setCallback(this, function(response){
                toastErrorHandler.handleResponse(
                    response, // handle failure
                    function(response){ 
                        var rtnValue = response.getReturnValue();
                        if (rtnValue !== null) {   
                            component.set("v.lineItem", rtnValue);
                            var averageCost = rtnValue["Average_Cost__c"];
                            
                            var originalPrice = rtnValue["List_Price__c"];
                            
                            var marginCriteria = component.get("v.marketDiscountCriteria");
                            var averageDiscountCriteria = (1-(averageCost*100)/(originalPrice*(100-marginCriteria)))*100;
                            if(isNaN(averageDiscountCriteria) || averageCost==0){
                                averageDiscountCriteria=0;
                            }
                            component.set("v.averageDiscountCriteria", averageDiscountCriteria);
                            
                          /*  $A.createComponent("ui:outputNumber", 
                                               {"value": averageDiscountCriteria}, 
                                               function(newCmp) {
                                                   var body = component.get("v.body");
                                                   body = [];
                                                   // newCmp is a reference to another component
                                                   body.push(newCmp);
                                                   component.set("v.body", body);
                                               }); */
                            // DEF-0780 - ATC call
                            if(!component.get("v.inCheckoutPage")) {
                                helper.lazyLoadBestDate(component, rtnValue);
                            }
                        } else {
                            helper.showToast("error", 'cart line Item not found', component,
                                             'Could not find cart line Item.');                        
                        }
                    },
                    function(response, message){ // report failure
                        helper.showToast("error", 'cart line Item not found', component,
                                         message);
                    }
                )            
            });        
            action.setBackground();
            $A.enqueueAction(action); 
    },
    // DEF-0780 - ATC call
    lazyLoadBestDate : function(component, lineItem) {
        var action = component.get("c.getBestDate");
        action.setParams({"detail" : lineItem});
        action.setCallback(this, function(response){
            var state = response.getState();
            var bestDate;
            if(state === "SUCCESS") {
                bestDate = response.getReturnValue();
                component.set("v.BestDate", bestDate);
                if(bestDate == null) {
                    component.set("v.bestDateMsg", 'Call');
                }
            }
            else if (state === "INCOMPLETE") {
                component.set("v.bestDateMsg", 'Error in loading best date');
            }
            else if (state === "ERROR") {
                component.set("v.bestDateMsg", 'Error in loading best date');
            }
        });
        action.setBackground();
        $A.enqueueAction(action); 
    },

    checkLineItemLocked:function(component, helper) {   
        var action = component.get("c.isLineItemLocked");
        var toastErrorHandler = component.find('toastErrorHandler');
            action.setParams({"lineItemId" : component.get('v.lineItemId')});
            action.setCallback(this, function(response){
                toastErrorHandler.handleResponse(
                    response, // handle failure
                    function(response){ 
                        var rtnValue = response.getReturnValue();
                        if (rtnValue !== null) {   
                            component.set("v.locked", rtnValue);
                        } else {
                            helper.showToast("error", 'cart line Item Lock status not found', component,
                                             'Could not find cart line Item Lock status.');                        
                        }
                    },
                    function(response, message){ // report failure
                        helper.showToast("error", 'cart line Item Lock status not found', component,
                                         message);
                    }
                )            
            });        
            action.setBackground();
            $A.enqueueAction(action); 
    },
    initialProductDetail: function(component, helper) {   
        var action = component.get("c.getProductDetail");
        var toastErrorHandler = component.find('toastErrorHandler');
        //REQ-438, If item.Product_Title__c is empty, get Product_Title__c from product feed API
        var productTitle = component.get("v.lineItem")["Product_Title__c"];
        var lineItemId;
        if($A.util.isEmpty(productTitle)){
            lineItemId =component.get("v.lineItemId");
        }  
        
        action.setParams({"productSKUId" : component.get('v.productSKUId'),
                          "lineItemId" : lineItemId});
        //End REQ-438, If item.Product_Title__c is empty, get Product_Title__c from product feed API
            action.setCallback(this, function(response){
                toastErrorHandler.handleResponse(
                    response, // handle failure
                    function(response){ 
                        var rtnValue = response.getReturnValue();
                        if (rtnValue !== null) {   
                            component.set("v.productDetail", rtnValue);
                            //REQ-438, get Product_Title__c from product feed API  
                            var updatedLineItem =  component.get("v.lineItem");
                            updatedLineItem["Product_Title__c"]=rtnValue["productTitle"];
                            component.set("v.lineItem", updatedLineItem);
                        } else {
                            helper.getProductInfoFromUnbxd(component,helper);                           
                        }
                    },
                    function(response, message){ // report failure
                        helper.showToast("error", 'Product in cart not found', component,
                                         message);
                    }
                )            
            });        
            action.setBackground();
            $A.enqueueAction(action); 
    },
    getProductInfoFromUnbxd : function(component,helper) {   
         var currentIndex =0;
        var action = component.get("c.getProductListSearch");
      
            action.setParams({"searchKey" : component.get('v.productSKUId'),
                              "currentIndex" : currentIndex,
                              "rows" : 1});
            var toastErrorHandler = component.find('toastErrorHandler');
            action.setCallback(this, function(response){
                toastErrorHandler.handleResponse(
                    response,
                    function(response){
                        var rtnValue = response.getReturnValue();
                        if (rtnValue !== null) {    
                            var obj = JSON.parse(rtnValue);
                            if(obj["response"]["numberOfProducts"]<=0){  
                                return;
                            }
                            for(var i=0; i<  obj["response"]["products"].length; i++){
                                
                                if(!$A.util.isEmpty(obj["response"]["products"][i]["id"])){                
                                    obj["response"]["products"][i]["sku"]=obj["response"]["products"][i]["id"];
                                }else if(!$A.util.isEmpty(obj["response"]["products"][i]["uniqueId"])){ 
                                    //3X SKU search response uniqueId
                                    obj["response"]["products"][i]["sku"]=obj["response"]["products"][i]["uniqueId"];
                                }
                                
                                obj["response"]["products"][i]["productTitle"]=obj["response"]["products"][i]["name"];
                            }
                            var productDetail = obj["response"]["products"][0];
                            productDetail["ecommSmallImage"] = productDetail["smallImageUrl"];
                           /* 
                            productDetail["swatches"] = [];
                            productDetail["swatches"]["imageSource"] =productDetail["swatchesimageUrl"] ? productDetail["swatchesimageUrl"] : [];
                            productDetail["swatches"]["color"]  =productDetail["swatchesname"] ? productDetail["swatchesname"] : [];
                            productDetail["swatches"]["sku"] =  productDetail["childSku"] ? productDetail["childSku"] : [];
                            */
                            productDetail["itemColor"] = productDetail["color"] ? productDetail["color"][0] : [];
                            /*
                            productDetail["detailedDescription"] = productDetail["description"] ? productDetail["description"] :[];
                            productDetail["productDescription"] = productDetail["productDetails"] ? productDetail["productDetails"] :[];
                            console.log(productDetail["variants"]);
                            productDetail["variants1"] = [];
                            if(productDetail["variants"]){
                                for(var i=0; i<  productDetail["variants"].length; i++){
                                    var variantOpt =  JSON.parse(productDetail["variants"][i]);
                                    productDetail["variants1"][i] = {};
                                    productDetail["variants1"][i]["sku"]= variantOpt["id"] ;
                                    productDetail["variants1"][i]["size"]= variantOpt["size2"] ;
                                    productDetail["variants1"][i]["imageSource"] = variantOpt["largeImageUrl"];
                                    productDetail["variants1"][i]["productVariantUrl"] = variantOpt["url"];
                                    
                                }
                                productDetail["variants"] = [];
                                productDetail["variants"] = productDetail["variants1"]; 
                                console.log(productDetail["variants"]);
                            }
                           */
                            
                            component.set("v.productDetail",  productDetail);
                            //REQ-438, get Product_Title__c from unbxd API  
                            var productTitle = component.get("v.lineItem")["Product_Title__c"];
                            if($A.util.isEmpty(productTitle)){                                
                                var updatedLineItem =  component.get("v.lineItem");
                                updatedLineItem["Product_Title__c"]=productDetail["productTitle"];
                                component.set("v.lineItem", updatedLineItem);
                                helper.saveProductTitle(component, helper);
                            }
                        }
                    },
                    function(response, message){ // report failure
                        helper.showToast("error", 'Product '+ component.get('v.productDetailId') +'not found', component,
                                         message);
                    }
                )
            });            
            action.setBackground();
            $A.enqueueAction(action); 
        
    },
    saveProductTitle:function(component, helper) { 
         var action = component.get("c.saveProductTitle");
        action.setParams({"productTitle":component.get("v.lineItem")["Product_Title__c"],
                          "lineItemId" : component.get("v.lineItem")["Id"]});
        action.setCallback(this, function(response){
            toastErrorHandler.handleResponse(
                    response, // handle failure
                    function(response){ 
                        
                    },
                    function(response, message){ // report failure
                        helper.showToast("error", 'Save Product Title Failed', component,
                                         message);
                    }
                )            
        });
    },
    saveDiscount: function(component, helper) { 
        var discountType = component.get("v.selectedDiscountType");
        var percentDiscountAmount = component.find("percentDiscountAmount").get("v.value");
        var flatDiscountAmount = component.find("flatDiscountAmount").get("v.value");       
             
        var discountReasonCode = component.find("discountReasonOption").get("v.value");
        var needApprover=component.get("v.showApproverSelectBox");
        var approverId = component.get("v.lineItem")["Discount_Approver__c"];
        var hasError = false;
        if(needApprover && (approverId=='' || approverId==undefined )){
            helper.showToast("error", 'Please Select An Approver.', component,
                             'Please Select Select An Approver.');   
            hasError = true;
        }
        if((discountType=='Percent' && percentDiscountAmount>0 && discountReasonCode==null)
           || (discountType=='Flat' && flatDiscountAmount>0 && discountReasonCode==null)){
            helper.showToast("error", 'Please Select A Discount Reason.', component,
                             'Please Select A Discount Reason.');   
            hasError = true;
        }
        if(hasError){
            return;
        }
        var action = component.get("c.saveDiscount");
        var toastErrorHandler = component.find('toastErrorHandler');
        action.setParams({"lineItemId" : component.get('v.lineItemId'),
                          "discountType" : discountType,
                          "percentDiscountAmount" : percentDiscountAmount,
                          "flatDiscountAmount" : flatDiscountAmount,
                          "discountReasonCode" : discountReasonCode,
                          "discountApplyOption" : component.find("discountApplyOption").get("v.value"),
                          "approverId" : component.get("v.lineItem")["Discount_Approver__c"]
                        
                         });
          
            action.setCallback(this, function(response){
                toastErrorHandler.handleResponse(
                    response, // handle failure
                    function(response){ 
                        var rtnValue = response.getReturnValue();
                        if (rtnValue !== null && rtnValue=='Success') {   
                           // component.set("v.productDetail", rtnValue);
                           helper.closeModal(component);
                           //$A.get("e.force:refreshView").fire();
                           helper.fireShoppingCartLineItemEvent(component, component.get("v.CART_ACTION_APPLY_DISCOUNT"), component.get('v.lineItemId'));
                        } else {
                            helper.showToast("error", 'Faile to save Discount', component,
                                             'Faile to save Discount.');                        
                        }
                    },
                    function(response, message){ // report failure
                        helper.showToast("error", 'Faile to save Discount', component,
                                         message);
                    }
                )            
            });        
            action.setBackground();
            $A.enqueueAction(action); 
    },
    tresholdenabledcall:function(component, helper) {

    var action=component.get("c.tresholdenabledcall");
        action.setParams({"b" : true
                         });
        action.setCallback(this, function(response){
             var State = response.getState();
              // alert('State'+ State);
            
                    if (component.isValid() && response.getState() === "SUCCESS") { 
                       // alert('responsevalie' + JSON.stringify(response.getReturnValue().Value));
                        var jsonData = JSON.parse(response.getReturnValue());
                       // alert('alert of json'+deliveryType);
                         if(jsonData == null){
                            
                         var valueThreshold = 0;   
                        }else{
                        for(var i=0; i<jsonData.length; i++) {
                            console.log('here' + jsonData[i].Value);
                            if(jsonData[i].Value == 1)
                            {
                            	var valueThreshold = jsonData[i].Value;
                               // alert('valueThreshold----'+valueThreshold);
                            }
                            
                        }
                        }
                    console.log('res----'+valueThreshold);
                   // component.set("v.tresholdenabledresponse",JSON.parse(response.getReturnValue()));
                    component.set("v.tresholdenabledresponse",valueThreshold);
                 //   console.log('value after' + JSON.parse(response.getReturnValue().Value));
                    console.log('treshold-------'+component.get("v.tresholdenabledresponse"));
                   
                }else if (State === "ERROR") {
                    //Error message display logic.
                    var errors = response.getError();
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "ERROR!",
                        "message": errors[0].message
                    });
                    toastEvent.fire();
                } 
            
        }); 
    $A.enqueueAction(action);
},
   saveDeliveryMode: function(component, helper) { 
        var action = component.get("c.saveDeliveryMode");
        var toastErrorHandler = component.find("toastErrorHandler");
     //  alert('deliveryType in shoppingcartlineitemhelper'+component.get("v.deliveryType"));
       		//alert('line id in savedeliverymode'+component.get('v.lineItemId'));
        action.setParams({"lineItemId" : component.get("v.lineItemId"),
                          "selectedShippingWay" : component.get("v.selectedShippingWay"),
                          "accId":component.get('v.accountId'),
                           "deliveryType":component.get("v.deliveryType")
                         //"shippingWayApplyOption" : component.find("shippingWayApplyOption").get("v.value")
                         });
          
            action.setCallback(this, function(response){
                toastErrorHandler.handleResponse(
                    response, // handle failure
                    function(response){ 
                        var rtnValue = response.getReturnValue();
                        if (rtnValue !== null) {   
                            if(rtnValue=='Success')
                            {
                                helper.closeModal(component);
                                helper.fireThresholdUpdateEvent(component, component.get("v.CART_ACTION_UPDATE_DELIVERY_MODE"), component.get('v.lineItemId'));
                              // $A.get('e.force:refreshView').fire();
                            }
                            else{
                                helper.showToast("error", '', component,rtnValue);  
                                
                            }
                        } else {
                            helper.showToast("error", 'Product not found', component,
                                             'Could not find product.');                        
                        }
                    },
                    function(response, message){ // report failure
                        helper.showToast("error", 'Product not found', component,
                                         message);
                    }
                )            
            });        
            action.setBackground();
            $A.enqueueAction(action); 
    },
    deleteFromCart: function(component, helper,lineItemId) { 
         console.log(lineItemId);
        var action = component.get("c.deleteFromCart");
        var toastErrorHandler = component.find('toastErrorHandler');
        action.setParams({"lineItemId" :lineItemId});
          
            action.setCallback(this, function(response){
                toastErrorHandler.handleResponse(
                    response, // handle failure
                    function(response){ 
                        var rtnValue = response.getReturnValue();
                        if (rtnValue !== null && rtnValue=='Success') {  
                           //$A.get("e.force:refreshView").fire();
                           helper.fireShoppingCartLineItemEvent(component, component.get("v.CART_ACTION_DELETE_ITEM"), component.get('v.lineItemId'));
                        } else {
                            helper.showToast("error", 'Failed to delete lineItem', component,
                                             'Failed to delete lineItem.');                        
                        }
                    },
                    function(response, message){ // report failure
                        helper.showToast("error", 'Failed to delete lineItem', component,
                                         message);
                    }
                )            
            });        
            action.setBackground();
            $A.enqueueAction(action); 
    },
    updateAsIs: function(component, helper, lineItemId, value) { 
        console.log('setting as is ' + lineItemId);
        var action = component.get("c.updateAsIs");
        var toastErrorHandler = component.find('toastErrorHandler');
        action.setParams({"lineItemId" : lineItemId, 
                          "asIs" : value});
          
        action.setCallback(this, function(response){
            toastErrorHandler.handleResponse(
                response, // handle failure
                function(response){ 
                    var rtnValue = response.getReturnValue();
                    if (rtnValue !== null && rtnValue=='Success') {
                        //$A.get("e.force:refreshView").fire();
                        console.log('noting success');
                        helper.fireShoppingCartLineItemEvent(component, component.get("v.CART_ACTION_MARK_ITEM_AS_IS"), component.get('v.lineItemId'));
                        // per client preference, no toast shown for success
                    } else {
                        helper.showToast("error", 'Failed to update As Is value', component,
                                         'Failed to update As Is value.');                        
                    }
                },
                function(response, message){ // report failure
                    helper.showToast("error", 'Error updating As Is Value', component,
                                     message);
                }
            )            
        });        
        action.setBackground();
        $A.enqueueAction(action); 
    },    
    closeModal : function(component,containerName){
        console.log("----in cancelI");
         
        var popUp = component.find(containerName);
        console.log(popUp);
        $A.util.removeClass(popUp, 'slds-fade-in-open');
        $A.util.addClass(popUp, 'slds-fade-in-close');
        var backdrop = component.find("backdropContainer");
        console.log(backdrop);
        $A.util.removeClass(backdrop, 'slds-modal-backdrop--open');
        $A.util.addClass(backdrop, 'slds-modal-backdrop--close');
    },
    setupApproverSelectBox : function(component,discountType){
        var totalFlatDiscountAmount = component.find("flatDiscountAmount").get("v.value");
        var flatDiscountAmount = totalFlatDiscountAmount/component.get("v.lineItem")["Quantity__c"];
       	if(component.find("discountApplyOption").get("v.value")==1){
            component.set("v.showApproverSelectBox",true); 
        }else{
            if(discountType == "Percent" ){
               if(component.find("percentDiscountAmount").get("v.value") >0 && component.find("percentDiscountAmount").get("v.value") > 
                component.get("v.averageDiscountCriteria")){
                    
                    component.set("v.showApproverSelectBox",true); 
                }else{
                     component.set("v.showApproverSelectBox",false); 
                }
            } else if(discountType == "Flat" ){
                if(  totalFlatDiscountAmount >0 && (flatDiscountAmount/component.get("v.lineItem")["List_Price__c"])*100
                   > component.get("v.averageDiscountCriteria")){
                    component.set("v.showApproverSelectBox",true); 
                }else{
                    component.set("v.showApproverSelectBox",false); 
                }
                
            }
    	}
	},
    updateQuantity:function(component,quantity){
        var action = component.get("c.updateQuantity");
        console.log(quantity);
        action.setParams({
            "lineItemId":component.get('v.lineItemId'),
            "num":quantity
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log(state);
            if (state === "SUCCESS") {
                var val=response.getReturnValue();
                //$A.get('e.force:refreshView').fire();
                this.fireShoppingCartLineItemEvent(component, component.get("v.CART_ACTION_UPDATE_QUANTITY"), component.get('v.lineItemId'));
            }
            
        });
        $A.enqueueAction(action); 
    },
    updateFPPSKU: function(component, helper,fppSku) { 
        var action = component.get("c.updateFppToLineItem");
        var toastErrorHandler = component.find('toastErrorHandler');
          
        action.setParams({"fppSku":fppSku,
                          "lineItemId" :component.get('v.lineItemId')});
          
            action.setCallback(this, function(response){
                toastErrorHandler.handleResponse(
                    response, // handle failure
                    function(response){ 
                        var rtnValue = response.getReturnValue();
                        if (rtnValue !== null && rtnValue=='Success') {  
                           //$A.get("e.force:refreshView").fire();
                           helper.fireShoppingCartLineItemEvent(component, component.get("v.CART_ACTION_UPDATE_FPP_SKU"), component.get('v.lineItemId'));
                        } else {
                            helper.showToast("error", 'Failed to update FPP', component,
                                             'Failed to update FPP.');                        
                        }
                    },
                    function(response, message){ // report failure
                        helper.showToast("error", 'Failed to update FPP', component,
                                         message);
                    }
                )            
            });        
            action.setBackground();
            $A.enqueueAction(action); 
    },             
    fireShoppingCartLineItemEvent : function(component, action, lineItemId){
        var event = component.getEvent("shoppingCartLineItemEvent");
        event.setParams({"action" : action, "lineItemId" : lineItemId });
        event.fire();
     },
    fireThresholdUpdateEvent : function(component, action, lineItemId){
        var event = component.getEvent("ThresholdUpdateEvent");
        event.setParams({"action" : action, "lineItemId" : lineItemId });
        event.fire();
    }
})