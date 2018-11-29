({
    close : function(component) {
        component.set("v.showModal", false);
        var overlay = component.find('overlay');
        $A.util.removeClass(overlay, 'slds-backdrop--open');
    }
})