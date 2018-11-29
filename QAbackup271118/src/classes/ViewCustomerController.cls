/****** v1 | Description: Methods for viewing customer associated records | 12/5/2017 | L OMeara */
/****** v2 | Description: Updated for person accounts | 2/1/2018 | L OMeara */
public with sharing class ViewCustomerController {
    @AuraEnabled
    public static List<Address__c> getCustomerAddresses(Id customerId){      
        return [SELECT Id,Address_Line_1__c,Address_Line_2__c,City__c,State__c,Zip_Code__c, Preferred__c,Address_Type__c,Address_Validation_Status__c, Address_Validation_Timestamp__c
                           FROM Address__c WHERE AccountId__c=:customerId ORDER BY Preferred__c DESC, LastModifiedDate DESC LIMIT 5];
    }
    
    @AuraEnabled
    public static void saveAddress(Address__c toSave) {
    	try {
            List<Address__c> prefList = new List<Address__c>();
            if (toSave.Preferred__c) { // if the preferred value is set to true, check if you have to unset it on another record
                prefList  = [SELECT Id, Preferred__c FROM Address__c WHERE Preferred__c=true AND AccountId__c =:toSave.AccountId__c];
                for (Address__c p : prefList){
                    p.Preferred__c = false;
                }
            }
            // EDQ validation trigger responsible for clearing managing the Validation Status field (Before Update, Before Insert)
            // will execute once per object type. We need to ensure that we perform the DML operation on the record
            // with presumably new values and then update the already existing records.
            upsert toSave;
            if (prefList.size() > 0) {
                update prefList;
            }
        }catch(Exception e){
            system.debug(e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static String SearchAddress(string searchTerm, string country, Integer take) {
        return EDQService.SearchAddress(searchTerm, country, take);
    }

    @AuraEnabled
    public static String FormatAddress(string formatUrl) {
        return EDQService.FormatAddress(formatUrl);
    }

    @AuraEnabled
    public static void updateOwner(String Id) {
        List<Account> acc=[Select Id,OwnerId from Account Where id=:Id];
        if(!acc.isEmpty()){
            acc[0].OwnerId=userInfo.getUserId();
            update acc[0];
        }
        List<Opportunity> cartLst= new List<Opportunity>();
        String oppExpireLimit=System.Label.Cart_limit;
        String query='Select Id,Name, AccountId, Account.Name,CreatedDate,StageName,Cart_Grand_Total__c '+
            'From Opportunity '+
            'Where  Account.RecordType.DeveloperName=\'Customer\' and  AccountId =:Id and StageName != \'Closed Won\' and StageName != \'Sale Suspended\' and StageName != \'Closed Lost\' and CreatedDate = LAST_N_DAYS:'+oppExpireLimit;


        cartLst=Database.query(query);
         if(!cartLst.isEmpty()){
            cartLst[0].OwnerId=userInfo.getUserId();
            update cartLst[0];
        }
    }
}