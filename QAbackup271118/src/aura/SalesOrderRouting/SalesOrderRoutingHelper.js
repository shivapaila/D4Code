({
	sortByOrders: function(component, field) {
        var sortAsc = component.get("v.sortAsc"),
            sortField = component.get("v.sortField"),
            recordsOrdrs = component.get("v.orders");
         
          	sortAsc = sortField != field || !sortAsc;  
        
        recordsOrdrs.sort(function(a,b){
            var t1 = a[field] == b[field],
                //t2 = a[field] > b[field];
            //return t1? 0: (sortAsc?-1:1)*(t2?-1:1);
            
            t2 = (!a[field] && b[field]) || (a[field] < b[field]); 
            return t1? 0: (sortAsc?-1:1)*(t2?1:-1);
        });
        component.set("v.sortAsc", sortAsc);
        component.set("v.sortField", field);
        component.set("v.orders", recordsOrdrs);    
    },
    
    sortBy: function(component, field) {
        var sortHisAsc = component.get("v.sortHisAsc"),
            sortField = component.get("v.sortField"),
            records = component.get("v.Hisorders");
        //sortHisAsc = field == sortField? !sortHisAsc: true;
          	sortHisAsc = sortField != field || !sortHisAsc;  
        
        records.sort(function(a,b){
            var t1 = a[field] == b[field],
                //t2 = a[field] > b[field];
            //return t1? 0: (sortHisAsc?-1:1)*(t2?-1:1);
             
            t2 = (!a[field] && b[field]) || (a[field] < b[field]); 
            return t1? 0: (sortHisAsc?-1:1)*(t2?1:-1);
        });
        component.set("v.sortHisAsc", sortHisAsc);
        component.set("v.sortField", field);
        component.set("v.Hisorders", records);
            
    },
    

})