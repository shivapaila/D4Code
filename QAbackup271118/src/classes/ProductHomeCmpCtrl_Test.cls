/* *******************************************************************************************************************
* Class Name   : ProductHomeCmpCtrl_Test
* Description  : Test class for ProductHomeCmpCtrl, the controller of ProductHome and ProductCategory lightning component.     
* Author       : JoJo Zhao (Perficient, Inc.)
* Created On   : 12/20/2017
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer                                   Date                   Modification ID      Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
*
**************************************************************************************************************************************/

@isTest
public class ProductHomeCmpCtrl_Test {
     @testSetup 
    static void setup() {
        TestDataFactory.prepareAPICustomSetting();
        
    }
    public static testMethod void calloutExceptionTest(){
        Test.startTest();
        
        String fetchType = 'CalloutExceptionTest';
        String parentCategoryId = 'AFHS-0181';
        Test.setMock(HttpCalloutMock.class, new ProductCategoryCallOutMock(fetchType));
        try{
            
            ProductCategoryWrapper pcw = ProductHomeCmpCtrl.getCategoryTree(parentCategoryId);
            System.assert(false);
        }catch(Exception ex){
            System.assert(true);
        }
        Test.stopTest();
    }
    
    public static testMethod void jsonExceptionTest(){
        Test.startTest();
        
        String fetchType='JSONExceptionTest';
        String parentCategoryId = 'AFHS-0181';
        Test.setMock(HttpCalloutMock.class, new ProductCategoryCallOutMock(fetchType));
        try{
            ProductCategoryWrapper pcw = ProductHomeCmpCtrl.getCategoryTree(parentCategoryId);
            System.assert(false);
        }catch(Exception ex){
            System.assert(true);
        }
        Test.stopTest();
    }
    
    public static testMethod void navigationCategoryTreeTest(){
        Test.startTest();
        
        String fetchType='other';
        String parentCategoryId = 'AFHS-0125';
        Test.setMock(HttpCalloutMock.class, new ProductCategoryCallOutMock(fetchType));
        ProductCategoryWrapper pcw = ProductHomeCmpCtrl.getCategoryTree(parentCategoryId);
        System.assertEquals('AFHS-0125', pcw.categoryId);
        Test.stopTest();
    }
    public static testMethod void navigationCategorySubTreeTest(){
        Test.startTest();
        
        String fetchType='ProductCategorySubTreeTest';
        String parentCategoryId = 'AFHS-0225';
        Test.setMock(HttpCalloutMock.class, new ProductCategoryCallOutMock(fetchType));
        ProductCategoryWrapper pcw = ProductHomeCmpCtrl.getCategoryTree(parentCategoryId);
        System.assertEquals('AFHS-0225', pcw.categoryId);
        Test.stopTest();
    }
    public static testMethod void navigationCategoryRootTreeTest(){
        Test.startTest();
        
        String fetchType='ProductCategoryRootTreeTest';
        Test.setMock(HttpCalloutMock.class, new ProductCategoryCallOutMock(fetchType));
        ProductCategoryWrapper pcw = ProductHomeCmpCtrl.getCategoryTree(null);
        System.assertEquals('All', pcw.categoryId);
        Test.stopTest();
    }
     public static testMethod void categoryBreadCrumbRootTest(){
        Test.startTest();
        
        String fetchType='breadCrumbCategoriesRootTest';
        Test.setMock(HttpCalloutMock.class, new ProductCategoryCallOutMock(fetchType));
        List<ProductCategoryWrapper> pwl=  ProductHomeCmpCtrl.getBreadCrumbCategoryTreeList(null);
         System.assertEquals(0, pwl.size());
        Test.stopTest();
    }    

    public static testMethod void categoryBreadCrumbTest(){
        Test.startTest();
        
        String fetchType='breadCrumbCategoriesTest';
        Test.setMock(HttpCalloutMock.class, new ProductCategoryCallOutMock(fetchType));
        List<ProductCategoryWrapper> pwl=  ProductHomeCmpCtrl.getBreadCrumbCategoryTreeList('AFHS-0125');
         System.assertEquals(1, pwl.size());
        Test.stopTest();
    }    
   
}