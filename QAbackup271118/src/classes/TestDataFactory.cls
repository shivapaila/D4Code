@isTest
public class TestDataFactory {

    public static final string CUSTOMER_PERSON_ACCOUNT_RECORD_TYPE_NAME = 'Customer';
    public static final string PROFILE_NAME_RSA = 'RSA';
    public static final string IPAD_DEVICE_NAME = 'xsdf-ghf-ghlu';

    // retrieve RSA Profile
    public static Profile getRSAProfile() {
        Profile p = [SELECT Id FROM Profile WHERE Name = :PROFILE_NAME_RSA];
        return p;
    }

    // create RSA User 
    public static User createRSAUser() {
        Profile p = getRSAProfile();
        User u = new User();
        u.CompanyName = 'Ashley';
        u.FirstName = 'Dan';
        u.LastName = 'Kelly';
        u.Street = '4000 MARKET ST';
        u.City = 'CAMP HILL';
        u.State = 'PA';
        u.PostalCode  = '17011';
        u.Phone  = '717-791-3300';
        //u.FederationIdentifier        
        u.Alias = 'dk';
        // Fix for Duplicate User name test failure for prod deployment
        u.Email = 'dk@test.com';
        u.EmailEncodingKey = 'UTF-8';
        u.LanguageLocaleKey = 'en_US';
        u.LocaleSidKey = 'en_US';
        u.ProfileId = p.Id;
        u.TimeZoneSidKey = 'America/Los_Angeles';
        u.UserName = 'dk@test.com.afi.testclass';
        u.DigestFrequency = 'N';
        u.DefaultGroupNotificationFrequency = 'N';
        u.UserPreferencesDisableAllFeedsEmail = false;
        u.UserPreferencesDisableProfilePostEmail = false;
        // custom fields
        u.RSA_ID__c = '12345';
        u.RSA_iPad_Device_Name__c= IPAD_DEVICE_NAME;
        u.AcctNo_ShipTo_ProfitCtr__c = '8888300-164-23-SWF';
        u.One_Source_ID__c = '10337';
        u.FulfillerID__c = 'SWF';
        return u;
    }

    public static void createOneSourceSetting(){
        OneSourceSettings__c oneSourceSetting = new OneSourceSettings__c();
        oneSourceSetting.Name = StoreInfo.ONE_SOURCE_API_CONFIG_NAME;
        oneSourceSetting.One_Source_API_Path__c = 'https://apigw.ashleyfurniture.com';
        oneSourceSetting.One_Source_API_Key__c = 'iuvg18wbwA3LwIyy4aj3wEPRTaQGGGYN';
        oneSourceSetting.One_Source_API_Refresh_Minutes__c = 1.0;
        insert oneSourceSetting;        
    }

    public static void createMarketSetting(){
        MarketSettings__c  marketSettings = new MarketSettings__c();
        marketSettings.Name = '8888300-164';
        marketSettings.Market_Code__c = 'SWF';
        insert marketSettings;        
    }

    public static List<Account> initializePersonAccounts(Integer numberOfRecords) {
        Id customerPersonAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(CUSTOMER_PERSON_ACCOUNT_RECORD_TYPE_NAME).getRecordTypeId();
        List<Account> accounts = new List<Account>();
        for (Integer i = 0 ; i < numberOfRecords ; i++ ) {
            
            Account acct = new Account();
            acct.recordTypeID = customerPersonAccountRecordTypeId;
            acct.LastName = 'last' + Math.random();
            acct.FirstName = 'first' + Math.random();
            acct.PersonEmail = acct.FirstName + '.' + acct.LastName + '@test.com';
            string phone = '888' + Integer.valueOf(Math.random() * 10000);
            while (phone.length() < 10){
                phone = phone + '0';
            }
            acct.phone = phone;
            
            accounts.add( acct);
        }
        return accounts;
    }
    
     public static List<Account> initializeAccounts(Integer numberOfRecords) {
        List<Account> accounts = new List<Account>();
        for (Integer i = 0 ; i < numberOfRecords ; i++ ) {
            
            Account acct = new Account();
            acct.Name = 'Test Account' + Math.random();
            accounts.add( acct);
        }
        return accounts;
    }

