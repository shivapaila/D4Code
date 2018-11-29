/* *******************************************************************************************************************
* Class Name   : ProductDetailCmpCtrl_Test
* Description  : Test class for ProductDetailCmpCtrl, the controller of ProductDetail lightning component.     
* Author       : JoJo Zhao (Perficient, Inc.)
* Created On   : 12/21/2017
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer                                   Date                   Modification ID      Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
*
**************************************************************************************************************************************/

@isTest
public class ProductDetailCmpCtrl_Test {
     @testSetup 
    static void setup() {
        TestDataFactory.prepareAPICustomSetting();
        
    }

    public static testMethod void calloutExceptionTest(){
      
        Test.startTest();
        
        String fetchType = 'CalloutExceptionTest';
        String productSkuId = 'W669-88';
        Test.setMock(HttpCalloutMock.class, new ProductDetailCallOutMock(fetchType));
       
        	ProductWrapper pw = ProductDetailCmpCtrl.getProductDetail(productSkuId);
            System.assertEquals(pw, null);
      
        Test.stopTest();
    }
    
    public static testMethod void jsonExceptionTest(){
        Test.startTest();
        
        String fetchType='JSONExceptionTest';
        String productSkuId = 'W669-88';
        Test.setMock(HttpCalloutMock.class, new ProductDetailCallOutMock(fetchType));
          
        ProductWrapper pw = ProductDetailCmpCtrl.getProductDetail(productSkuId);
          System.assertEquals(pw, null);
      
        Test.stopTest();
    }
    
    public static testMethod void categoryProductListTest(){
        Test.startTest();
        
        String fetchType='other';
        String productSkuId = 'W669-88';
        Test.setMock(HttpCalloutMock.class, new ProductDetailCallOutMock(fetchType));
        ProductWrapper pw = ProductDetailCmpCtrl.getProductDetail(productSkuId);
        System.assertEquals('W669-88 Title name', pw.productTitle);
        Test.stopTest();
    }
    
    public static testMethod void testProductWrapper(){
        String productWrapperString = '{"variants":null,"swatches":null,"standardWidth":null,"standardHeight":null,"standardDepth":null,"smallImageUrl":null,"sku":null,"rolloverImageUrl":null,"ratingInfo":null,"productTitle":null,"primaryImageId":null,"priceInfo":null,"path":null,"media":null,"lifestyle":null,"largeImageUrl":null,"itemColor":null,"isDirectShipOnly":null,"imageUrls":null,"imageUrl":null,"imageSize":null,"imageSetId":null,"genericColors":null,"fabricdetails":null,"ecommSmallImage":null,"ecommRolloverImage":null,"eCommLargeImage":null,"dimensionDescription":null,"detailedDescription":null,"crossSells":null,"completeYourCollection":null,"categoryName":null,"categoryId":null,"categories":null}';
        ProductWrapper pw = (ProductWrapper)JSON.deserialize(productWrapperString, ProductWrapper.class); 
        System.assertEquals(true, pw != null);
        System.assertEquals(true, pw.primaryImageId == null);
        System.assertEquals(true, pw.categoryName == null);
        System.assertEquals(true, pw.path == null);
        System.assertEquals(true, pw.detailedDescription == null);
        System.assertEquals(true, pw.eCommLargeImage == null);
        System.assertEquals(true, pw.ecommSmallImage == null);
        System.assertEquals(true, pw.ecommRolloverImage == null);
        System.assertEquals(true, pw.largeImageUrl == null);
        System.assertEquals(true, pw.smallImageUrl == null);
        System.assertEquals(true, pw.rolloverImageUrl == null);
        System.assertEquals(true, pw.imageSetId == null); 
        System.assertEquals(true, pw.imageUrls == null); 
        System.assertEquals(true, pw.imageSize == null); 
        System.assertEquals(true, pw.lifestyle == null); 
        System.assertEquals(true, pw.itemColor == null); 
        System.assertEquals(true, pw.genericColors == null);
        System.assertEquals(true, pw.isDirectShipOnly == null);
        System.assertEquals(true, pw.fabricdetails == null); 
        System.assertEquals(true, pw.dimensionDescription == null); 
        System.assertEquals(true, pw.standardDepth == null); 
        System.assertEquals(true, pw.standardHeight == null); 
        System.assertEquals(true, pw.standardWidth == null);
        System.assertEquals(true, pw.media == null);
        System.assertEquals(true, pw.categories == null); 
        System.assertEquals(true, pw.crossSells == null); 
        System.assertEquals(true, pw.completeYourCollection == null); 
        System.assertEquals(true, pw.priceInfo == null); 
        System.assertEquals(true, pw.ratingInfo == null);
        System.assertEquals(true, pw.variants == null);                                                                                
    }
    
}