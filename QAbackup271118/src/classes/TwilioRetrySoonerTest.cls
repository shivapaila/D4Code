/**************************************************************************************************
* Name       : TwilioRetrySoonerTest
* Purpose    : test Class for TwilioRetrySoonerScheduler and TwilioRetrySoonerBatch
***************************************************************************************************
* Author            | REQ    | Created Date    | Description
***************************************************************************************************
*Perficient         | 195    | 03/05/2018      | Initial Draft
**************************************************************************************************/
@isTest
private with sharing class TwilioRetrySoonerTest 
{
	@testSetup static void methodName()
	{
		insert new List<TwilioConfig__c>{new TwilioConfig__c(Name = (Utilities_SalesAndService.isSandbox ? 'TWILIO_Sandbox' : 'TWILIO_Prod'), Messaging_Service_Id__c = 'test service id', AccountSid__c = 'AC12345678901234567890123456789012', AuthToken__c = '12345678901234567890123456789012')};

		Account testAccount = new Account(FirstName = 'Test', LastName = 'PersonAccount', PersonEmail = 'testemail@sfdctestclass.com', phone='2222200000');
        testAccount.RecordTypeId = (Id)Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        insert testAccount;

        insert new Task(WhatId = testAccount.Id, Subject = System.Label.Sooner_Msg_Task_Subject, Description = 'test description',
        				Type='Text', Status='Open', Is_Sooner__c = true, Twilio_Message_Id__c = 'testMessageId',
        				Twilio_Sent_To_Phone_Number__c = '0000011111', Sooner_Msg_Retry_Count__c = 0);
	}
	// Messege is sent and delivered but status is not updated yet in SFDC task
	// so do not retry the message
	static testMethod void twilioRetryAlreadyDelivered()
	{
		String messageStatusBody = '{"sid": "testMessageId", '+
										'"date_created": "Wed, 07 Mar 2018 02:07:11 +0000", '+
										'"date_updated": "Wed, 07 Mar 2018 02:07:11 +0000", '+
										'"date_sent": "Wed, 07 Mar 2018 02:07:11 +0000", '+
										'"account_sid": "AC12345678901234567890123456789012", '+
										'"to": "0000011111", "from": "test service id", '+
										'"messaging_service_sid": "testMessageId", '+
										'"body": "*AshleyHomeStore* Exciting News, your order is available and is scheduled for delivery on 3/15/2018! Please call us at 1-866-436-3388-today by 7PM if this date is not acceptable.", '+
										'"status": "delivered", "num_segments": "2", "num_media": "0", '+
										'"direction": "outbound-api", "api_version": "2010-04-01", "price": "-0.01500", "price_unit": "USD", '+
										'"error_code": null, "error_message": null, '+
										'"uri": "/2010-04-01/Accounts/AC12345678901234567890123456789012/Messages/testMessageId.json", '+
										'"subresource_uris": {"media": "/2010-04-01/Accounts/AC12345678901234567890123456789012/Messages/testMessageId/Media.json"}}';
		Twilio_TestHTTPMock.getInstance().putResponse('GET',
            'https://api.twilio.com/2010-04-01/Accounts/AC12345678901234567890123456789012/Messages/testMessageId.json',
            new Twilio_TestHTTPMock.Response(messageStatusBody,200));

		test.startTest();
		database.executebatch(new TwilioRetrySoonerBatch(Label.TwilioSoonerPollingBatch), 1);
		test.stopTest();
		Task updatedTask = [Select Id, IsClosed, Sooner_Msg_Retry_Count__c from Task];
		System.assertEquals(true, updatedTask.IsClosed);
		System.assertEquals(0, updatedTask.Sooner_Msg_Retry_Count__c);
	}
	// Messege is not delivered so retry the message
	static testMethod void twilioRetryUndelivered()
	{
		String messageStatusBody = '{"sid": "testMessageId_New", '+
										'"date_created": "Wed, 07 Mar 2018 02:07:11 +0000", '+
										'"date_updated": "Wed, 07 Mar 2018 02:07:11 +0000", '+
										'"date_sent": "Wed, 07 Mar 2018 02:07:11 +0000", '+
										'"account_sid": "AC12345678901234567890123456789012", '+
										'"to": "0000011111", "from": "test service id", '+
										'"messaging_service_sid": "testMessageId", '+
										'"body": "*AshleyHomeStore* Exciting News, your order is available and is scheduled for delivery on 3/15/2018! Please call us at 1-866-436-3388-today by 7PM if this date is not acceptable.", '+
										'"status": "undelivered", "num_segments": "2", "num_media": "0", '+
										'"direction": "outbound-api", "api_version": "2010-04-01", "price": "-0.01500", "price_unit": "USD", '+
										'"error_code": null, "error_message": null, '+
										'"uri": "/2010-04-01/Accounts/AC12345678901234567890123456789012/Messages/testMessageId.json", '+
										'"subresource_uris": {"media": "/2010-04-01/Accounts/AC12345678901234567890123456789012/Messages/testMessageId/Media.json"}}';
		Twilio_TestHTTPMock.getInstance().putResponse('GET',
            'https://api.twilio.com/2010-04-01/Accounts/AC12345678901234567890123456789012/Messages/testMessageId.json',
            new Twilio_TestHTTPMock.Response(messageStatusBody,200));
		Twilio_TestHTTPMock.getInstance().putResponse('POST',
            'https://api.twilio.com/2010-04-01/Accounts/AC12345678901234567890123456789012/Messages.json',
            new Twilio_TestHTTPMock.Response(messageStatusBody,200));

		test.startTest();
		database.executebatch(new TwilioRetrySoonerBatch(Label.TwilioSoonerPollingBatch), 1);
		test.stopTest();
		Task updatedTask = [Select Id, Twilio_Message_Id__c, Sooner_Msg_Retry_Count__c from Task];
		System.assertEquals('testMessageId_New', updatedTask.Twilio_Message_Id__c);
		System.assertEquals(1, updatedTask.Sooner_Msg_Retry_Count__c);
	}

	// just to cover the scheduler class
	static testMethod void callScheduler()
	{
		String messageStatusBody = '{"sid": "testMessageId", '+
										'"date_created": "Wed, 07 Mar 2018 02:07:11 +0000", '+
										'"date_updated": "Wed, 07 Mar 2018 02:07:11 +0000", '+
										'"date_sent": "Wed, 07 Mar 2018 02:07:11 +0000", '+
										'"account_sid": "AC12345678901234567890123456789012", '+
										'"to": "0000011111", "from": "test service id", '+
										'"messaging_service_sid": "testMessageId", '+
										'"body": "*AshleyHomeStore* Exciting News, your order is available and is scheduled for delivery on 3/15/2018! Please call us at 1-866-436-3388-today by 7PM if this date is not acceptable.", '+
										'"status": "delivered", "num_segments": "2", "num_media": "0", '+
										'"direction": "outbound-api", "api_version": "2010-04-01", "price": "-0.01500", "price_unit": "USD", '+
										'"error_code": null, "error_message": null, '+
										'"uri": "/2010-04-01/Accounts/AC12345678901234567890123456789012/Messages/testMessageId.json", '+
										'"subresource_uris": {"media": "/2010-04-01/Accounts/AC12345678901234567890123456789012/Messages/testMessageId/Media.json"}}';
		Twilio_TestHTTPMock.getInstance().putResponse('GET',
            'https://api.twilio.com/2010-04-01/Accounts/AC12345678901234567890123456789012/Messages/testMessageId.json',
            new Twilio_TestHTTPMock.Response(messageStatusBody,200));

		test.startTest();
		try
		{
			TwilioRetrySoonerScheduler testSch = new TwilioRetrySoonerScheduler();
			System.schedule('Twilio Retry', '0 0 * * * ?', testSch);
			testSch = new TwilioRetrySoonerScheduler(Label.TwilioSoonerPollingBatch);
		}
		catch(Exception e)
		{
			System.debug('some exception');
		}
		test.stopTest();
	}
}