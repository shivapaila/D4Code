({
    initialPriceZone : function(component,helper) {   
        var action = component.get("c.getPriceZoneFacet");
        action.setCallback(this, function(response){
            var rtnValue = response.getReturnValue();
            console.log(rtnValue);
            console.log('here');
            if(rtnValue!=null){
                
                component.set("v.priceZone", rtnValue);
            }else{
                component.set("v.priceZone", "salePrice_fq");
            }
            
            var searchKey = component.get('v.searchKey');
            if (!$A.util.isUndefinedOrNull(searchKey)){
                searchKey = searchKey.trim();
            }

            if( !$A.util.isUndefinedOrNull(searchKey) && searchKey.length>0 ) {
                helper.initialProductSearch(component, helper);  
            }else{
                helper.initialProductFilter(component,helper);
            }
            
        });            
        action.setBackground();
        $A.enqueueAction(action); 
    },
    /*initialProductList : function(component,helper) {  
        var action = component.get("c.getCategoryProductList");
        if( component.get('v.parentCategoryId')!==undefined 
           && component.get('v.parentCategoryId')!=null
           && component.get('v.parentCategoryId')!='root'){
            action.setParams({"categoryId" : component.get('v.parentCategoryId')});
            var toastErrorHandler = component.find('toastErrorHandler');
            action.setCallback(this, function(response){
                toastErrorHandler.handleResponse(
                    response,
                    function(response){
                        var rtnValue = response.getReturnValue();
                        if (rtnValue !== null) {    
                            component.set("v.categoryProductList", rtnValue); 
                            helper.moveCursor(component);
                        }else {
                            helper.showToast("error", 'Product List not found', component,
                                             'Could not find product List.');                        
                        }
                    },
                    function(response, message){ // report failure
                        helper.showToast("error", 'Product category not found', component,
                                         message);
                    }
                )
            });            
            action.setBackground();
            $A.enqueueAction(action); 
        }
    },*/
    initialProductSearch : function(component,helper) {   
        var currentIndex = component.get("v.apiCursorIndex");
        var depth=component.get("v.loadMoreDepth");
        var action = component.get("c.getProductListSearch");
        if( component.get('v.searchKey')!==undefined 
           && component.get('v.searchKey')!=null 
           && component.get('v.searchKey').length>0){
            action.setParams({"searchKey" : component.get('v.searchKey'),
                              "currentIndex" : currentIndex,
                              "rows" : 96});
            var toastErrorHandler = component.find('toastErrorHandler');
            action.setCallback(this, function(response){
                toastErrorHandler.handleResponse(
                    response,
                    function(response){
                        var rtnValue = response.getReturnValue();
                        if (rtnValue !== null) {    
                             console.log(rtnValue);
                            var obj = JSON.parse(rtnValue);
                            helper.popularFilterAndList(component, helper, obj);
                        }else {
                            helper.showToast("error", 'Product List not found', component,
                                             'Could not find product List.');                        
                        }
                    },
                    function(response, message){ // report failure
                        helper.showToast("error", 'Product category not found', component,
                                         message);
                    }
                )
            });            
            action.setBackground();
            $A.enqueueAction(action); 
        }
    },
    initialProductFilter : function(component,helper) {   
        var currentIndex = component.get("v.apiCursorIndex");
        var depth=component.get("v.loadMoreDepth");
        var action = component.get("c.getProductListFilter");
        if( component.get('v.parentCategoryId')!==undefined 
           && component.get('v.parentCategoryId')!=null
           && component.get('v.parentCategoryId')!='root'){
            var categoryId = component.get('v.parentCategoryId');
            
            var filter = '(category_ids:"'+categoryId+'")';
            
            filter = escape(filter);
            console.log(filter);
            action.setParams({"categoryId" : categoryId,
                              "currentIndex" : currentIndex,
                              "rows" : 96,
                              "filterStr" :  filter});
            var toastErrorHandler = component.find('toastErrorHandler');
            action.setCallback(this, function(response){
                toastErrorHandler.handleResponse(
                    response,
                    function(response){
                        var rtnValue = response.getReturnValue();
                        if (rtnValue !== null) {    
                            // console.log(rtnValue);
                            var obj = JSON.parse(rtnValue);
                            helper.popularFilterAndList(component, helper, obj);
                        }else {
                            helper.showToast("error", 'Product List not found', component,
                                             'Could not find product List.');                        
                        }
                    },
                    function(response, message){ // report failure
                        helper.showToast("error", 'Product category not found', component,
                                         message);
                    }
                )
            });            
            action.setBackground();
            $A.enqueueAction(action); 
        }
    },
    
    popularFilterAndList : function(component,helper,obj){
        if(!$A.util.isEmpty(obj["facets"])){
            
            
            helper.loadPriceOptions(component, "selectedPriceScope", obj["facets"][component.get("v.priceZone")]["values"]["counts"], "Price");
            helper.loadOptions(component, "selectedColorType", obj["facets"]["color_fq"]["values"],"Color");
            
            helper.loadOptions(component, "selectedFabricType", obj["facets"]["material_fq"]["values"],"Fabric");
            
            helper.loadOptions(component, "selectedLifestyleType", obj["facets"]["styledescription_fq"]["values"],"Lifestyle");
        }else{
              helper.showToast("error", 'Product List filter facets not found', component,
                                         'Could not find Product List filter facets.');    
        }
        if(!$A.util.isEmpty(obj["response"])){
            
                       for(var i=0; i<  obj["response"]["products"].length; i++){
                         //   console.log(obj["response"]["products"][i]["largeImageUrl"]);

                if($A.util.isEmpty(obj["response"]["products"][i]["sku"])){             	
                    if(!$A.util.isEmpty(obj["response"]["products"][i]["id"])){                
                        obj["response"]["products"][i]["sku"]=obj["response"]["products"][i]["id"];
                    }else if(!$A.util.isEmpty(obj["response"]["products"][i]["uniqueId"])){ 
                        //3X SKU search response uniqueId
                        obj["response"]["products"][i]["sku"]=obj["response"]["products"][i]["uniqueId"];
                    }
                }
                obj["response"]["products"][i]["productTitle"]=obj["response"]["products"][i]["name"];
            }
            component.set("v.categoryProductList", obj["response"]["products"]); 
            component.set("v.totalDepth",  obj["response"]["numberOfProducts"]);
            helper.moveCursorForFilter(component,helper);
            
        }else{
             helper.showToast("error", 'Product List not found', component,
                                         'Could not find Product List.');   
        }

        component.set("v.viewLoadMoreButton", true);
    },
 
    filterProductListBase : function(component,helper,isLoadMore) {

        component.set("v.viewLoadMoreButton", false);

        var currentIndex = 0;  
        if(isLoadMore){     
            currentIndex = component.get("v.apiCursorIndex");
        }else{
            component.set("v.apiCursorIndex",0);
        }
        
        var filter="";
        if(component.find("selectedPriceScope").get("v.value")!=undefined && component.find("selectedPriceScope").get("v.value")!=0){
            filter = filter+  component.get("v.priceZone")+":"+component.find("selectedPriceScope").get("v.value");
        }
        if(component.find("selectedColorType").get("v.value")!=undefined && component.find("selectedColorType").get("v.value")!=0){
            if(filter.length>1){
                filter = filter+ ' AND ' + 'color_fq:"'+component.find("selectedColorType").get("v.value")+'"';
            }else{
                filter = filter+'color_fq:"'+component.find("selectedColorType").get("v.value")+'"';
                
            }
        }
        
        if(component.find("selectedFabricType").get("v.value")!=undefined && component.find("selectedFabricType").get("v.value")!=0){
            if(filter.length>1){
                filter = filter+ " AND " + "material_fq:"+component.find("selectedFabricType").get("v.value");
            }else{
                filter = filter+"material_fq:"+component.find("selectedFabricType").get("v.value");
                
            }
        }
        if(component.find("selectedLifestyleType").get("v.value")!=undefined && component.find("selectedLifestyleType").get("v.value")!=0){
            if(filter.length>1){
                filter = filter+ " AND " + "styledescription_fq:"+component.find("selectedLifestyleType").get("v.value");
            }else{
                filter = filter+"styledescription_fq:"+component.find("selectedLifestyleType").get("v.value");
                
            }
        }
        /* filter = filter + ")";
        console.log(filter);
        if(filter.length<=2){
            filter = '';
        }
        filter = escape(filter);*/
        console.log(filter);
        if( component.get('v.searchKey')!==undefined 
           && component.get('v.searchKey')!=null 
           && component.get('v.searchKey').length>0){
            var action = component.get("c.getProductListSearch");
            
            if(filter.length>0){
                filter = '('+filter+')';
            }
            filter = escape(filter);
            action.setParams({"searchKey" : component.get('v.searchKey'),
                              "currentIndex" : currentIndex,
                              "rows" : 96,
                              "filterStr" :  filter});
        }else if( component.get('v.parentCategoryId')!==undefined 
                 && component.get('v.parentCategoryId')!=null
                 && component.get('v.parentCategoryId')!='root'){
            var action = component.get("c.getProductListFilter");
             var categoryId = component.get('v.parentCategoryId');
            
            if(filter.length>0){
                filter = '('+ filter + 'AND category_ids:"'+categoryId+'")';
            }else{
                filter = '(category_ids:"'+categoryId+'")';
            }
            filter = escape(filter);
            console.log(filter);
            action.setParams({"categoryId" : categoryId,
                              "currentIndex" : currentIndex,
                              "rows" : 96,
                              "filterStr" : filter});
        }else{
            return;
        }
        var toastErrorHandler = component.find('toastErrorHandler');
        action.setCallback(this, function(response){
            toastErrorHandler.handleResponse(
                response,
                function(response){
                    var rtnValue = response.getReturnValue();
                    if (rtnValue !== null) {    
                        //   console.log(rtnValue);
                        var obj = JSON.parse(rtnValue);
                        for(var i=0; i<  obj["response"]["products"].length; i++){
                            
                            if(!$A.util.isEmpty(obj["response"]["products"][i]["id"])){                
                                obj["response"]["products"][i]["sku"]=obj["response"]["products"][i]["id"];
                            }else if(!$A.util.isEmpty(obj["response"]["products"][i]["uniqueId"])){ 
                                //3X SKU search response uniqueId
                                obj["response"]["products"][i]["sku"]=obj["response"]["products"][i]["uniqueId"];
                            }
                            obj["response"]["products"][i]["isValidProductPrice"]=true;
                            obj["response"]["products"][i]["productTitle"]=obj["response"]["products"][i]["name"];
                        }
                        if(isLoadMore){

                            var categoryProductListAlready = component.get("v.categoryProductList");
                             if(!$A.util.isEmpty(categoryProductListAlready)){
                              
                            component.set("v.categoryProductList",  categoryProductListAlready.concat(obj["response"]["products"])); 
                              }else{
                                 component.set("v.categoryProductList", obj["response"]["products"]);

                              }
                            component.set("v.totalDepth",  obj["response"]["numberOfProducts"]);
                            helper.refreshForInvalidPriceProduct(component,helper);
                        }else{
                            component.set("v.categoryProductList", obj["response"]["products"]);
                            component.set("v.totalDepth",  obj["response"]["numberOfProducts"]);
                            helper.moveCursorForFilter(component,helper);
                        }
                    }else {
                        helper.showToast("error", 'Product List not found', component,
                                         'Could not find product List.');                        
                    }
                    component.set("v.viewLoadMoreButton", true);
                },
                function(response, message){ // report failure
                    helper.showToast("error", 'Product List not found', component,
                                     message);
                }
            )
        });            
        action.setBackground();
        $A.enqueueAction(action); 
        
    },
    loadMoreViaAPI : function(component,helper) {  
         helper.filterProductListBase(component,helper, true);
    },
    moveCursorForFilter: function(component,helper) {        
        var categoryProductListAll = component.get("v.categoryProductList");
        var currentIndex = component.get("v.cursorIndex");
        var depth=component.get("v.loadMoreDepth");
        var categoryProductListToShow;
   
        if(component.get("v.totalDepth") > currentIndex+depth){
            categoryProductListToShow = categoryProductListAll.slice(0, currentIndex+depth);
            component.set("v.hasMore", true);
            component.set("v.viewLoadMoreButton",true); 
        }else{
            categoryProductListToShow = categoryProductListAll.slice(0, categoryProductListAll.length);
            component.set("v.hasMore", false);
        } 
        component.set("v.categoryProductListToShow", categoryProductListToShow);   
        component.set("v.cursorIndex",currentIndex+depth); 
		
        var currentAPIIndex = component.get("v.apiCursorIndex");
        component.set("v.apiCursorIndex",currentAPIIndex+96); 
        if(categoryProductListAll.length<component.get("v.totalDepth") ){
            helper.loadMoreViaAPI(component,helper);
        }else{
            component.set("v.viewLoadMoreButton",true); 
        }
    },
    refreshForInvalidPriceProduct: function(component,helper) {        
        var categoryProductListAll = component.get("v.categoryProductList");
        var currentIndex = component.get("v.cursorIndex");
        
        var depth=component.get("v.loadMoreDepth");
        var categoryProductListToShow;
         
          var currentAPIIndex = component.get("v.apiCursorIndex");
           if(categoryProductListAll.length==0 && currentAPIIndex < component.get("v.totalDepth")){
                helper.loadMoreViaAPI(component,helper);
                component.set("v.hasMore", true);
           }else if(categoryProductListAll.length==0 && currentAPIIndex >= component.get("v.totalDepth")){
                component.set("v.hasMore", false);
           }
        if(categoryProductListAll.length > currentIndex){
            
            categoryProductListToShow = categoryProductListAll.slice(0, currentIndex);
            // component.set("v.hasMore", true);
        }else{
            categoryProductListToShow = categoryProductListAll.slice(0, categoryProductListAll.length);
            // component.set("v.hasMore", false);
        }
               component.set("v.categoryProductListToShow", categoryProductListToShow);   
      //  var productListWrapper = component.find('productListWrapper');
      //  $A.util.removeClass(productListWrapper, 'slds-hide');

    },
   /* moveCursor: function(component) {
        var categoryProductListAll = component.get("v.categoryProductList");
        var currentIndex = component.get("v.cursorIndex");
        var depth=component.get("v.loadMoreDepth");
        var categoryProductListToShow;
        if(categoryProductListAll.length > currentIndex+depth){
            categoryProductListToShow = categoryProductListAll.slice(0, currentIndex+depth);
            component.set("v.hasMore", true);
        }else{
            categoryProductListToShow = categoryProductListAll.slice(0, categoryProductListAll.length);
            component.set("v.hasMore", false);
        } 
        console.log(categoryProductListToShow);
        component.set("v.categoryProductListToShow", categoryProductListToShow);   
        component.set("v.cursorIndex",component.get("v.cursorIndex")+depth); 
    },*/
    showToast : function(type, title, component, message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            type: type,
            title: title,
            message: message,
        });
        toastEvent.fire();
    },
    loadPriceOptions: function (component, selectCmpId, initialData,initialLable) {
        var opts = [];
        var obj={};
        obj["id"] =  0;
        obj["label"] = initialLable;
        opts.push(obj);
        for(var i=0; i< initialData.length; i=i+2){
            var obj={};
            var scope= (initialData[i+2]===undefined ? (parseInt(initialData[i])+100):initialData[i+2]);
            obj["id"] =  "["+initialData[i] +" TO " + scope +"]";
            
            //obj["label"] = '$'+ initialData[i] +" - " + '$'+scope+"("+ initialData[i+1]+")";
            obj["label"] ='$'+ parseInt(initialData[i]).toFixed(2) +" - " + '$'+parseInt(scope).toFixed(2);//Remove number behind options
            opts.push(obj);
        }
        console.log(opts);
        var cmp = component.find(selectCmpId);
        cmp.set('v.body', []); // clear all options
        var body = cmp.get('v.body');
        opts.forEach(function (opt) {
            $A.createComponent(
                'aura:html',
                {
                    tag: 'option',
                    HTMLAttributes: {
                        value: opt.id,
                        text: opt.label
                    }
                },
                function (newOption) {
                    //Add options to the body
                    if (component.isValid()) {
                        body.push(newOption);
                        cmp.set('v.body', body);
                    }
                })
        });
        cmp.set('v.value', 0);
    },
    loadOptions: function (component, selectCmpId, initialData,initialLable) {
        var opts = [];
        var obj={};
        obj["id"] =  0;
        obj["label"] = initialLable;
        opts.push(obj);
        for(var i=0; i< initialData.length; i=i+2){
            var obj={};
            obj["id"] =  initialData[i];
            //obj["label"] = initialData[i]+"("+ initialData[i+1]+")";
            obj["label"] = initialData[i];//Remove number behind options
            opts.push(obj);
        }
        console.log(opts);
        var cmp = component.find(selectCmpId);
        cmp.set('v.body', []); // clear all options
        var body = cmp.get('v.body');
        opts.forEach(function (opt) {
            $A.createComponent(
                'aura:html',
                {
                    tag: 'option',
                    HTMLAttributes: {
                        value: opt.id,
                        text: opt.label
                    }
                },
                function (newOption) {
                    //Add options to the body
                    if (component.isValid()) {
                        body.push(newOption);
                        cmp.set('v.body', body);
                    }
                })
        });
        cmp.set('v.value', 0);
    }
})