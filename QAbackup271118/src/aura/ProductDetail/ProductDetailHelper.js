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
            action.setParams({"productSKUId" : component.get('v.productDetailId')});
            action.setCallback(this, function(response){
                toastErrorHandler.handleResponse(
                    response, // handle failure
                    function(response){ 
                        
                        console.log(response);
                        var rtnValue = response.getReturnValue();
                        if (rtnValue !== null) {   
                            
                            component.set("v.productDetail", rtnValue);
                            console.log(JSON.stringify(rtnValue["variants"]));
                            console.log(JSON.stringify(rtnValue["swatches"]));
                            
                            // set the initial main product image
                            // get the image url without postfix
                            // split('?')
                            var initialImageURL = (!$A.util.isEmpty(rtnValue.ecommRolloverImage) ? rtnValue.ecommRolloverImage : rtnValue.eCommLargeImage);
                            if(!$A.util.isEmpty(initialImageURL)){
                                
                                var imageUrlArr = initialImageURL.split('?');
                                component.set("v.mainImage", imageUrlArr[0]);
                                
                            }
                            component.set("v.foundProductDetail", true);
                            
                            //event to notify Home, productDetail productTitle value
                            var eventComponent = component.getEvent("ProductDetailNotifyToProductHome");
                            eventComponent.setParams({ "notifyParam": rtnValue["productTitle"] });
                            eventComponent.fire(); 
                            
                            
                        } else {
                            console.log('=====> get from unbxd');
                          	helper.getProductInfoFromUnbxd(component,helper);     
                        }
                    },
                    function(response, message){ // report failure
                           helper.showToast("error", 'Product not found', component,
                                         message);
                    }
                )            
            });        
            action.setBackground();
            $A.enqueueAction(action); 
    }, 
    getProductInfoFromUnbxd : function(component,helper) {   
         var currentIndex =0;
        var action = component.get("c.getProductListSearch");
     //alert('result key is'+component.get('v.productDetailId'));
            action.setParams({"searchKey" : component.get('v.productDetailId'),
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
                            var initialImageURL = productDetail["largeImageUrl"];
                            if(!$A.util.isEmpty(initialImageURL)){
                                
                                var imageUrlArr = initialImageURL.split('?');
                                component.set("v.mainImage", imageUrlArr[0]);
                                
                            }
                            productDetail["swatches"] = [];

                            if(productDetail["swatchesimageUrl"]){
                                 for(var i=0; i<  productDetail["swatchesimageUrl"].length; i++){
                                    productDetail["swatches"][i] = {};
                                    productDetail["swatches"][i]["imageSource"] =productDetail["swatchesimageUrl"] ? productDetail["swatchesimageUrl"][i] : [];
                                    productDetail["swatches"][i]["color"]  =productDetail["swatchesname"] ? productDetail["swatchesname"][i] : [];
                                    productDetail["swatches"][i]["sku"] =  productDetail["childSku"] ? productDetail["childSku"][i] : [];
                              
                               }
                            }
                             productDetail["itemColor"] = productDetail["color"] ? productDetail["color"][0] : [];
                            console.log(productDetail["swatches"]);
                            
                            productDetail["detailedDescription"] = productDetail["description"] ? productDetail["description"] :[];
                            productDetail["productDescription"] = productDetail["productDetails"] ? productDetail["productDetails"] :[];
                            console.log(productDetail["variants"]);
                            productDetail["variants1"] = [];
                            if(productDetail["variants"]){
                                for(var i=0; i<  productDetail["variants"].length; i++){
                                    var variantOpt =  JSON.parse(productDetail["variants"][i]);
                                    if($A.util.isEmpty(variantOpt["size2"])){
                                        break;
                                    }
                                    productDetail["variants1"][i] = {};
                                    productDetail["variants1"][i]["sku"]= variantOpt["id"] ;
                                    productDetail["variants1"][i]["size"]= variantOpt["size2"] ;
                                    productDetail["variants1"][i]["imageSource"] = variantOpt["largeImageUrl"];
                                    productDetail["variants1"][i]["productVariantUrl"] = variantOpt["url"];
                                    
                                }
                                productDetail["variants"] = [];
                                productDetail["variants"] = productDetail["variants1"]; 
                                console.log(productDetail["variants"]);
                            }
                           
                            
                            component.set("v.productDetail",  productDetail);
                            component.set("v.foundProductDetail", true);
                            
                            //event to notify Home, productDetail productTitle value
                            var eventComponent = component.getEvent("ProductDetailNotifyToProductHome");
                            eventComponent.setParams({ "notifyParam": obj["response"]["products"][0]["productTitle"] });
                            eventComponent.fire(); 
                        }else {
                            helper.showToast("error", 'Product not found', component,
                                             'Could not find product.');                        
                        }
                    },
                    function(response, message){ // report failure
                        helper.showToast("error", 'Product not found', component,
                                         message);
                    }
                )
            });            
         
        action.setBackground();
            $A.enqueueAction(action); 
        
    },
    navToProduct: function(component, sku, name=null) {
        var parentCategoryId = component.get('v.parentCategoryId');

        var productEvent = component.getEvent('productEvent');
        productEvent.setParams({
            parentCategoryId : (!$A.util.isUndefinedOrNull(parentCategoryId) ? parentCategoryId : null),
            productDetailId : sku
        });
        productEvent.fire(); 
    },
    getRecId : function(component) {
        var url=location.href.split('/n/');
        if(url != null && url[1] != null){
            var splitUrl=url[1].split('?');
            if(splitUrl != null && splitUrl[1] != null){
                var Id=splitUrl[1].split('=');
                if(Id != null && Id[1] != null){
                    component.set('v.recordId',Id[1]);
                }else{
                    helper.showToast("error", 'No Customer', component,
                                         'Please choose a customer.');   
                    
                }
            }
        }
    }
})