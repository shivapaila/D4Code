/* *******************************************************************************************************************
* Class Name   : ProductListCmpCtrl_Test
* Description  : Test class for ProductListCmpCtrl, the controller of ProductList lightning component.     
* Author       : JoJo Zhao (Perficient, Inc.)
* Created On   : 12/21/2017
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer                                   Date                   Modification ID      Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
*
**************************************************************************************************************************************/

@isTest
public class ProductListCmpCtrl_Test {
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
            List<ProductWrapper> cpw = ProductListCmpCtrl.getCategoryProductList(parentCategoryId);
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
        Test.setMock(HttpCalloutMock.class, new ProductListCallOutMock(fetchType));
        try{            
            List<ProductWrapper> cpw = ProductListCmpCtrl.getCategoryProductList(parentCategoryId);
            System.assert(false);
        }catch(Exception ex){
            System.assert(true);
        }
        Test.stopTest();
    }
    
    public static testMethod void categoryProductListTest(){
        Test.startTest();
        
        String fetchType='other';
        String parentCategoryId = 'AFHS-0225';
        Test.setMock(HttpCalloutMock.class, new ProductListCallOutMock(fetchType));
        List<ProductWrapper> cpw = ProductListCmpCtrl.getCategoryProductList(parentCategoryId);
        System.assertEquals(3, cpw.size());
        Test.stopTest();
    }
    
     public static testMethod void unbxdProductListSearchTest(){
        Test.startTest();
        
        String fetchType='unbxd';
        String searchSku = '3X0000006820';
        Test.setMock(HttpCalloutMock.class, new ProductListCallOutMock(fetchType));
        String cpw = ProductListCmpCtrl.getProductListSearch(searchSku, 0, 96, null);
        System.assertNotEquals(null, cpw);
        Test.stopTest();
    }

	public static testMethod void unbxdProductListCategoryTest(){
        Test.startTest();
        
        String fetchType='unbxd';
        String categoryId = 'bedding-top';
        Test.setMock(HttpCalloutMock.class, new ProductListCallOutMock(fetchType));
        String cpw = ProductListCmpCtrl.getProductListFilter(categoryId, 0, 96, null);
       	System.assertNotEquals(null, cpw);
        Test.stopTest();
    }    
}