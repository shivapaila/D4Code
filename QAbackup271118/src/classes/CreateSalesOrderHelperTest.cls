/**************************************************************************************************
* Name       : CreateSalesOrderHelper
* Purpose    : Test Class for CreateSalesOrderHelper
***************************************************************************************************
* Author            | Version    | Created Date    | Description
***************************************************************************************************
*Sridhar            | 1.0        | 2/20/2018       | Initial Draft
*Sridhar            | 1.0        | 2/25/2018       | Final Draft
**************************************************************************************************/
@isTest
public class CreateSalesOrderHelperTest {
    
    @testSetup
    public static void initsetup(){
		// Create custom setting
        TestDataFactory.prepareAPICustomSetting();
    }
    @isTest
    public static void testCreateOrder(){
        String recordTypeId  = [select Id from RecordType where (Name='Customer') and (SobjectType='Account')].Id;
        Account acc= new Account(
          RecordTypeID=recordTypeId ,
          FirstName='Test FName',
          LastName='Test LName',
          PersonMailingStreet='teststreet1',
          PersonMailingPostalCode='12345',
          PersonMailingCity='SFO',
          PersonEmail='test@yahoo.com',
          PersonMobilePhone='1234567897',
          Phone ='(404) 643-3751',
          Phone_2__pc ='(404) 643-3752',
          Phone_3__pc ='(404) 643-3753'
        );
        insert acc;

        Opportunity opp = new Opportunity();
        opp.stageName ='Saved Shopping Cart';
        opp.accountId = acc.Id;
        opp.closeDate = Date.newInstance(System.now().year(), System.now().month(), System.now().day())+7;
        opp.name = 'Test Opportunity Name';
        opp.Delivery_Notes__c = 'Delivery Notes';
        opp.Text_Message_Opt_In__c = true;
        insert opp;
		
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
        
        Electronic_Signature__c signObj1 = new Electronic_Signature__c();
        signObj1.AccountId__c = acc.Id;
        signObj1.Signature_Type__c = 'Customer Order Acceptance';
        signObj1.ObjectID__c = opp.Id;
        insert signObj1;
        
        ContentVersion cv1 = new ContentVersion();
        cv1.title = 'test content trigger';      
        cv1.PathOnClient ='test';           
        cv1.VersionData = Blob.valueOf('TestingSignature');          
        insert cv1;         
                                                
        ContentVersion testContent1 = [SELECT id, ContentDocumentId FROM ContentVersion where Id = :cv1.Id];

        ContentDocumentLink newFileShare1 = new ContentDocumentLink();
        newFileShare1.contentdocumentid = testcontent1.contentdocumentid;
        newFileShare1.LinkedEntityId = signObj1.Id;
        newFileShare1.ShareType= 'V';
        insert newFileShare1;
        
        Shopping_cart_line_item__c lineItem = new Shopping_cart_line_item__c();
        lineItem.Product_SKU__c = 'M80421';
        lineItem.Discount__c=0;
        lineItem.DiscountType__c = 'Percent';
        lineItem.Flat_Discounted_Amount__c = 0;
        lineItem.List_Price__c = 284;
        lineItem.Average_Cost__c = 146.49;
        lineItem.Quantity__c = 2;
        lineItem.Opportunity__c = opp.Id;
        lineItem.Delivery_Mode__c ='HD';
        lineItem.Discount_Status__c = 'Not Applicable';
        lineItem.Estimated_Tax__c = 39.76;
        lineItem.Extended_Price__c = 568;
        lineItem.ItemType__c = 0;

        insert lineItem;

        Address__c add = new Address__c();
        add.AccountId__c = acc.Id;
        add.Address_Line_1__c = '55 Trinity Avenue';
        add.City__c = 'Atlanta';
        add.State__c = 'GA';
        add.Country__c = 'US';
        add.Zip_Code__c = '30303';
        insert add;

        Cart_Payment_Transaction__c payment = new Cart_Payment_Transaction__c();
        payment.Transaction_Number__c = 'EFB-PAY-19HHVG';
        payment.Payment_Type__c = 'Cash';
        payment.Payment_Amount__c = 568;
        payment.Opportunity__c = opp.Id;
        insert payment;


        Payment_Type__c payType = new Payment_Type__c();
        payType.TenderCode__c = 'CSH';
        payType.TenderCodeDescription__c = 'Cash';
        payType.DocumentNumber__c = '9000';
        payType.Last_Updated_PaymentTypes_Info__c = System.now();
        
        insert payType;
		CheckoutFormWrapper formWrap = new CheckoutFormWrapper();
        formWrap.shipPhone = '4123241234';
        formWrap.billPhone = '4123241234';
        formWrap.shipEmail = 'test@perficient.com';
        formWrap.billEmail = 'test@perficient.com';
        Test.setMock(HttpCalloutMock.class, new Mock());
        Test.startTest();
        //System.assertNotEquals(CreateSalesOrderHelper.CreateOrder(acc.Id, true, add.Id, add.Id, formWrap),null);
        //To be corrected later
        ////CreateSalesOrderHelper.getPayments((CreateSalesOrderHelper.getOpportunity(acc.Id)).Id);
        ////CreateSalesOrderHelper.saveShoppingCartLineItems((CreateSalesOrderHelper.getOpportunity(acc.Id)).Id,'NUM001');
        try{
            CreateSalesOrderHelper.CreateOrderInHome(acc.Id, add.Id, add.Id, formWrap);
        	//CreateSalesOrderHelper.CreateOrder(acc.Id, true, add.Id, add.Id, formWrap);    
        }catch(Exception e){}
        //CreateSalesOrderHelper.saveShoppingCartLineItems((CreateSalesOrderHelper.getOpportunity(acc.Id)).Id,'NUM001');
        
        //System.assertNotEquals(CreateSalesOrderHelper.getPayments(opp.Id),null);
        //System.assertNotEquals(CreateSalesOrderHelper.CreateOrderInHome(acc.Id, add.Id, add.Id, formWrap),null);
        Test.stopTest();
    }

