({
    doInit: function(component,event, helper){
        component.set("v.selectedDiscountType","Percent");
        var discountReasonCode = component.get("v.opp")["Discount_Reason_Code__c"];
        
        component.find("discountReasonOption").set("v.value",$A.util.isEmpty(discountReasonCode)?"null":discountReasonCode);
        
        var allItems = component.get("v.shoppingCartLineItems");
        var itemMap=[];
        var itemTotal=[];
        var totalSize;
        var itemWrapperMap=[];
        var hasDiscountItem=false;
        allItems.forEach(function(item){
            totalSize = itemTotal.push(item["item"]);
            itemMap[item["item"]["Id"]]=item["item"];
            itemWrapperMap[item["item"]["Id"]]=item;
            if(item["isLocked"]){
                component.set("v.haslockedItem", true);
                component.set("v.selectedApprover", item["item"]["Discount_Approver__r"]["Name"]);
            }
            //DEF-0877
            if(item["isDiscountSelected"]){
                component.get("v.opp")["Discount__c"]=item["item"]["Discount__c"];
                hasDiscountItem=true;
            }
        });
        if(!hasDiscountItem){
            component.get("v.opp")["Discount__c"]=0;
        }
        var currentItem = component.find("setCurrentItemDiscount");
        var currentItemId=  currentItem.get("v.value");
        component.set("v.averageDiscountCriteria", itemWrapperMap[currentItemId]["averageDiscountCriteria"]);
        var initSelectedItems=[];
        var initSelectedItemsExcludeCurrentItem=[];
        
        initSelectedItems.push(component.get("v.lineItem")["Id"]);
        var initialSelectBoxCmp = component.find("setDiscount");
        if(totalSize>1){
            initialSelectBoxCmp.forEach(function(element){
                var iteratorItem = element.get("v.value");
                if(iteratorItem!=component.get("v.lineItem")["Id"] 
                    && itemMap[iteratorItem]["Discount__c"]==component.get("v.opp")["Discount__c"]
                    && component.get("v.opp")["Discount__c"]>0){
                    
                    element.set("v.checked", true);
                    initSelectedItems.push(iteratorItem);
                }else{
                    element.set("v.checked", false);
                    
                }
                if(itemMap[iteratorItem]["Discount__c"]==component.get("v.opp")["Discount__c"]
                        && component.get("v.opp")["Discount__c"]>0){
            
                    initSelectedItemsExcludeCurrentItem.push(iteratorItem);
                }
            });
        }else{
              var iteratorItem = initialSelectBoxCmp.get("v.value");
                if(iteratorItem!=component.get("v.lineItem")["Id"] 
                    && itemMap[iteratorItem]["Discount__c"]==component.get("v.opp")["Discount__c"]
                    && component.get("v.opp")["Discount__c"]>0){
                    
                    initialSelectBoxCmp.set("v.checked", true);
                    initSelectedItems.push(iteratorItem);
                }else{
                    initialSelectBoxCmp.set("v.checked", false);
                    
                }
                if(itemMap[iteratorItem]["Discount__c"]==component.get("v.opp")["Discount__c"]
                        && component.get("v.opp")["Discount__c"]>0){
            
                    initSelectedItemsExcludeCurrentItem.push(iteratorItem);
                }
        }
        if(initSelectedItems.length>1){
            component.set("v.modalTitle",'Multiple Items');
            
        }else if(initSelectedItems.length==1){
            component.set("v.modalTitle",itemMap[initSelectedItems[0]]["Product_Title__c"]);
        }else{
            component.set("v.modalTitle",'');
            
        }
        component.set("v.shoppingCartLineItemsForCancel",initSelectedItemsExcludeCurrentItem);
        helper.setupApproverSelectBox(component);
        helper.caculateOriginalPrice(component,helper);
    },
    operateCheckbox: function(component, event, helper){
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
        var updatedValue = event.getSource().get("v.value");
        var checkFlag = event.getSource().get("v.checked");
        var      SelectedTotalOriginalPrice=component.get("v.SelectedTotalOriginalPrice");
        if(checkFlag){
            SelectedTotalOriginalPrice +=itemMap[updatedValue]["List_Price__c"]*itemMap[updatedValue]["Quantity__c"];
        }else{
            SelectedTotalOriginalPrice -=itemMap[updatedValue]["List_Price__c"]*itemMap[updatedValue]["Quantity__c"];
        }
        component.set("v.SelectedTotalOriginalPrice",SelectedTotalOriginalPrice);
        var opp = component.get("v.opp");
        
        opp["Cart_Discount_Price__c"]= Math.round(SelectedTotalOriginalPrice*(1 - opp["Discount__c"]/100)*100)/100;
        opp["Cart_Flat_Discount_Amount__c"]= SelectedTotalOriginalPrice- opp["Cart_Discount_Price__c"];
        component.set("v.opp", opp);
        
        
        helper.setupApproverSelectBox(component);
        var checkSelectedItem=[];
        var selectedAll = true;
        var currentItem = component.find("setCurrentItemDiscount");
        var currentItemId=  currentItem.get("v.value");
        
        if(!currentItem.get("v.checked")) {
            selectedAll=false;
        }else{
            checkSelectedItem.push(currentItemId);
        }
        if(totalSize>1){
            component.find("setDiscount").forEach(function(element){
                var itemId= element.get("v.value");
                if(itemId!=currentItemId && itemMap[itemId]["Product_SKU__c"][0]!='*'){
                    if(!element.get("v.checked")) {
                        selectedAll=false;
                    }else{
                        checkSelectedItem.push(itemId);
                    } 
                }
            });
        }else{
            var itemId= component.find("setDiscount").get("v.value");
                if(itemId!=currentItemId && itemMap[itemId]["Product_SKU__c"][0]!='*'){
                    if(!component.find("setDiscount").get("v.checked")) {
                        selectedAll=false;
                    }else{
                        checkSelectedItem.push(itemId);
                    } 
                }
        }
        if(checkSelectedItem.length>1){
            component.set("v.modalTitle",'Multiple Items');
            
        }else if(checkSelectedItem.length==1){
            component.set("v.modalTitle",itemMap[checkSelectedItem[0]]["Product_Title__c"]);
        }else{
            component.set("v.modalTitle",'');
            
        }
        component.find("setAllDiscount").set("v.checked", selectedAll);
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
    },
    changeDiscount: function(component, event, helper){
        var updatedValue = event.getSource().get("v.value");
        var auraId = event.getSource().get("v.name");
        var itemTotalPrice =  component.get("v.SelectedTotalOriginalPrice");
        
        if(auraId=='itemsPrice'){
            component.find("flatDiscountAmount").set("v.value",(itemTotalPrice-updatedValue));
            var percentDiscountAmount = Math.round(1000000*(itemTotalPrice-updatedValue)/itemTotalPrice)/10000;
            component.find("percentDiscountAmount").set("v.value",percentDiscountAmount);
            component.set("v.cartDiscount",percentDiscountAmount);
             

        }else if(auraId=='flatDiscountAmount'){
            
            component.find("itemsPrice").set("v.value",(itemTotalPrice-updatedValue));
            var percentDiscountAmount = Math.round(1000000*(updatedValue)/itemTotalPrice)/10000;
            component.find("percentDiscountAmount").set("v.value",percentDiscountAmount);
            
            
        }else if(auraId=='percentDiscountAmount' ){
            component.find("itemsPrice").set("v.value",Math.round(100*itemTotalPrice-updatedValue*itemTotalPrice)/100);
            component.find("flatDiscountAmount").set("v.value",Math.round(updatedValue*itemTotalPrice)/100);
            
        }
        
        
        helper.setupApproverSelectBox(component);
    },
    selectAllItems: function(component, event, helper){
        var updatedValue = event.getSource().get("v.value");
        var checkFlag = event.getSource().get("v.checked");
        
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
        //Caculate current open discount modal item
        var currentItem = component.find("setCurrentItemDiscount");
        var currentItemId=  currentItem.get("v.value");
        
        currentItem.set("v.checked", checkFlag);
        
        var changeSelectedItems=[];
        if(checkFlag){
            changeSelectedItems.push(component.get("v.lineItem")["Id"]);
        }
        if(totalSize>1){
            component.find("setDiscount").forEach(function(element){
                var itemId= element.get("v.value");
                if(itemId!=currentItemId && itemMap[itemId]["Product_SKU__c"][0]!='*'){
                    element.set("v.checked", checkFlag);
                    if(checkFlag){
                        changeSelectedItems.push(itemId);
                    }
                }
            });
        }else{
             var itemId=  component.find("setDiscount").get("v.value");
                if(itemId!=currentItemId && itemMap[itemId]["Product_SKU__c"][0]!='*'){
                     component.find("setDiscount").set("v.checked", checkFlag);
                    if(checkFlag){
                        changeSelectedItems.push(itemId);
                    }
                }
        }
        if(changeSelectedItems.length>1){
            component.set("v.modalTitle",'Multiple Items');
            
        }else if(changeSelectedItems.length==1){
            component.set("v.modalTitle",itemMap[changeSelectedItems[0]]["Product_Title__c"]);
        }else{
            component.set("v.modalTitle",'');
            
        }
        helper.setupApproverSelectBox(component);
        helper.caculateOriginalPrice(component,helper);
        //DEF-0885        
        if(changeSelectedItems.length>=1){
              changeSelectedItems.forEach(function(element){
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
    },
    cancelModal: function(component, event, helper){
        var allItems =  component.get("v.shoppingCartLineItems");
        
        var itemDiscountPriceMap=[];
        allItems.forEach(function(item){
            itemDiscountPriceMap[item["item"]["Id"]]=item;
            itemDiscountPriceMap[item["item"]["Id"]]["isDiscountSelected"]=false;
        });
        
        var originalInitialSelectedItem=component.get("v.shoppingCartLineItemsForCancel");
         if(originalInitialSelectedItem.length>=1){
              originalInitialSelectedItem.forEach(function(element){
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
        
        component.getEvent("NotifyParentCloseDiscountModal").fire();
    },
    updateDiscount : function(component, event, helper){
        helper.saveDiscount(component, helper);
    }
})