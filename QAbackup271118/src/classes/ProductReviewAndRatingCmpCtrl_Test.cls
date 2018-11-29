/* *******************************************************************************************************************
* Class Name   : ProductReviewAndRatingCmpCtrl_Test
* Description  : Test class for ProductReviewAndRatingCmpCtrl, the controller of ProductReviewAndRating lightning component.     
* Author       : JoJo Zhao (Perficient, Inc.)
* Created On   : 12/20/2017
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer                                   Date                   Modification ID      Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
*
**************************************************************************************************************************************/
@isTest
public class ProductReviewAndRatingCmpCtrl_Test {
    @testSetup 
    static void setup() {
        TestDataFactory.prepareAPICustomSetting();
        
    }
    
    public static testMethod void calloutExceptionTest(){
        Test.startTest();
        
        String fetchType = 'CalloutExceptionTest';
        String parentSkuId = '1200014';
        Test.setMock(HttpCalloutMock.class, new ProductReviewAndRatingCallOutMock(fetchType));
        try{
            Map<String, ProductRatingStatisticWrapper>  prw = ProductReviewAndRatingCmpCtrl.getProductRatingList(new String[]{parentSkuId});
            System.assert(false);
        }catch(Exception ex){
            System.assert(true);
        }
        try{
            Map<String, List<ProductReviewWrapper>>   pvw = ProductReviewAndRatingCmpCtrl.getProductReviewList(new String[]{parentSkuId});
            System.assert(false);
        }catch(Exception ex){
            System.assert(true);
        }
        Test.stopTest();
    }
    
    public static testMethod void jsonExceptionTest(){
        Test.startTest();
        
        String fetchType='JSONExceptionTest';
        String parentSkuId = '1200014';
        Test.setMock(HttpCalloutMock.class, new ProductReviewAndRatingCallOutMock(fetchType));
        try{
            Map<String, ProductRatingStatisticWrapper>  prw = ProductReviewAndRatingCmpCtrl.getProductRatingList(new String[]{parentSkuId});
            System.assert(false);
        }catch(Exception ex){
            System.assert(true);
        }
        try{
            Map<String, List<ProductReviewWrapper>>   pvw = ProductReviewAndRatingCmpCtrl.getProductReviewList(new String[]{parentSkuId});
            System.assert(false);
        }catch(Exception ex){
            System.assert(true);
        }
        Test.stopTest();
    }
    
    public static testMethod void prodRatingTest(){
        Test.startTest();
        
        String fetchType='RatingTest';
        String parentSkuId = '1200014';
        Test.setMock(HttpCalloutMock.class, new ProductReviewAndRatingCallOutMock(fetchType));
        Map<String, ProductRatingStatisticWrapper>  prw = ProductReviewAndRatingCmpCtrl.getProductRatingList(new String[]{parentSkuId});
        System.assertEquals(5.0, prw.get(parentSkuId).averageOverallRating);
        Test.stopTest();
    }
    public static testMethod void prodReviewsTest(){
        Test.startTest();
        
        String fetchType='ReviewsTest';
        String parentSkuId = '1200014';
        Test.setMock(HttpCalloutMock.class, new ProductReviewAndRatingCallOutMock(fetchType));
        Map<String, List<ProductReviewWrapper>>   pvw = ProductReviewAndRatingCmpCtrl.getProductReviewList(new String[]{parentSkuId});
        System.assertEquals(1, pvw.get(parentSkuId).size());
        Test.stopTest();
    }
}