({
    // Method to create signature object
    doInit : function(component, event, helper) {
        helper.createSignatureObj(component, helper);
    }, 
    
    
    // Method to close Customer Order Acceptance overlay 
    cancelDialog : function(component, helper) {
        component.getEvent("NotifyParentCloseAcceptance").fire();
    }, 
    
    // Method to proceed with placing the order once the customer has signd and accepted
    goToNext : function(component, event, helper) {
        helper.goForward(component, helper);
    },
    
    handleScroll : function(component, event, helper) {
        var scrollCompleted = false;
        $(".signatureWrapper").hide();
        $(".tcsContent").scroll(function(){
            var a=$(".tcsContent").scrollTop();
            var b=$(".tcsContent").innerHeight();
            var c=$(".tcsContent")[0].scrollHeight;
            if(!scrollCompleted){
                if(a + b >= c){
                   $(".signatureWrapper").show();
                   scrollCompleted = true;
                }else{
                   $(".signatureWrapper").hide();
                }
            }
        });	
	}
})