({
    validateAmount: function(amt, totalAmt, targeAmt) {
    	if($A.util.isEmpty(amt)|| isNaN(amt)){
            this.toastMessage("error","","Please enter valid amount.");
            return false;
        }
        else if(amt <= 0) {
        	this.toastMessage('error', '', 'Transaction Amount should be greater than 0.');
        	return false;
        }
        else if(totalAmt > targeAmt) {
        	this.toastMessage("error","","The amount exceed the total amount.");
        	return false;
        }
        return true;
    },
	toastMessage : function(type,title,message){
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            type: type,
            title: title, 
            message: message,
        });
        toastEvent.fire();
    }
})