    public static List<Contact> initializeContacts(Id accountId, Integer numberOfRecords) {
        List<Contact> contacts = new List<Contact>();
        for (Integer i = 0 ; i < numberOfRecords ; i++ ) {            
            Contact con = new Contact();
            con.AccountId = accountId;
            con.LastName = 'last' + Math.random();
            con.FirstName = 'first' + Math.random();
            con.Email = con.FirstName + '.' + con.LastName + '@test.com';
            string phone = '888' + Integer.valueOf(Math.random() * 10000);
            while (phone.length() < 10){
                phone = phone + '0';
            }
            con.phone = phone;
            contacts.add( con);
        }
        return contacts;
    }
    
    public static List<Case> initializeCases(Id accountId, Id contactId, Integer numberOfRecords) {
        List<Case> cases = new List<Case>();
        for (Integer i = 0 ; i < numberOfRecords ; i++ ) {            
            Case c = new Case();
            c.Status = 'New';
            c.Priority = 'Medium';
            c.Origin = 'Web';
            c.Subject = 'Subject ' +  Math.random();
            c.Type = 'Delivery_Order_inquiry';
            c.Sub_Type__c = CaseTriggerHandler.CASE_SUB_TYPE_DAMAGE;            
            c.AccountId = accountId;
            c.ContactId = contactId;
            cases.add(c);
        }
        return cases;
    }

    public static List<SalesOrder__x> initializeSalesOrders(Integer numberOfRecords){
        List<SalesOrder__x> salesOrders = new List<SalesOrder__x>();
        for (Integer i = 0 ; i < numberOfRecords ; i++ ) {   
            SalesOrder__x testSalesOrder = new SalesOrder__x();
            testSalesOrder.phhDeliveryType__c = 'G1';
            testSalesOrder.phhStoreID__c = '345550-636';
            testSalesOrder.phhHot__c = true;
            testSalesOrder.phhOrder_Notes__c = 'Some notes';
          //  testSalesOrder.phhDesiredDate__c = Date.today();
            testSalesOrder.phhDatePromised__c = Date.today();
            testSalesOrder.externalId = 'ord-00' + String.valueof(i);
            testSalesOrder.fulfillerID__c = '009090-001';
            salesOrders.add(testSalesOrder);
        }
        return salesOrders;
    }

     public static List<SalesOrderItem__x> initializeSalesOrderLineItems(Integer numberOfRecords){
        List<SalesOrderItem__x> salesOrderLineItems = new List<SalesOrderItem__x>();
        for (Integer i = 0 ; i < numberOfRecords ; i++ ) {   
            SalesOrderItem__x testLineItem = new SalesOrderItem__x();
            testLineItem.phdDeliveryDueDate__c = Date.today();
            testLineItem.phdItemDesc__c = 'bedroom set xyz';
            testLineItem.phdQuantity__c = 1;
            testLineItem.phdItemSKU__c = 'Sku-00' + String.valueOf(i);             
            testLineItem.externalId = 'ordline-00' + String.valueOf(i);
            salesOrderLineItems.add(testLineItem);
        }
        return salesOrderLineItems;       
    }

    public static List<Task> initializeTasks(Id whatId, Id whoId, Integer numberOfRecords){
        List<Task> tasks = new List<Task>();
        for (Integer i = 0 ; i < numberOfRecords ; i++ ) {   
            Task testTask = new Task();
            testTask.Subject = 'Test subject';
            testTask.WhatId = whatId;
            testTask.WhoId = whoId;
            testTask.ActivityDate = Date.today();
            tasks.add(testTask);
        }

        return tasks;
    }