	@isTest
    public static void testCreateOrder1(){
        String recordTypeId  = [select Id from RecordType where (Name='Customer') and (SobjectType='Account')].Id;
        Account acc= new Account(
          RecordTypeID=recordTypeId ,
          FirstName='Test FName',
          LastName='Test LName',
          PersonMailingStreet='teststreet1',
          PersonMailingPostalCode='12345',
          PersonMailingCity='SFO',
          PersonEmail='test@yahoo.com',
          PersonMobilePhone='1234567897',
          Phone ='(404) 643-3751',
          Phone_2__pc ='(404) 643-3752',
          Phone_3__pc ='(404) 643-3753'
        );
        insert acc;

        Opportunity opp = new Opportunity();
        opp.stageName ='Saved Shopping Cart';
        opp.accountId = acc.Id;
        opp.closeDate = Date.newInstance(System.now().year(), System.now().month(), System.now().day())+7;
        opp.name = 'Test Opportunity Name';
        opp.Delivery_Notes__c = 'Delivery Notes';
        opp.Text_Message_Opt_In__c = true;
        insert opp;
		
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
        
        Electronic_Signature__c signObj1 = new Electronic_Signature__c();
        signObj1.AccountId__c = acc.Id;
        signObj1.Signature_Type__c = 'Customer Order Acceptance';
        signObj1.ObjectID__c = opp.Id;
        insert signObj1;
        
        ContentVersion cv1 = new ContentVersion();
        cv1.title = 'test content trigger';      
        cv1.PathOnClient ='test';           
        cv1.VersionData = Blob.valueOf('TestingSignature');          
        insert cv1;         
                                                
        ContentVersion testContent1 = [SELECT id, ContentDocumentId FROM ContentVersion where Id = :cv1.Id];

        ContentDocumentLink newFileShare1 = new ContentDocumentLink();
        newFileShare1.contentdocumentid = testcontent1.contentdocumentid;
        newFileShare1.LinkedEntityId = signObj1.Id;
        newFileShare1.ShareType= 'V';
        insert newFileShare1;
        
        Shopping_cart_line_item__c lineItem = new Shopping_cart_line_item__c();
        lineItem.Product_SKU__c = 'M80421';
        lineItem.Discount__c=0;
        lineItem.DiscountType__c = 'Percent';
        lineItem.Flat_Discounted_Amount__c = 0;
        lineItem.List_Price__c = 284;
        lineItem.Average_Cost__c = 146.49;
        lineItem.Quantity__c = 2;
        lineItem.Opportunity__c = opp.Id;
        lineItem.Delivery_Mode__c ='HD';
        lineItem.Discount_Status__c = 'Not Applicable';
        lineItem.Estimated_Tax__c = 39.76;
        lineItem.Extended_Price__c = 568;
        lineItem.ItemType__c = 0;

        insert lineItem;

        Address__c add = new Address__c();
        add.AccountId__c = acc.Id;
        add.Address_Line_1__c = '55 Trinity Avenue';
        add.City__c = 'Atlanta';
        add.State__c = 'GA';
        add.Country__c = 'US';
        add.Zip_Code__c = '30303';
        insert add;

        Cart_Payment_Transaction__c payment = new Cart_Payment_Transaction__c();
        payment.Transaction_Number__c = 'EFB-PAY-19HHVG';
        payment.Payment_Type__c = 'Cash';
        payment.Payment_Amount__c = 568;
        payment.Opportunity__c = opp.Id;
        insert payment;


        Payment_Type__c payType = new Payment_Type__c();
        payType.TenderCode__c = 'CSH';
        payType.TenderCodeDescription__c = 'Check';
        payType.DocumentNumber__c = '9000';
        payType.Last_Updated_PaymentTypes_Info__c = System.now();
        insert payType;

		CheckoutFormWrapper formWrap = new CheckoutFormWrapper();
        formWrap.shipPhone = '4123241234';
        formWrap.billPhone = '4123241234';
        formWrap.shipEmail = 'test@perficient.com';
        formWrap.billEmail = 'test@perficient.com';
        Test.setMock(HttpCalloutMock.class, new Mock());
        Test.startTest();
        //System.assertNotEquals(CreateSalesOrderHelper.CreateOrder(acc.Id, true, add.Id, add.Id, formWrap),null);
        //To be corrected later
        ////CreateSalesOrderHelper.getPayments((CreateSalesOrderHelper.getOpportunity(acc.Id)).Id);
        CreateSalesOrderHelper.saveShoppingCartLineItems((CreateSalesOrderHelper.getOpportunity(acc.Id)).Id,'NUM001');
        try{
            CreateSalesOrderHelper.CreateOrderInHome(acc.Id, add.Id, add.Id, formWrap);
        	//CreateSalesOrderHelper.CreateOrder(acc.Id, true, add.Id, add.Id, formWrap);    
        }catch(Exception e){}
        //CreateSalesOrderHelper.saveShoppingCartLineItems((CreateSalesOrderHelper.getOpportunity(acc.Id)).Id,'NUM001');
        
        //System.assertNotEquals(CreateSalesOrderHelper.getPayments(opp.Id),null);
        //System.assertNotEquals(CreateSalesOrderHelper.CreateOrderInHome(acc.Id, add.Id, add.Id, formWrap),null);
        Test.stopTest();
    }

