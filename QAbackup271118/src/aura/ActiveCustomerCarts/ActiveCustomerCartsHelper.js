({
	renderPage: function(component, event, helper) {
		var records = component.get("v.customerwithActiveCartLst"),
			//var records = component.get("v.getCustomerwithActiveCarts"),
            pageNumber = component.get("v.pageNumber"),
            pageRecords = records.slice((pageNumber-1)*10, pageNumber*10);
        //alert('page records'+JSON.stringify(pageRecords));
        component.set("v.currentList", pageRecords);
	},
    SearchHelper: function(component, event,helper) {
       
         if(component.get("v.searchKeyword"))
        {
        var action = component.get("c.fetchAccount");
        action.setParams({
            'searchKeyWord': component.get("v.searchKeyword")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
               //alert('store response is '+JSON.stringify(storeResponse));
                // if storeResponse size is 0 ,display no record found message on screen.
                if (storeResponse.length == 0) {
                    component.set("v.Message", true);
                    component.set('v.pageNumber',0);
                } else {
                    component.set('v.pageNumber',1);
                    component.set("v.Message", false);
                }
                
                // set searchResult list with return value from server.
                
                component.set("v.customerwithActiveCartLst", storeResponse);
                component.set("v.maxPage", Math.floor((storeResponse.length+9)/10));
                this.renderPage(component, event, helper);
                
            }
 
        });
        $A.enqueueAction(action);
		}
		else
        {
            var val= component.get("v.initialLst");
            component.set("v.customerwithActiveCartLst",val);
            component.set("v.maxPage", Math.floor((val.length+9)/10));
            this.renderPage(component, event, helper);
        }
    },
})