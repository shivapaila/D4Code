@isTest
private class TwilioSendSMSController_Test {
    
    @isTest 
    static void testgetMobileNumberFromContact() {
        //test with mobile phone populated
        Contact testContact = new Contact(MobilePhone = '8889990000');
        System.assert(TwilioSendSMSController.getMobileNumberFromContact(testContact) == '8889990000');

        //test with Phone populated with cell phone type
        testContact.MobilePhone = null;
        testContact.Phone = '7779990000';
        testContact.Phone_Type__c = TwilioSendSMSController.MOBILE_PHONE_IDENTIFIER;
        System.assert(TwilioSendSMSController.getMobileNumberFromContact(testContact) == '7779990000');

        //test with Phone2 populated with cell phone type
        testContact.Phone_Type__c = 'Landline';
        testContact.Phone_2__c = '6669990000';
        testContact.Phone_2_Type__c = TwilioSendSMSController.MOBILE_PHONE_IDENTIFIER;
        System.assert(TwilioSendSMSController.getMobileNumberFromContact(testContact) == '6669990000');

        //test with Phone3 populated with cell phone type
        testContact.Phone_2_Type__c = 'Landline';
        testContact.Phone_3__c = '5559990000';
        testContact.Phone_3_Type__c = TwilioSendSMSController.MOBILE_PHONE_IDENTIFIER;
        System.assert(TwilioSendSMSController.getMobileNumberFromContact(testContact) == '5559990000');
    }
    @isTest 
    static void testgetMobilePhoneNumber() {

        //create test person account        
        List<Account> testPersonAccounts = TestDataFactory.initializePersonAccounts(1);
        testPersonAccounts[0].PersonMobilePhone = '8889990000';
        insert testPersonAccounts;
        Id personContactId = [Select PersonContactId from Account where Id =:testPersonAccounts[0].Id].PersonContactId;

        Id serviceRequestRecordTypeId = Utilities_SalesAndService.getRecordTypeId(Case.SobjectType, CaseTriggerHandler.CASE_RECORD_TYPE_SERVICE_REQUEST_DEVELOPER_NAME);
        List<Case> testCases = TestDataFactory.initializeCases(testPersonAccounts[0].Id, personContactId, 1);
        testCases[0].RecordTypeId = serviceRequestRecordTypeId;
        insert testCases;

        System.assert(TwilioSendSMSController.getMobilePhoneNumber(testPersonAccounts[0].Id) == '8889990000');
        System.assert(TwilioSendSMSController.getMobilePhoneNumber(personContactId) == '8889990000');
        System.assert(TwilioSendSMSController.getMobilePhoneNumber(testCases[0].Id) == '8889990000');
    }
    
    @isTest
    static void testsendTextMessageViaTwilio(){
        //create test person account        
        List<Account> testPersonAccounts = TestDataFactory.initializePersonAccounts(1);
        testPersonAccounts[0].PersonMobilePhone = '8889990000';
        insert testPersonAccounts;
        Id personContactId = [Select PersonContactId from Account where Id =:testPersonAccounts[0].Id].PersonContactId;

        //set up custom setting for Twilio
        TwilioConfig__c tconfig = new TwilioConfig__c();
        tconfig.Name = Utilities_SalesAndService.isSandbox ? 'TWILIO_Sandbox' : 'TWILIO_Prod';
        tconfig.Messaging_Service_Id__c = 'test service id';
        tconfig.AccountSid__c = 'AC03c2fcd60e144e7cbeee413fcbf812a3';
        tconfig.AuthToken__c = '12345678901234567890123456789012';
        insert tconfig;

        string accountJsonResponseBody='{'
        +'"account_sid": "AC03c2fcd60e144e7cbeee413fcbf812a3",'
        +'"api_version": "2010-04-01",'
        +'"body": "Test sending MMS from twilio",'
        +'"num_segments": "1",'
        +'"num_media": "1",'
        +'"date_created": "Mon, 1 Feb 2012 10:49:17 +0000",'
        +'"date_sent": "Mon, 1 Feb 2012 10:49:17 +0000",'
        +'"date_updated": "Mon, 1 Feb 2012 10:49:17 +0000",'
        +'"direction": "outbound-api",'
        +'"from": "+14158141829",'
        +'"price": "null",'
        +'"price_unit":"usd",'
        +'"sid": "MM90c6fc909d8504d45ecdb3a3d5b3556e",'
        +'"status": "queued",'
        +'"to": "+14159978453",'
        +'"uri": "/2010-04-01/Accounts/AC03c2fcd60e144e7cbeee413fcbf812a3/MM90c6fc909d8504d45ecdb3a3d5b3556e.json",'
        +'"subresource_uris": '
        +'{"media":"/2010-04-01/Accounts/AC03c2fcd60e144e7cbeee413fcbf812a3/Messages/MMbd2135c6d10f417faf1e03fac4e8397b/Media.json"}'
        +'}';
        
        Twilio_TestHTTPMock.getInstance().putResponse('POST',
            'https://api.twilio.com/2010-04-01/Accounts/AC03c2fcd60e144e7cbeee413fcbf812a3/Messages.json',
            new Twilio_TestHTTPMock.Response(accountJsonResponseBody,200));

        TwilioSendSMSController.SendTextMessageResponse response = TwilioSendSMSController.sendTextMessageViaTwilio(personContactId, '2223334444', 'test message');
        System.debug('*****response: '+response);
        System.assert(response.isSuccess);

        System.assert([Select count() from Task where subject =: TwilioSendSMSController.SMS_SENT_TASK_SUBJECT] == 1);
    }

    @isTest
    static void testsendTextMessageViaTwilioWithOutSettings(){
        List<Account> testPersonAccounts = TestDataFactory.initializePersonAccounts(1);
        testPersonAccounts[0].PersonMobilePhone = '8889990000';
        insert testPersonAccounts;
        Id personContactId = [Select PersonContactId from Account where Id =:testPersonAccounts[0].Id].PersonContactId;

        TwilioSendSMSController.SendTextMessageResponse response = TwilioSendSMSController.sendTextMessageViaTwilio(personContactId, '2223334444', 'test message');
        System.assert(response.isSuccess == false);

        System.assert([Select count() from Task where subject =: TwilioSendSMSController.SMS_SENT_TASK_SUBJECT] == 0);
    }

    @isTest
    static void testremovePhoneFormatting(){
        System.assert(TwilioSendSMSController.removePhoneFormatting('((999-000---6767)) ') == '9990006767');
    }
    
}