public class CCSalesLookupResponseWrapper {

	@AuraEnabled
    public String SalesOrderNumber {get;set;}
    @AuraEnabled
    public String CustomerID {get;set;}
    @AuraEnabled
    public String AccountNumber {get;set;}
    @AuraEnabled
    public String ReferenceNumber {get;set;}
    @AuraEnabled
    public String AuthorizationNumber {get;set;}
    @AuraEnabled
    public String TransactionAmount {get;set;}
    @AuraEnabled
    public String TransactionDate {get;set;}
    @AuraEnabled
    public String TransactionTime {get;set;}
    @AuraEnabled
    public String ExpirationDate {get;set;}
    @AuraEnabled
    public String RequestDate {get;set;}
    @AuraEnabled
    public String IsVoidSale {get;set;}
    @AuraEnabled
    public String TransactionStatus {get;set;}
    @AuraEnabled
    public String TermsCode {get;set;}
    @AuraEnabled
    public String CardType {get;set;}
    @AuraEnabled
    public String ReasonCode {get;set;}
    @AuraEnabled
    public String ReasonDescription {get;set;}
    @AuraEnabled
    public String SignatureFilePath {get;set;}
}