/*
 * This class will provide methods to interact with CARA Order API with OAuth security. It extends the platform class Auth.AuthProviderPluginClass
 * and provides methods for Oauth Initialization(Autorization), OAuth Access token Request and Refresh.
 */
public with sharing class CARAAPIAuthProvider extends Auth.AuthProviderPluginClass 
{
    public static final string CARA_API_AUTH_SETTING_SANDBX = 'CARA_API_Sandbox';
    public static final string CARA_API_AUTH_SETTING_PRODUCTION = 'CARA_API_Prod';
    public static final string CUSTOM_METADATA_TYPE_API_NAME = 'Oauth_Setting__mdt';

    public static final string OAUTH_SETTING_KEY = Utilities_SalesAndService.isSandbox ? CARA_API_AUTH_SETTING_SANDBX : CARA_API_AUTH_SETTING_PRODUCTION;
    public static final Oauth_Setting__mdt OAUTH_SETTING;

    private String authProvider = Utilities_SalesAndService.isSandbox ? CARA_API_AUTH_SETTING_SANDBX : CARA_API_AUTH_SETTING_PRODUCTION; 
    private String userName = 'Anonymous User'; 

    static{
        for(Oauth_Setting__mdt  os : [Select Client_Id__c,Client_Secret__c,DeveloperName,Grant_Type__c,
                                      NamespacePrefix,Scope__c,Token_URL__c, password__c, resource__c, username__c,
                                      Callback__c 
                                      from Oauth_Setting__mdt]){
            if(OAUTH_SETTING_KEY.equalsIgnoreCase(os.DeveloperName)){
                OAUTH_SETTING = os;
                break;
            }
        }
    }   

    /**
     * performs an Oauth token refresh when an access token has expired.
     * 
     *
     * @param  refreshToken the refresh token that will be sent to the Oauth server
     *
     * @return an Oauth Token response that has an access token, a refresh token and other attributes
     */
    public static CARAuthTokenResponse getAccessTokenFromRefreshToken(string refreshToken){
        CARAuthTokenResponse response;

        if(OAUTH_SETTING != null){
            try{
                String body = 'grant_type=' + 'refresh_token';
                body += '&client_secret=' + EncodingUtil.urlEncode(OAUTH_SETTING.Client_Secret__c, 'UTF-8');
                body += '&client_id=' + EncodingUtil.urlEncode(OAUTH_SETTING.Client_Id__c, 'UTF-8');
                body += '&scope=' + EncodingUtil.urlEncode(OAUTH_SETTING.Scope__c, 'UTF-8');
                body += '&resource=' + EncodingUtil.urlEncode(OAUTH_SETTING.resource__c, 'UTF-8');
                body += '&refresh_token=' + refreshToken;

                HttpRequest req = new HttpRequest();
                req.setEndpoint(OAUTH_SETTING.Token_URL__c);
                req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
                req.setBody(body);
                req.setMethod('POST');
                
                HttpResponse res = new Http().send(req);
                if(res.getStatusCode() == 200){
                    response = (CARAuthTokenResponse)JSON.deserialize(res.getBody(), CARAuthTokenResponse.Class);
                }   
                else{
                    new ErrorLogController().createLog(new ErrorLogController.Log('CARAAPIAuthProvider', 'getAccessTokenFromRefreshToken', 
                                                'Failed to retrieve token for CARA ODATA API.-' + res.getStatusCode()+ '-' +res.getBody())); 
                } 
            }
            Catch(Exception ex){
                new ErrorLogController().createLog(new ErrorLogController.Log('CARAAPIAuthProvider', 'getAccessTokenFromRefreshToken', 
                                                ex.getMessage())); 
            }
        }
        else{
            new ErrorLogController().createLog(new ErrorLogController.Log('CARAAPIAuthProvider', 'getAccessTokenFromRefreshToken', 
                                                'Oauth setting not found for ' + OAUTH_SETTING_KEY));           
        }
        return response;

    }

    /**
     * Method gets an Access token based on Oauth inputs like Client Secret, Client Id, username, pasword etc...
     * stored in Custom Metadata Type.
     *
     *
     * @return an Oauth Token response that has an access token, a refresh token and other attributes
     */
    public static CARAuthTokenResponse getAccessToken(){
        CARAuthTokenResponse response;

        if(OAUTH_SETTING != null){
            String body = 'grant_type=' + OAUTH_SETTING.Grant_Type__c;
            body += '&client_secret=' + EncodingUtil.urlEncode(OAUTH_SETTING.Client_Secret__c, 'UTF-8');
            body += '&client_id=' + EncodingUtil.urlEncode(OAUTH_SETTING.Client_Id__c, 'UTF-8');
            body += '&scope=' + EncodingUtil.urlEncode(OAUTH_SETTING.Scope__c, 'UTF-8');
            body += '&resource=' + EncodingUtil.urlEncode(OAUTH_SETTING.resource__c, 'UTF-8');
            body += '&username=' + EncodingUtil.urlEncode(OAUTH_SETTING.username__c, 'UTF-8');
            body += '&password=' + EncodingUtil.urlEncode(OAUTH_SETTING.password__c, 'UTF-8');

            HttpRequest req = new HttpRequest();
            req.setEndpoint(OAUTH_SETTING.Token_URL__c);
            req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            req.setBody(body);
            req.setMethod('POST');
            
            HttpResponse res = new Http().send(req);
            if(res.getStatusCode() == 200){
                response = (CARAuthTokenResponse)JSON.deserialize(res.getBody(), CARAuthTokenResponse.Class);
            }   
            else{
                new ErrorLogController().createLog(new ErrorLogController.Log('CARAAPIAuthProvider', 'getAccessTokenFromRefreshToken', 
                                                'Failed to retrieve token for CARA ODATA API.-' + res.getStatusCode()+ '-' +res.getBody())); 
            } 
        }
        else{
            new ErrorLogController().createLog(new ErrorLogController.Log('CARAAPIAuthProvider', 'getAccessToken', 
                                                'Oauth setting not found for ' + OAUTH_SETTING_KEY)); 
        }
        return response;
    }

    /**
     * Returns the API name of the metadata used to store Oauth configuration for the Auth Provider.
     * 
     * @return API name of Custom Metadata Type used for Auth provider
     */
    public String getCustomMetadataType() {
        return CUSTOM_METADATA_TYPE_API_NAME;
    }    

    /**
     * Returns a page refrence for OAuthAutorizationBypass VF page that eill take the state and callback url passed and redirects to the 
     * callback url of the Auth Provider so that Token Generation can be performed.
     *
     * @return a VF page refrence with query parameters for Oauth state and callback url for Auth Provider populated
     */
    public PageReference initiate(Map<string,string> authProviderConfiguration, String stateToPropagate) {
        PageReference passThroughPage = Page.OAuthAutorizationBypass;
        passThroughPage.getParameters().put(OAuthAutorizationBypassController.OAUTH_STATE_PARAMETER_NAME, stateToPropagate);
        passThroughPage.getParameters().put(OAuthAutorizationBypassController.OAUTH_CALLBACK_URL_PARAMETER_NAME
            , OAUTH_SETTING.Callback__c);
        return passThroughPage;        
    } 

    public Auth.AuthProviderTokenResponse handleCallback(Map<string,string> authProviderConfiguration, Auth.AuthProviderCallbackState state ) {
        CARAuthTokenResponse tokenResponse = getAccessToken();
        return new Auth.AuthProviderTokenResponse(authProvider, tokenResponse.access_token, tokenResponse.refresh_token, state.queryParameters.get('state'));
    }

    public Auth.UserData getUserInfo(Map<string,string> authProviderConfiguration, Auth.AuthProviderTokenResponse response) {
        return new Auth.UserData(null, null, null, null, null, null, userName, null, authProvider, null, new Map<String,String>()); 
    } 

    public override Auth.OAuthRefreshResult refresh(Map<String,String> authProviderConfiguration, String refreshToken) {
        try{
            CARAuthTokenResponse tokenResponse = getAccessTokenFromRefreshToken(refreshToken);
            return new Auth.OAuthRefreshResult(tokenResponse.access_token, tokenResponse.refresh_token);
        }
        Catch(Exception ex){
            return new Auth.OAuthRefreshResult(null, null, ex.getMessage());
        }
    } 

    public class CARAuthTokenResponse{
        public string token_type {get;set;}
        public string scope {get;set;}
        public string expires_in {get;set;}
        public string ext_expires_in {get;set;}
        public string expires_on {get;set;}
        public string not_before {get;set;}
        public string resource {get;set;}
        public string access_token {get;set;}
        public string refresh_token {get;set;}
    }  
}