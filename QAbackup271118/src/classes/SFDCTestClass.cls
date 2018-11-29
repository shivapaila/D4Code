public class SFDCTestClass {
    
   @AuraEnabled
    public static List<Contact> getContacts() {
        List<Contact> contacts = 
                [SELECT Id, Name, MailingStreet,lastViewedDate, Phone, Email, LeadSource FROM Contact Where LastViewedDate != null Order By LastViewedDate Desc];

        //Add isAccessible() check
        return contacts;
    
}

}