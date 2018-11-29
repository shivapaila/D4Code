({
	doInit : function(component, event, helper) {
     var productId =   component.get('v.productDetailId');
     var skey = component.get('v.searchKey');
        //alert('skey is '+skey);
        if(skey != null){
           // alert('entered if');
          // component.set("v.productDetailId",null); 
          /* var appEvent = $A.get("e.c:NavigateToWrapperComponentAppEvent");
            appEvent.setParams({
                "targetCmpName" : 'ProductCategoryWrapperCmp',
                "targetCmpParameters" : {"parentCategoryId": null, "productDetailId": null, "searchKey": skey}
            });             
            appEvent.fire();*/
            window.location.reload(true);
           //alert('event fired if');
        }
         else{
             //alert('in else');
		helper.initialProductDetail(component, helper);
        }
        
	}, 
    expandDescription : function(component, event, helper) {
        var closedText = 'More +';
        var openText = 'Less -';
        if (component.get("v.descriptionLinkText") == closedText) {
            var descTarget = component.find('productDescription');
            $A.util.removeClass(descTarget, 'details');
            component.set("v.descriptionLinkText", openText);            
        } else {
            var descTarget = component.find('productDescription');
            $A.util.addClass (descTarget, 'details');            
            component.set("v.descriptionLinkText", closedText);            
        }

    }, 
    expandDimension : function(component, event, helper) {
        var closedText = 'More +';
        var openText = 'Less -';
        if (component.get("v.dimensionLinkText") == closedText) {
            var dimeTarget = component.find('dimensionDescription');
            $A.util.removeClass(dimeTarget, 'details');
            component.set("v.dimensionLinkText", openText);            
        } else {
            var dimeTarget = component.find('dimensionDescription');
            $A.util.addClass (dimeTarget, 'details');            
            component.set("v.dimensionLinkText", closedText);            
        }

    }, 
    addToCart : function(component, event, helper) {
        // FIXME
        component.set("v.showcustomerModal", true);
        var overlay = component.find('backdrop');
        $A.util.addClass(overlay, 'slds-backdrop--open');
    },
    closeCustomerModal: function(component, event, helper) {
        component.set("v.showcustomerModal", false);
        var overlay = component.find('backdrop');
        $A.util.removeClass(overlay, 'slds-backdrop--open');
	},
    closeCustomerModalAndRefresh: function(component, event, helper) {
        
        component.set("v.showcustomerModal", false);
        var overlay = component.find('backdrop');
        $A.util.removeClass(overlay, 'slds-backdrop--open');
        //In case add to cart for new guest, refresh concierge_head active cart numbers,so refresh whole page
        // var subComponentName =  event.getParam("notifyParam1");        
        //  if (['AddCustomer','FindCustomer'].indexOf(subComponentName) > -1) {
        //Both FindCustomer and AddCustomer addToCart action need to refresh header component to refresh the active cart number
    
            var appEvent = $A.get("e.c:NotifyHeaderComponentEvent"); 
            appEvent.fire();
        // }
	},
    openDeliveryModal: function(component, event, helper) {
        component.set("v.showDeliveryModal", true);
        var overlay = component.find('backdrop');
        $A.util.addClass(overlay, 'slds-backdrop--open');    
    },
    closeDeliveryModal: function(component, event, helper) {
        component.set("v.showDeliveryModal", false);
        var overlay = component.find('backdrop');
        $A.util.removeClass(overlay, 'slds-backdrop--open');    
    },
    decrement : function(component, event, helper) {
        var quantity = component.get("v.quantity"); 
        quantity--;
        if (quantity > 0) {
            component.set("v.quantity", quantity);            
        }
    }, 
    increment : function(component, event, helper) {
        var quantity = component.get("v.quantity"); 
        quantity++;
        component.set("v.quantity", quantity);            
    }, 
    goToProduct : function(component, event, helper) {
        var selectedItem = event.currentTarget; 
        var skuInfo = selectedItem.dataset.record; 
		helper.navToProduct(component, skuInfo);
    },
    mattressSelect: function(component, event, helper) {
        var skuInfo = component.find("mattressField").get("v.value");
        console.log('sku is ' + skuInfo);
        if (!$A.util.isEmpty(skuInfo)) {
            console.log('nav');
            helper.navToProduct(component, skuInfo);            
        }
    },
    showImageModal: function(component, event, helper) {
        component.set("v.showModal", true);
        var overlay = component.find('overlay');
        $A.util.addClass(overlay, 'slds-backdrop--open');        
    }, 
    closeImageModal: function(component, event, helper) {
        component.set("v.showModal", false);
        var overlay = component.find('overlay');
        $A.util.removeClass(overlay, 'slds-backdrop--open');
    },
    shiftImageLeft: function(component, event, helper) {
       /* var left = component.get("v.start");
        var right = component.get("v.end");
        if (left > 0) {
            component.set("v.start", left-1);		
            component.set("v.end", right-1);   
        }	*/
        
        /*var currentOffset = $( "div.scroll-horizontal" ).scrollLeft();
        $( "div.scroll-horizontal" ).scrollLeft( currentOffset-300 );*/

        var productThumbWrapper = component.find('productThumbWrapperElement');
        if (productThumbWrapper) {
            var productThumbWrapperElement = productThumbWrapper.getElement();
            var currentOffset = productThumbWrapperElement.scrollLeft;
            productThumbWrapperElement.scrollLeft = currentOffset-300;
        }        
        
    },
    shiftImageRight: function(component, event, helper) {
       /* var imagelist = component.get("v.productDetail.media");
        var left = component.get("v.start");
        var right = component.get("v.end");
        if (right < imagelist.length) {
            component.set("v.start", left+1);		
            component.set("v.end", right+1);		
        }*/
        /*var currentOffset = $( "div.scroll-horizontal" ).scrollLeft();
        $( "div.scroll-horizontal" ).scrollLeft( currentOffset+300 );*/

        var productThumbWrapper = component.find('productThumbWrapperElement');
        if (productThumbWrapper) {
            var productThumbWrapperElement = productThumbWrapper.getElement();
            var currentOffset = productThumbWrapperElement.scrollLeft;
            productThumbWrapperElement.scrollLeft = currentOffset+300;
        }         
    },
    changeImage: function(component, event, helper) {
        var selectedItem = event.currentTarget; 
        var selectedImage = selectedItem.dataset.record;
        component.set("v.mainImage", selectedImage);
    },
    handlePriceEvent: function(component, event) {
        // set the attributes based on event data
        console.log('event -->'+event.getParam("productPrice"));
        component.set('v.productPrice',event.getParam("productPrice"));
    },
    doIn:function(component,event){
       window.location.reload(true);
    }
})