    public static List<Event> initializeEvents(Id whatId, Id whoId, Integer numberOfRecords){
        List<Event> events = new List<Event>();
        for (Integer i = 0 ; i < numberOfRecords ; i++ ) {   
            Event testEvent = new Event();
            testEvent.Subject = 'Test subject';
            testEvent.WhatId = whatId;
            testEvent.WhoId = whoId;
            testEvent.ActivityDateTime = DateTime.now();
            testEvent.DurationInMinutes = 120;
            events.add(testEvent);
        }

        return events;
    }
    
    
    public static void prepareAPICustomSetting(){
        List<Integration_Settings__c> cSettings = new List<Integration_Settings__c>();
        Integration_Settings__c cProdSetting = new Integration_Settings__c();
        cProdSetting.Name = ProductAPIBaseHelper.PRODUCT_API_ENDPOINT_SETTING_NAME;
        cProdSetting.End_Point_URL__c = 'https://ashley-preprod-qa.apigee.net';
        cProdSetting.API_Key__c = 'bGna5ABiJwsJyqV9DDtQmTBEH2Kpz713';
        cSettings.add(cProdSetting);
        
        Integration_Settings__c cItemDetailsSettings = new Integration_Settings__c();
        cItemDetailsSettings.Name = ProductAPIBaseHelper.ITEM_DETAIL_API_ENDPOINT_SETTING_NAME;
        cItemDetailsSettings.End_Point_URL__c = 'https://ashley-preprod-qa.apigee.net';
        cItemDetailsSettings.API_Key__c = 'bGna5ABiJwsJyqV9DDtQmTBEH2Kpz713';
        cSettings.add(cItemDetailsSettings); 
        
        Integration_Settings__c cReviewsSetting = new Integration_Settings__c();
        cReviewsSetting.Name = ProductAPIBaseHelper.PRODUCT_REVIEWS_API_ENDPOINT_SETTING_NAME;
        cReviewsSetting.End_Point_URL__c = 'http://api.bazaarvoice.com';
        cReviewsSetting.API_Key__c = 'cahEQLoVNXaj7oT8J9Og6xTKBdO1kFPNZWNQtCvQ13a3A';
        cSettings.add(cReviewsSetting);
        
        
        Integration_Settings__c cFilterSetting = new Integration_Settings__c();
        cFilterSetting.Name = ProductAPIBaseHelper.PRODUCT_FILTER_API_ENDPOINT_SETTING_NAME;
        cFilterSetting.End_Point_URL__c = 'http://search.unbxdapi.com';
        cFilterSetting.API_Key__c = '7e84d34e5d696f6eaac042a422b5e9f9';
        cSettings.add(cFilterSetting);
        
        Integration_Settings__c cATPsettings=new Integration_Settings__c();
        cATPsettings.Name = ShoppingCartLineItemCmpCtrl.ATP_API_SETTING_NAME;
        cATPsettings.End_Point_URL__c = 'https://ashley-preprod-dev.apigee.net/inventory';
        cATPsettings.API_Key__c = 'bGna5ABiJwsJyqV9DDtQmTBEH2Kpz713';
        cSettings.add(cATPsettings);
        
        Integration_Settings__c cEcommPricingSetting = new Integration_Settings__c();
        cEcommPricingSetting.Name = ProductAPIBaseHelper.ECOMM_PRICING_API_ENDPOINT_SETTING_NAME;
        cEcommPricingSetting.End_Point_URL__c = 'https://ashley-preprod-qa.apigee.net';
        cEcommPricingSetting.API_Key__c = 'bGna5ABiJwsJyqV9DDtQmTBEH2Kpz713';
        cSettings.add(cEcommPricingSetting);
        Integration_Settings__c sandboxSetting = new Integration_Settings__c(Name = API_ATCClient.INTEGRATION_SETTING_KEY_SANDBOX, API_Key__c = 'test key');
        cSettings.add(sandboxSetting);
        
        Integration_Settings__c productionSetting = new Integration_Settings__c(Name = API_ATCClient.INTEGRATION_SETTING_KEY_PRODUCTION, API_Key__c = 'test key');
        cSettings.add(productionSetting);
        
       
        Integration_Settings__c pmtTypesSettings = new Integration_Settings__c(
            Name ='PaymentTypesAPI',
            API_Key__c ='bGna5ABiJwsJyqV9DDtQmTBEH2Kpz713',
            End_Point_URL__c='https://ashley-preprod-dev.apigee.net');
        
        cSettings.add(pmtTypesSettings);
        
        Integration_Settings__c paymentTerminalnSetting= new Integration_Settings__c(
            Name ='PaymentTerminalAPI'
            , API_Key__c ='bGna5ABiJwsJyqV9DDtQmTBEH2Kpz713'
            , End_Point_URL__c='https://ashley-preprod-dev.apigee.net'
        );
        cSettings.add(paymentTerminalnSetting);
        
        Integration_Settings__c mainSettings = new Integration_Settings__c();
        mainSettings.Name = FinanceApiHelper.PAYMENT_API_SETTING_NAME;
        mainSettings.End_Point_URL__c = 'https://ashley-preprod-qa.apigee.net/authorizationgateway/authorizations';
        mainSettings.API_Key__c = 'apigeeapikey1234';
        cSettings.add(mainSettings); 

        Integration_Settings__c ccSettings = new Integration_Settings__c();
        ccSettings.Name = API_CCPayment.CC_API_SETTING_NAME;
        ccSettings.End_Point_URL__c = 'https://ashley-preprod-qa.apigee.net/authorizationgateway/authorizations';
        ccSettings.API_Key__c = 'apigeeapikey1234';
        cSettings.add(ccSettings);

        Integration_Settings__c finSettings = new Integration_Settings__c();
        finSettings.Name = FinanceApiHelper.FINANCE_TERMS_API_SETTING_NAME;
        finSettings.End_Point_URL__c = 'https://ashley-preprod-qa.apigee.net/authorizationgateway/authorizations';
        finSettings.API_Key__c = 'apigeeapikey1234';
        cSettings.add(finSettings);         

        Integration_Settings__c creditAuthorization = new Integration_Settings__c();
        creditAuthorization.Name = ConciergeFinancingPaymentController.FINANCE_TERMS_API_SETTING_NAME;
        creditAuthorization.End_Point_URL__c = 'https://ashley-preprod-dev.apigee.net';
        creditAuthorization.API_Key__c = 'bGna5ABiJwsJyqV9DDtQmTBEH2Kpz713';
        cSettings.add(creditAuthorization); 
        
        Integration_Settings__c cAtcCallDaysSetting = new Integration_Settings__c();
        cAtcCallDaysSetting.Name = ShoppingCartDetailCmpCtrl.ATC_CALL_DAYS_API_SETTING_NAME;
        cAtcCallDaysSetting.End_Point_URL__c = 'https://ashley-preprod-qa.apigee.net';
        cAtcCallDaysSetting.API_Key__c = 'bGna5ABiJwsJyqV9DDtQmTBEH2Kpz713';
        cSettings.add(cAtcCallDaysSetting);
        
        insert cSettings;
        
        MarketSettings__c  marketSettings = new MarketSettings__c();
        marketSettings.Name = '8888300-164';
        marketSettings.Market_Code__c = 'SWF';
        insert marketSettings;    
        
        OneSourceSettings__c oneSourceSetting = new OneSourceSettings__c();
        oneSourceSetting.Name = StoreInfo.ONE_SOURCE_API_CONFIG_NAME;
        oneSourceSetting.One_Source_API_Path__c = 'https://apigw.ashleyfurniture.com';
        oneSourceSetting.One_Source_API_Key__c = 'iuvg18wbwA3LwIyy4aj3wEPRTaQGGGYN';
        oneSourceSetting.One_Source_API_Refresh_Minutes__c = 1.0;
        insert oneSourceSetting;
        
        ConciergeProductAPISetting__c cPathSetting = new ConciergeProductAPISetting__c();
        cPathSetting.Name = ProductAPIBaseHelper.PRODUCT_API_SETTING_NAME;
        cPathSetting.Product_API_ItemDetail_Path__c= '/homestores/{0}/item-details?profitCenter={1}';
        cPathSetting.Payment_API_Types_Path__c = '/homestores/{0}/finance/payment-terminals/payment-types?apikey={1}';
        cPathSetting.Payment_API_Terms_Path__c = '/homestores/{0}/finance/payment-terminals/payment-types/{1}?apikey={2}';
        cPathSetting.Payment_Terminal__c = '/homestores/{0}/finance/payment-terminals/{1}?apikey={2}';
        cPathSetting.CC_Sales_API_Path__c = '/homestores/{0}/finance/payment-terminals/cc-sales?apikey={1}';
        cPathSetting.ATPAPISetting__c= '/retail?as={0}&sqt={1}|{2}|{3}&pc={4}';
        cPathSetting.Product_Reviews_API_Reviews_Path__c= '/data/reviews.json?apiversion={0}&passkey={1}&stats=reviews&filter=productid:{2}';
        cPathSetting.Product_Reviews_API_Statistics_Path__c= '/data/statistics.json?apiversion={0}&passkey={1}&stats=reviews&filter=productid:{2}';
        cPathSetting.Product_Reviews_API_Version__c= '5.4';      
        cPathSetting.CreditAuthorizationAPI_Path__c = '/homestores/{0}/finance/credit-authorizations';  
        cPathSetting.Product_API_ProdDetail_Path__c='/productinformation/retail/products?sku={0}&apikey={1}';
        cPathSetting.ATC_CALL_DAYS_API__c='/homestores/{0}/salesorders/sales-orders/settings/ATC_CALL_DAYS?profitCenter={1}';
        cPathSetting.Discount_Threshhold_API__c='/homestores/{0}/salesorders/sales-orders/settings/DISCOUNT_MANAGER_OVERRIDE_THRESHOLD?profitCenter={1}';
        insert cPathSetting;
        Delivery_Window__c window = new Delivery_Window__c(Name = 'Delivery Window', Number_of_hours__c = 24,window__c=43,LastUpdatedDate__c=system.now()); 
        insert window;
        
        Payment_Type__c  marketSet = new Payment_Type__c();
        //marketSet.Name = '8888300-164';
        marketSet.DocumentNumber__c = 'SWF';
        insert marketSet;    
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
        
        return acc;
    }
    
    
   public static Opportunity  prepareShoppingCart(Account acc){
        Opportunity opp =  new Opportunity();
        opp.AccountId = acc.Id;
        opp.Name=acc.Name+'-'+system.today().format();
        opp.StageName='Saved Shopping Cart';
        opp.CloseDate=Date.Today().addDays(30);
        opp.Cart_ZipCode__c='30004';
        insert opp;
        return opp;
    }
    
