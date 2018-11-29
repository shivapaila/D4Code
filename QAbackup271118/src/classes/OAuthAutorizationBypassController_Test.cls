@isTest
private class OAuthAutorizationBypassController_Test {
	
	@isTest 
	static void testRedirect() {
		PageReference pageRef = Page.OAuthAutorizationBypass;
	    pageRef.getParameters().put(OAuthAutorizationBypassController.OAUTH_STATE_PARAMETER_NAME, 'xyz');
	    pageRef.getParameters().put(OAuthAutorizationBypassController.OAUTH_CALLBACK_URL_PARAMETER_NAME, 'http://test.com');
	    Test.setCurrentPage(pageRef);

	    OAuthAutorizationBypassController controller = new OAuthAutorizationBypassController();
	    PageReference callBack = controller.redirectToCallBack();

	    System.assert(callBack.getParameters().get(OAuthAutorizationBypassController.OAUTH_STATE_PARAMETER_NAME) == 'xyz');
	    System.assert(callBack.getUrl().startswith('http://test.com'));
	    system.debug(callBack.getUrl());
	}	
	
}