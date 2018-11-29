({
   doInit : function(component, event, helper) {
       helper.initialCustomerList(component, event, helper);
    },
    search: function(component, event, helper) {        
        var searchKeyFld = component.find("searchId");
        var srcValue = searchKeyFld.get("v.value");
        
        searchKeyFld.set("v.errors", null);
        // call helper method
        if(srcValue !=null && srcValue != ''){
            helper.SearchHelper(component, event);
        }
        else{
            helper.initialCustomerList(component, event, helper);//component.set('v.accounts',null);
        }
        
        
    },
    attachSignature : function(component, event, helper) {
       
        var selectedItem = event.currentTarget; 
        var RecordId = selectedItem.dataset.record;
        //event to notify Parent to openSignatureListModal, attachSignature
        var eventComponent = component.getEvent("NotifyParentOpenModal");
        eventComponent.setParams({ "notifyParam": RecordId });
        eventComponent.fire(); 
        
    },
    renderPage: function(component, event, helper) {
          helper.renderPage(component,event,helper);
    },
    addtocart : function(component, event, helper) {
        var selectedItem = event.currentTarget; 
        var RecordId = selectedItem.dataset.record;
        //event to notify Parent to openSignatureListModal, attachSignature
        var eventComponent = component.getEvent("NotifyParentAddToCart");
        eventComponent.setParams({ "notifyParam": RecordId, "notifyParam1": 'FindCustomer' });
        eventComponent.fire(); 
    },
    goToRecord : function(component, event, helper) {
        var element = event.target;
        while (element && (element.tagName !== 'A')) {
            element = element.parentNode;
        }
        if (element) {
            event.stopPropagation();
            event.preventDefault();

            var recordId = element.getAttribute('data-record');
            var appEvent = $A.get("e.c:NavigateToWrapperComponentAppEvent");
            appEvent.setParams({
                "targetCmpName" : 'CustomersCartWrapperCmp',
                "targetCmpParameters" : {"recordId": recordId}
            });
            appEvent.fire();           
        }
	}
})