/* *******************************************************************************************************************
* Class Name   : CheckoutControllerTest
* Description  : Test class for CheckoutController     
* Author       : Prabha Kannan (Perficient, Inc.)
* Created On   : 02/13/2018
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer                                   Date                   Modification ID      Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
*
**************************************************************************************************************************************/
@isTest
public class CheckoutControllerTest {   
     @testSetup 
    static void setup() {
        TestDataFactory.prepareAPICustomSetting();
        
    }
    @isTest
    public static void getAddressesTest() 
    {   
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
        addr.Address_Type__c='Ship To';
        insert addr;
        
        // Create address
        Address__c addr1 = new Address__c();
        addr1.AccountId__c = acc.Id;
        addr1.Address_Line_1__c = 'Sample address 1';
        addr1.Address_Line_2__c = 'Sample address 2';
        addr1.City__c = 'Sample city';
        addr1.State__c = 'Sample state';
        addr1.Country__c = 'Sample country';
        addr1.Zip_Code__c = '123456';
        addr1.Address_Type__c='Bill To';
        insert addr1;
        
        // Create address
        Address__c addr2 = new Address__c();
        addr2.AccountId__c = acc.Id;
        addr2.Address_Line_1__c = 'Sample address 1';
        addr2.City__c = 'Sample city';
        addr2.State__c = 'Sample state';
        addr2.Country__c = 'Sample country';
        addr2.Zip_Code__c = '123456';
        addr2.Address_Type__c='Ship To';
        insert addr2;
        
        Test.startTest();
        CheckoutController cntrl = CheckoutController.getAddresses(acc.Id);
        Test.stopTest();
        System.assert(cntrl.addressList.size()>0);
    }
    
    @isTest
    public static void getShoppingCartLineItemsTest() 
    { 
        Account acc =  prepareCustomerInfo();
        Opportunity opp =  prepareShoppingCart(acc);
        Map<String ,List<Shopping_cart_line_item__c>> lineitemMap=CheckoutController.getShoppingCartLineItems(acc.Id);
        system.assert(lineitemMap != null);
    }
    
    @isTest
    public static void updateShoppingCartLineItemsTest() 
    { 
        Account acc =  prepareCustomerInfo();
        Opportunity opp =  prepareShoppingCart(acc);
        List<Shopping_cart_line_item__c> lineItems = TestDataFactory.prepareShoppingCartLineItems(opp, true);
        Map<String ,List<Shopping_cart_line_item__c>> lineitemMap=new Map<String ,List<Shopping_cart_line_item__c>>();
        lineitemMap=CheckoutController.updateShoppingCartLineItems('2018-09-09', lineItems, acc.Id);
    }
    
    @isTest
    public static void updateAsFutureDatedSaleTest() 
    { 
        Account acc =  prepareCustomerInfo();
        Opportunity opp =  prepareShoppingCart(acc);
        List<Shopping_cart_line_item__c> lineItems = TestDataFactory.prepareShoppingCartLineItems(opp, true);
        Map<String ,List<Shopping_cart_line_item__c>> lineitemMap=new Map<String ,List<Shopping_cart_line_item__c>>();
        lineitemMap=CheckoutController.updateAsFutureDatedSale(lineItems, acc.Id , false);
        lineitemMap=CheckoutController.updateAsFutureDatedSale(lineItems, acc.Id , true);
        system.assert(lineitemMap != null);
        
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
        line.List_Price__c = 288.99;
        line.Opportunity__c = opp.Id;
        line.Delivery_Mode__c='HD';
        lineItems.add(line);
        
        Shopping_cart_line_item__c line2 = new Shopping_cart_line_item__c();
        line2.Product_SKU__c ='M80221';
        line2.Quantity__c =1;
        line2.List_Price__c = 284;
        line2.Opportunity__c = opp.Id;
        line.Delivery_Mode__c='HD';
        lineItems.add(line2);
        
        
        insert lineItems;
        return opp;
    }
    
    @isTest
    public static void StoreInfoTest() 
    { 
        CheckoutController ctrl = new CheckoutController();
        ctrl=CheckoutController.getStoreInfo();
        system.assertEquals('8888300',ctrl.acctNo );
    }
    
