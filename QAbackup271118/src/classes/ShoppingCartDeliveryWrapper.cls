public class ShoppingCartDeliveryWrapper {
    @AuraEnabled
    public ShoppingCartAddressWrapper Address{get;set;}
    @AuraEnabled
    public String FirstName{get;set;}
    @AuraEnabled
    public String LastName{get;set;}
    @AuraEnabled
    public String EmailAddress{get;set;}
    @AuraEnabled
    public String HomePhone{get;set;}
    @AuraEnabled
    public String WorkPhone{get;set;}
    @AuraEnabled
    public String CellPhone{get;set;}
    
}