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
        var percentDiscountAmount = Number(component.get("v.opp")["Discount__c"]);     
        
        var discountReasonCode = component.find("discountReasonOption").get("v.value");
        var needApprover=component.get("v.showApproverSelectBox");
        var approverId = component.get("v.lineItem")["Discount_Approver__c"];
        var hasError = false;
        if(percentDiscountAmount<0 ){
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
        if( percentDiscountAmount>0  && discountReasonCode=="null"){
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
                          "discountReasonCode" : discountReasonCode=="null"?"":discountReasonCode,//Fix Post mentioned error of DEF-0772 on 8/8/2018  
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
                        var event = component.getEvent("shoppingCartLineItemEvent");
                        event.setParams({"action" : component.get("v.CART_ACTION_APPLY_DISCOUNT"), "lineItemIds" : seletedItem });
                        event.fire();
                      //  $A.get("e.force:refreshView").fire();
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
        var itemDiscountPriceMap=[];
        var itemTotal=[];
        var totalSize;
        allItems.forEach(function(item){
            itemMap[item["item"]["Id"]]=item["item"];
            itemDiscountPriceMap[item["item"]["Id"]]=item;
            itemDiscountPriceMap[item["item"]["Id"]]["isDiscountSelected"]=false;
            totalSize=itemTotal.push(item["item"]);
        });
        //Caculate seleted items 1 quantity total and discount   
        var SelectedTotalOriginalPrice =0;
        var selectedAll = true;
        //Caculate current open discount modal item
        var currentItem = component.find("setCurrentItemDiscount");
        var currentItemId=  currentItem.get("v.value");
        var changeSelectedItems=[];
        if(currentItem.get("v.checked")){
            SelectedTotalOriginalPrice+=Number((itemMap[currentItemId]["List_Price__c"]*itemMap[currentItemId]["Quantity__c"]).toFixed(2));
        	changeSelectedItems.push(component.get("v.lineItem")["Id"]);
        }else{
            selectedAll = false;
        }
        //Caculate other items
        if(totalSize>1){
            component.find("setDiscount").forEach(function(element){
                var itemId= element.get("v.value");
                if(itemId!=currentItemId && itemMap[itemId]["Product_SKU__c"][0]!='*' && itemDiscountPriceMap[itemId]["isLocked"]==false){
                    if(!element.get("v.checked")) {
                        selectedAll=false;
                    }else{
                        changeSelectedItems.push(itemId);
                        SelectedTotalOriginalPrice+=itemMap[itemId]["List_Price__c"]*itemMap[itemId]["Quantity__c"];
                    } 
                }
            });
        }else{
            var itemId= component.find("setDiscount").get("v.value");
            if(itemId!=currentItemId && itemMap[itemId]["Product_SKU__c"][0]!='*' && itemDiscountPriceMap[itemId]["isLocked"]==false){
                if(!component.find("setDiscount").get("v.checked")) {
                    selectedAll=false;
                }else{
                    changeSelectedItems.push(itemId);
                    SelectedTotalOriginalPrice+=itemMap[itemId]["List_Price__c"]*itemMap[itemId]["Quantity__c"];
                } 
            }
        }
        component.set("v.SelectedTotalOriginalPrice", (!$A.util.isUndefinedOrNull(SelectedTotalOriginalPrice) ? SelectedTotalOriginalPrice : 0) );
             component.find("setAllDiscount").set("v.checked", selectedAll);


        this.updateAllAfterAction(component,itemMap,itemDiscountPriceMap,changeSelectedItems);
    },
    updateAllAfterAction : function(component, itemMap,itemDiscountPriceMap,checkSelectedItem){
        var opp=component.get("v.opp");
        if(checkSelectedItem.length>1){
            component.set("v.modalTitle",'Multiple Items');
            
        }else if(checkSelectedItem.length==1){
            component.set("v.modalTitle",itemMap[checkSelectedItem[0]]["Product_Title__c"]);
        }else{
            component.set("v.modalTitle",'');
            
        }
        //Caculate Total Line in Grid
        var SelectedTotalOriginalPrice = component.get("v.SelectedTotalOriginalPrice");
        var totalPrice =component.get("v.CartTotalOriginalPrice");
        var DiscountPrice =0;
        var SelectedDiscountPrice = 0;
        for (var itemId in itemMap) {
            if(checkSelectedItem.includes(itemId)){
                DiscountPrice +=Math.round(itemMap[itemId]["List_Price__c"]*(1 - opp["Discount__c"]/100)*100)*itemMap[itemId]["Quantity__c"]/100;
                SelectedDiscountPrice +=Math.round(itemMap[itemId]["List_Price__c"]*(1 - opp["Discount__c"]/100)*100)*itemMap[itemId]["Quantity__c"]/100;
            }else{
                DiscountPrice +=itemMap[itemId]["Discount_Price__c"]*itemMap[itemId]["Quantity__c"];
                
            }
        }   
        component.set("v.CartTotalDiscountedPrice",DiscountPrice);
        component.set("v.CartFlatDiscountAmount",totalPrice-DiscountPrice);
        component.set("v.CartAverageDiscount",Math.round(1000000*(totalPrice-DiscountPrice)/totalPrice)/1000000);
        
                
        component.set("v.SelectedTotalDiscountedPrice",SelectedDiscountPrice);
        component.set("v.SelectedFlatDiscountAmount",SelectedTotalOriginalPrice-SelectedDiscountPrice);
        component.set("v.SelectedAverageDiscount",opp["Discount__c"]/100);
           var opp = component.get("v.opp");
        
        if (!$A.util.isUndefinedOrNull(SelectedTotalOriginalPrice) && !isNaN(SelectedTotalOriginalPrice)) {
            opp["Cart_Discount_Price__c"]= Math.round(100*SelectedDiscountPrice)/100;
            opp["Cart_Flat_Discount_Amount__c"]= Math.round(100*(SelectedTotalOriginalPrice-SelectedDiscountPrice))/100;
        } else {
            opp["Cart_Flat_Discount_Amount__c"] = 0;
            opp["Cart_Discount_Price__c"] = 0;
        }
        component.set("v.opp", opp);

        
        //DEF-0885        
        if(checkSelectedItem.length>=1){
            checkSelectedItem.forEach(function(element){
                itemDiscountPriceMap[element]["isDiscountSelected"]=true;
                
            });
            
        }  
        var newShoppingCartLineItems = [];
        
        for (var k in itemDiscountPriceMap) {
            if (itemDiscountPriceMap.hasOwnProperty(k)) {
                newShoppingCartLineItems.push(itemDiscountPriceMap[k]);
            }
            if(k==component.get("v.lineItem")["Id"]){
                component.set("v.isCurrentItemDiscountSelected", itemDiscountPriceMap[k]["isDiscountSelected"]);
            }
        }
        component.set("v.shoppingCartLineItems", newShoppingCartLineItems);
    }
})