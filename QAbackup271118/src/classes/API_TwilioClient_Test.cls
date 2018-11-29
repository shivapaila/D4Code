@isTest
private class API_TwilioClient_Test {
    
    @isTest 
    static void test_method_one() {
        //set up custom setting
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

        API_TwilioClient.TwilioSmsWrapper smsMessageWrapper = new API_TwilioClient.TwilioSmsWrapper ('+15555555555', 'test message', 'unique id','sonumber');
        API_TwilioClient.TwilioSmsWrapper response = API_TwilioClient.sendSms(smsMessageWrapper);
        System.assert(response.isSuccess);
    }
    
    @isTest 
    static void test_method_two() {
        //set up custom setting
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
        
        List<API_TwilioClient.TwilioSmsWrapper> smsList =new List<API_TwilioClient.TwilioSmsWrapper>();
        smsList.add(new API_TwilioClient.TwilioSmsWrapper ('+15555555555', 'test message1', 'unique id 1','soNumber'));
        
        Test.startTest();
        API_TwilioClient.TwilioSmsWrapper batchId = API_TwilioClient.sendSms(smsList[0]);
        Test.stopTest();
    }
    
}