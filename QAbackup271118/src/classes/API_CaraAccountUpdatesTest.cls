/**************************************************************************************************
* Name       : API_CaraAccountUpdatesTest
* Purpose    : test Class for API_CaraAccountUpdates
***************************************************************************************************
* Author            | REQ    | Created Date    | Description
***************************************************************************************************
*Perficient         |         | 03/05/2018      | Initial Draft
**************************************************************************************************/
@isTest
private class API_CaraAccountUpdatesTest 
{
	@testSetup static void methodName()
	{
		insert new Trigger_Integration__c(Account_Updates_to_CARA__c = true);
		Account testAccount = new Account(FirstName = 'Test', LastName = 'PersonAccount', PersonEmail = 'testemail@sfdctestclass.com', phone='2222200000');
        testAccount.RecordTypeId = (Id)Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        insert testAccount;
	}

	// success response for updating Account
	private static testMethod void testAccountUpdate()
	{
		String responseString = '[{'+
								       '"SFGuestID": "0012900000GRH28AAH",'+
								       '"IsSuccess": true,'+
								       '"ResponseMessage": "Updated the details successfully for the person account ID : 0012900000GRH28AAH and store ID: 133."'+
								   '},'+
								   '{'+
								       '"SFGuestID": "0012900000GRH0kAAH",'+
								       '"IsSuccess": true,'+
								       '"ResponseMessage": "Updated the details successfully for the person account ID : 0012900000GRH28AAH and store ID: 133."'+
								   '}'+
								    ']';
		Test.setMock(HttpCalloutMock.class, new API_CaraAccountUpdatesMock(200, 'OK', responseString));
		Account testAccount = [Select Id, FirstName, LastName, PersonEmail, Phone, Phone_2__pc, Phone_3__pc from Account][0];

        test.startTest();
        testAccount.LastName = 'PersonAccountChanged';
        update testAccount;
        test.stopTest();
        // there should not be an error record created
        System.assertEquals(0, [Select count() from ErrorLog__c]);
	}

	// success response for updating Address
	private static testMethod void testAddressUpdate()
	{
		String responseString = '[{'+
								       '"SFGuestID": "0012900000GRH28AAH",'+
								       '"IsSuccess": true,'+
								       '"ResponseMessage": "Updated the details successfully for the person account ID : 0012900000GRH28AAH and store ID: 133."'+
								   '}'+
								    ']';
		Test.setMock(HttpCalloutMock.class, new API_CaraAccountUpdatesMock(200, 'OK', responseString));
		Account testAccount = [Select Id, FirstName, LastName, PersonEmail, Phone, Phone_2__pc, Phone_3__pc from Account][0];
        Address__c testAddress =  new Address__c(AccountId__c = testAccount.Id, Address_Line_1__c = 'Test Address line 1', Address_Line_2__c = 'Test Address line 2',
        											City__c = 'test city', State__c = 'CA', Zip_Code__c = '99999', Country__c = 'US');
        insert testAddress;
        test.startTest();
        testAddress.State__c = 'VA';
        update testAddress;
        test.stopTest();
        // there should not be an error record created
        System.assertEquals(0, [Select count() from ErrorLog__c]);
	}

	// failure response - one of the record is failed
	private static testMethod void testAccountUpdateInvalidPhone()
	{
		String responseString = '[{'+
								       '"SFGuestID": "0012900000GRH28AAH",'+
								       '"IsSuccess": false,'+
								       '"ResponseMessage": "Phone is invalid"'+
								   '}'+
								    ']';
		Test.setMock(HttpCalloutMock.class, new API_CaraAccountUpdatesMock(200, 'OK', responseString));
		Account testAccount = [Select Id, FirstName, LastName, PersonEmail, Phone, Phone_2__pc, Phone_3__pc from Account][0];

        test.startTest();
        testAccount.LastName = 'PersonAccountChanged';
        update testAccount;
        test.stopTest();
        // there should be an error record created
        System.assertEquals(1, [Select count() from ErrorLog__c]);
	}	

	// failure response - one of the record is failed
	private static testMethod void testBadRequest()
	{
		String responseString = '[{Bad Request}]';
		Test.setMock(HttpCalloutMock.class, new API_CaraAccountUpdatesMock(400, 'Bad Request', responseString));
		Account testAccount = [Select Id, FirstName, LastName, PersonEmail, Phone, Phone_2__pc, Phone_3__pc from Account][0];

        test.startTest();
        testAccount.LastName = 'PersonAccountChanged';
        update testAccount;
        test.stopTest();
        // there should be an error record created
        System.assertEquals(1, [Select count() from ErrorLog__c]);
	}
}