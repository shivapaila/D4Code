@isTest
public class ShoppingCartDetailCmpCtrl_Test {

    @testSetup
    public static void prepareAPICustomSetting(){
        TestDataFactory.prepareAPICustomSetting();
                
    }
    @isTest
    public static void getShoppingCartLineItemsTest(){
        Account acc =  prepareCustomerInfo();
        Opportunity opp =  prepareShoppingCart(acc);
        Test.startTest();
        List<Shopping_cart_line_item__c> lineItems = ShoppingCartDetailCmpCtrl.getShoppingCartLineItems(acc.Id);
        System.assertEquals(3, lineItems.size());
        Test.stopTest();
    }
    @isTest
    public static void getShoppingCartTest(){
        Account acc =  prepareCustomerInfo();
        Opportunity opp =  prepareShoppingCart(acc);
        Test.startTest();
        Opportunity oppFetch = ShoppingCartDetailCmpCtrl.getShoppingCart(acc.Id);
        System.assertEquals(opp.Id, oppFetch.Id);
        Test.stopTest();
    }
    @isTest
    public static void getShippingWayListTest(){
        List<PairObj> deliveryModeList = ShoppingCartDetailCmpCtrl.getShippingWayList();
        System.assertNotEquals(null, deliveryModeList);
    }
    @isTest
    public static void getDiscountReasonListTest(){
        List<PairObj> discountReasons = ShoppingCartDetailCmpCtrl.getDiscountReasonList();
        System.assertNotEquals(null, discountReasons);
    }
    @isTest
    public static void getRSAOneSourceIdTest(){
        String sourceId = ShoppingCartDetailCmpCtrl.getRSAOneSourceId();
    }
    @isTest
    public static void getCartStateListTest(){
        List<PairObj> states = ShoppingCartDetailCmpCtrl.getCartStateList();
        System.assertNotEquals(null, states);
    }
    @isTest
    public static void getRSAMarketDiscountThreshholdsTest(){
        Test.setMock(HttpCalloutMock.class,  new StoreInfoMock());
        Test.startTest();        
        Decimal threshhold = ShoppingCartDetailCmpCtrl.getRSAMarketDiscountThreshholds();
        System.assertNotEquals(null, threshhold);
        Test.stopTest();
    }
    @isTest
    public static void getFPPTypesTest(){
        Test.startTest();
        String fetchType = 'other';
        Test.setMock(HttpCalloutMock.class, new FppTypesCallOutMock(fetchType));
        List<WarrantyItemWrapper> fpps = ShoppingCartDetailCmpCtrl.getFPPTypes();
        System.assertNotEquals(null, fpps);
        Test.stopTest();
    }
    @isTest
    public static void saveCartAddressInfoTest(){
        Account acc =  prepareCustomerInfo();
        Opportunity opp =  prepareShoppingCart(acc);
        opp.Cart_ZipCode__c ='310005';
        opp.Cart_State__c ='FL';
        Test.startTest();
        String result = ShoppingCartDetailCmpCtrl.saveCartAddressInfo(opp);
        System.assertEquals('Success', result);
        Test.stopTest();
    }
    @isTest
    public static void getShoppingCartTaxInfoExceptionTest(){
         Account acc =  prepareCustomerInfo();
        Opportunity opp =  prepareShoppingCart(acc);
        Test.startTest();
        
        String fetchType = 'CalloutExceptionTest';
        Test.setMock(HttpCalloutMock.class, new ShoppingCartItemDetailsCallOutMock(fetchType));
        try{
            ShoppingCartResponseWrapper cart = ShoppingCartDetailCmpCtrl.getShoppingCartTaxInfo(acc.Id);
            
            System.assert(false);
        }catch(Exception ex){
            System.assert(true);
        }
        Test.stopTest();
    }
    @isTest
    public static void getShoppingCartTaxInfoJSONExceptionTest(){
         Account acc =  prepareCustomerInfo();
        Opportunity opp =  prepareShoppingCart(acc);
        Test.startTest();
        
        String fetchType = 'JSONExceptionTest';
        Test.setMock(HttpCalloutMock.class, new ShoppingCartItemDetailsCallOutMock(fetchType));
        try{
            ShoppingCartResponseWrapper cart = ShoppingCartDetailCmpCtrl.getShoppingCartTaxInfo(acc.Id);
            
            System.assert(false);
        }catch(Exception ex){
            System.assert(true);
        }
        Test.stopTest();
    }
    @isTest
    public static void getShoppingCartTaxInfoTest(){
        Account acc =  prepareCustomerInfo();
        Opportunity opp =  prepareShoppingCart(acc);
        Test.startTest();
        
        String fetchType = 'other';
        Test.setMock(HttpCalloutMock.class, new ShoppingCartItemDetailsCallOutMock(fetchType));
        
        ShoppingCartResponseWrapper cart = ShoppingCartDetailCmpCtrl.getShoppingCartTaxInfo(acc.Id);
         System.assertNotEquals(null, cart);
        Test.stopTest();
    }
    @isTest
    public static void testCanViewCheckOnPendingItems(){
        Account acc =  prepareCustomerInfo();
        Opportunity opp =  prepareShoppingCart(acc);
         
          // set up settings
        Profile_Details__c profSettings = new Profile_Details__c();
        profSettings.Name = ShoppingCartDetailCmpCtrl.CHECKOUT_PROFILENAMESKEY;
        profSettings.Profile_Names__c = ShoppingCartDetailCmpCtrl.ALL_PROFILES;
        insert profSettings;
         
        Test.startTest();
        String canView = ShoppingCartDetailCmpCtrl.canViewCheckout(acc.id);
        System.assert(canView.contains('viewCheckout'));
        Test.stopTest();
    }
    @isTest
    public static void testCanViewCheckoutNoConfig(){
        Test.startTest();
        Boolean result = ShoppingCartDetailCmpCtrl.canViewCheckOnProfile();
        System.assertEquals(false, result);
        Test.stopTest();
    }
    @isTest
    public static void testCanViewCheckoutAll(){
        // set up settings
        Profile_Details__c profSettings = new Profile_Details__c();
        profSettings.Name = ShoppingCartDetailCmpCtrl.CHECKOUT_PROFILENAMESKEY;
        profSettings.Profile_Names__c = ShoppingCartDetailCmpCtrl.ALL_PROFILES;
        insert profSettings;
        
        Test.startTest();
        Boolean result = ShoppingCartDetailCmpCtrl.canViewCheckOnProfile();
        System.assertEquals(true, result);
        Test.stopTest();
    }
    @isTest
    public static void testCanViewCheckout(){
        // set up settings
        String standardProfile = 'Standard User';
        Profile p = [SELECT Id FROM Profile WHERE Name=:standardProfile];
        Profile_Details__c profSettings = new Profile_Details__c();
        profSettings.Name = ShoppingCartDetailCmpCtrl.CHECKOUT_PROFILENAMESKEY;
        profSettings.Profile_Names__c = standardProfile;
        insert profSettings;
        
        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles',
                          UserName=uniqueUserName);

