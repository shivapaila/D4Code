({
	init : function(component, event, helper) {
        
        /*
        //Read pageReference
	    var pageReference = component.get("v.pageReference");
        
         // If navigation from another location
        if (!$A.util.isUndefinedOrNull(pageReference)){
            //Read parameters from pageReference state
            var receivedParams = pageReference.state;
            //Set component attributes to paameters received from state
    	 	if(!$A.util.isUndefinedOrNull(receivedParams.c__recordId)){
                //window.location.reload(true);
                component.set("v.guestId",receivedParams.c__recordId);
                console.log('recordi' + component.get("v.guestId"));
                component.set("v.renderSubComponent",true);
            } 
                                    

        }*/
        
              
        var pageReference = component.get("v.pageReference");
        
        if(pageReference != null){
            //alert('test');
            //Read parameters from pageReference state
            var receivedParams = pageReference.state; 
            //alert('receivedParams------'+receivedParams);
            //Set component attributes to pameters received from state
            
            if(!$A.util.isUndefinedOrNull(receivedParams.c__recordId)){
                component.set("v.guestId",receivedParams.c__recordId);
                component.set("v.rendSubComponent",true);
                component.set("v.rSubComponent",true);
                  
                
            }
           
        }
        
               
	}
})