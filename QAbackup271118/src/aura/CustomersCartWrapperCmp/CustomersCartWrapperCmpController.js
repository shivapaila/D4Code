({
	init : function(component, event, helper) {
      
		       
        var pageReference = component.get("v.pageReference");
        
        if(pageReference != null){
            //Read parameters from pageReference state
            var receivedParams = pageReference.state;
            //alert('receivedParams------'+receivedParams);
            //Set component attributes to pameters received from state
            
            if(!$A.util.isUndefinedOrNull(receivedParams.c__recordId)){
                component.set("v.recordId",receivedParams.c__recordId);
                component.set("v.renderSubComponent",true);
                component.set("v.SubComponent",true);
               
                 
            }
           
        }
	}
   

})