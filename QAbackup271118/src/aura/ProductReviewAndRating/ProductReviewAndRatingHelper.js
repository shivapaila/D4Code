({
	 initialProductRating : function(component, helper) {
         var action = component.get("c.getProductRatingList");
         var productIdList = [];
         productIdList.push(component.get("v.productDetailId"));
         action.setParams({"productIdList" : productIdList });
         
         action.setCallback(this, function(a){
             var state = a.getState();
             if (state === "SUCCESS") {
                 var rtnValue = a.getReturnValue();
                 if(rtnValue!=null){
                     var thisSku = component.get("v.productDetailId");
                     var productRatings = rtnValue[thisSku] ? rtnValue[thisSku] : [];
                     if(!$A.util.isEmpty(productRatings)){
                         component.set("v.productRating", productRatings["averageOverallRating"]);
                         // note - this value is the total count of reviews for this product and related products
                         component.set("v.productReviewsSize", productRatings["totalReviewCount"]);
                         
                     }
                 }
                 
             }else if (state === "ERROR") {                        
                 helper.showToast("error", 'Rating Load Error', component,
                                  a.getError()[0].message);
             }
         });        
         action.setBackground();
         $A.enqueueAction(action); 
     },
    initialProductReviews : function(component, helper) {
        var action = component.get("c.getProductReviewList");
        var productIdList = [];
        productIdList.push(component.get("v.productDetailId"));
        action.setParams({"productIdList" : productIdList });
        
        action.setCallback(this, function(a){
            var state = a.getState();
            if (state === "SUCCESS") {
                var rtnValue = a.getReturnValue();
                 console.log(rtnValue);
                if (rtnValue !== null) {   
                    // note - this api returns reviews for the requested product 
                    // as well as for related products. 
                    // per chatter on the user story https://ashley.lightning.force.com/one/one.app#/sObject/a056A00000DvnFfQAJ/view
                    // the intent was to supply the maximum relevant reviews
                    // to that end we are combining the list and showing the top 5
                    var thisSku = component.get("v.productDetailId");
                    var productReviews = rtnValue[thisSku] ? rtnValue[thisSku] : [];
                    for (var key in rtnValue) {
                        if (key != thisSku) {
                        	productReviews = productReviews.concat(rtnValue[key]);                            
                        }
                    }
                    component.set("v.productReviews", productReviews);
                }
            }else if (state === "ERROR") {                        
                helper.showToast("error", 'Review Load Error', component,
                                 a.getError()[0].message);
            }
        });        
        action.setBackground();
        $A.enqueueAction(action); 
    }, 
    showToast : function(type, title, component, message) {
        var inConsole = component.get("v.inSvcConsole");
        if (!inConsole) { // if we're in lightning message this way
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                type: type,
                // note - leaving mode field for reference 
                //mode: 'dismissible',
                title: title,
                message: message,
            });
            toastEvent.fire();
        } else {
            component.set("v.messageType", type);
            component.set("v.message", message);
        }
    },
})