    @isTest
    public static void callItemCheckTest(){
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
        
        
        Account acc =  prepareCustomerInfo();
        Opportunity opp =  prepareShoppingCart(acc);
        List<Shopping_cart_line_item__c> lineItems = TestDataFactory.prepareShoppingCartLineItems(opp, true);
        Address__c addr = new Address__c();
        addr.AccountId__c = acc.Id;
        addr.Address_Line_1__c = 'Sample address 1';
        addr.Address_Line_2__c = 'Sample address 2';
        addr.City__c = 'Sample city';
        addr.State__c = 'Sample state';
        addr.Country__c = 'Sample country';
        addr.Zip_Code__c = '123456';
        insert addr;
        test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new MockCallout(200, 'OK', sampleResponse,new Map<String, String>()));  
        
        API_ATCClient.ATCPayload payLoad = new API_ATCClient.ATCPayload ();
        payLoad.city = 'Dallas';
        payLoad.country = 'US';
        payLoad.deliveryMode = 'Home';
        payLoad.postalCode = '75252';
        payLoad.region = 'TX';
        payLoad.products.add(new API_ATCClient.ProductWrapper('test sku', 1));
        Map<String ,List<Shopping_cart_line_item__c>> returnLst=CheckoutController.callItemCheck(string.valueof(system.today()), lineItems, acc.Id,addr.Id);
        system.assert(returnLst != null);
        test.stopTest();
        
    }
    
    @isTest
    public static void callItemCheckEmptyDateTest(){
        String sampleResponse = '{"deliveryWindows": []}';

        Account acc =  prepareCustomerInfo();
        Opportunity opp =  prepareShoppingCart(acc);
        List<Shopping_cart_line_item__c> lineItems = TestDataFactory.prepareShoppingCartLineItems(opp, true);
        Address__c addr = new Address__c();
        addr.AccountId__c = acc.Id;
        addr.Address_Line_1__c = 'Sample address 1';
        addr.Address_Line_2__c = 'Sample address 2';
        addr.City__c = 'Sample city';
        addr.State__c = 'Sample state';
        addr.Country__c = 'Sample country';
        addr.Zip_Code__c = '123456';
        insert addr;
        test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new MockCallout(200, 'OK', sampleResponse,new Map<String, String>()));  
        
        API_ATCClient.ATCPayload payLoad = new API_ATCClient.ATCPayload ();
        payLoad.city = 'Dallas';
        payLoad.country = 'US';
        payLoad.deliveryMode = 'Home';
        payLoad.postalCode = '75252';
        payLoad.region = 'TX';
        payLoad.products.add(new API_ATCClient.ProductWrapper('test sku', 1));
        Map<String ,List<Shopping_cart_line_item__c>> returnLst=CheckoutController.callItemCheck(string.valueof(system.today()), lineItems, acc.Id,addr.Id);
        system.assert(returnLst != null);
        test.stopTest();
        
    }
     @isTest
    public static void createNewAddressTest() 
    { 
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
        
        // Create address
        Address__c addr1 = new Address__c();
        addr1.AccountId__c = acc.Id;
        addr1.Address_Line_1__c = 'Sample address 1';
        addr1.Address_Line_2__c = 'Sample address 2';
        addr1.City__c = 'Sample city';
        addr1.State__c = 'Sample state';
        addr1.Country__c = 'Sample country';
        addr1.Zip_Code__c = '123456';
        insert addr1;
        
        // Create address
        Address__c addr2 = new Address__c();
        addr2.AccountId__c = acc.Id;
        addr2.Address_Line_1__c = 'Sample address 1';
        addr2.City__c = 'Sample city';
        addr2.State__c = 'Sample state';
        addr2.Country__c = 'Sample country';
        addr2.Zip_Code__c = '123456';
        insert addr2;
        CheckoutController cntrl = CheckoutController.getAddresses(acc.Id);
        cntrl.formWrap.shipAddr1= 'test address 1';
        cntrl.formWrap.shipAddr2 = 'test address 2';
        cntrl.formWrap.shipCity= 'test city';
        cntrl.formWrap.shipState = 'test state';
        cntrl.formWrap.shipPostalCode = '123457';
        cntrl.formWrap.billAddr1= 'test address 1';
        cntrl.formWrap.billAddr2 = 'test address 2';
        cntrl.formWrap.billCity= 'test city';
        cntrl.formWrap.billState = 'test state';
        cntrl.formWrap.billPostalCode = '123457';
        cntrl.formWrap.oldAddrId=addr1.Id;
        String formWrapStr=JSON.serialize(cntrl.formWrap);
        String mapWrap= JSON.serialize(cntrl.formWrapMap);
        test.startTest();
        CheckoutController.createNewAddress(cntrl.addressList,cntrl.addressList1,formWrapStr, true, acc.Id, mapWrap);
        System.assert(cntrl.addressList.size()>0);
        CheckoutController.createNewAddress(cntrl.addressList,cntrl.addressList1,formWrapStr, false, acc.Id, mapWrap);
        System.assert(cntrl.addressList.size()>0);
        
        test.stopTest();
        
        
        
    }
    
     @isTest
    public static void saveDesiredDeliveryDateTest() 
    { 
        Account acc =  prepareCustomerInfo();
        Opportunity opp =  prepareShoppingCart(acc);
        Date currentDay = System.today();
        Boolean result = CheckoutController.saveDesiredDeliveryDate(opp.Id, currentDay.year()+'-'+(currentDay.month()+1)+'-'+currentDay.day());
        System.assert(result);
    }
    @isTest
    public static void updateAddressOnOptyTest() 
    { 
        RecordType customerAccRT = [Select Id from recordType where SObjectType='Account' and Name='Customer'];
        
        Account acc =  prepareCustomerInfo();
        Opportunity opp =  prepareShoppingCart(acc);
        List<Shopping_cart_line_item__c> lineItems = TestDataFactory.prepareShoppingCartLineItems(opp, true);
        
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
        
        // Create address
        Address__c addr1 = new Address__c();
        addr1.AccountId__c = acc.Id;
        addr1.Address_Line_1__c = 'Main Street';
        addr1.Address_Line_2__c = '100';
        addr1.City__c = 'Cumming';
        addr1.State__c = 'GA';
        addr1.Country__c = 'Sample country';
        addr1.Zip_Code__c = '30041';
        insert addr1;
        
        // Create address
        Address__c addr2 = new Address__c();
        addr2.AccountId__c = acc.Id;
        addr2.Address_Line_1__c = 'Sample address 1';
        addr2.City__c = 'Sample city';
        addr2.State__c = 'Sample state';
        addr2.Country__c = 'Sample country';
        addr2.Zip_Code__c = '123456';
        insert addr2;
        CheckoutController cntrl = CheckoutController.getAddresses(acc.Id);
        cntrl.formWrap.shipAddr1= 'test address 1';
        cntrl.formWrap.shipAddr2 = 'test address 2';
        cntrl.formWrap.shipCity= 'test city';
        cntrl.formWrap.shipState = 'test state';
        cntrl.formWrap.shipPostalCode = '123457';
        cntrl.formWrap.billAddr1= 'test address 1';
        cntrl.formWrap.billAddr2 = 'test address 2';
        cntrl.formWrap.billCity= 'test city';
        cntrl.formWrap.billState = 'test state';
        cntrl.formWrap.billPostalCode = '123456';
        cntrl.formWrap.oldAddrId=addr1.Id;
        cntrl.formWrap.shipPhone = '1234567890';
        String formWrapStr=JSON.serialize(cntrl.formWrap);
        String mapWrap= JSON.serialize(cntrl.formWrapMap);
        
        Test.startTest();
        String fetchType = 'other';
        Test.setMock(HttpCalloutMock.class, new ShoppingCartItemDetailsCallOutMock(fetchType));
        CheckoutController.updateAddressOnOpty(formWrapStr, acc.Id, addr1.Id, addr1.Id);
        System.assert(cntrl.addressList.size()>0);
        Test.stopTest();
    }
    
    @isTest
    public static void suspendSalesTest() 
    { 
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
        Boolean res = CheckoutController.suspendSales(formWrapStr, acc.Id, addr.Id, addr.Id);
        Test.stopTest();
        System.assert(res == true);
    }
}