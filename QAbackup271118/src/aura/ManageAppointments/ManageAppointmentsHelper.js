({
	renderPage: function(component, event, helper) {
		var records = component.get("v.TodaysEvents"),
            pageNumber = component.get("v.pageNumber"),
            pageRecords = records.slice((pageNumber-1)*10, pageNumber*10);
        component.set("v.currentList", pageRecords);
        console.log(component.get('v.currentList'));
	}
})