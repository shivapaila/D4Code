/* *******************************************************************************************************************
* Class Name   : API_Sonner_Test
* Description  : Test class for API Sonner.     
* Author       : Venkat (Perficient, Inc.)
* Created On   : 1/11/2018
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer                                   Date                   Modification ID      Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* Perficient                                     02-28-2018              REQ-195             Updated
**************************************************************************************************************************************/
@isTest
public class API_Sonner_Test {
    
    private static testMethod void testResponse(){
        
        //Creating Account
        Account testAccount = new Account(FirstName = 'Test', LastName = 'PersonAccount', PersonEmail = 'testemail@sfdctestclass.com', phone='2222200000');
        testAccount.RecordTypeId = (Id)Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        insert testAccount;  

        API_Sonner.SonnerWrapper sfSoonerObject = new API_Sonner.SonnerWrapper();
        sfSoonerObject.sfAccountID = testAccount.Id;
        sfSoonerObject.storeID = 0;
        sfSoonerObject.soNumber = '000000';
        sfSoonerObject.previousDeliveryDate = System.now().addHours(8);
        sfSoonerObject.newDeliveryDate = System.now();
        sfSoonerObject.customerName = 'Test PersonAccount';
        sfSoonerObject.fulfillerID = '';
        sfSoonerObject.contactStatus = 'Active';
        sfSoonerObject.orderType = 'Open';
        sfSoonerObject.numberOfPieces = '2';
        sfSoonerObject.phone = '+12222200000';
        sfSoonerObject.phone2 = '';
        sfSoonerObject.phone3 = '';

        insert new List<TwilioConfig__c>{new TwilioConfig__c(Name = 'TWILIO_Sandbox', Messaging_Service_Id__c = 'TESTMSGSID', AccountSid__c = 'ACTESTACCNO', AuthToken__c = 'TESTAUTHTOKEN'),
                                            new TwilioConfig__c(Name = 'TWILIO_Prod', Messaging_Service_Id__c = 'TESTMSGSID', AccountSid__c = 'ACTESTACCNO', AuthToken__c = 'TESTAUTHTOKEN')};
        
        Test.startTest();

        //Sending the response to the class
        API_BaseResponse result = API_Sonner.doPost(new List<API_Sonner.SonnerWrapper>{sfSoonerObject});

        Test.stopTest();
        
        System.assert(result.isSuccess);
        //Task should be created for Contact
        List<Task> resultTasks = [SELECT Id,Subject, WhatId
                                  FROM Task 
                                  WHERE WhatId = :testAccount.Id];

        System.assertEquals(System.Label.Sooner_Msg_Task_Subject,resultTasks[0].Subject);
        System.assertEquals(testAccount.Id, resultTasks[0].WhatId);
    }

    private static testMethod void testResponseWithMultipleNumbers(){
        
        //Creating Account
        Account testAccount = new Account(FirstName = 'Test', LastName = 'PersonAccount', PersonEmail = 'testemail@sfdctestclass.com', phone='2222200000');
        testAccount.RecordTypeId = (Id)Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        insert testAccount;  

        API_Sonner.SonnerWrapper sfSoonerObject = new API_Sonner.SonnerWrapper();
        sfSoonerObject.sfAccountID = testAccount.Id;
        sfSoonerObject.storeID = 0;
        sfSoonerObject.soNumber = '000000';
        sfSoonerObject.previousDeliveryDate = System.now().addHours(8);
        sfSoonerObject.newDeliveryDate = System.now();
        sfSoonerObject.customerName = 'Test PersonAccount';
        sfSoonerObject.fulfillerID = '';
        sfSoonerObject.contactStatus = 'Active';
        sfSoonerObject.orderType = 'Open';
        sfSoonerObject.numberOfPieces = '2';
        sfSoonerObject.phone = '+12222200000';
        sfSoonerObject.phone2 = '+13333300000';
        sfSoonerObject.phone3 = '+14444400000';

        insert new List<TwilioConfig__c>{new TwilioConfig__c(Name = 'TWILIO_Sandbox', Messaging_Service_Id__c = 'TESTMSGSID', AccountSid__c = 'ACTESTACCNO', AuthToken__c = 'TESTAUTHTOKEN'),
                                            new TwilioConfig__c(Name = 'TWILIO_Prod', Messaging_Service_Id__c = 'TESTMSGSID', AccountSid__c = 'ACTESTACCNO', AuthToken__c = 'TESTAUTHTOKEN')};
        
        Test.startTest();

        //Sending the response to the class
        API_BaseResponse result = API_Sonner.doPost(new List<API_Sonner.SonnerWrapper>{sfSoonerObject});

        Test.stopTest();
        
        System.assert(result.isSuccess);
        System.assertEquals('Batch Process Queued', result.message);
    }
}