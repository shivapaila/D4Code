@isTest
public class APIDeleteCustomerFromCARA_Test {
    //For direct delete
    @isTest static void testGetMethod(){
        //Create Account
        Account delacct = new Account();
       // delacct.recordTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get(CUSTOMER_PERSON_ACCOUNT_RECORD_TYPE_NAME).getRecordTypeId();
        delacct.LastName = 'last' + Math.random();
        delacct.FirstName = 'first' + Math.random();
        delacct.PersonEmail = delacct.FirstName + '.' + delacct.LastName + '@test.com';
        delacct.Primary_Language__pc = 'English';
        string phone = '888' + Integer.valueOf(Math.random() * 10000);
        while (phone.length() < 10){
            phone = phone + '0';
        }
        delacct.phone = phone;
        Insert delacct;
        //Create Case
        //Create Opportunity
        //Create ES
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/v1/contact-cleaning/DeleteContactId='+delacct.Id+'&MergeContactId='; 
        req.httpMethod = 'GET';
        req.addHeader('Content-Type', 'application/json'); 
        RestContext.request = req;
        RestContext.response = res;
        String resmsg = APIDeleteCustomerFromCARA.doGet();
        System.debug(resmsg);
   		Test.stopTest();
    }
    @isTest static void testGetMethod2(){
        //Create Account
        Account delacct = new Account();
       // delacct.recordTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get(CUSTOMER_PERSON_ACCOUNT_RECORD_TYPE_NAME).getRecordTypeId();
        delacct.LastName = 'last' + Math.random();
        delacct.FirstName = 'first' + Math.random();
        delacct.PersonEmail = delacct.FirstName + '.' + delacct.LastName + '@test.com';
        delacct.Primary_Language__pc = 'English';
        string phone = '888' + Integer.valueOf(Math.random() * 10000);
        while (phone.length() < 10){
            phone = phone + '0';
        }
        delacct.phone = phone;
        Insert delacct;
        //Create Case
        //Create Opportunity
        //Create ES
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/v1/contact-cleaning/DeleteContactId=&MergeContactId='+delacct.Id; 
        req.httpMethod = 'GET';
        req.addHeader('Content-Type', 'application/json'); 
        RestContext.request = req;
        RestContext.response = res;
        String resmsg = APIDeleteCustomerFromCARA.doGet();
        System.debug(resmsg);
   		Test.stopTest();
    }
    //For merging and deleting
    @isTest static void testGetMethod3(){
        //Create Account
        Account delacct = new Account();
       // delacct.recordTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get(CUSTOMER_PERSON_ACCOUNT_RECORD_TYPE_NAME).getRecordTypeId();
        delacct.LastName = 'last' + Math.random();
        delacct.FirstName = 'first' + Math.random();
        delacct.PersonEmail = delacct.FirstName + '.' + delacct.LastName + '@test.com';
        delacct.Primary_Language__pc = 'English';
        string phone = '888' + Integer.valueOf(Math.random() * 10000);
        while (phone.length() < 10){
            phone = phone + '0';
        }
        string phone2 = '888' + Integer.valueOf(Math.random() * 10000);
        while (phone.length() < 10){
            phone = phone + '0';
        }
        string phone3 = '889' + Integer.valueOf(Math.random() * 10000);
        while (phone.length() < 10){
            phone = phone + '0';
        }
        delacct.phone = phone;
        delacct.Phone_2__pc = phone2;
        delacct.Phone_3__pc = phone3;
        delacct.PersonEmail = 'pqr@mm.com';
        delacct.Email_2__pc ='pqr@mm.com';
        delacct.Strike_Counter__pc = 10;
        Insert delacct;
        System.debug('delacct-->'+delacct.Id);
        
        Account mergeacct = new Account();
       // delacct.recordTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get(CUSTOMER_PERSON_ACCOUNT_RECORD_TYPE_NAME).getRecordTypeId();
        mergeacct.LastName = 'last' + Math.random();
        mergeacct.FirstName = 'first' + Math.random();
        mergeacct.PersonEmail = mergeacct.FirstName + '.' + mergeacct.LastName + '@test.com';
        mergeacct.Primary_Language__pc = 'English';
        phone = '888' + Integer.valueOf(Math.random() * 10000);
        mergeacct.Strike_Counter__pc = 2;
        Insert mergeacct;
        
        //Create Contact
        try{
            Contact con = [SELECT Id, AccountId from Contact where AccountId =:delacct.Id];
        }
        catch(Exception e){
            
        }
        
        //Create Address
        Address__c testDelAd = new Address__c();
        testDelAd.Address_Line_1__c = '123 Other Test Coverage St'; 
        testDelAd.City__c = 'Franklin';
        testDelAd.State__c = 'TN';
        testDelAd.Preferred__c = true;
        testDelAd.Address_Type__c ='Bill To';
        testDelAd.Address_Line_2__c='123 test';
        testDelAd.Address_Validation_Status__c='test';
        testDelAd.Country__c='India';
        testDelAd.AccountId__c = delacct.Id;
        Insert testDelAd;
        try{
            Address__c testDelAd2 = new Address__c();
            testDelAd2.Address_Line_1__c = '123 Other '; 
            testDelAd2.City__c = 'Fran';
            testDelAd2.State__c = 'TN2';
            testDelAd2.Preferred__c = false;
            testDelAd2.Address_Type__c ='Bill To';
            testDelAd2.Address_Line_2__c='123 test22';
            testDelAd2.Address_Validation_Status__c='test22';
            testDelAd2.Country__c='India';
            testDelAd2.AccountId__c = delacct.Id;
            Insert testDelAd2;
        }
        Catch(Exception ex){
            
        }
        Address__c testMergeAd = new Address__c();
        testMergeAd.Address_Line_1__c = '123 Other Test Coverage St'; 
        testMergeAd.City__c = 'Franklin';
        testMergeAd.State__c = 'TN';
        testMergeAd.Preferred__c = true;
        testMergeAd.Address_Type__c ='Bill To';
        testMergeAd.Address_Line_2__c='123 test';
        testMergeAd.Address_Validation_Status__c='test';
        testMergeAd.Country__c='India';
        testMergeAd.AccountId__c = mergeacct.Id;
        Insert testMergeAd;
                
        //Create Case
        Case c = new Case();
        c.Status = 'New';
        c.Priority = 'Medium';
        c.Origin = 'Web';
        c.Subject = 'Subject ' +  Math.random();
        c.Type = 'Delivery_Order_inquiry';
        c.Sub_Type__c = CaseTriggerHandler.CASE_SUB_TYPE_DAMAGE;			
        c.AccountId = delacct.Id;
        c.Address__c = testDelAd.Id;
        c.Sales_Order__c = '122324:332536575';
        Insert c;
        
        Case c2 = new Case();
        c2.Status = 'New';
        c2.Priority = 'Medium';
        c2.Origin = 'Web';
        c2.Subject = 'Subject ' +  Math.random();
        c2.Type = 'Delivery_Order_inquiry';
        c2.Sub_Type__c = CaseTriggerHandler.CASE_SUB_TYPE_DAMAGE;			
        c2.AccountId = delacct.Id;
        c2.Sales_Order__c = '122324:3325365745';
        Insert c2;
        
        //Create Opportunity
        Opportunity op = new Opportunity();
        op.Name = 'TestOp';
        op.CloseDate = Date.today();
        op.AccountId = delacct.Id;
        op.StageName = 'Closed Won';
        Insert op;
        //Create ES
        Electronic_Signature__c es = new Electronic_Signature__c();
        es.Name = 'Test';
        es.AccountId__c = delacct.Id;
        Insert es;
        
        //Create Task
        Task testTask = new Task();
        testTask.Subject = 'Test subject';
        testTask.WhatId = delacct.Id;
        testTask.ActivityDate = Date.today();
        Insert testTask;
        //Create Event
        Event testEvent = new Event();
        testEvent.Subject = 'Test subject';
        testEvent.WhatId = delacct.Id;
        testEvent.ActivityDateTime = DateTime.now();
        testEvent.DurationInMinutes = 120;
        Insert testEvent;
        
        
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI ='/services/apexrest/v1/contact-cleaning/DeleteContactId='+delacct.Id+'&MergeContactId='+mergeacct.Id; 
        req.httpMethod = 'GET';
        req.addHeader('Content-Type', 'application/json'); 
        RestContext.request = req;
        RestContext.response = res;
        String resmsg = APIDeleteCustomerFromCARA.doGet();
        System.debug(resmsg);
   		Test.stopTest();
    }

}