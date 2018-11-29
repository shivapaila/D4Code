/* *******************************************************************************************************************
* Class Name   : ProductHomeCmpCtrl
* Description  : Controller class for ProductHome lightning component.     
* Author       : JoJo Zhao (Perficient, Inc.)
* Created On   : 12/7/2017
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer                                   Date                   Modification ID      Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
*
**************************************************************************************************************************************/

public class ProductHomeCmpCtrl {
    
    /**
* @description <get ProductCategoryWrapper, the top level is start category itself, ProductCategoryWrapper.categories is the sub-category group>                                                        
* @param <parentCategoryId: Start category node>
* @return <ProductCategoryWrapper>
**/
    @AuraEnabled
    public static ProductCategoryWrapper getCategoryTree(String parentCategoryId) { 
        System.debug('parentCategoryId:'+parentCategoryId);
        ProductCategoryAPIHelper categoryAPIHelper = new ProductCategoryAPIHelper();
        String sourceURL = categoryAPIHelper.getAPIEndpoint(parentCategoryId);
        
        String resJSON = categoryAPIHelper.connectToAPIGetJSON(sourceURL);
        ProductCategoryWrapper categoryTree =  categoryAPIHelper.parseJSONToCategoryWrapper(resJSON);
        
        if(categoryTree.name=='All'){
            
            //got to metadata to get discount percent
            Category_List__mdt[] categoryList = [SELECT Id, MasterLabel, DeveloperName,
                                                 Category_Id__c,Order__c  FROM Category_List__mdt order by Order__c ASC];
            categoryTree.categoriesWithImage = new List<ProductCategoryWrapper>();
            for(Category_List__mdt customCategory: categoryList){
                ProductCategoryWrapper p = new ProductCategoryWrapper();
                p.categoryId = customCategory.Category_Id__c;
                p.name = customCategory.MasterLabel;
                p.categoryImagePath = customCategory.DeveloperName;
                p.parentCategoryId = categoryTree.categoryId;
                categoryTree.categoriesWithImage.add(p);
            }
        }
        
        System.debug('categoryTree:'+categoryTree);
        return categoryTree;
    }
    
     /**
* @description <get ProductCategoryWrapper, the top level is start category itself, ProductCategoryWrapper.categories is the sub-category group>                                                        
* @param <parentCategoryId: Start category node>
* @return <ProductCategoryWrapper>
**/
    @AuraEnabled
    public static List<ProductCategoryWrapper> getBreadCrumbCategoryTreeList(String parentCategoryId) { 
        ProductCategoryAPIHelper categoryAPIHelper = new ProductCategoryAPIHelper();
        String sourceURL = categoryAPIHelper.getXMLAPIEndpoint(null);
        // String sourceURL = categoryAPIHelper.getAPIEndpoint(parentCategoryId);
        
        String resJSON = categoryAPIHelper.connectToAPIGetJSON(sourceURL);
        ProductCategoryWrapper categoryTree =  categoryAPIHelper.parseJSONToCategoryWrapper(resJSON);
        //   System.debug('resJSON:'+categoryTree);
        List<ProductCategoryWrapper> allCategories = new List<ProductCategoryWrapper>();
        allCategories.add(categoryTree);
        if(categoryTree.categories!=null){
            
            allCategories.addAll(categoryTree.categories);
            
            List<ProductCategoryWrapper> subCategories = categoryTree.categories;
            while(subCategories.size()>0){
                List<ProductCategoryWrapper> newSubCategories = new      List<ProductCategoryWrapper>();
                for(ProductCategoryWrapper pw:subCategories){
                    if(pw.categories!=null){
                        allCategories.addAll(pw.categories);
                        
                        newSubCategories.addAll(pw.categories);
                    }
                }
                subCategories.clear();
                subCategories.addAll(newSubCategories);
            }
            
            
            
        }
        system.Debug(allCategories);
        
        Map<String, ProductCategoryWrapper> cgMap = new Map<String, ProductCategoryWrapper> ();
        
        for(ProductCategoryWrapper cg:allCategories){
            cgMap.put(cg.categoryId, cg);
        }
        system.Debug(cgMap);
        
          
        List<ProductCategoryWrapper> crumbCategoryList = new  List<ProductCategoryWrapper>();
        List<ProductCategoryWrapper> sortedCrumbCategoryList = new  List<ProductCategoryWrapper>();
        
        while(parentCategoryId!=null && parentCategoryId!='0'){
            
            ProductCategoryWrapper parentCategory = cgMap.get(parentCategoryId) ;
            crumbCategoryList.add(parentCategory);
            parentCategoryId = parentCategory.parentCategoryId; 
            
        }
        for(Integer i=crumbCategoryList.size(); i>1;i--){
            sortedCrumbCategoryList.add(crumbCategoryList[i-1]);
        }
        return sortedCrumbCategoryList;
    }
}