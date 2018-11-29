/* *******************************************************************************************************************
* Class Name   : MyCustomerControllerTest
* Description  : Test class for MyCustomerController.     
* Author       : Theyagarajan Sadhasivam (Perficient, Inc.)
* Created On   : 12/18/2017
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer                                   Date                   Modification ID      Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* Moon Cui (Perficient)                       2/1/2018                                    Updated for Person Account.
**************************************************************************************************************************************/
@isTest
public class MyCustomerControllerTest  {
    
    
    public static Account createAccounts() 
    {
        Account acc =new Account();
        String rtypeId=[Select id From RecordType Where DeveloperName='Customer' AND SobjectType='Account'].id;
        acc.RecordTypeId=rtypeId;
        acc.FirstName='Test';
        acc.LastName='Test';
        acc.Phone='9090909090';
        acc.PersonEmail = 'MyCustomerControllerTest@test.com';
        insert acc;

        Id [] fixedSearchResults= new Id[1];
        fixedSearchResults[0] = acc.id;
        Test.setFixedSearchResults(fixedSearchResults);

        return acc;        
    }
    
    @isTest
    public static void getAccountsTest()
    {
        MyCustomerControllerTest.createAccounts();
        List<Account> accLst=MyCustomerController.getAccounts();
        system.assert(!accLst.isEmpty());
    }
    
    @isTest
    public static void fetchAccountTest()
    {
        MyCustomerControllerTest.createAccounts();
        List<Account> accLst=MyCustomerController.findAccount('test', false);
        system.assert(!accLst.isEmpty());
    }
    
    @isTest
    public static void addToCartTest(){
         prepareAPICustomSetting();
        
        Account con=MyCustomerControllerTest.createAccounts();
        Opportunity opp = new Opportunity();
        opp.Name='test';
        opp.AccountId=con.Id;
        opp.CloseDate=system.today();
        opp.StageName='Saved Shopping Cart';
        insert opp;
        String prod='{"primaryImageId":"10116150M","productTitle":"Tempur Flex Supreme Queen Mattress","sku":"3510038","standardDepth":"80.0000000000000000","isDirectShipOnly": false,"standardHeight":"11.7500000000000000","standardWidth":"60.0000000000000000"}';
        String prodPrice='{"ImagePath":"https://www.ashleydirect.com/graphics/AD_Images/na.jpg","ItemDescription":"FLX SUP HY MED QN MATTRESS","ItemSku":"3510038","NailedDamagedQty":0,"OnHandAvailableQty":0,"OriginalPrice":2699}';
          Test.startTest();
        
        String fetchType = 'other';
         Test.setMock(HttpCalloutMock.class, new ShoppingCartItemDetailsCallOutMock(fetchType));
      
        //Test.setMock(HttpCalloutMock.class, new ProductDetailCallOutMock(fetchType));
     
        MyCustomerController.addToCart(con.Id, prod, prodPrice, 2);
        List<Shopping_cart_line_item__c > lineItemLst=[Select Id,Name,Opportunity__c,Product_SKU__c,List_Price__c,quantity__c 
                                                       From Shopping_cart_line_item__c 
                                                       where Opportunity__c=:opp.Id];
        system.assert(!lineItemLst.isEmpty());
        Test.stopTest();
        
    }
    
    @isTest
    public static void addToCartNoOppTest(){
        prepareAPICustomSetting();
        Account con=MyCustomerControllerTest.createAccounts();
        String prod='{"primaryImageId":"10116150M","productTitle":"Tempur Flex Supreme Queen Mattress","sku":"3510038","standardDepth":"80.0000000000000000","isDirectShipOnly": true,"standardHeight":"11.7500000000000000","standardWidth":"60.0000000000000000"}';
        String prodPrice='{"ImagePath":"https://www.ashleydirect.com/graphics/AD_Images/na.jpg","ItemDescription":"FLX SUP HY MED QN MATTRESS","ItemSku":"3510038","NailedDamagedQty":0,"OnHandAvailableQty":0,"OriginalPrice":2699}';
        Test.startTest();
        
        String fetchType = 'other';
       // Test.setMock(HttpCalloutMock.class, new ProductDetailCallOutMock(fetchType));
          Test.setMock(HttpCalloutMock.class, new ShoppingCartItemDetailsCallOutMock(fetchType));
      
        MyCustomerController.addToCart(con.Id, prod, prodPrice, 2);
        List<Opportunity> oppLst=[Select id,name,AccountId 
                                  From Opportunity 
                                  Where AccountId=:con.Id];
        system.assert(!oppLst.isEmpty());
        if(!oppLst.isEmpty()){
            
            
            List<Shopping_cart_line_item__c > lineItemLst=[Select Id,Name,Opportunity__c,Product_SKU__c,List_Price__c,quantity__c 
                                                           From Shopping_cart_line_item__c 
                                                           where Opportunity__c=:oppLst[0].Id];
            system.assert(!lineItemLst.isEmpty());
            
            
        }
        Test.stopTest();
    }
    
