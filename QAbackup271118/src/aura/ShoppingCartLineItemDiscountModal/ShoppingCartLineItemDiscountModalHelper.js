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
	saveDiscount: function(component, helper) { 
        var discountType = component.get("v.selectedDiscountType");
        var percentDiscountAmount = Number(component.find("percentDiscountAmount").get("v.value"));
        var flatDiscountAmount = Number(component.find("flatDiscountAmount").get("v.value"));       
             
        var discountReasonCode = component.find("discountReasonOption").get("v.value");
        var needApprover=component.get("v.showApproverSelectBox");
        var approverId = component.get("v.lineItem")["Discount_Approver__c"];
        var hasError = false;
        if(percentDiscountAmount<0 || flatDiscountAmount<0 ){
            helper.showToast("error", 'Please Input Valid Discount Amount.', component,
                             'You are trying to apply a negative discount, Please input valid discount amount to continue.');   
            
            hasError = true;
        }
        //DEF-0902
        if(percentDiscountAmount>100){
            helper.showToast("error", 'Please Input Valid Discount Amount.', component,
                             'You are trying to apply a large discount exceed the product original price, Please input valid discount amount to continue.');   
            
            hasError = true;
        }
        if( (percentDiscountAmount>0 || flatDiscountAmount>0 ) && discountReasonCode=="null"){
            helper.showToast("error", 'Please Select A Discount Reason.', component,
                             'You are trying to apply a discount, Please select discount reason to continue.');   
            hasError = true;
        }

        if(needApprover && (approverId=='' || approverId==undefined )){
            helper.showToast("error", 'Please Select An Approver.', component,
                             'The discount you are trying to apply requires approval. Please select an approver to continue.');   
            hasError = true;
        }

        var seletedItem=new Array();
         //Caculate current open discount modal item
        var currentItem = component.find("setCurrentItemDiscount");
        var currentItemId=  currentItem.get("v.value");
        if(currentItem.get("v.checked")){
           seletedItem.push(currentItemId);
        }
          var allItems =  component.get("v.shoppingCartLineItems");
         var itemTotal=[];
        var totalSize;
        allItems.forEach(function(item){
              totalSize=itemTotal.push(item["item"]);
        });
        if(totalSize>1){
            component.find("setDiscount").forEach(function(element){
                var itemId= element.get("v.value");
                if(element.get("v.checked")){
                    seletedItem.push(itemId);
                }
            });
        }else{
            var itemId= component.find("setDiscount").get("v.value");
            if(component.find("setDiscount").get("v.checked")){
                seletedItem.push(itemId);
            }  
        }
        if(seletedItem.length==0){
            helper.showToast("error", 'Please Select at least one item.', component,
                             'Please  Select at least one item.');   
            hasError = true;
        }
        if(hasError){
            return;
        }
        var action = component.get("c.saveDiscount");
        var toastErrorHandler = component.find('toastErrorHandler');
        action.setParams({"lineItemId" : component.get('v.lineItem')["Id"],
                          "lineItemIdList" : seletedItem,
                          "percentDiscountAmount" : percentDiscountAmount,
                          "discountReasonCode" : discountReasonCode,
                          "approverId" : component.get("v.lineItem")["Discount_Approver__c"]
                         });
          
            action.setCallback(this, function(response){
                toastErrorHandler.handleResponse(
                    response, // handle failure
                    function(response){ 
                        var rtnValue = response.getReturnValue();
                        if (rtnValue !== null && rtnValue=='Success') {   
                           // component.set("v.productDetail", rtnValue);
                            component.getEvent("NotifyParentCloseDiscountModal").fire();
                           $A.get("e.force:refreshView").fire();
                        } else {
                            helper.showToast("error", 'Failed to save Discount', component,
                                             'Failed to save Discount.');                        
                        }
                    },
                    function(response, message){ // report failure
                        helper.showToast("error", 'Failed to save Discount', component,
                                         message);
                    }
                )            
            });        
            action.setBackground();
            $A.enqueueAction(action); 
    },
    setupApproverSelectBox : function(component){
        var oppDiscount = component.find("percentDiscountAmount").get("v.value");
    
                var seletedItem=new Array();
         //Caculate current open discount modal item
        var currentItem = component.find("setCurrentItemDiscount");
        var currentItemId=  currentItem.get("v.value");
        if(currentItem.get("v.checked")){
           seletedItem.push(currentItemId);
        }
        
        var allItems = component.get("v.shoppingCartLineItems");
        var itemTotal=[];
        var totalSize;
        var itemWrapperMap=[];
        allItems.forEach(function(item){
            itemWrapperMap[item["item"]["Id"]]=item;
            
            totalSize=itemTotal.push(item["item"]);
        });

        if(totalSize>1){
            component.find("setDiscount").forEach(function(element){
                var itemId= element.get("v.value");
                if(element.get("v.checked")){
                    seletedItem.push(itemId);
                }
            });
        }else{
              var itemId=  component.find("setDiscount").get("v.value");
                if( component.find("setDiscount").get("v.checked")){
                    seletedItem.push(itemId);
                }
        }
        var hasItemApprove = false
        seletedItem.forEach(function(sItem){
            var itemDiscountPrice = Math.round(itemWrapperMap[sItem]["item"]["List_Price__c"]*(1- oppDiscount/100)*100)/100;
            if(Number(oppDiscount)>0 && 
               Number(oppDiscount)>Number(itemWrapperMap[sItem]["averageDiscountCriteria"])
              && Number(itemDiscountPrice)!=Number(itemWrapperMap[sItem]["item"]["List_Price__c"])){
                hasItemApprove = true;
                return;
            }
        });
        if(hasItemApprove){
             component.set("v.showApproverSelectBox",true); 
        }else{
             component.set("v.showApproverSelectBox",false); 
        }
	},
    caculateOriginalPrice: function(component,helper){
        
        var allItems =  component.get("v.shoppingCartLineItems");
        var itemMap=[]; 
        var itemTotal=[];
        var totalSize;
        allItems.forEach(function(item){
            itemMap[item["item"]["Id"]]=item["item"];
            totalSize = itemTotal.push(item["item"]);
        });
        //Caculate seleted items 1 quantity total and discount   
        var SelectedTotalOriginalPrice =0;
         var selectedAll = true;
        //Caculate current open discount modal item
        var currentItem = component.find("setCurrentItemDiscount");
        var currentItemId=  currentItem.get("v.value");
        if(currentItem.get("v.checked")){
            SelectedTotalOriginalPrice+=itemMap[currentItemId]["List_Price__c"]*itemMap[currentItemId]["Quantity__c"];
        }else{
            selectedAll = false;
        }
        //Caculate other items
        if(totalSize>1){
            component.find("setDiscount").forEach(function(element){
                var itemId= element.get("v.value");
                if(itemId!=currentItemId && itemMap[itemId]["Product_SKU__c"][0]!='*'){
                    if(!element.get("v.checked")) {
                        selectedAll=false;
                    }else{
                        SelectedTotalOriginalPrice+=itemMap[itemId]["List_Price__c"]*itemMap[itemId]["Quantity__c"];
                    } 
                }
            });
        }else{
              var itemId= component.find("setDiscount").get("v.value");
                if(itemId!=currentItemId && itemMap[itemId]["Product_SKU__c"][0]!='*'){
                    if(!component.find("setDiscount").get("v.checked")) {
                        selectedAll=false;
                    }else{
                        SelectedTotalOriginalPrice+=itemMap[itemId]["List_Price__c"]*itemMap[itemId]["Quantity__c"];
                    } 
                }
        }
         component.set("v.SelectedTotalOriginalPrice", (!$A.util.isUndefinedOrNull(SelectedTotalOriginalPrice) ? SelectedTotalOriginalPrice : 0) );
         var opp = component.get("v.opp");
         
        if (!$A.util.isUndefinedOrNull(SelectedTotalOriginalPrice) && !isNaN(SelectedTotalOriginalPrice)) {
            opp["Cart_Discount_Price__c"]= Math.round(SelectedTotalOriginalPrice*(1 - opp["Discount__c"]/100)*100)/100;
            opp["Cart_Flat_Discount_Amount__c"]= SelectedTotalOriginalPrice- opp["Cart_Discount_Price__c"];
        } else {
            opp["Cart_Flat_Discount_Amount__c"] = 0;
            opp["Cart_Discount_Price__c"] = 0;
        }
        component.set("v.opp", opp);
        component.find("setAllDiscount").set("v.checked", selectedAll);
    }
})