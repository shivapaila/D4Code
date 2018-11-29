({
	hideSigModal : function(component) {
        var cmpBack = component.find('Modalbackdrop');
        $A.util.removeClass(cmpBack,'slds-backdrop--open');
       	component.set("v.showSignature", false);		
	}
})