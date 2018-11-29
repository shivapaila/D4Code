@isTest
public class ShoppingCartDiscountModalCtrl_Test {

    @testSetup
    public static void initsetup(){
        TestDataFactory.prepareAPICustomSetting();
    }      
    @isTest
    public static void getLineItemDetailTest(){
        User user1 =  TestDataFactory.prepareRSAUser('U1');
        System.runAs(user1){
            Account acc =  TestDataFactory.prepareCustomerInfo();
            Opportunity opp =  TestDataFactory.prepareShoppingCart(acc);
            List<Shopping_cart_line_item__c> lineItems =   TestDataFactory.prepareShoppingCartLineItems(opp);
            List<String> checkedLineItems =  new List<String>();
            checkedLineItems.add(lineItems[1].Id);
            checkedLineItems.add(lineItems[3].Id);
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new Mock());
            Shopping_cart_line_item__c item = ShoppingCartLineItemCmpCtrl.getLineItemDetail(lineItems[0].Id);
            System.assertEquals(lineItems[0].Id, item.Id);
            String result = ShoppingCartDiscountModalCtrl.saveDiscount(lineItems[0].Id,checkedLineItems, 90.0,'', user1.Id);
            System.assertEquals('Success', result);
            Test.stopTest();
        }
    }
    public class Mock implements HttpCalloutMock {
        private String discountAPIResponse = '{ "Value": "10.0" }';  
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json');
            
            if(req.getEndPoint().contains('apigw.ashleyfurniture.com')){
                res.setBody(StoreInfoMock.prepareMockResponse()); 
            }else {
                res.setBody(discountAPIResponse); 
            }
            res.setStatusCode(200);
            if(req.getEndPoint().contains('apigw.ashleyfurniture.com')){
                res.setStatus('Complete');
            }else{
                res.setStatus('OK');
            }
            return res;
        }
    }    
}