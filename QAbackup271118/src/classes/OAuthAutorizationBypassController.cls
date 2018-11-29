/*
 * This is a controller class for  OAuthAutorizationBypass VF page. The page is used to bypass the Autorization portion of an Oauth 
 * Autentication flow when the salesforce application already has the username and password of an integration user and will go directly
 * to Token generation without autorization. The page accepts a state and a callback url of the Auth provider as parameters and redirects 
 * to the Auth call back page passing in the state.
 */
public with sharing class OAuthAutorizationBypassController {
	public static final string OAUTH_STATE_PARAMETER_NAME = 'state';
	public static final string OAUTH_CALLBACK_URL_PARAMETER_NAME = 'redirecttourl';


	public PageReference redirectToCallBack(){
		string callBackUrl = ApexPages.currentPage().getParameters().get(OAUTH_CALLBACK_URL_PARAMETER_NAME);
		callBackUrl += '?' + OAUTH_STATE_PARAMETER_NAME + '=' + ApexPages.currentPage().getParameters().get(OAUTH_STATE_PARAMETER_NAME) ;
		return new PageReference(callBackUrl);				
	}
}