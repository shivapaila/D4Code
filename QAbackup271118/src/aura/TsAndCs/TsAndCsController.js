({
    doInit : function(component, event, helper) {
        helper.createSignatureObj(component, helper);
    }, 
    cancelDialog : function(component, helper) {
        component.getEvent("NotifyParentCloseTsAndCs").fire();
    }, 
    goToNext : function(component, event, helper) {
        helper.goForward(component, helper);
       //  window.location.reload(true);
    },
    /*
    //REQ-441 Remove Capture Signature Control
    handleScroll : function(component, event, helper) {
        var scrollCompleted = false;
        $(".signatureWrapper").hide();
        $(".tcsContent").scroll(function(){
            var a=$(".tcsContent").scrollTop();
            var b=$(".tcsContent").innerHeight();
            var c=$(".tcsContent")[0].scrollHeight;
            console.log('logic execution');
            if(!scrollCompleted){
                if(a + b >= c){
                   $(".signatureWrapper").show();
                   scrollCompleted = true;
                }else{
                   $(".signatureWrapper").hide();
                }
            }
        });	
	}*/
})