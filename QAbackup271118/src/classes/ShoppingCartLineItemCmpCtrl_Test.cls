@isTest
public class ShoppingCartLineItemCmpCtrl_Test {
    
    public static testMethod void getLineItemDetailTest(){
        
        // Create custom setting
        TestDataFactory.prepareAPICustomSetting();
       
        User user1 =  prepareRSAUser('U1');
        Account acc =  prepareCustomerInfo();
        Opportunity opp =  prepareShoppingCart(acc);
        List<Shopping_cart_line_item__c> lineItems =   prepareShoppingCartLineItems(opp);
        Test.startTest();
        Shopping_cart_line_item__c item = ShoppingCartLineItemCmpCtrl.getLineItemDetail(lineItems[0].Id);
        System.assertEquals(lineItems[0].Id, item.Id);
        String result1 = ShoppingCartLineItemCmpCtrl.saveDiscount(lineItems[0].Id,'Flat',30,5,'', 0,user1.Id);
        System.assertEquals('Success', result1);
        String result2 = ShoppingCartLineItemCmpCtrl.saveDiscount(lineItems[1].Id,'Flat',30,1,'', 1,user1.Id);
        System.assertEquals('Success', result2);
        String result3 = ShoppingCartLineItemCmpCtrl.saveDiscount(lineItems[0].Id,'Percent',5,5,'', 0,user1.Id);
        System.assertEquals('Success', result3);
        String result4 = ShoppingCartLineItemCmpCtrl.saveDiscount(lineItems[1].Id,'Percent',30,5,'', 1,user1.Id);
        System.assertEquals('Success', result4);
        String result5 = ShoppingCartLineItemCmpCtrl.saveDiscount(lineItems[0].Id,'Percent',90,5,'', 0,user1.Id);
        System.assertEquals('Success', result5);
        Boolean isLocked = ShoppingCartLineItemCmpCtrl.isLineItemLocked(lineItems[0].Id);
        System.assertEquals(true, isLocked);
        
        String result6 = ShoppingCartLineItemCmpCtrl.saveDiscount(lineItems[1].Id,'Percent',60,5,'', 1,user1.Id);
        System.assertEquals('Success', result6);
        String result7= ShoppingCartLineItemCmpCtrl.saveDiscount(lineItems[2].Id,'Flat',60,640,'', 0,user1.Id);
        System.assertEquals('Success', result7);
        
        String result8= ShoppingCartLineItemCmpCtrl.saveDiscount(lineItems[3].Id,'Flat',60,720,'', 1,user1.Id);
        System.assertEquals('Success', result8);
        
        
        
        Test.stopTest();
    }
    
    public static testMethod void saveDeliveryModeTest(){
        // Create custom setting
        TestDataFactory.prepareAPICustomSetting();
		
        User user1 =  prepareRSAUser('U1');
        Account acc =  prepareCustomerInfo();
        Opportunity opp =  prepareShoppingCart(acc);
        List<Shopping_cart_line_item__c> lineItems =   prepareShoppingCartLineItems(opp);
        Test.startTest();
        ShoppingCartLineItemCmpCtrl.saveDeliveryMode(lineItems[0].Id, 
                                                     'HD',acc.Id,'THD');
                                                     //0);
        Shopping_cart_line_item__c item = ShoppingCartLineItemCmpCtrl.getLineItemDetail(lineItems[0].Id);
        System.assertEquals('HD', item.Delivery_Mode__c);
        
        ShoppingCartLineItemCmpCtrl.saveDeliveryMode(lineItems[0].Id, 
                                                     'TW', 
                                                     acc.Id,'PDI');
        
        Shopping_cart_line_item__c item2 = ShoppingCartLineItemCmpCtrl.getLineItemDetail(lineItems[1].Id);
        System.assertEquals('TW', item2.Delivery_Mode__c);
        
        Test.stopTest();
    }
    
