public with sharing class ConciergeRecordDetailAfterCreateCtrl {

    public static String CONCIERGE_PROFILENAMESKEY  = 'Concierges';
    
    @AuraEnabled
    public static Boolean isConciergeProfile() {
        try{
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
        catch(Exception e){
            System.debug('Exception in checking current user profile: ' + e.getMessage() + ' : ' + e.getStackTraceString());
            return false;
        }
    }
}