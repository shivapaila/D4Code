({
	getRecordId : function(cmp, event, helper) {
        // Get record id from Url 
        var sPageURL = decodeURIComponent(window.location); //You get the whole decoded URL of the page.
        var sURLVarString = sPageURL.split('?'); //Split by & so that you get the key value pairs separately in a list
        var sURLVariables = sURLVarString[sURLVarString.length-1].split('&'); //Split by & so that you get the key value pairs separately in a list
        var sParameterName;
        var paramObj = new Object();
        var i;
		
        for (i = 0; i < sURLVariables.length; i++) {
            sParameterName = sURLVariables[i].split('='); //to split the key from the value.
            paramObj[sParameterName[0]] = sParameterName[1];
        }
        cmp.set('v.guestId',paramObj['recordId']);
        cmp.set('v.oppId',paramObj['oppId']);   
	}
})