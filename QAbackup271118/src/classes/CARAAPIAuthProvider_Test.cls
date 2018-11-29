@isTest
private class CARAAPIAuthProvider_Test {
	
	@isTest 
	static void testGetAccessToken() {
		string sampleResponse = '{"token_type": "Bearer","scope": "user_impersonation","expires_in": "3600","ext_expires_in": "0",';
		sampleResponse += '"expires_on": "1516937602", "not_before": "1516933702","resource": "https://sampleresource.com",';
		sampleResponse += '"access_token": "sampleaccesstoken",  "refresh_token": "samplerefreshtoken","id_token": "sampleidtoken"}';
		Test.setMock(HttpCalloutMock.class, new MockCallout(200, 'ok', sampleResponse ,new Map<String, String>()));	

		CARAAPIAuthProvider.CARAuthTokenResponse tokenResponse = CARAAPIAuthProvider.getAccessToken();

		System.assert(tokenResponse.access_token == 'sampleaccesstoken');
		System.assert(tokenResponse.scope == 'user_impersonation');
		System.assert(tokenResponse.expires_in == '3600');
		System.assert(tokenResponse.ext_expires_in == '0');
		System.assert(tokenResponse.expires_on == '1516937602');
		System.assert(tokenResponse.not_before == '1516933702');
		System.assert(tokenResponse.refresh_token == 'samplerefreshtoken');
		System.assert(tokenResponse.token_type == 'Bearer');
		System.assert(tokenResponse.resource == 'https://sampleresource.com');
	}
	
	@isTest 
	static void testGetRefreshToken() {
		string sampleResponse = '{"token_type": "Bearer","scope": "user_impersonation","expires_in": "3600","ext_expires_in": "0",';
		sampleResponse += '"expires_on": "1516937602", "not_before": "1516933702","resource": "https://sampleresource.com",';
		sampleResponse += '"access_token": "sampleaccesstoken",  "refresh_token": "samplerefreshtoken","id_token": "sampleidtoken"}';
		Test.setMock(HttpCalloutMock.class, new MockCallout(200, 'ok', sampleResponse ,new Map<String, String>()));	

		CARAAPIAuthProvider.CARAuthTokenResponse tokenResponse = CARAAPIAuthProvider.getAccessTokenFromRefreshToken('refresh token');

		System.assert(tokenResponse.access_token == 'sampleaccesstoken');
		
	}
	@isTest 
	static void testinitiate() {
		CARAAPIAuthProvider provider = new CARAAPIAuthProvider();
		PageReference autorizePage = provider.initiate(new Map<string,string>(), 'sampale ststae');
		System.assert(autorizePage != null);

		System.assert(provider.getCustomMetadataType() == CARAAPIAuthProvider.CUSTOM_METADATA_TYPE_API_NAME);
		
	}
	@isTest 
	static void testgetUserInfo() {
		CARAAPIAuthProvider provider = new CARAAPIAuthProvider();
		Auth.UserData userData = provider.getUserInfo(new Map<string,string>(), null);
		System.assert(userData.userName != null);		
	}

	@isTest 
	static void testhandleCallback() {
		string sampleResponse = '{"token_type": "Bearer","scope": "user_impersonation","expires_in": "3600","ext_expires_in": "0",';
		sampleResponse += '"expires_on": "1516937602", "not_before": "1516933702","resource": "https://sampleresource.com",';
		sampleResponse += '"access_token": "sampleaccesstoken",  "refresh_token": "samplerefreshtoken","id_token": "sampleidtoken"}';
		Test.setMock(HttpCalloutMock.class, new MockCallout(200, 'ok', sampleResponse ,new Map<String, String>()));	

		CARAAPIAuthProvider provider = new CARAAPIAuthProvider();

		Auth.AuthProviderCallbackState callBackState = new Auth.AuthProviderCallbackState(new Map<String,String>(),
			'test body', new Map<String,String>{'state' => 'xyz'});
		Auth.AuthProviderTokenResponse callBackresponse = provider.handleCallback(new Map<string,string>(), callBackState);
		System.assert(callBackresponse.oauthToken == 'sampleaccesstoken');		
	}

	@isTest 
	static void testrefresh() {
		string sampleResponse = '{"token_type": "Bearer","scope": "user_impersonation","expires_in": "3600","ext_expires_in": "0",';
		sampleResponse += '"expires_on": "1516937602", "not_before": "1516933702","resource": "https://sampleresource.com",';
		sampleResponse += '"access_token": "sampleaccesstoken",  "refresh_token": "samplerefreshtoken","id_token": "sampleidtoken"}';
		Test.setMock(HttpCalloutMock.class, new MockCallout(200, 'ok', sampleResponse ,new Map<String, String>()));	

		CARAAPIAuthProvider provider = new CARAAPIAuthProvider();
		Auth.OAuthRefreshResult refreshResponse = provider.refresh(new Map<string,string>(), null);
		System.assert(refreshResponse.accessToken  == 'sampleaccesstoken');		
	}
	
}