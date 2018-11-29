({
	doInit : function(component, event, helper) {
        if( component.get("v.productDetailId")!==undefined
           && component.get("v.productDetailId")!=null ){
            var onlyRating = component.get("v.onlyRating");
            if(onlyRating){   
                helper.initialProductRating(component, helper);
            }else{       
                helper.initialProductRating(component, helper);
                helper.initialProductReviews(component, helper);
            }
        }
	}, 
    expandReviews : function(component, event, helper) {
        var closedText = 'More +';
        var openText = 'Less -';
        var max = component.get("v.productReviewsSize")-1;
        if(max > 4){
            max = 4;
        }
        if (component.get("v.reviewLinkText") == closedText) {
            component.set("v.end", max+1);            
            component.set("v.reviewLinkText", openText);            
        } else {
            component.set("v.end", 1);            
            component.set("v.reviewLinkText", closedText);            
        }

    }  
})