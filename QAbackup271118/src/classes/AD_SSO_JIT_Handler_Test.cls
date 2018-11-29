@isTest
private class AD_SSO_JIT_Handler_Test {
    
    @isTest 
    static void testCreateUser() {
        ADSecurityGroupToSalesforceProfile__mdt testAdProfileMapping = [Select AD_Security_Group__c, Profile_Name__c,  Role_Name__c, GUID__c
        from  ADSecurityGroupToSalesforceProfile__mdt limit 1];

        Id profileId = Utilities_SalesAndService.getProfileIdByName(testAdProfileMapping.Profile_Name__c);
        Id roleId = Utilities_SalesAndService.getUserRoleIdByName(testAdProfileMapping.Role_Name__c);

        Map<String,String> samlAttributes = new Map<String,String>();
        samlAttributes.put(AD_SSO_JIT_Handler.EMAIL_ATTRIBUTE_NAME, 'test@test.com');
        samlAttributes.put(AD_SSO_JIT_Handler.FIRST_NAME_ATTRIBUTE_NAME, 'first');
        samlAttributes.put(AD_SSO_JIT_Handler.LAST_NAME_ATTRIBUTE_NAME, 'last');
        samlAttributes.put(AD_SSO_JIT_Handler.USER_SECURITY_GROUP_ATTRIBUTE_NAME, testAdProfileMapping.GUID__c);
        string assertion = 'pre text<Attribute Name="' + AD_SSO_JIT_Handler.USER_SECURITY_GROUP_ATTRIBUTE_NAME + '"><AttributeValue>' + testAdProfileMapping.GUID__c + '</AttributeValue></Attribute>post text';

        User testUser = new AD_SSO_JIT_Handler().createUser(null, null, null, 'test@test.com', samlAttributes, EncodingUtil.base64Encode(Blob.valueof(assertion)));

        System.assert(testUser.Email == 'test@test.com', 'Email should have been set to attribute value');
        System.assert(testUser.FirstName == 'first', 'First Name should have been set to attribute value');
        System.assert(testUser.LastName == 'last', 'Last Name should have been set to attribute value');

        if(profileId != null){
            System.assert(profileId == testUser.ProfileId, 'Profile should have been set based on AD Security Group');
        }
        if(roleId != null){
            System.assert(roleId == testUser.UserRoleId, 'User role should have been set based on AD Security Group');
        }
        
    }

    @isTest 
    static void testUpdateUser() {
        ADSecurityGroupToSalesforceProfile__mdt testAdProfileMapping = [Select AD_Security_Group__c, Profile_Name__c,  Role_Name__c, GUID__c
        from  ADSecurityGroupToSalesforceProfile__mdt limit 1];

        Id profileId = Utilities_SalesAndService.getProfileIdByName(testAdProfileMapping.Profile_Name__c);
        Id roleId = Utilities_SalesAndService.getUserRoleIdByName(testAdProfileMapping.Role_Name__c);

        User testUserForUpdate = [Select Id 
                                  from User 
                                  where Id !=: UserInfo.getUserId() and IsActive = true and Profile.UserLicense.Name = 'Salesforce'
                                  limit 1];     

        Map<String,String> samlAttributes = new Map<String,String>();
        samlAttributes.put(AD_SSO_JIT_Handler.EMAIL_ATTRIBUTE_NAME, 'test@test.com');
        samlAttributes.put(AD_SSO_JIT_Handler.FIRST_NAME_ATTRIBUTE_NAME, 'first');
        samlAttributes.put(AD_SSO_JIT_Handler.LAST_NAME_ATTRIBUTE_NAME, 'last');
        samlAttributes.put(AD_SSO_JIT_Handler.USER_SECURITY_GROUP_ATTRIBUTE_NAME, testAdProfileMapping.GUID__c);
        string assertion = 'pre text<Attribute Name="' + AD_SSO_JIT_Handler.USER_SECURITY_GROUP_ATTRIBUTE_NAME + '"><AttributeValue>' + testAdProfileMapping.GUID__c + '</AttributeValue></Attribute>post text';

        Test.startTest();
        new AD_SSO_JIT_Handler().updateUser(testUserForUpdate.Id, null, null,null, 'test@test.com', samlAttributes, EncodingUtil.base64Encode(Blob.valueof(assertion)));
        Test.stopTest();

        User testUser = [Select Id,FirstName, LastName, ProfileId,UserRoleId,Email 
                        from User 
                        where Id =:testUserForUpdate.Id];   
        
        System.assert(testUser.Email == 'test@test.com', 'Email should have been set to attribute value');
        System.assert(testUser.FirstName == 'first', 'First Name should have been set to attribute value');
        System.assert(testUser.LastName == 'last', 'Last Name should have been set to attribute value');

        if(profileId != null){
            System.assert(profileId == testUser.ProfileId, 'Profile should have been set based on AD Security Group');
        }
        if(roleId != null){
            System.assert(roleId == testUser.UserRoleId, 'User role should have been set based on AD Security Group');
        }
        
    }
    @isTest 
    static void testTokenGeneration(){
        string sampleResponse = '{"token_type": "Bearer",  "expires_in": 3599,  "ext_expires_in": 0,    "access_token": "xyz"}';
        Test.setMock(HttpCalloutMock.class, new MockCallout(200, 'order updated', sampleResponse ,new Map<String, String>()));  
        string oauthToken = AD_SSO_JIT_Handler.getAccessTokenForOverFlowGroups();
        System.assert(oauthToken == 'xyz');
    }

    @isTest
    static void testGetAllGroupMembershipsFromOverFlowLink(){
        string sampleResponse = '{"@odata.context":"https://graph.microsoft.com/v1.0/$metadata#Collection(Edm.String)","value":["a2b6d8f5-fd71-4736-9c0f-4fa162b1d431","cc294289-048f-44fe-a710-7981cc1cd95f"]}';
        Test.setMock(HttpCalloutMock.class, new MockCallout(200, 'order updated', sampleResponse ,new Map<String, String>()));  
        List<string> groups  = AD_SSO_JIT_Handler.getAllGroupMembershipsFromOverFlowLink('tenantId', 'userobjectid');
        System.assert(groups.size() == 2);
    }   
}