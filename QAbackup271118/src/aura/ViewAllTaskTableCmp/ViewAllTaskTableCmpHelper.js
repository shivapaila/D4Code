({
    sortBy: function(component, field) {
        var lst = component.get('v.allTasksLst');
        var tsk=[];
        for(var i=0;i<lst.length;i++){
            //var lst=component.get('v.currentList')[i];
            console.log('-->'+JSON.stringify(lst[i].taskObj));
            tsk.push(lst[i].taskObj);
        }
        
        console.log('tsk-->'+tsk.length);
        component.set('v.AllTasks',tsk);
        var sortAsc = component.get("v.sortAsc"),
            sortField = component.get("v.sortField"),
            records = component.get("v.AllTasks");
        sortAsc = sortField != field || !sortAsc;
        records.sort(function(a,b){
            var t1 = a[field] == b[field],
                t2 = (!a[field] && b[field]) || (a[field] < b[field]);
            return t1? 0: (sortAsc?-1:1)*(t2?1:-1);
        });
        component.set("v.sortAsc", sortAsc);
        component.set("v.sortField", field);
        console.log('after sort-->'+records.length);
        component.set("v.AllTasks", records);
        var action = component.get("c.formWrapper");
        action.setParams({
            'tskLst':component.get("v.AllTasks")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var val=response.getReturnValue();
                console.log('sorted returned-->'+JSON.stringify(val.wrapperLst));
                
                component.set("v.allTasksLst",val.wrapperLst);
                this.renderPage(component);
            }
            
        });
        $A.enqueueAction(action);
        
    },
    renderPage: function(component, event, helper) {
        var records = component.get("v.allTasksLst"),
            pageNumber = component.get("v.pageNumber"),
            pageRecords = records.slice((pageNumber-1)*10, pageNumber*10);
        component.set("v.currentList", pageRecords);
        console.log(component.get('v.currentList'));
    }
})