public class AddressUpdateController {
    @AuraEnabled
    public static void updateAddress(Address__c Address) {
        try {
            UPDATE Address;
        } catch (Exception e) {
            system.debug('Exception is ' + e);
        }
    }
    @AuraEnabled
    public Static Address__c fetchAddress(Id AddressId) {
        List<Address__c> lstOfadd = new List<Address__c>();

        if (AddressId != null)
            lstOfadd = [SELECT Id,AccountId__c,Name,Address_Line_1__c, Address_Line_2__c,Address_Type__c, Address_Validation_Status__c,Address_Validation_Timestamp__c,City__c,StatePL__c,State__c,Country__c,Preferred__c,Geocode__Latitude__s,Geocode__Longitude__s,Zip_Code__c FROM Address__c WHERE Id = :AddressId];


        System.debug(lstOfadd.get(0));
        if (!lstOfadd.isEmpty())
        return lstOfadd.get(0);
        return null;


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