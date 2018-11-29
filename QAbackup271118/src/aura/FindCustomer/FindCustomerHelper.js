({
    initialCustomerList : function(component, event, helper) {
       var showView =  component.get("v.showView");
       console.log(showView == 'My Guests');
       if(showView == 'My Guests'){
           // Load all contact data
           var action = component.get("c.getAccounts");
           
           action.setCallback(this, function(response) {
               var state = response.getState();
                if (state === "SUCCESS"){
                    var val=response.getReturnValue();
                    if (val.length == 0) {
                      component.set("v.Message", true);
                    }else {
                      component.set("v.Message", false);
                      var sortOrder = component.get("v.sortOrder");
                      if(sortOrder!=null && sortOrder =="ASC"){
                        val.reverse();
                      }
                    }
                    component.set("v.accounts", val);
                    component.set("v.maxPage", Math.floor((val.length+9)/10));
                    helper.renderPage(component,event,helper);
                }
               
           });
           $A.enqueueAction(action);
       }else{           
         component.set("v.accounts", null);
       }
       
    },
    renderPage: function(component, event, helper) {
        console.log(component.get("v.accounts"));
        if(component.get("v.accounts") != null){
            var records = component.get("v.accounts"),
                pageNumber = component.get("v.pageNumber"),
                pageRecords = records.slice((pageNumber-1)*10, pageNumber*10);
            console.log(pageRecords);
            component.set("v.currentList", pageRecords);
        }
    },
    SearchHelper: function(component, event,helper) {
        
        var showView =  component.get("v.showView");        
        var action = component.get("c.findAccount");        
        action.setParams({
            'searchKeyWord': component.get("v.searchKeyword"),
            'isMyGuest': showView == 'My Guests'
        });
        
        var spinner = component.find("spinner");
        $A.util.toggleClass(spinner, "slds-hide");
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                // if storeResponse size is 0 ,display no record found message on screen.
                if (storeResponse.length == 0) {
                    component.set("v.Message", true);
                } else {
                    component.set("v.Message", false);
                }
                
                // set searchResult list with return value from server.
                
                if(storeResponse ==''){
                    component.set('v.pageNumber',0);  
                }
                else{
                    component.set('v.pageNumber',1);
                }
                var sortOrder = component.get("v.sortOrder");
                if(sortOrder!=null && sortOrder =="ASC"){
                    storeResponse.reverse();
                }
                component.set("v.accounts", storeResponse);
                component.set("v.maxPage", Math.floor((storeResponse.length+9)/10));
                this.renderPage(component, event, helper);
                
            }
            $A.util.toggleClass(spinner, "slds-hide");    
        });
        $A.enqueueAction(action);
        
    }
})