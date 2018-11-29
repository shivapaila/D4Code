/* *******************************************************************************************************************
* Class Name   : ProductCategoryCallOutMock
* Description  : Http Call Out Mock test class for Asheley Product Retail - Product Navigatable Category API .
* Author       : JoJo Zhao (Perficient, Inc.)
* Created On   : 12/20/2017
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer                                   Date                   Modification ID      Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
*
**************************************************************************************************************************************///
@isTest
global class ProductCategoryCallOutMock implements HttpCalloutMock {
    private String fetchType;
    /**
    * @description <Constructor to set api type> 
    **/
    global ProductCategoryCallOutMock(String apiType){
        this.fetchType = apiType;
    }
    
    /**
    * @description <Implement the interface HttpCalloutMock's respond method to return mock response>
    * @return <return is the Mocked JSON string or throw a CalloutException>
    **/
	global HTTPResponse respond(HTTPRequest req) {
        if(fetchType == 'CalloutExceptionTest'){
            CalloutException e = (CalloutException)CalloutException.class.newInstance();
            e.setMessage('Throw CalloutException Test. Unauthorized endpoint, please check Setup->Security->Remote site settings.');
            throw e;
        }else{
            system.debug(req.getEndpoint());
            System.assertEquals('GET', req.getMethod());
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            
            ProductCategoryWrapper productCategoryTree;
            List<ProductCategoryWrapper> breadCrumbList = new List<ProductCategoryWrapper> ();
            if(fetchType == 'JSONExceptionTest'){
                res.setBody('Non JSON format String to make it throw JSONException when do the JSON Parse');
            }else if(fetchType == 'ProductCategoryRootTreeTest'){
                productCategoryTree = prepareProductCategoryRootTree();
                String bodyContent = JSON.serialize(productCategoryTree);
                res.setBody(bodyContent);
            }else if(fetchType == 'ProductCategorySubTreeTest'){
                productCategoryTree = prepareProductCategorySubTree();
                String bodyContent = JSON.serialize(productCategoryTree);
                res.setBody(bodyContent);
            }else if(fetchType == 'breadCrumbCategoriesRootTest'){
                 productCategoryTree = prepareProductCategoryRootTree();
                breadCrumbList.add(productCategoryTree);
                String bodyContent = JSON.serialize(breadCrumbList);
                res.setBody(bodyContent);
            }else if(fetchType == 'breadCrumbCategoriesTest'){
                 productCategoryTree = prepareProductCategorySubTree();
                productCategoryTree.parentCategoryId='0';
                 breadCrumbList.add(productCategoryTree); 
                for(ProductCategoryWrapper subPC:productCategoryTree.categories){
                    subPC.parentCategoryId=productCategoryTree.categoryId;
                }
                breadCrumbList.addAll(productCategoryTree.categories);
                String bodyContent = JSON.serialize(breadCrumbList);
                res.setBody(bodyContent);
            }else{
                productCategoryTree = prepareProductCategory('AFHS-0125');
                String bodyContent = JSON.serialize(productCategoryTree);
                res.setBody(bodyContent);
            }
            res.setStatusCode(200);
            return res;
        }
    }


     /**
    * @description <Simulate ProductCategoryTree info>                                                       
    * @return <Asserts return is the Mocked ProductCategoryWrapper object>
    **/    
    public static ProductCategoryWrapper prepareProductCategoryRootTree(){
        ProductCategoryWrapper productCategoryTree = prepareProductCategory('All');
        productCategoryTree.categories = new List<ProductCategoryWrapper>();
        String[] categoriesId = new String[]{'AFHS-0225','AFHS-0226','AFHS-0227'};
            for(String cId: categoriesId){
                ProductCategoryWrapper productCategory = prepareProductCategory(cId);
                productCategoryTree.categories.add(productCategory);
            }
        return productCategoryTree;
    }
    
      /**
    * @description <Simulate ProductCategoryTree info>                                                       
    * @return <Asserts return is the Mocked ProductCategoryWrapper object>
    **/    
    public static ProductCategoryWrapper prepareProductCategorySubTree(){
        ProductCategoryWrapper productCategoryTree = prepareProductCategory('AFHS-0225');
        productCategoryTree.categories = new List<ProductCategoryWrapper>();
        String[] categoriesId = new String[]{'AFHS-0125','AFHS-0126','AFHS-0127'};
            for(String cId: categoriesId){
                ProductCategoryWrapper productCategory = prepareProductCategory(cId);
                productCategoryTree.categories.add(productCategory);
            }
        return productCategoryTree;
    }



     /**
    * @description <Simulate ProductCategoryWrapper data>                                                       
    * @return <Asserts return is the Mocked ProductCategoryWrapper object>
    **/    
    public static ProductCategoryWrapper prepareProductCategory(String categoryId){
        ProductCategoryWrapper productCategory = new ProductCategoryWrapper();
        productCategory.categoryId = categoryId;
        productCategory.name = categoryId;
        productCategory.categories = null;
        productCategory.path = '/productinformation/retail/categories/'+categoryId+'/productabstracts';
        return productCategory;
    }
    
}