    public static List<Shopping_cart_line_item__c> prepareShoppingCartLineItems(Opportunity opp, Boolean doInsert){
        List<Shopping_cart_line_item__c> lineItems = new  List<Shopping_cart_line_item__c>();
        Shopping_cart_line_item__c line = new Shopping_cart_line_item__c();
        line.Product_SKU__c ='1200014';
        line.Quantity__c =1;
        line.Delivery_Mode__c='HD';
        line.List_Price__c = 288.99;
        line.Opportunity__c = opp.Id;
        line.Average_Cost__c = 40.99;
        line.DeliveryDate__c=system.today();
        line.isFutureDatedSale__c=false;
        lineItems.add(line);
        
        Shopping_cart_line_item__c line2 = new Shopping_cart_line_item__c();
        line2.Product_SKU__c ='M80221';
        line2.Quantity__c =1;
        line2.List_Price__c = 284;
        line2.Delivery_Mode__c='DS';
        line2.Opportunity__c = opp.Id;
        line2.DeliveryDate__c=system.today();
        line2.Average_Cost__c = 80.99;
        line2.isFutureDatedSale__c=false;
        lineItems.add(line2);
        
        Shopping_cart_line_item__c line3 = new Shopping_cart_line_item__c();
        line3.Product_SKU__c ='J80221';
        line3.Quantity__c =1;
        line3.List_Price__c = 800;
        line3.Opportunity__c = opp.Id;
        line3.DeliveryDate__c=system.today();
        line3.Average_Cost__c = 100.99;
        line3.isFutureDatedSale__c=false;
        lineItems.add(line3); 
        
        Shopping_cart_line_item__c line4 = new Shopping_cart_line_item__c();
        line4.Product_SKU__c ='K80221';
        line4.Quantity__c =1;
        line4.List_Price__c = 800;
        line4.Opportunity__c = opp.Id;
        line4.DeliveryDate__c=system.today();
        line4.Average_Cost__c = 80.99;
        line4.isFutureDatedSale__c=false;
        lineItems.add(line4); 
        Shopping_cart_line_item__c line5 = new Shopping_cart_line_item__c();
        line5.Product_SKU__c ='*KSADJPR5YNT';
        line5.Quantity__c =1;
        line5.List_Price__c = 249.99;
        line5.Opportunity__c = opp.Id;
        line5.DeliveryDate__c=system.today();
        line5.Average_Cost__c = 59.99;
        line5.isFutureDatedSale__c=false;
        lineItems.add(line5);
        if(doInsert)
        {
        insert lineItems;
        }
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
	
    public static List<Shopping_cart_line_item__c> prepareShoppingCartLineItems(Opportunity opp){
        
        List<Shopping_cart_line_item__c> lineItems = prepareShoppingCartLineItems(opp,true);
        
        return lineItems;
        
    }
   
}