        Test.startTest();
        
        System.runAs(u){
            Boolean result = ShoppingCartDetailCmpCtrl.canViewCheckOnProfile();
             System.assertEquals(true, result);
        }
       
        Test.stopTest();
    }
    @isTest
    public static void getShoppingCartLineItemsWrapperTest(){
        Account acc =  prepareCustomerInfo();
        Opportunity opp=prepareShoppingCart(acc);
        
        String[] str;
        System.runAs(TestDataFactory.createRSAUser()){
            Test.startTest();
            //Test.setMock(HttpCalloutMock.class, new ATPCallOutMock('other'));
            Test.setMock(HttpCalloutMock.class, new ShoppingCartLineItemsWrapperMock());
            List<lineItemWrapper> wrap=ShoppingCartDetailCmpCtrl.getShoppingCartLineItemsWrapper(acc.Id, str);
            system.assertNotEquals(null, wrap);
            
            Test.stopTest();
        }
    }
     @isTest
    public static void callDeliveryWindowApiTest()
    {
        StoreInfoWrapper si = new StoreInfoWrapper('8888300-164-23');   
        si.fulfillerId = '8888300-164';
        Delivery_Window__c del=[SELECT Name, SetupOwnerId, CreatedDate,LastUpdatedDate__c,LastModifiedDate,window__c,Number_of_hours__c 
                                                              FROM Delivery_Window__c 
                                                              WHERE IsDeleted = False and Name='Delivery Window'];
        del.window__c=null;
        update del;
        string sampleResponse='[{"DefaultValue":"43","Name":"ATC_CALL_Days","ProfitCenter":23,"SubProfitCenter":"","PropertyGroup":"1","Value":"43"}]';
        Test.setMock(HttpCalloutMock.class, new MockCallout(200, 'OK', sampleResponse,new Map<String, String>())); 
        Test.startTest();
        del=ShoppingCartDetailCmpCtrl.callDeliveryWindowApi(si);
        system.assert(del != null);
        Test.stopTest();
    }
    @isTest
    private static void getGuestDetailsTest(){
        Test.startTest();
        Account acc = prepareCustomerInfo();
        Account resAcc = ShoppingCartDetailCmpCtrl.getGuestDetails(acc.Id);
        Test.stopTest();
        System.assert(resAcc!=null);
    }
    @isTest
    private static void suspendToPosCartTest(){
        Account acc = prepareCustomerInfo();
        Opportunity opp = prepareShoppingCart(acc);
        
        // Create address
        Address__c addr = new Address__c();
        addr.AccountId__c = acc.Id;
        addr.Address_Line_1__c = 'Sample address 1';
        addr.Address_Line_2__c = 'Sample address 2';
        addr.City__c = 'Sample city';
        addr.State__c = 'Sample state';
        addr.Country__c = 'Sample country';
        addr.Zip_Code__c = '123456';
        insert addr;
        
        Electronic_Signature__c signObj = new Electronic_Signature__c();
        signObj.AccountId__c = acc.Id;
        signObj.Signature_Type__c = 'Opt into text messages';
        signObj.ObjectID__c = opp.Id;
        insert signObj;
        
        ContentVersion cv = new ContentVersion();
        cv.title = 'test content trigger';      
        cv.PathOnClient ='test';           
        cv.VersionData = Blob.valueOf('TestingSignature');          
        insert cv;         
                                                
        ContentVersion testContent = [SELECT id, ContentDocumentId FROM ContentVersion where Id = :cv.Id];

        ContentDocumentLink newFileShare = new ContentDocumentLink();
        newFileShare.contentdocumentid = testcontent.contentdocumentid;
        newFileShare.LinkedEntityId = signObj.Id;
        newFileShare.ShareType= 'V';
        insert newFileShare;
        
        String sampleResponse = '{"salesOrderResult" : [{"SalesOrderNumber": 0,"DeliveryViaCode": "HD","SalesOrderReferenceId": "b073b150-e8fe-480b-aadb-4e0e7dc2a20a"}],';
        sampleResponse += '"customerId" : "4046433752A",';
        sampleResponse += '"eReceiptBlobStorageUri": "https://caradev.blob.core.windows.net/concierge-ereceipts/8888300-164/20180409/400321770_400321780_400321790.pdf"}';
        
        Test.setMock(HttpCalloutMock.class, new MockCallout(200, 'OK', sampleResponse,new Map<String, String>()));  
       
        CheckoutFormWrapper formWrap = new CheckoutFormWrapper();
        String formWrapStr = JSON.serialize(formWrap);
        Test.startTest();
        Boolean res = ShoppingCartDetailCmpCtrl.suspendToPosCart(formWrapStr, acc.Id, addr.Id, addr.Id);
        Test.stopTest();
        System.assert(res == true);
    }   
    @isTest
    private static void createNewAddressTest() {
        RecordType customerAccRT = [Select Id from recordType where SObjectType='Account' and Name='Customer'];
        
        // Create account
        Account acc =  new Account();
        acc.FirstName = 'Test';
        acc.LastName = 'Acc';
        acc.RecordTypeId = customerAccRT.Id;
        acc.Phone ='(0)888-998-766';
        acc.PersonEmail = 'spalakkode@ashleyfurniture.com';
        insert acc;
        
        // Create address
        Address__c addr = new Address__c();
        addr.AccountId__c = acc.Id;
        addr.Address_Line_1__c = 'Sample address 1';
        addr.Address_Line_2__c = 'Sample address 2';
        addr.City__c = 'Sample city';
        addr.State__c = 'Sample state';
        addr.Country__c = 'Sample country';
        addr.Zip_Code__c = '123456';
        insert addr;
        
        // New address
        Address__c addr1 = new Address__c();
        addr1.AccountId__c = acc.Id;
        addr1.Address_Line_1__c = 'Sample address 1';
        addr1.Address_Line_2__c = 'Sample address 2';
        addr1.City__c = 'Sample city New';
        addr1.State__c = 'Sample state New';
        addr1.Country__c = 'Sample country New';
        addr1.Zip_Code__c = '1234567';
        
        Test.startTest();
        String addrIdNew = ShoppingCartDetailCmpCtrl.createNewAddress(acc.Id, addr1);
        String addrIdOld = ShoppingCartDetailCmpCtrl.createNewAddress(acc.Id, addr);
        Test.stopTest();
        System.assert(addrIdNew != null);
        System.assert(addrIdOld != null);
    }
    // Prepare Test Data    
    public static Account prepareCustomerInfo(){
        
        RecordType customerAccRT = [Select Id from recordType where SObjectType='Account' and Name='Customer'];
       // RecordType customerConRT= [Select Id from recordType where SObjectType='Contact' and Name='Customer'];
        
        Account acc =  new Account();
        acc.FirstName = 'testAccF';
        acc.LastName = 'testAccL';
        acc.RecordTypeId = customerAccRT.Id;
        acc.Phone ='(0)888-998-766';
        insert acc;
    /*    Contact con =new Contact(AccountId = acc.Id);
        con.FirstName = 'testCustomer';
        con.LastName = 'testJo';
        con.Email = 'testJoCustomer@test.com';
        con.MailingPostalCode ='310004';
        con.MailingState='GA';
        con.RecordTypeId=customerConRT.Id;
        
        insert con;*/
        
        return acc;
    }
    
    public static Opportunity  prepareShoppingCart(Account acc){
        Opportunity opp =  new Opportunity();
        opp.AccountId = acc.Id;
        opp.Name=acc.Name+'-'+system.today().format();
        opp.StageName='Saved Shopping Cart';
        opp.CloseDate=Date.Today().addDays(30);
        
        insert opp;
        
        List<Shopping_cart_line_item__c> lineItems = new  List<Shopping_cart_line_item__c>();
        Shopping_cart_line_item__c line = new Shopping_cart_line_item__c();
        line.Product_SKU__c ='1200014';
        line.Quantity__c =1;
        line.Delivery_Mode__c='HD';
        line.List_Price__c = 288.99;
        line.Average_Cost__c = 188.99;
        line.Opportunity__c = opp.Id;
        lineItems.add(line);
        
        Shopping_cart_line_item__c line2 = new Shopping_cart_line_item__c();
        line2.Product_SKU__c ='M80221';
        line2.Quantity__c =1;
        line2.List_Price__c = 284;
        line2.Average_Cost__c = 184.99;
        line2.Opportunity__c = opp.Id;
        lineItems.add(line2);
        
        Shopping_cart_line_item__c line3 = new Shopping_cart_line_item__c();
        line3.Product_SKU__c ='*KSADJPR5YNT';
        line3.Quantity__c =1;
        line3.List_Price__c = 249.99;
        line3.Average_Cost__c = 149.99;
        line3.Opportunity__c = opp.Id;
        lineItems.add(line3);
        insert lineItems;
        return opp;
    }
    public class ShoppingCartLineItemsWrapperMock implements HttpCalloutMock {
        private String discountThreshholdAPIResponse = '{ "Value": "10.0" }';
        private String atpApiSettingResponse = '{"properties": { "accountShipTo": "8888300-164","postalCode": "30004","skuQuantity": "1200014|1|false"},"entities": [{"sku": "1200014","message": "Usually ships in 4 to 8 days","bestDate": "2018-05-12T00:00:00"}]}';
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json');
            if (req.getEndPoint().contains('sales-orders')){
                res.setBody(discountThreshholdAPIResponse);            
            }             
            else if (req.getEndPoint().contains('retail')){
                res.setBody(atpApiSettingResponse);            
            } 
            else if(req.getEndPoint().contains('productinformation')){
                res.setBody(JSON.serialize(ProductDetailCallOutMock.prepareProductDetail())); 
            }
            else if(req.getEndPoint().contains('apigw.ashleyfurniture.com')){
                res.setBody(StoreInfoMock.prepareMockResponse()); 
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
    
    @isTest
    private static void getCheckoutSummaryInfoTest(){
        Account acc = prepareCustomerInfo();
        Opportunity opp = prepareShoppingCart(acc);
        
        // Create address
        Address__c addr = new Address__c();
        addr.AccountId__c = acc.Id;
        addr.Address_Line_1__c = 'Sample address 1';
        addr.Address_Line_2__c = 'Sample address 2';
        addr.City__c = 'Sample city';
        addr.State__c = 'Sample state';
        addr.Country__c = 'Sample country';
        addr.Zip_Code__c = '123456';
        insert addr;
        Test.startTest();
        
        String fetchType = 'other';
        Test.setMock(HttpCalloutMock.class, new ShoppingCartItemDetailsCallOutMock(fetchType));
        ShoppingCartDetailCmpCtrl.getCheckoutSummaryInfo(acc.Id, addr.Id);
        test.stopTest();
    }
    @isTest
    private static void checkSKUPresentTest(){
        Account acc = prepareCustomerInfo();
        Opportunity opp = prepareShoppingCart(acc);
        Boolean result=ShoppingCartDetailCmpCtrl.checkSKUPresent('1200014');
        system.assert(result == false);
    }
    @isTest
    private static void updateLineItemWithSKUTest(){
        Account acc = prepareCustomerInfo();
        Opportunity opp =  TestDataFactory.prepareShoppingCart(acc); 
        List<Shopping_cart_line_item__c> lineItems =   TestDataFactory.prepareShoppingCartLineItems(opp);
        if(!lineItems.isEmpty()){
            test.startTest();
            String fetchType = 'other';
            Test.setMock(HttpCalloutMock.class, new ShoppingCartItemDetailsCallOutMock(fetchType));
            Map<String, Object> testResult=ShoppingCartDetailCmpCtrl.updateLineItemWithSKU(acc.Id,lineItems[0]);
            system.assert(testResult != null);
            test.stopTest();
        }
        
    }
    
}