    public static Account prepareCustomerInfo(){
        
        RecordType customerAccRT = [Select Id from recordType where SObjectType='Account' and Name='Customer'];
       // RecordType customerConRT= [Select Id from recordType where SObjectType='Contact' and Name='Customer'];
        
        Account acc =  new Account();
        acc.FirstName = 'testAccF';
        acc.LastName = 'testAccL';
        acc.RecordTypeId = customerAccRT.Id;
        acc.Phone ='(0)888-998-766';
        insert acc;
        prepareAddress(acc);
        return acc;
    }

   public static Address__c prepareAddress(Account account){
        Address__c address = new Address__c(
            AccountId__c = account.Id
            , Address_Line_1__c = 'test address 1'
            , Address_Line_2__c = 'test address 2'
            , City__c = 'test city'
            , State__c = 'GA'
            , Country__c = 'US'
            , Zip_Code__c = '30140'         
        );
        insert address;
        return address;
    }    
    
    
   public static Opportunity  prepareShoppingCart(Account acc){
        Address__c address = null;
        for (Address__c a : [SELECT Id FROM Address__c WHERE accountId__c = :acc.Id]){
            address = a;
        }
        Opportunity opp =  new Opportunity();
        opp.AccountId = acc.Id;
        opp.Name=acc.Name+'-'+system.today().format();
        opp.StageName='Saved Shopping Cart';
        opp.CloseDate=Date.Today().addDays(30);
        opp.Cart_ZipCode__c='30004';
        opp.Bill_To_Address__c = (address!=null ? address.Id : null);
        opp.ShipTo_Address__c = (address!=null ? address.Id : null);
        insert opp;
        return opp;
    }
    
    public static List<Shopping_cart_line_item__c> prepareShoppingCartLineItems(Opportunity opp){
        List<Shopping_cart_line_item__c> lineItems = new  List<Shopping_cart_line_item__c>();
        Shopping_cart_line_item__c line = new Shopping_cart_line_item__c();
        line.Product_SKU__c ='1200014';
        line.Quantity__c =1;
        line.Delivery_Mode__c='DS';
        line.List_Price__c = 288.99;
        line.Opportunity__c = opp.Id;
        line.Average_Cost__c = 40.99;
        lineItems.add(line);
        
        Shopping_cart_line_item__c line2 = new Shopping_cart_line_item__c();
        line2.Product_SKU__c ='M80221';
        line2.Quantity__c =1;
        line2.List_Price__c = 284;
        line2.Opportunity__c = opp.Id;
        line2.Delivery_Mode__c='HD';
        line2.Average_Cost__c = 80.99;
        lineItems.add(line2);
        
        Shopping_cart_line_item__c line3 = new Shopping_cart_line_item__c();
        line3.Product_SKU__c ='J80221';
        line3.Quantity__c =1;
        line3.List_Price__c = 800;
        line3.Opportunity__c = opp.Id;
        
        line3.Average_Cost__c = 100.99;
        lineItems.add(line3); 
        
        Shopping_cart_line_item__c line4 = new Shopping_cart_line_item__c();
        line4.Product_SKU__c ='K80221';
        line4.Quantity__c =1;
        line4.List_Price__c = 800;
        line4.Opportunity__c = opp.Id;
        
        line4.Average_Cost__c = 80.99;
        lineItems.add(line4); 
        Shopping_cart_line_item__c line5 = new Shopping_cart_line_item__c();
        line5.Product_SKU__c ='*KSADJPR5YNT';
        line5.Quantity__c =1;
        line5.List_Price__c = 249.99;
        line5.Opportunity__c = opp.Id;
        
        line5.Average_Cost__c = 59.99;
        lineItems.add(line5);
        insert lineItems;
        return lineItems;
    }
    
