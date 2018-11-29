/*
 * This clas will be used for Single Sign ON (SSO) to facilitate Just in Time (JIT) user provisioning and user updates. The class accepts 
 * attributes past as part of the SSO assertion and creates/updates users. The class is refrenced in single sign on Configuration. 
 */
global class AD_SSO_JIT_Handler implements Auth.SamlJitHandler  {
    public static final string DEFAULT_TIME_ZONE = 'America/New_York';
    public static final string DEFAULT_LOCALE = 'en_US';
    public static final string DEFAULT_LANGUAGE = 'en_US';
    public static final string DEFAULT_EMAIL_ENCODING = 'ISO-8859-1';

    public static final string FIRST_NAME_ATTRIBUTE_NAME = 'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/givenname';
    public static final string LAST_NAME_ATTRIBUTE_NAME = 'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/surname';
    public static final string EMAIL_ATTRIBUTE_NAME = 'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress';
    public static final string USER_FEDERATION_IDENTIFIER_ATTRIBUTE_NAME = 'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name';
    public static final string USER_SECURITY_GROUP_ATTRIBUTE_NAME = 'http://schemas.microsoft.com/ws/2008/06/identity/claims/groups';
    public static final string GROUP_OVERFLOW_LINK_ATTRIBUTE_NAME= 'http://schemas.microsoft.com/claims/groups.link';
    public static final string TENANT_ID_ATTRIBUTE_NAME = 'http://schemas.microsoft.com/identity/claims/tenantid';
    public static final string USER_OBJECT_IDENTIFIER_ATTRIBUTE_NAME = 'http://schemas.microsoft.com/identity/claims/objectidentifier';
    public static final string ONE_SOURCE_ID_ATTRIBUTE_NAME = 'afOneSourceID';
    public static final string RSA_ID_ATTRIBUTE_NAME = 'afRSAID';

    public static final string GROUP_OVERFLOW_OAUTH_SETTING_DEVELLOPER_NAME_SANDBOX = 'SSO_Group_Overflow_Sandbox';
    public static final string GROUP_OVERFLOW_OAUTH_SETTING_DEVELLOPER_NAME_PRODUCTION = 'SSO_Group_Overflow_Prod';
    public static final string MICROSOFT_GRAPH_NAMED_CREDENITIAL_NAME = 'Micosoft_Graph';

    
    /**
     * Method handles new User creation and Existing User Updates as part of SSO. User attributes are populated based on some set Default values and 
     * Information recived as part of the SSO as attributes. 
     *
     * @param  create  a boolean indicating if this is a new user
     * @param  u  the user record representing the new or existing user
     * @param  federationIdentifier  the federation id of the user
     * @Param attributes set of attributes passed as part of the SSO
     * @Param asseration the raw assertion sent as part of SSO
     */
    private void handleUser(boolean create, User u,  String federationIdentifier, Map<String, String> attributes, string assertion) {
        System.debug('**** assertion: '+ assertion);
        if(create) {
            //set user default values
            u.LanguageLocaleKey = DEFAULT_LANGUAGE;
            u.LocaleSidKey = DEFAULT_LOCALE;
            u.TimeZoneSidKey = DEFAULT_TIME_ZONE;
            u.EmailEncodingKey = DEFAULT_EMAIL_ENCODING;

            //set federation id
            if(attributes.containsKey(USER_FEDERATION_IDENTIFIER_ATTRIBUTE_NAME)) {
                u.FederationIdentifier = attributes.get(USER_FEDERATION_IDENTIFIER_ATTRIBUTE_NAME);                
                u.UserName = attributes.get(USER_FEDERATION_IDENTIFIER_ATTRIBUTE_NAME);                
            } else {
                u.FederationIdentifier = federationIdentifier;
                u.UserName = federationIdentifier;
            }
            //append user name with sandbox name in sandbox
            if(Utilities_SalesAndService.isSandbox){
                u.userName = u.userName + '.' + Utilities_SalesAndService.getEnvironmentName();
            }

        }

        if(attributes.containsKey(EMAIL_ATTRIBUTE_NAME)) {
            u.Email = attributes.get(EMAIL_ATTRIBUTE_NAME);
        }
        if(attributes.containsKey(FIRST_NAME_ATTRIBUTE_NAME)) {
            u.FirstName = attributes.get(FIRST_NAME_ATTRIBUTE_NAME);
        }
        if(attributes.containsKey(LAST_NAME_ATTRIBUTE_NAME)) {
            u.LastName = attributes.get(LAST_NAME_ATTRIBUTE_NAME);
        }
        if(attributes.containsKey(ONE_SOURCE_ID_ATTRIBUTE_NAME)) {
            u.One_Source_ID__c = attributes.get(ONE_SOURCE_ID_ATTRIBUTE_NAME);
        }
        if(attributes.containsKey(RSA_ID_ATTRIBUTE_NAME)) {
            u.RSA_ID__c = attributes.get(RSA_ID_ATTRIBUTE_NAME);
        }

        //get group memberships for user and translate to Role/Profile
        List<String> groups = new List<String>();

        if(attributes.containsKey(USER_SECURITY_GROUP_ATTRIBUTE_NAME)) {
            //the out of the box attribute map does not handle muli value attributes and the raw asseion is parsed to pull all group memberships
            groups = getAllGroupMemberships(assertion);
        }
        //users who belong to more than 150 groups will not have group information embeded in SAML assertion, an API call out is required to get those groups
        else if(attributes.containsKey(GROUP_OVERFLOW_LINK_ATTRIBUTE_NAME) && attributes.containsKey(TENANT_ID_ATTRIBUTE_NAME) && 
            attributes.containsKey(USER_OBJECT_IDENTIFIER_ATTRIBUTE_NAME)){
            groups = getAllGroupMembershipsFromOverFlowLink(attributes.get(TENANT_ID_ATTRIBUTE_NAME), 
                attributes.get(USER_OBJECT_IDENTIFIER_ATTRIBUTE_NAME));
        }
        
        if(!groups.isEmpty()) {  
            List<ADSecurityGroupToSalesforceProfile__mdt> sfdcGroupSettings = new List<ADSecurityGroupToSalesforceProfile__mdt>();
            for(string g: groups){
            System.debug('=====> ' + g);
                if(Utilities_SalesAndService.adSecurityGroupdMap.get(g.toUpperCase()) != null){
                    sfdcGroupSettings.add(Utilities_SalesAndService.adSecurityGroupdMap.get(g.toUpperCase()));
                }
            }
            System.debug('****** sfdcGroupSettings: ' + sfdcGroupSettings); 
            if(!sfdcGroupSettings.isEmpty()){
                ADSecurityGroupToSalesforceProfile__mdt adGroup = getHighestPriorityAdGroup(sfdcGroupSettings);
                Id profileId = Utilities_SalesAndService.getProfileIdByName(adGroup.Profile_Name__c);
                Id roleId = Utilities_SalesAndService.getUserRoleIdByName(adGroup.Role_Name__c);
                if(profileId != null){
                    u.profileId = profileId;
                }
                if(roleId != null){
                    u.UserRoleID = roleId; 
                }
            }
        }

        if(create){
            u.Alias = getAlias(u.firstName, u.lastName);
            u.CommunityNickName = getNickName(u.firstName, u.lastName);
        }

        if(!create) {
            update(u);
        }
    }
     /**
     * Method is called when a new User to salesforce tries to login through SSO. The method populates attribues for 
     * the new user and returns it to the platfor for creation.
     *
     * @param  samlSsoProviderId  the Identity Provider ID
     * @param  communityId  The Id of the Community if user is logging through a community
     * @param  portalId  The Id of the portal if user is logging through a portal
     * @param  federationIdentifier  the federation id of the new user 
     * @param  attributes  set of attributes passed as part of the SSO
     * @param  assertion the full assertion text sent to salesforce during SSO
     * @return a User record representing a new user to be created
     */
     global User createUser(Id samlSsoProviderId, Id communityId, Id portalId, String federationIdentifier, Map<String, String> attributes, String assertion) {
        User u = new User();
        handleUser(true, u,federationIdentifier, attributes, assertion);
        return u;
    }

    /**
     * Method is called when a User that is already established in salesforce tries to login through SSO. The method populates attribues for 
     * the updated user.
     *
     * @param  samlSsoProviderId  the Identity Provider ID
     * @param  communityId  The Id of the Community if user is logging through a community
     * @param  portalId  The Id of the portal if user is logging through a portal
     * @param  federationIdentifier  the federation id of the new user 
     * @param  attributes  set of attributes passed as part of the SSO
     * @param  assertion the full assertion text sent to salesforce during SSO
     * @return a User record representing the updated user
     */
    global void updateUser(Id userId, Id samlSsoProviderId, Id communityId, Id portalId, String federationIdentifier, Map<String, String> attributes, String assertion) {
        User u = [SELECT Id FROM User WHERE Id=:userId];
        handleUser(false, u,federationIdentifier, attributes, assertion);
    }

    /**
     * Method generates an Alias based on first name and last name
     * the updated user.
     *
     * @param  firstName  the first name of the user
     * @param  lastName  the last name of the user
     * @return a string representing the Alias for the user
     */
    private static string getAlias(string firstName, string lastName){  
        string alias = firstName != null ? firstName.left(1) : '';
        if(lastName != null){
            alias += lastname.left(5 - alias.length());
        }
        return alias;
    }

    /**
     * Method generates a Nick Name based on first name and last name
     * the updated user.
     *
     * @param firstName  the first name of the user
     * @param  lastName  the last name of the user
     * @return a string representing the Nick Name for the user
     */
    private static string getNickName(string firstName, string lastName){
        string nickName =  getAlias( firstName,  lastName);
        if([select count() from user where CommunityNickName =: nickName] > 0){
            nickName += DateTime.now().getTime();
        }
        return nickName;
    }

     /**
     * Filters a list of AD security Group memberships to provide the membership with the Highest priority and should override all other memberships.
     * Memberships with lower Priority Index override memberships with lower priority Index.
     *
     * @param  groups  list of Ad Security Group memberships 
     * @return the Ad group membership with the Highest priority
     */
    private static ADSecurityGroupToSalesforceProfile__mdt getHighestPriorityAdGroup(List<ADSecurityGroupToSalesforceProfile__mdt> groups){
        ADSecurityGroupToSalesforceProfile__mdt highestPriorityGroup = null;
        for(ADSecurityGroupToSalesforceProfile__mdt g: groups){
            if(highestPriorityGroup == null){
                highestPriorityGroup = g;
            }
            else if(g.Priority_Index__c < highestPriorityGroup.Priority_Index__c){
               highestPriorityGroup = g; 
            }
        }

        return highestPriorityGroup;
    }

    /**
     * Gets group membership GUIDs from the assertion sent as part of SSO. Only users with 150 or less group memberships 
     * will have this attribute populated.
     *
     * @param  assertion the base64 encoded asseration that was passed as part of the SSO
     * @return the list of group memberships
     */
    public static List<String> getAllGroupMemberships(string assertion){
        List<string> allGroupMemberships = new List<String>();
        string rawAssertionText =(EncodingUtil.base64Decode(assertion)).toString();
        string groupMembershipStartTag = '<Attribute Name="' + USER_SECURITY_GROUP_ATTRIBUTE_NAME + '">';
        if(rawAssertionText.indexof(groupMembershipStartTag) >= 0){

            //trim anyting before group membership attribute 
            rawAssertionText = rawAssertionText.substring(rawAssertionText.indexof(groupMembershipStartTag));

            string endOfAttributeTag = '</Attribute>';

            //trim anything after the end of the attribute tag
            Integer lastIndex = rawAssertionText.indexof(endOfAttributeTag) + endOfAttributeTag.length();
            rawAssertionText = rawAssertionText.subString(0, lastIndex);

            Dom.Document d = new Dom.Document();
            d.load(rawAssertionText);
            Dom.XmlNode[] nodes = d.getRootElement().getChildElements();
            if(nodes != null){
                for(Dom.XMLNode n: nodes){
                    if(n.getText() != null){
                        allGroupMemberships.add(n.getText());
                    }
                }
            }
        }
        
        return allGroupMemberships;

    }

    /**
     * Gets group membership GUIDs from tan API call for extended group membership data. Only users with more than 150 
     * group memberships will have the link included in the SAML Assertion.
     * will have this attribute populated.
     *
     * @param  tenantId the tenant(Ashley) GUID
     * @param  userObjectIdentifier the user GUID used to identify user in AD
     * @return the list of group memberships
     */
    public static List<String> getAllGroupMembershipsFromOverFlowLink(string tenantId, string userObjectIdentifier){
        List<string> allGroupMemberships = new List<String>();        
       
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:'+ MICROSOFT_GRAPH_NAMED_CREDENITIAL_NAME + '/' + tenantId + '/users/' + userObjectIdentifier + '/getMemberObjects');
        req.setHeader('Accept', 'application/json;odata.metadata=minimal');
        req.setHeader('Content-Type', 'application/json;odata=minimalmetadata;streaming=false');
        req.setHeader('Authorization', 'Bearer '+ getAccessTokenForOverFlowGroups());
        req.setBody('{"securityEnabledOnly": true}');
        req.setMethod('POST');

        HttpResponse res = new Http().send(req);
        if(res.getStatusCode() == 200){
            System.debug(res.getBody());
            Map<String,Object> responseMap = (Map<String,Object>)JSON.deserializeUntyped(res.getBody());
            if(responseMap.containsKey('value')){
                List<Object> objs= (List<Object>)responseMap.get('value');
                for(Object obj: objs){
                    allGroupMemberships.add(String.valueOf(obj));
                }
                
            }
        }  
         
        return allGroupMemberships;
    }

    public class AccessTokenResponse{
        public string token_type {get;set;}
        public string access_token {get;set;}
        public Integer expires_in {get;set;}
    }

    /**
     * Gets an OAUTH token that will be used in API calls. Information to get the Token is stored in a Custom Metadata type.
     *
     * 
     * @return Oauth token that can be used for API calls to get group memberships
     */
    public static string getAccessTokenForOverFlowGroups(){
        string accessToken;
        Oauth_Setting__mdt oauthSetting;
        string oauthSettingKey = Utilities_SalesAndService.isSandbox ? GROUP_OVERFLOW_OAUTH_SETTING_DEVELLOPER_NAME_SANDBOX : GROUP_OVERFLOW_OAUTH_SETTING_DEVELLOPER_NAME_PRODUCTION;
        for(Oauth_Setting__mdt  os : [Select Client_Id__c,Client_Secret__c,DeveloperName,Grant_Type__c,
                                      NamespacePrefix,Scope__c,Token_URL__c 
                                      from Oauth_Setting__mdt]){
            if(oauthSettingKey.equalsIgnoreCase(os.DeveloperName)){
                oauthSetting = os;
                break;
            }
        }
        if(oauthSetting != null){           
            String body = 'grant_type=' + oauthSetting.Grant_Type__c;
            body += '&client_secret=' + oauthSetting.Client_Secret__c;
            body += '&client_id=' + oauthSetting.Client_Id__c;
            body += '&scope=' + EncodingUtil.urlEncode(oauthSetting.Scope__c, 'UTF-8');

            HttpRequest req = new HttpRequest();
            req.setEndpoint(oauthSetting.Token_URL__c);
            req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            req.setBody(body);
            req.setMethod('POST');
            
            HttpResponse res = new Http().send(req);
            if(res.getStatusCode() == 200){
                AccessTokenResponse tokenResponse = (AccessTokenResponse)JSON.deserialize(res.getBody(), AccessTokenResponse.Class);
                accessToken = tokenResponse.access_token;
            }   
            else{
                System.debug('Failed to retrive token for overflow group membership.-' + res.getStatusCode()+ '-' +res.getBody());
            } 
        }
        else{
            System.debug('No Custom Data Found for Group Overflow Oauth Setting');
        }
        return accessToken;  
    }
}