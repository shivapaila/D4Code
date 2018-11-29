public class CCPaymentResponseWrapper {
    
    @AuraEnabled
    public String SalesGuid {get;set;}
    @AuraEnabled
    public Integer CashGroup {get;set;}
    @AuraEnabled
    public Boolean PaymentReceived {get;set;}
    @AuraEnabled
    public String AccountNumber {get;set;}
    @AuraEnabled
    public Decimal Amount {get;set;}
    @AuraEnabled
    public String AuthorizationNumber {get;set;}
    @AuraEnabled
    public Integer DocumentNumber {get;set;}
    @AuraEnabled
    public String ReferenceNumber {get;set;}
    @AuraEnabled
    public String TermsCode {get;set;}
    @AuraEnabled
    public String TermsCodeDescription {get;set;}
    @AuraEnabled
    public String TenderCode {get;set;}
    @AuraEnabled
    public String Status {get;set;}
    @AuraEnabled
    public Integer ExpirationDays {get;set;}
    @AuraEnabled
    public String TransactionDate {get;set;}
    @AuraEnabled
    public String TransactionTime {get;set;}
    @AuraEnabled
    public String AccountLookUpRequestID {get;set;}
    @AuraEnabled
    public String FinanceTerms {get;set;}
}