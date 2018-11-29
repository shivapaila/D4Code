({
    handleError : function(errors, isIncomplete) {
        var error = "Unknown error";
        if (errors) {
            if (errors[0] && errors[0].message) {
                error =  errors[0].message;
            }
        }
        if(isIncomplete) {
            error = 'could not complete request, please check back later';
        }
        this.showToast('Error', '', error);
    },
    
    showToast : function(type, title, message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message": message,
            "type": type,
        });
        toastEvent.fire();
    }
})