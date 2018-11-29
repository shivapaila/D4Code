({
	openClose : function(component, event, helper) {
        var expanded = component.get("v.priceExpanded");
        var salePrice = component.get("v.ecommPrice");
        console.log('salepriceloigs' + JSON.stringify(salePrice));
        if (!expanded && $A.util.isEmpty(salePrice)) {
            helper.getSalePrice(component, event, helper);
        } else if (!expanded) {
            helper.open(component);
        } else {
            helper.close(component);
        }
    }
})