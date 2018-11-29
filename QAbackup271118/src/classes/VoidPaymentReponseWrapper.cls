public class VoidPaymentReponseWrapper {

	@AuraEnabled
    public String voidId{get;set;}

    @AuraEnabled
    public String authorizationId{get;set;}

    @AuraEnabled
    public Decimal Amount{get;set;}

    @AuraEnabled
    public String currencyCode{get;set;}

    @AuraEnabled
    public String providerTransactionCode{get;set;}

    @AuraEnabled
    public String providerResultCode{get;set;}

}