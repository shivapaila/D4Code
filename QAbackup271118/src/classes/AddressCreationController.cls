public class AddressCreationController {

    @AuraEnabled
    public Static Address__c getAddress(Id AddressId) {
        List<Address__c> add = [SELECT Id,AccountId__c,Name,Address_Line_1__c, Address_Line_2__c,Address_Type__c, Address_Validation_Status__c,Address_Validation_Timestamp__c,City__c,StatePL__c,State__c,Country__c,Preferred__c,Geocode__Latitude__s,Geocode__Longitude__s,Zip_Code__c FROM Address__c WHERE Id = :AddressId];
        return add[0];
    }


    @AuraEnabled
    public Static Address__c saveAddress(Address__c Address) {
        Address.AccountId__r = null;
        //   String accid = Address.AccountId__c;
        // Perform isUpdatable() checking first, then
        //upsert Address;
        
        try {
            if(Address.id != null)
            {
            	UPDATE Address;
            }
            else
            {
                system.debug('Address-------'+Address);
                insert Address;
            }
        } catch (Exception e) {
            system.debug('Exception is ' + e);
             throw new AuraHandledException(e.getMessage());
        }
        return Address;

    }
    // EDQ added
    @AuraEnabled
    public static String SearchAddress(string searchTerm, string country, Integer take) {
        return EDQService.SearchAddress(searchTerm, country, take);
    }

    // EDQ added
    @AuraEnabled
    public static String FormatAddress(string formatUrl) {
        return EDQService.FormatAddress(formatUrl);
    }
}