public class VoidPaymentRequestWrapper {
	
    @AuraEnabled
    public String initiatingTransactionId{get;set;}
    
    @AuraEnabled
    public String AuthorizationId{get;set;}
    
    @AuraEnabled
    public Decimal Amount{get;set;}
    
    @AuraEnabled
    public String Currencyc{get;set;}
}