      @isTest
    public static void addToCartStarSKUTest(){
        prepareAPICustomSetting();
        Account con=MyCustomerControllerTest.createAccounts();
        Opportunity opp = new Opportunity();
        opp.Name='test';
        opp.AccountId=con.Id;
        opp.CloseDate=system.today();
        opp.StageName='Saved Shopping Cart';
        insert opp;
        
        Shopping_cart_line_item__c lineItem=new Shopping_cart_line_item__c();
        lineItem.Opportunity__c=opp.Id;
        lineItem.Product_SKU__c='3510038';
        lineItem.Quantity__c=1;
        lineItem.Delivery_Mode__c = 'HD';
        lineItem.Product_Title__c = 'Tempur Flex Supreme Queen Mattress';
        insert lineItem;
        String prod='{"sku":"*HDTV42"}';
        
        Test.startTest();
        
        String fetchType = 'starSKU';
          Test.setMock(HttpCalloutMock.class, new ShoppingCartItemDetailsCallOutMock(fetchType));
      
        MyCustomerController.addToCart(con.Id, prod, null, 1);
        List<Opportunity> oppLst=[Select id,name,AccountId 
                                  From Opportunity 
                                  Where AccountId=:con.Id];
        system.assert(!oppLst.isEmpty());
        if(!oppLst.isEmpty()){
            
            
            List<Shopping_cart_line_item__c > lineItemLst=[Select Id,Name,Opportunity__c,Product_SKU__c,List_Price__c,quantity__c 
                                                           From Shopping_cart_line_item__c 
                                                           where Opportunity__c=:oppLst[0].Id];
            system.assert(!lineItemLst.isEmpty());
            
            
        }
        Test.stopTest();
    }
  
      @isTest
    public static void addToCartPackageSKUTest(){
        prepareAPICustomSetting();
        Account con=MyCustomerControllerTest.createAccounts();
          Opportunity opp = new Opportunity();
        opp.Name='test';
        opp.AccountId=con.Id;
        opp.CloseDate=system.today();
        opp.StageName='Saved Shopping Cart';
        insert opp;
         Shopping_cart_line_item__c lineItem=new Shopping_cart_line_item__c();
        lineItem.Opportunity__c=opp.Id;
        lineItem.Product_SKU__c='D697-50B';
        lineItem.Quantity__c=1;
        lineItem.Delivery_Mode__c = 'HD';
        lineItem.Product_Title__c = 'Table Border';
        insert lineItem;
        String prod='{"sku":"APK-D697-50"}';
        
        Test.startTest();
        
        String fetchType = 'packageSKU';
          Test.setMock(HttpCalloutMock.class, new ShoppingCartItemDetailsCallOutMock(fetchType));
      
        MyCustomerController.addToCart(con.Id, prod, null, 1);
        List<Opportunity> oppLst=[Select id,name,AccountId 
                                  From Opportunity 
                                  Where AccountId=:con.Id];
        system.assert(!oppLst.isEmpty());
        if(!oppLst.isEmpty()){
            
            
            List<Shopping_cart_line_item__c > lineItemLst=[Select Id,Name,Opportunity__c,Product_SKU__c,List_Price__c,quantity__c 
                                                           From Shopping_cart_line_item__c 
                                                           where Opportunity__c=:oppLst[0].Id];
            system.assert(!lineItemLst.isEmpty());
            
            
        }
        Test.stopTest();
    }
    
      @isTest
    public static void addToCartPackageSKUNoOppTest(){
        prepareAPICustomSetting();
        Account con=MyCustomerControllerTest.createAccounts();
        String prod='{"sku":"APK-D697-50"}';
        
        Test.startTest();
        
        String fetchType = 'packageSKU';
          Test.setMock(HttpCalloutMock.class, new ShoppingCartItemDetailsCallOutMock(fetchType));
      
        MyCustomerController.addToCart(con.Id, prod, null, 1);
        List<Opportunity> oppLst=[Select id,name,AccountId 
                                  From Opportunity 
                                  Where AccountId=:con.Id];
        system.assert(!oppLst.isEmpty());
        if(!oppLst.isEmpty()){
            
            
            List<Shopping_cart_line_item__c > lineItemLst=[Select Id,Name,Opportunity__c,Product_SKU__c,List_Price__c,quantity__c 
                                                           From Shopping_cart_line_item__c 
                                                           where Opportunity__c=:oppLst[0].Id];
            system.assert(!lineItemLst.isEmpty());
            
            
        }
        Test.stopTest();
    }
    public static void prepareAPICustomSetting(){
        TestDataFactory.prepareAPICustomSetting();
        
        NewOpportunityDefaultAddress__c defaultOppAddress = new NewOpportunityDefaultAddress__c();
        defaultOppAddress.Name = 'defaultOppAddress';
        defaultOppAddress.PostCode__c = '31009';
        defaultOppAddress.StateOrProvince__c = 'GA';
        insert defaultOppAddress;
    }
}