({
    showToast : function(type, title, component, message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            type: type,
            title: title,
            message: message,
        });
        toastEvent.fire();
    },
	 initialProductDetail: function(component, helper) { 
       
        var action = component.get("c.getProductDetail");
        var toastErrorHandler = component.find('toastErrorHandler');
         var prSku = component.get("v.productSKUId");
         
         if(prSku.includes('*')==false){
          
          action.setParams({"productSKUId" : prSku});
            action.setCallback(this, function(response){
                toastErrorHandler.handleResponse(
                    response, // handle failure
                    function(response){ 
                        var rtnValue = response.getReturnValue();
                       // alert('response is '+JSON.stringify(rtnValue));
                        if (rtnValue !== null) {   
                            component.set("v.productDetail", rtnValue);
                        } 
                        else {
                            helper.getProductInfoFromUnbxd(component,helper);                           
                        }
                    },
                    function(response, message){ // report failure
                        console.log(message);
                        helper.showToast("error", 'Product Detail not found', component,
                                         'The system is unable to retrieve product details.');
                    }
                )            
            });        
            action.setBackground();

            $A.enqueueAction(action); 
          
     }
    },
    getProductInfoFromUnbxd : function(component,helper) { 
       
       		var currentIndex =0;
       		 var action = component.get("c.getProductDetail");
        	
        	action.setParams({"searchKey" : component.get('v.productSKUId'),
                              "currentIndex" : currentIndex,
                              "rows" : 1});
            var toastErrorHandler = component.find('toastErrorHandler');
            action.setCallback(this, function(response){
                toastErrorHandler.handleResponse(
                    response,
                    function(response){
                        var rtnValue = response.getReturnValue();
                        
                        if (rtnValue !== null) {    
                            // console.log(rtnValue);
                            var obj = JSON.parse(rtnValue);
                            if(obj["response"]["numberOfProducts"]<=0){
                                helper.showToast("error", 'Product not found', component,
                                             'Could not find product.');    
                                return;
                            }
                            for(var i=0; i<  obj["response"]["products"].length; i++){
                                
                                if(!$A.util.isEmpty(obj["response"]["products"][i]["id"])){                
                                    obj["response"]["products"][i]["sku"]=obj["response"]["products"][i]["id"];
                                }else if(!$A.util.isEmpty(obj["response"]["products"][i]["uniqueId"])){ 
                                    //3X SKU search response uniqueId
                                    obj["response"]["products"][i]["sku"]=obj["response"]["products"][i]["uniqueId"];
                                }
                                
                                obj["response"]["products"][i]["productTitle"]=obj["response"]["products"][i]["name"];
                            }
                            var productDetail = obj["response"]["products"][0];
                            productDetail["ecommSmallImage"] = productDetail["smallImageUrl"];
                            productDetail["itemColor"] = productDetail["color"] ? productDetail["color"][0] : [];
                            component.set("v.productDetail",  productDetail);
                            
                        }else {
                            helper.showToast("error", 'Product' + component.get('v.productDetailId') + 'not found', component,
                                             'The system is unable to retrieve product details.');                        
                        }
                    },
                    function(response, message){ // report failure
                        console.log(message);
                        helper.showToast("error", 'Product '+ component.get('v.productDetailId') +'not found', component,
                                         'The system is unable to retrieve product details.');
                    }
                )
            });            
            action.setBackground();
            $A.enqueueAction(action); 
        
    }
})