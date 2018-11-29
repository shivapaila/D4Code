public class PaymentDistributionWrapper {
    
    @AuraEnabled
    public Integer CashDistributionType{get;set;}
    @AuraEnabled
    public Integer CashGroup{get;set;}
    @AuraEnabled
    public Boolean PaymentReceived{get;set;}
    @AuraEnabled
    public Decimal Amount{get;set;}
    @AuraEnabled
    public String AuthorizationNumber{get;set;}
    @AuraEnabled
    public String Code{get;set;}
    @AuraEnabled
    public Decimal DocumentNumber{get;set;}
    @AuraEnabled
    public String ReferenceNumber{get;set;}
    @AuraEnabled
    public String TermsCode{get;set;}
    @AuraEnabled
    public String Description{get;set;}
    @AuraEnabled
    public String TermsDescription{get;set;}    
}