    public static User prepareRSAUser(String aliaStr){
        Profile p = [Select Id from profile where name='RSA'];
        User u = new User();
        u.ProfileId = p.Id;
        u.FirstName ='testRSA'+aliaStr;
        u.LastName ='testL';
        u.Alias = aliaStr;
        u.One_Source_ID__c='11002';
        u.AcctNo_ShipTo_ProfitCtr__c = '8888300-164-23-SWF';
        u.Username = 'testRSA'+aliaStr+'@test.com';
        u.Email =  'testRSA'+aliaStr+'@test.com';
        u.CommunityNickname =aliaStr;
        u.TimeZoneSidKey ='America/Los_Angeles';
        u.LocaleSidKey='en_US';
        u.EmailEncodingKey='ISO-8859-1';
        u.LanguageLocaleKey='en_US';
        insert u;
        return u;
    }
    public static testMethod void getATPResponseTest(){
        // Create custom setting
        TestDataFactory.prepareAPICustomSetting();

        Account acc =  prepareCustomerInfo();
        Opportunity opp =  prepareShoppingCart(acc); 
        List<Shopping_cart_line_item__c> lineItems =   prepareShoppingCartLineItems(opp);
         List<lineItemWrapper> shoppingDetail = new  List<lineItemWrapper>();
        for (Shopping_cart_line_item__c detail : lineItems) {
            lineItemWrapper line =new lineItemWrapper();
            line.item=detail;
            shoppingDetail.add(line);
        }
        String endPointURL='https://ashley-preprod-dev.apigee.net/inventory/retail?as=8888300-164&sqt=1200014|3|false&pc=30004';                   
        Integration_Settings__c pmtTypesConf= Integration_Settings__c.getValues(ShoppingCartLineItemCmpCtrl.ATP_API_SETTING_NAME);
        
        Test.startTest();      
        String fetchType = 'other';
        Test.setMock(HttpCalloutMock.class, new ATPCallOutMock(fetchType));
        shoppingDetail = ShoppingCartLineItemCmpCtrl.getATPResponse(endPointURL,shoppingDetail,pmtTypesConf);
        if(!shoppingDetail.isEmpty()){
             System.assertNotEquals(null, shoppingDetail[0].msg);
        }
       
        Test.stopTest();
    }
    public static testMethod void getBestDateTest(){
        TestDataFactory.prepareAPICustomSetting();
        
        Account acc =  prepareCustomerInfo();
        Opportunity opp =  prepareShoppingCart(acc); 
        opp.Cart_State__c='GA';
        opp.Cart_ZipCode__c='30004';
        update opp;
        List<Shopping_cart_line_item__c> lineItems =   prepareShoppingCartLineItems(opp);
        String sampleResponse = '{"deliveryWindows": [';
        for(Integer i=0; i < 5; i++){
            sampleResponse += '{';
            sampleResponse += '"start": "' + API_ATCClient.formatDateToISO8601(Date.today().addDays(i)) + '",';
            sampleResponse += '"end": "' + API_ATCClient.formatDateToISO8601(Date.today().addDays(i)) + '",';
            sampleResponse += '"sortIndex": ' + String.valueOf(i);
            sampleResponse += '}';
            if(i != 4){
                sampleResponse += ',';
            }
        }        
        sampleResponse += ']}';
        
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new MockCallout(200, 'OK', sampleResponse,new Map<String, String>()));
        if(!lineItems.isEmpty()){
            DateTime bestDate=ShoppingCartLineItemCmpCtrl.getBestDate(lineItems[0]);  
            system.assert(bestDate != null);
        }
        
