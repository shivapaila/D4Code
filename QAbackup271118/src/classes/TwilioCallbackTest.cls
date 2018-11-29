/* *******************************************************************************************************************
* Class Name   : TwilioCallbackTest
* Description  : Test class for TwilioCallback.     
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer                                   Date                   Modification ID      Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* Perficient                              	02-28-2018              REQ-195             Updated
**************************************************************************************************************************************/
@isTest
public class TwilioCallbackTest 
{
	// test valid callback response
        private static testMethod void testCallback()
	{
	Account testAccount = new Account(FirstName = 'Test', LastName = 'PersonAccount', PersonEmail = 'testemail@sfdctestclass.com', phone='2222200000');
        testAccount.RecordTypeId = (Id)Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        insert testAccount;

        insert new Task(is_Sooner__c = true, Twilio_Message_Id__c = 'TestSMSID', WhatId = testAccount.Id, Subject = 'Test callback', Description = 'Test Description');

        RestRequest req = new RestRequest();
        req.headers.put('X-Twilio-Signature', 'TestSignature');
        req.headers.put('Host', 'testHost');
        req.params.put('SmsSid', 'TestSMSID');
        req.params.put('SmsStatus', 'delivered');

        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        TwilioCallback.reportSMSStatus();
        system.assertEquals(true, [Select IsClosed from Task where is_Sooner__c = true].IsClosed);

        Test.stopTest();
	}
        // test with invalid Msg ID
	private static testMethod void testCallBackWithNoValidTask()
	{
	RestRequest req = new RestRequest();
        req.headers.put('X-Twilio-Signature', 'TestSignature');
        req.headers.put('Host', 'testHost');
        req.params.put('SmsSid', 'TestSMSID');
        req.params.put('SmsStatus', 'delivered');

        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        TwilioCallback.reportSMSStatus();
        system.assertEquals(300, res.statusCode);

        Test.stopTest();
	}
        // test with no msg id
        private static testMethod void testCallBackWithNoMsgId()
        {
        RestRequest req = new RestRequest();
        req.headers.put('X-Twilio-Signature', 'TestSignature');
        req.headers.put('Host', 'testHost');
        req.params.put('SmsSid', '');
        req.params.put('SmsStatus', '');

        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        TwilioCallback.reportSMSStatus();
        system.assertEquals(400, res.statusCode);

        Test.stopTest();
        }
}