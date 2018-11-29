({
    search: function(component, event, helper) {
        var searchKeyFld = component.find("searchId");
        var zipValue = searchKeyFld.get("v.value");
        
        if (/(^\d{5}$)|(^\d{5}-\d{4}$)/.test(zipValue)) {
            helper.searchHelper(component, event);
        } else {
           helper.showToast("error", 'Search Input', component,
                            'Please input a valid zip code.');            
        }
    },
})