        Test.stopTest();
    }
    public static testMethod void updateQuantityTest(){
        TestDataFactory.prepareAPICustomSetting();
        
        Account acc =  prepareCustomerInfo();
        Opportunity opp =  prepareShoppingCart(acc); 
        List<Shopping_cart_line_item__c> lineItems =   prepareShoppingCartLineItems(opp);
        if(!lineItems.isEmpty()){
            lineItems[0].DeliveryDate__c=system.today();
            update lineItems[0];
            String result=ShoppingCartLineItemCmpCtrl.updateQuantity(lineItems[0].Id, 4);
            system.assert(result == 'Success');
        }
    }
    
    public static testMethod void updateAsIsTest(){
        TestDataFactory.prepareAPICustomSetting();
        
        Account acc =  prepareCustomerInfo();
        Opportunity opp =  prepareShoppingCart(acc); 
        List<Shopping_cart_line_item__c> lineItems =   prepareShoppingCartLineItems(opp);
        if(!lineItems.isEmpty()){
            String result=ShoppingCartLineItemCmpCtrl.updateAsIs(lineItems[0].Id, true);
            system.assert(result == 'Success');
        }
    }
    
    public static testMethod void deleteFromCartTest(){
        TestDataFactory.prepareAPICustomSetting();
        
        Account acc =  prepareCustomerInfo();
        Opportunity opp =  prepareShoppingCart(acc); 
        List<Shopping_cart_line_item__c> lineItems =   prepareShoppingCartLineItems(opp);
        if(!lineItems.isEmpty()){
            String result=ShoppingCartLineItemCmpCtrl.deleteFromCart(lineItems[0].Id);
            system.assert(result == 'Success');
        }
    }
    
    public static testMethod void saveProductTitleTest(){
        TestDataFactory.prepareAPICustomSetting();
        
        Account acc =  prepareCustomerInfo();
        Opportunity opp =  prepareShoppingCart(acc); 
        List<Shopping_cart_line_item__c> lineItems =   prepareShoppingCartLineItems(opp);
        if(!lineItems.isEmpty()){
            ShoppingCartLineItemCmpCtrl.saveProductTitle('test title', lineItems[0].Id);
            Shopping_cart_line_item__c item=[Select Product_Title__c from Shopping_cart_line_item__c where id=:lineItems[0].Id];
            if(item != null){
                system.assert(item.Product_Title__c == 'test title');
            }
        }
    }
    
    public static testMethod void updateFppToLineItemTest(){
        TestDataFactory.prepareAPICustomSetting();
        
        Account acc =  prepareCustomerInfo();
        Opportunity opp =  prepareShoppingCart(acc); 
        List<Shopping_cart_line_item__c> lineItems =   prepareShoppingCartLineItems(opp);
        if(!lineItems.isEmpty()){
            ShoppingCartLineItemCmpCtrl.updateFppToLineItem('*KSADJPR5YNT', lineItems[0].Id);
            Shopping_cart_line_item__c item=[Select WarrantySku__c from Shopping_cart_line_item__c where id=:lineItems[0].Id];
            if(item != null){
                system.assert(item.WarrantySku__c == '*KSADJPR5YNT');
            }
        }
    }
    
    public static testMethod void getProductDetailTest(){
        TestDataFactory.prepareAPICustomSetting();
        
        Account acc =  prepareCustomerInfo();
        Opportunity opp =  prepareShoppingCart(acc); 
        List<Shopping_cart_line_item__c> lineItems =   prepareShoppingCartLineItems(opp);
        if(!lineItems.isEmpty()){
            Test.startTest();
            String fetchType='other';
            String productSkuId = 'W669-88';
            Test.setMock(HttpCalloutMock.class, new ProductDetailCallOutMock(fetchType));
            ProductWrapper pw = ShoppingCartLineItemCmpCtrl.getProductDetail(productSKUId, lineItems[0].Id);
            System.assertEquals('W669-88 Title name', pw.productTitle);
            Test.stopTest();
        }
    }

    public static testMethod void entitiesWrapperTest() {
        test.startTest();
        EntitiesWrapper ew = new EntitiesWrapper();
        ew.sku = 'Testsku';
        ew.message = 'test message';
        ew.bestDate = System.now();
        test.stoptest();
    }
   public static testMethod void tresholdenabledcalltest(){
        TestDataFactory.prepareAPICustomSetting();
       
       String sampleResponse = '[{"DefaultValue": "1","Name": "THRES_HOLD_ENABLED","ProfitCenter": 25,"SubProfitCenter": "","PropertyGroup": "1","Value": "1"}]';
            Test.startTest();
           
            ShoppingCartLineItemCmpCtrl.tresholdenabledcall(false);
             StoreInfoWrapper si = new StoreInfoWrapper('12991');
            si.fulfillerId='8888300-164';
            si.profitCtr='25';
            si.OneSourceID = '12991';
            Test.stopTest();
   }
    
}