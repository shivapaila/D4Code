/* *******************************************************************************************************************
* Class Name   : RSAAccountInfoControllerTest
* Description  : A test class for the Lightning Apex Controller RSAAccountInfoController
*				
* Author       : Sriram (Perficient, Inc.)
* Created On   : 05/23/2018
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer                                   Date                   Modification ID      Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* Sriram									  07/23									      This test controller is deprecated.
*																						  Please use the ConciergeServiceControllerTest
**************************************************************************************************************************************/
@isTest
private class RSAAccountInfoControllerTest {

	@testSetup 
	static void setup() {
  		TestDataFactory.prepareAPICustomSetting();
	}

	@isTest
	static void testGetRSAAccountInfo()	{
        StoreInfoMock fakeResponse = new StoreInfoMock(200, 'Complete',
                                                       '{"oneSourceID":"14444","LocationID":"2667","OneSourceName":"Alpharetta, GA","LocationName":"Alpharetta, GA","LegacyStoreID":"133","ProfitCenter":"34","AccountNo":"8888300","Shipto":"298","ZIP":"30022","RDCNUM":"164","FulfillerID":"8888300-164"}',
                                                       null);
		Test.setMock(HttpCalloutMock.class, fakeResponse);		
		User rsaUser = TestDataFactory.createRSAUser();
		insert rsaUser;
		System.runAs(rsaUser) {
			RSAAccountInfoWrapper rsaAccountInfo = null;
			Test.startTest();
			rsaAccountInfo = RSAAccountInfoController.getRSAAccountInfo();
			Test.stopTest();
			System.assertEquals(true, rsaAccountInfo!=null, 'Expecting the RSA Account Information for the RSA User');
		}
	}
}