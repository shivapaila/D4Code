({
    doInit: function(component,event, helper){
        component.set("v.selectedDiscountType","Percent");
        //Fix DEF-0948, show ellipse discount icon seleted item discount reason code as initial reason code in discount modal
        var discountReasonCode = component.get("v.lineItem")["Discount_Reason_Code__c"];
        
        component.find("discountReasonOption").set("v.value",$A.util.isEmpty(discountReasonCode)?"null":discountReasonCode);
        
     
        var allItems = component.get("v.shoppingCartLineItems");
        var itemMap=[];
        var itemTotal=[];
        var totalSize;
        var itemWrapperMap=[];
        var totalPrice=0;
        var DiscountPrice=0;
        allItems.forEach(function(item){
            totalPrice +=  Number((item["item"]["List_Price__c"]*item["item"]["Quantity__c"]).toFixed(2));
                
            if(item["item"]["Id"]== component.get("v.lineItem")["Id"] ){
                 DiscountPrice +=Number((item["item"]["List_Price__c"]*item["item"]["Quantity__c"]).toFixed(2));
            }else{
                DiscountPrice +=  Number((item["item"]["Discount_Price__c"]*item["item"]["Quantity__c"]).toFixed(2));
            }
            totalSize = itemTotal.push(item["item"]);
            itemMap[item["item"]["Id"]]=item["item"];
            itemWrapperMap[item["item"]["Id"]]=item;
            //Fix DEF-0853, only block discount modal finalize when ellipse discount icon seleted item is pending on approval.
            if(item["isLocked"] && item["item"]["Id"]==component.get("v.lineItem")["Id"]){
                component.set("v.haslockedItem", true);
                component.set("v.selectedApprover", item["item"]["Discount_Approver__r"]["Name"]);
            }
            
        });
        component.set("v.CartTotalOriginalPrice",totalPrice);
        component.set("v.CartTotalDiscountedPrice",DiscountPrice);
        component.set("v.CartFlatDiscountAmount",totalPrice-DiscountPrice);
        component.set("v.CartAverageDiscount",Math.round(1000000*DiscountPrice/totalPrice)/10000);
        
        var currentItem = component.find("setCurrentItemDiscount");
        var currentItemId=  currentItem.get("v.value");
        component.get("v.opp")["Discount__c"]=itemMap[component.get("v.lineItem")["Id"]]["Discount__c"];
        component.set("v.cartDiscount",Math.round(100*itemMap[component.get("v.lineItem")["Id"]]["Discount__c"])/100);
       
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
                    
                    element.set("v.checked", false);
                   // initSelectedItems.push(iteratorItem);
                }else{
                    element.set("v.checked", false);
                    
                }
                if(itemMap[iteratorItem]["Discount__c"]==component.get("v.opp")["Discount__c"]
                   && component.get("v.opp")["Discount__c"]>0){
                    itemWrapperMap[iteratorItem]["isDiscountSelected"] = false;
                //    initSelectedItemsExcludeCurrentItem.push(iteratorItem);
                }else{
                    itemWrapperMap[iteratorItem]["isDiscountSelected"] = false;
                }
            });
        }else{
            var iteratorItem = initialSelectBoxCmp.get("v.value");
            if(iteratorItem!=component.get("v.lineItem")["Id"] 
               && itemMap[iteratorItem]["Discount__c"]==component.get("v.opp")["Discount__c"]
               && component.get("v.opp")["Discount__c"]>0){
                
                initialSelectBoxCmp.set("v.checked", false);
              //  initSelectedItems.push(iteratorItem);
            }else{
                initialSelectBoxCmp.set("v.checked", false);
                
            }
            if(itemMap[iteratorItem]["Discount__c"]==component.get("v.opp")["Discount__c"]
               && component.get("v.opp")["Discount__c"]>0){
                itemWrapperMap[iteratorItem]["isDiscountSelected"] = false;
               // initSelectedItemsExcludeCurrentItem.push(iteratorItem);
            }else{
                itemWrapperMap[iteratorItem]["isDiscountSelected"] = false;
            }
        }
        itemWrapperMap[component.get("v.lineItem")["Id"] ]["isDiscountSelected"] = true;
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
        var opp = component.get("v.opp");
        
        var allItems =  component.get("v.shoppingCartLineItems");
        var itemMap=[];
        var itemDiscountPriceMap=[];
        var itemTotal=[];
        var totalSize;        
        var totalPrice=0;
        var DiscountPrice=0;
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
            SelectedTotalOriginalPrice +=Number((itemMap[updatedValue]["List_Price__c"]*itemMap[updatedValue]["Quantity__c"]).toFixed(2));
         }else{
            SelectedTotalOriginalPrice -=Number((itemMap[updatedValue]["List_Price__c"]*itemMap[updatedValue]["Quantity__c"]).toFixed(2));    
        }
        component.set("v.SelectedTotalOriginalPrice",SelectedTotalOriginalPrice);

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
                if(itemId!=currentItemId && itemMap[itemId]["Product_SKU__c"][0]!='*' && itemDiscountPriceMap[itemId]["isLocked"]==false){
                    if(!element.get("v.checked")) {
                        selectedAll=false;
                    }else{
                        checkSelectedItem.push(itemId);
                    } 
                }
            });
        }else{
            var itemId= component.find("setDiscount").get("v.value");
            if(itemId!=currentItemId && itemMap[itemId]["Product_SKU__c"][0]!='*' && itemDiscountPriceMap[itemId]["isLocked"]==false){
                if(!component.find("setDiscount").get("v.checked")) {
                    selectedAll=false;
                }else{
                    checkSelectedItem.push(itemId);
                } 
            }
        }
        
        component.find("setAllDiscount").set("v.checked", selectedAll);
        helper.updateAllAfterAction(component,itemMap,itemDiscountPriceMap,checkSelectedItem);
                
        helper.setupApproverSelectBox(component);
    },
    changeDiscount: function(component, event, helper){
        var updatedValue = event.getSource().get("v.value");
        var auraId = event.getSource().get("v.name");
        var itemTotalPrice =  component.get("v.SelectedTotalOriginalPrice");
        
        if(auraId=='itemsPrice'){
            component.find("flatDiscountAmount").set("v.value",(itemTotalPrice-updatedValue));
            var percentDiscountAmount = Math.round(1000000*(itemTotalPrice-updatedValue)/itemTotalPrice)/10000;
            
           var opp=component.get("v.opp");
            opp["Discount__c"]=percentDiscountAmount;
            component.set("v.opp",opp);
            
                component.find("percentDiscountAmount").set("v.value",Math.round(100*percentDiscountAmount)/100);
        
            
        }else if(auraId=='flatDiscountAmount'){
            
            component.find("itemsPrice").set("v.value",(itemTotalPrice-updatedValue));
            var percentDiscountAmount = Math.round(1000000*(updatedValue)/itemTotalPrice)/10000;
             var opp=component.get("v.opp");
            opp["Discount__c"]=percentDiscountAmount;
            component.set("v.opp",opp);
            component.find("percentDiscountAmount").set("v.value",Math.round(100*percentDiscountAmount)/100);
        
        }else if(auraId=='percentDiscountAmount' ){
            component.find("itemsPrice").set("v.value",Math.round(100*itemTotalPrice-updatedValue*itemTotalPrice)/100);
            component.find("flatDiscountAmount").set("v.value",Math.round(updatedValue*itemTotalPrice)/100);
            
            var opp=component.get("v.opp");
            opp["Discount__c"]=updatedValue;
            component.set("v.opp",opp);
        }
        
         helper.caculateOriginalPrice(component,helper);
        
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
                if(itemId!=currentItemId && itemMap[itemId]["Product_SKU__c"][0]!='*' && itemDiscountPriceMap[itemId]["isLocked"]==false){
                    element.set("v.checked", checkFlag);
                    if(checkFlag){
                        changeSelectedItems.push(itemId);
                    }
                }
            });
        }else{
             var itemId=  component.find("setDiscount").get("v.value");
                if(itemId!=currentItemId && itemMap[itemId]["Product_SKU__c"][0]!='*' && itemDiscountPriceMap[itemId]["isLocked"]==false){
                     component.find("setDiscount").set("v.checked", checkFlag);
                    if(checkFlag){
                        changeSelectedItems.push(itemId);
                    }
                }
        }

        helper.caculateOriginalPrice(component,itemMap,itemDiscountPriceMap,changeSelectedItems);
        
        helper.setupApproverSelectBox(component);
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