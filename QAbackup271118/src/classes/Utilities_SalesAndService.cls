public without sharing class Utilities_SalesAndService {
    public static Map<string,Id> userProfileMap{
        get {
            if (userProfileMap == null) {
                userProfileMap = new Map<String,Id>();
                for(Profile p: [Select Id,Name from Profile]){
                    userProfileMap.put(p.name.toUpperCase(), p.Id);
                }                
            }
            return userProfileMap;
        }
        private set;
    }

    /**
     * Gets the salesforce Id of a profile given the name of the profile. A null value will be returned if the profile name does not 
     * match an existing profile in salesforce.
     *
     * @param  profileName  the name of the profile
     * @return the salesforce Id of the profile  
     */
    public static Id getProfileIdByName(string profileName){
        Id profileId = null;
        if(profileName != null && userProfileMap.get(profileName.toUpperCase()) != null){
            profileId = userProfileMap.get(profileName.toUpperCase());
        }
        return profileId;
    }

    public static Map<string,Id> userRoleMap{
        get {
            if (userRoleMap == null) {
                userRoleMap = new Map<String,Id>();
                for(UserRole r: [SELECT Id,Name FROM UserRole]){
                    userRoleMap.put(r.name.toUpperCase(), r.Id);
                }                
            }
            return userRoleMap;
        }
        private set;
    }

    /**
     * Gets the salesforce Id of a user role given the name of the role. A null value will be returned if the user role name does not 
     * match an existing role in salesforce.
     *
     * @param  userRoleName  the name of the user role
     * @return the salesforce Id of the user role  
     */
    public static Id getUserRoleIdByName(string userRoleName){
        Id userRoleId = null;
        if(userRoleName != null && userRoleMap.get(userRoleName.toUpperCase()) != null){
            userRoleId = userRoleMap.get(userRoleName.toUpperCase());
        }
        return userRoleId;
    }

    public static Map<Schema.SObjectType, Map<String, Id>> recordTypesCache {
        get {
            if (recordTypesCache == null) {
                recordTypesCache = new Map<Schema.SObjectType, Map<String, Id>>();
                List<RecordType> recordTypes = [Select Id, DeveloperName, Name, SobjectType From RecordType];
                for (RecordType r : recordTypes) {
                    Schema.SObjectType sObj = Schema.getGlobalDescribe().get(r.SobjectType);
                    if (!recordTypesCache.containsKey(sObj)) {
                        recordTypesCache.put(sObj, new Map<String, Id>());
                    }
                    recordTypesCache.get(sObj).put(r.DeveloperName.toUpperCase(), r.Id);
                }
            }
            return recordTypesCache;
        }
        private set;
    }

    /**
     * Gets the salesforce Id a record type for a specfic Standard/Custom object and Developer name of a record type.
     *
     *
     * @param  sobjectType  the type of Sobject for which record type id is desired
     * @param recordTypeDeveloperName the Developer name of the record type
     * @return the Salesfoce Id of the record type
     */
    public static Id getRecordTypeId(Schema.SObjectType sobjectType, string recordTypeDeveloperName) {
        return recordTypesCache.get(sobjectType).get(recordTypeDeveloperName.toUpperCase());
    }

    public static Boolean isSandbox {
        get{
            if(isSandbox == null){
                isSandbox = [SELECT IsSandbox FROM Organization].IsSandbox;
            }
            return isSandbox;
        }
        private set;
    }

    /**
     * Gets the name of the current environment (Sandbox name if in sandbox "Production" otherwise)
     *
     * @return the name of the sandbox or "Production"
     */
    public static String getEnvironmentName(){
        String environmentName = '';
        if(isSandbox){
            String host = URL.getSalesforceBaseUrl().getHost();
            //Sandbox Host will look like 'shayes--Dev.cs91.my.salesforce.com' - from non VF context
            String nonVFContextHost = host.substring(0,host.indexOf('.'));
            environmentName = nonVFContextHost.substringAfter('--');

            //Sample Sandbox Host will look like 'dev-shayes.cs91.force.com' - from VF context
            if(String.isBlank(environmentName)){
                environmentName = host.substringBefore('-');
            }
        } else{
            environmentName = 'production';
        }
        return environmentName.toLowerCase();
    }

    public static Map<string, ADSecurityGroupToSalesforceProfile__mdt> adSecurityGroupdMap{
        get {
            if (adSecurityGroupdMap == null) {
                adSecurityGroupdMap = new Map<String,ADSecurityGroupToSalesforceProfile__mdt>();
                for(ADSecurityGroupToSalesforceProfile__mdt adSecurityToProfile: [SELECT AD_Security_Group__c, Profile_Name__c, Role_Name__c, Priority_Index__c, GUID__C 
                                                                                    FROM ADSecurityGroupToSalesforceProfile__mdt]){
                    Id profileId = getProfileIdByName(adSecurityToProfile.Profile_Name__c);
                    if(profileId != null){
                        adSecurityGroupdMap.put(adSecurityToProfile.GUID__C.toUpperCase(), adSecurityToProfile);
                    }
                }                
            }
            return adSecurityGroupdMap;
        }
        private set;
    }

    /**
     * Gets an Integartion setting from a Custom Setting for a given setting key (case insensitive)
     *
     * @param  settingKey  the key of the custom setting
     * @return the custom setting if found, null otherwise
     */
    public static Integration_Settings__c getIntegrationSetting(string settingKey){

        Integration_Settings__c isetting;
        for(Integration_Settings__c setting: Integration_Settings__c.getall().values()){
            if(settingKey.equalsIgnoreCase(setting.Name)){
                isetting = setting;
            }
        }

        return isetting;
    }

    public static User currentUser{
        get {
            if (currentUser == null) {
                currentUser = [Select Id, FederationIdentifier, Email, UserName 
                               from User 
                               where Id =: UserInfo.getUserId()];                               
            }
            return currentUser;
        }
        private set;
    }
    @AuraEnabled
    public static Boolean isConciergeProfile() {
        
        String CONCIERGE_PROFILENAMESKEY  = 'Concierges';
        Id currentUserProfileId = UserInfo.getProfileId();

        //Get all delivery and techinican profile names
        String conciergeProfiles = Profile_Details__c.getInstance(CONCIERGE_PROFILENAMESKEY).Profile_Names__c;
        
        //Check if current user's profile matches any of delivery/technician profiles
        for(String pName : conciergeProfiles.split(',')){
            if(Utilities_SalesAndService.getProfileIdByName(pName) == currentUserProfileId){
                return true;
            }
        }
        return false;
    }
    
}