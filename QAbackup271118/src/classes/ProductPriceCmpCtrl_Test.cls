/* *******************************************************************************************************************
* Class Name   : ProductPriceCmpCtrl_Test
* Description  : Test class for ProductPriceCmpCtrl, the controller of ProductPriceBase lightning component.     
* Author       : JoJo Zhao (Perficient, Inc.)
* Created On   : 12/20/2017
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer                                   Date                   Modification ID      Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
*
**************************************************************************************************************************************/

@isTest
public class ProductPriceCmpCtrl_Test {
     @testSetup 
    static void setup() {
        TestDataFactory.prepareAPICustomSetting();
        
    }
    public static testMethod void calloutExceptionTest(){
        Test.startTest();
        
        String fetchType = 'CalloutExceptionTest';
        String parentSkuId = 'W669-88';
        Test.setMock(HttpCalloutMock.class, new ProductPriceCallOutMock(fetchType));
          try{
            
           
        ProductPriceWrapper ppw = ProductPriceCmpCtrl.getProductPrice(parentSkuId);
            System.assert(false);
        }catch(Exception ex){
            System.assert(true);
        }        Test.stopTest();
    }
    
    public static testMethod void jsonExceptionTest(){
        Test.startTest();
        
        String fetchType='JSONExceptionTest';
        String parentSkuId = 'W669-88';
        Test.setMock(HttpCalloutMock.class, new ProductPriceCallOutMock(fetchType));
        try{
            ProductPriceWrapper ppw = ProductPriceCmpCtrl.getProductPrice(parentSkuId);
            System.assert(false);
        }catch(Exception ex){
            System.assert(true);
        }
        Test.stopTest();
    }
    
    public static testMethod void productPriceTest(){
        Test.startTest();
        
        String fetchType='other';
        String parentSkuId = 'W669-88';
        Test.setMock(HttpCalloutMock.class, new ProductPriceCallOutMock(fetchType));
        ProductPriceWrapper ppw = ProductPriceCmpCtrl.getProductPrice(parentSkuId);
        System.assertEquals(899.99, ppw.OriginalPrice);
        Test.stopTest();
    }
}