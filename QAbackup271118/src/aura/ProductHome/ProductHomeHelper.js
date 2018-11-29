({
    initialListInfo : function(component, parentCategoryId, productDetailId, searchKey, success) {
        var self = this;
        var params = {"parentCategoryId" : parentCategoryId};  
        this.callout(component, 'getCategoryTree', params, function(response) {
          var rtnValue = response.getReturnValue();
          if (rtnValue !== null) {    
              component.set("v.categoryTree", rtnValue);
              if(!$A.util.isEmpty(productDetailId)){
                  self.createProductDetailComponent(component, parentCategoryId, productDetailId,searchKey,success);    
              }else{
                  if(rtnValue['name']!='All' ||!$A.util.isEmpty(searchKey) ){
                      if(!$A.util.isEmpty(searchKey)){
                        component.set("v.noCategoryDropdownList", true);
                      }
                      self.createProductListComponent(component, rtnValue['categoryId'], searchKey, success);  
                  }else{
                      //rtnValue is the category tree
                      self.createProductCategoryComponent(component, rtnValue, success); 
                  }
              }
              if(rtnValue.categories===undefined){
                  var selectedCategoryId = component.find("selectedCategoryId");
                  $A.util.removeClass(selectedCategoryId, "slds-hide");
                  $A.util.toggleClass(selectedCategoryId, "slds-hide");
              }else{
                  var selectedCategoryId = component.find("selectedCategoryId");
                  $A.util.removeClass(selectedCategoryId, "slds-hide");
              }
              var categoryListDiv = component.find("categoryListDiv");
              $A.util.removeClass(categoryListDiv, "slds-hide");
          } else {
              self.showToast("error", 'Product category not found', component, 'Could not find product category.');                        
          }
        }, function(response, message){
          self.showToast("error", 'Product category not found', component, message);    
        });
    },
    initialCategoryBreadCrumb : function(component, parentCategoryId, success) {
        var self = this;
        var params = {"parentCategoryId" : parentCategoryId};  
        this.callout(component, 'getBreadCrumbCategoryTreeList', params, function(response) {
            var rtnValue = response.getReturnValue();
            console.log('rtnvalueforbreadcrumb' + JSON.stringify(rtnValue));
            if (rtnValue !== null) {    
                component.set("v.categoryBreadCrumbLink", rtnValue);
                if (success) {
                  success.call(this);
                }                 
            } else {
                self.showToast("error", 'Product category crumb not found', component, 'Could not find product category crumb.');                        
            }
        }, function(response, message){
            self.showToast("error", 'Product category crumb not found', component, message);            
        });
    },
    showToast : function(type, title, component, message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            type: type,
            title: title,
            message: message,
        });
        toastEvent.fire();
    },
   /*
    * Callout to Apex Lightning Controller
    */  
    callout: function(component, name, params, success, failure) {   
      var action = component.get('c.' + name);
      var toastErrorHandler = component.find('toastErrorHandler');
      if (params) {
          action.setParams(params);
      }
      action.setCallback(this, function(response){
        toastErrorHandler.handleResponse(response, success, failure); 
      });        
      action.setBackground();
      $A.enqueueAction(action);
    },
    createProductDetailComponent: function(component, parentCategoryId, productDetailId,searchKey,success) {
      $A.createComponent( "c:ProductDetail", 
                         {	"searchKey":searchKey,
                            "parentCategoryId": parentCategoryId,
                            "productDetailId": productDetailId
                          }, 
                          function(newCmp, status) {
                            if (newCmp.isValid() && status === "SUCCESS") {
                              var body = component.get("v.body");
                              body = [];
                              // newCmp is a reference to another component
                              body.push(newCmp);
                              component.set("v.body", body);
                              if (success) {
                                success.call(this);
                              }
                            }
                          }
                      );       
    },
    createProductListComponent: function(component, categoryId, searchKey, success) {
      $A.createComponent( "c:ProductList", 
                          {
                            "parentCategoryId": categoryId,
                            "searchKey": (!$A.util.isUndefinedOrNull(searchKey) ? escape(searchKey) : null)
                          }, 
                          function(newCmp, status) {
                            if (newCmp.isValid() && status === "SUCCESS") {
                              var body = component.get("v.body");
                              body = [];
                              // newCmp is a reference to another component
                              body.push(newCmp);
                              component.set("v.body", body);
                              if (success) {
                                success.call(this);
                              }
                            }
                          }
                      );       
    },
    createProductCategoryComponent: function(component, categoryTree, success) {
      $A.createComponent( "c:ProductCategory", 
                          {
                            "categoryTree": categoryTree
                          }, 
                          function(newCmp, status) {
                            if (newCmp.isValid() && status === "SUCCESS") {
                              var body = component.get("v.body");
                              body = [];
                              // newCmp is a reference to another component
                              body.push(newCmp);
                              component.set("v.body", body);
                              if (success) {
                                success.call(this);
                              }
                            }
                          }
                      );       
    }           
})