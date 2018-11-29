({
    doInit: function(component, event, helper) {
     	 //alert('enter');
      //  alert('shopping cart '+ component.set("v.RendershpForUpdate"));
        helper.tresholdenabledcall(component, helper);
        component.set("v.currentUserId",$A.get("$SObjectType.CurrentUser.Id"));
        component.set("v.RendershpForUpdate");
        var productSku = component.get('v.productSKUId');
        if(productSku.startsWith('*')){
            component.set('v.isStarItem', true);
            helper.initialLineItem(component, helper); 
        }else{
            component.set('v.isStarItem', false);
            // DEF-0780 - no need to get product detail
            //helper.initialProductDetail(component, helper);
            helper.initialLineItem(component, helper);
            helper.checkLineItemLocked(component, helper);  
        }
        //alert('exit');
    },
    donetreshold :function(component, event, helper) {
        component.set("v.Tresholdpopup",false);
        
    },
    checkPremiumhomedelivery :function(component, event, helper) {
     
        var phd=component.get("v.Premiumhomedelivery");
       
        if(phd==true){
        //  alert('true1');
           component.set("v.freehomedelivery",false);  
           component.set("v.deliveryType","PDI");  
        }
        
    },
    checkfreehomedelivery :function(component, event, helper) {
       var fhd =component.get("v.freehomedelivery");
        if(fhd==true){
         //   alert('true2');
          	component.set("v.Premiumhomedelivery",false);
            component.set("v.deliveryType","THD");  
        }
        
       
    },
    
    checkdeliveryvideo :function(component, event, helper) {
       var tdv=component.get("v.tresholddeliveryvideo");
       // alert('tdv'+tdv);
        if(tdv==true){
            component.set("v.deliveryvideopopup",true);
        }
    },
    closevideomodal :function(component, event, helper) {
        component.set("v.deliveryvideopopup",false);
    },
    openModal : function(component, event, helper){
        var selectedItem = event.currentTarget; 
        var containerName = selectedItem.dataset.record;       
        var popUp = component.find(containerName);
        $A.util.removeClass(popUp, 'slds-fade-in-close');
        $A.util.addClass(popUp, 'slds-fade-in-open');
        var backdrop = component.find("backdropContainer");
        $A.util.removeClass(backdrop, 'slds-modal-backdrop--close');
        $A.util.addClass(backdrop, 'slds-modal-backdrop--open');
        var discountType = component.get("v.lineItem")["DiscountType__c"];
        
        component.set("v.selectedDiscountType",discountType);
        var discountReasonCode = component.get("v.lineItem")["Discount_Reason_Code__c"];
        component.find("discountReasonOption").set("v.value",discountReasonCode);
        
        
        var deliveryMode = component.get("v.lineItem")["Delivery_Mode__c"];
        component.set("v.selectedShippingWay",deliveryMode);
        component.find("shippingWay").forEach(function(element){
            if(element.get("v.value")==deliveryMode)
                element.set("v.checked", true);
            else
                element.set("v.checked", false);
        });  
        var discountStatus = component.get("v.lineItem")["Discount_Status__c"];
        if(discountStatus=="Discount Pending Approval")
            component.set("v.locked",true);
  
      
        helper.setupApproverSelectBox(component,discountType);
    },
    cancelModal : function(component, event, helper){
        var selectedItem = event.currentTarget; 
        var containerName = selectedItem.dataset.record;
        helper.closeModal(component,containerName);
        component.set("v.Premiumhomedelivery",false);
        component.set("v.freehomedelivery",false);
    },
    
    handleShippingWayRadioClick: function(component, event, helper){
        var currentChoosedShippingWay = event.getSource().get("v.value");
       if(currentChoosedShippingWay=='HD'){
          component.set("v.Tresholdpopup",true);
         component.set("v.againTresholdpopup",true);  
        }else{
          component.set("v.Tresholdpopup",false);  
            component.set("v.againTresholdpopup",false);  
        } 
        //alert('currentChoosedShippingWay'+currentChoosedShippingWay);
        component.set("v.selectedShippingWay",currentChoosedShippingWay);
        component.find("shippingWay").forEach(function(element){
            if(element.get("v.value")==currentChoosedShippingWay)
            	element.set("v.checked", true);
            else
                element.set("v.checked", false);
        });
    },
    
    updateDeliveryMode: function(component, event, helper){
        
        var selectedItem = event.currentTarget; 
        var sku = selectedItem.dataset.record;
        helper.saveDeliveryMode(component, helper);
        component.set("v.Tresholdpopup",true);
        
    },
    deleteLineItem: function(component, event, helper){
        var selectedItem = event.currentTarget; 
        var lineItemId = selectedItem.dataset.record;
        helper.deleteFromCart(component, helper, lineItemId);
    },
    changeAsIs: function(component, event, helper){
        var lineItemId = component.get("v.lineItemId");
        var aiv=component.get("v.lineItem.As_Is__c");
        helper.updateAsIs(component, helper, lineItemId, aiv);
    },
    moveToWishlist: function(component, event, helper){
        
    },
    updateFPP: function(component, event, helper){
        component.set('v.SelectedWarranty',event.target.value);
        var fppsku = event.target.value;
        helper.updateFPPSKU(component, helper, fppsku);        
    },
    changeDiscount: function(component, event, helper){
         var updatedValue = event.getSource().get("v.value");
        var auraId = event.getSource().get("v.name");
        var itemTotalPrice = component.get("v.itemTotalPrice");
        if(auraId=='itemsPrice'){
            component.find("flatDiscountAmount").set("v.value",(itemTotalPrice-updatedValue));
            component.find("percentDiscountAmount").set("v.value",Math.round(10000*(itemTotalPrice-updatedValue)/itemTotalPrice)/100);
            
            var discountType = 'Flat';
            component.set("v.selectedDiscountType",discountType);
            
            helper.setupApproverSelectBox(component,discountType);
        }else if(auraId=='flatDiscountAmount'){
            
            component.find("itemsPrice").set("v.value",(itemTotalPrice-updatedValue));
            component.find("percentDiscountAmount").set("v.value",Math.round(10000*(updatedValue)/itemTotalPrice)/100);
            var discountType = 'Flat';
            component.set("v.selectedDiscountType",discountType);
            
            helper.setupApproverSelectBox(component,discountType);
        }else if(auraId=='percentDiscountAmount' ){
            component.find("itemsPrice").set("v.value",Math.round(100*itemTotalPrice-updatedValue*itemTotalPrice)/100);
            component.find("flatDiscountAmount").set("v.value",Math.round(updatedValue*itemTotalPrice)/100);
            
            var discountType = 'Percent';
            component.set("v.selectedDiscountType",discountType);
            
            helper.setupApproverSelectBox(component,discountType);
        }
    },
    updateDiscount : function(component, event, helper){
        helper.saveDiscount(component, helper);
    },
    navigateToProd: function(component, event, helper) {
        var selectedItem = event.currentTarget; 
        var productId = selectedItem.dataset.record;
        var appEvent = $A.get("e.c:NavigateToWrapperComponentAppEvent");
        appEvent.setParams({
            "targetCmpName" : 'ProductCategoryWrapperCmp',
            "targetCmpParameters" : {"parentCategoryId": null, "productDetailId": productId, "searchKey": null}
        });             
        appEvent.fire();  
    },
   decrement : function(component, event, helper) {
       
       var quantity = component.find("itemQuantity").get("v.value"); 
        quantity--;
        if (quantity > 0) {
            component.find("itemQuantity").set("v.value",quantity); 
            
            helper.updateQuantity(component,quantity);
        }else{
            //REQ-489 item 3
            var containerName = 'deleteConfirmContainer';       
            var popUp = component.find(containerName);
            $A.util.removeClass(popUp, 'slds-fade-in-close');
            $A.util.addClass(popUp, 'slds-fade-in-open');
            var backdrop = component.find("backdropContainer");
            $A.util.removeClass(backdrop, 'slds-modal-backdrop--close');
            $A.util.addClass(backdrop, 'slds-modal-backdrop--open');
        }
    },
    increment : function(component, event, helper) {
       var quantity = component.find("itemQuantity").get("v.value"); 
       quantity++;
       component.find("itemQuantity").set("v.value",quantity); 
       helper.updateQuantity(component,quantity);
    },
    mannualUpdateQuantity : function(component, event, helper) {
        var quantity =  component.find("itemQuantity").get("v.value");
        helper.updateQuantity(component,quantity);
    },
    deleteFPP:function(component, event, helper) {
        var selectedItem = event.currentTarget; 
        var lineItemId = selectedItem.dataset.record;
        var fppsku='';
        helper.updateFPPSKU(component, helper, fppsku);
    },
    openDiscountModal:function(component,event,helper){
        //event to notify Parent to openDiscountModal
        var eventComponent = component.getEvent("NotifyParentOpenDiscountModal");
        eventComponent.setParams({ "notifyParam":  component.get('v.lineItem')});
        eventComponent.setParams({ "notifyParam1": component.get('v.productDetail') });
        eventComponent.fire(); 
    },
    handleDeliveryDateSelected : function(component, event, helper){
        var DM =  event.getParam("deliveryMode");
        var deliveryMode =  component.get("v.lineItem.Delivery_Mode__c");
        if(DM == deliveryMode)
           component.set("v.lineItem.DeliveryDate__c",event.getParam("deliveryDate"));  
    }
})