    private class Mock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json');
            if (req.getEndpoint().startsWith('https://ashley-preprod')) {
                res.setBody('{"salesOrderResult":[{"SalesOrderNumber":0,"DeliveryViaCode":"HD","SalesOrderReferenceId":"b073b150-e8fe-480b-aadb-4e0e7dc2a20a"}],"customerId":"4046433752A"}');
                res.setStatusCode(201); 
            } else {
				res.setBody('{"SalesOrderLineList":[{"ActionCode":0,"LineNumber":1,"PackageLineNumber":0,"ItemNumber":"1200020","Quantity":3,"DeliverViaCode":"HD","AvailableDate":"2018-03-05T00:00:00","ItemType":0,"OriginalPrice":399.99,"UnitCost":162.76,"UnitPrice":399.99,"ExtendedPrice":1199.97,"UnitDiscountAmount":0.0,"UnitDiscountPercent":0.0,"UnitPriceAdjustments":[],"RetailDescription":"Chair","Itemcategory":"DU","CartonQuantity":1.0,"Taxes":{"TotalTaxAmount":0.0,"Taxes":[{"CalculationSequence":1,"TaxJurisdiction":"031","TaxRate":6.000,"TaxAmount":71.99820,"TaxableAmount":1199.97},{"CalculationSequence":2,"TaxJurisdiction":"031","TaxRate":0.000,"TaxAmount":0.0,"TaxableAmount":0.0},{"CalculationSequence":3,"TaxJurisdiction":"031","TaxRate":0.000,"TaxAmount":0.0,"TaxableAmount":0.0}],"TaxCode":"031","TaxDescription":"\\"do not use\\"-Clayton"},"TotalTax":71.99820,"TaxAmount1":71.99820,"TaxAmount2":0.0,"TaxAmount3":0.0,"DefaultTaxCode":null,"WarrantySku":""},{"ActionCode":0,"LineNumber":2,"PackageLineNumber":0,"ItemNumber":"M80421","Quantity":2,"DeliverViaCode":"HD","AvailableDate":"2018-03-05T00:00:00","ItemType":0,"OriginalPrice":284.0,"UnitCost":146.49,"UnitPrice":284.0,"ExtendedPrice":568.0,"UnitDiscountAmount":0.0,"UnitDiscountPercent":0.0,"UnitPriceAdjustments":[],"RetailDescription":"Full Mattress","Itemcategory":"BI","CartonQuantity":1.0,"Taxes":{"TotalTaxAmount":0.0,"Taxes":[{"CalculationSequence":1,"TaxJurisdiction":"031","TaxRate":6.000,"TaxAmount":34.080,"TaxableAmount":568.0},{"CalculationSequence":2,"TaxJurisdiction":"031","TaxRate":0.000,"TaxAmount":0.0,"TaxableAmount":0.0},{"CalculationSequence":3,"TaxJurisdiction":"031","TaxRate":0.000,"TaxAmount":0.0,"TaxableAmount":0.0}],"TaxCode":"031","TaxDescription":"\\"do not use\\"-Clayton"},"TotalTax":34.080,"TaxAmount1":34.080,"TaxAmount2":0.0,"TaxAmount3":0.0,"DefaultTaxCode":null,"WarrantySku":""},{"ActionCode":0,"LineNumber":3,"PackageLineNumber":0,"ItemNumber":"*DELIV-TAX","Quantity":1,"DeliverViaCode":"HD","AvailableDate":"2018-03-05T00:00:00","ItemType":3,"OriginalPrice":70.0,"UnitCost":0.0,"UnitPrice":70.0,"ExtendedPrice":70.0,"UnitDiscountAmount":0.0,"UnitDiscountPercent":0.0,"UnitPriceAdjustments":[],"RetailDescription":"Delivery Fees","Itemcategory":"ZDE","CartonQuantity":1.0,"Taxes":{"TotalTaxAmount":0.0,"Taxes":[{"CalculationSequence":1,"TaxJurisdiction":"031","TaxRate":6.000,"TaxAmount":4.200,"TaxableAmount":70.0},{"CalculationSequence":2,"TaxJurisdiction":"031","TaxRate":0.000,"TaxAmount":0.0,"TaxableAmount":0.0},{"CalculationSequence":3,"TaxJurisdiction":"031","TaxRate":0.000,"TaxAmount":0.0,"TaxableAmount":0.0}],"TaxCode":"031","TaxDescription":"\\"do not use\\"-Clayton"},"TotalTax":4.200,"TaxAmount1":4.200,"TaxAmount2":0.0,"TaxAmount3":0.0,"DefaultTaxCode":null,"WarrantySku":""},{"ActionCode":0,"LineNumber":4,"PackageLineNumber":0,"ItemNumber":"*RECYCLEMCA2","Quantity":1,"DeliverViaCode":"HD","AvailableDate":"2018-03-05T00:00:00","ItemType":4,"OriginalPrice":8.0,"UnitCost":0.0,"UnitPrice":8.0,"ExtendedPrice":8.0,"UnitDiscountAmount":0.0,"UnitDiscountPercent":0.0,"UnitPriceAdjustments":null,"RetailDescription":"Updated Mattress Recycling Fee - CA","Itemcategory":"ZZ","CartonQuantity":1.0,"Taxes":{"TotalTaxAmount":0.0,"Taxes":[{"CalculationSequence":1,"TaxJurisdiction":"031","TaxRate":6.000,"TaxAmount":0.480,"TaxableAmount":8.0},{"CalculationSequence":2,"TaxJurisdiction":"031","TaxRate":0.000,"TaxAmount":0.0,"TaxableAmount":0.0},{"CalculationSequence":3,"TaxJurisdiction":"031","TaxRate":0.000,"TaxAmount":0.0,"TaxableAmount":0.0}],"TaxCode":"031","TaxDescription":"\\"do not use\\"-Clayton"},"TotalTax":0.480,"TaxAmount1":0.480,"TaxAmount2":0.0,"TaxAmount3":0.0,"DefaultTaxCode":null,"WarrantySku":""},{"ActionCode":0,"LineNumber":5,"PackageLineNumber":0,"ItemNumber":"*RECYCLEMCA2","Quantity":1,"DeliverViaCode":"HD","AvailableDate":"2018-03-05T00:00:00","ItemType":4,"OriginalPrice":8.0,"UnitCost":0.0,"UnitPrice":8.0,"ExtendedPrice":8.0,"UnitDiscountAmount":0.0,"UnitDiscountPercent":0.0,"UnitPriceAdjustments":null,"RetailDescription":"Updated Mattress Recycling Fee - CA","Itemcategory":"ZZ","CartonQuantity":1.0,"Taxes":{"TotalTaxAmount":0.0,"Taxes":[{"CalculationSequence":1,"TaxJurisdiction":"031","TaxRate":6.000,"TaxAmount":0.480,"TaxableAmount":8.0},{"CalculationSequence":2,"TaxJurisdiction":"031","TaxRate":0.000,"TaxAmount":0.0,"TaxableAmount":0.0},{"CalculationSequence":3,"TaxJurisdiction":"031","TaxRate":0.000,"TaxAmount":0.0,"TaxableAmount":0.0}],"TaxCode":"031","TaxDescription":"\\"do not use\\"-Clayton"},"TotalTax":0.480,"TaxAmount1":0.480,"TaxAmount2":0.0,"TaxAmount3":0.0,"DefaultTaxCode":null,"WarrantySku":""}],"SalesGrandTotal":1965.21,"TotalCost":1853.97,"TotalDiscountAmount":0.0,"TotalNextDayCharge":0.0,"TotalTaxAmount":111.24,"TotalWarrantyAmount":0.0,"TotalDeliveryAmount":70.0,"TotalRecycleAmount":16.0,"IsTaxExempt":null,"TaxExemptCode":null,"IsTaxExemptCertificateOnFile":false,"TaxExemptExpirationDate":"0001-01-01T00:00:00","TaxExemptNumber":0,"TaxContactName":null,"TaxContactNumber":null,"CustomerId":null,"POSUserName":null,"POSPassword":null,"RSAId":null,"CartGuid":"10d0b6d0-6825-4529-b7ad-bac15c2e201d","Delivery":{"Address":{"City":"Atlanta","PostalCode":"30303","StateOrProvince":"GA"}}}');
                res.setStatusCode(200);         
            }
            res.setStatus('OK');
            return res;
        }
    }

}