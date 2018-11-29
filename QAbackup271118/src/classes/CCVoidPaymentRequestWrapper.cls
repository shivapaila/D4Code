public class CCVoidPaymentRequestWrapper {

    @AuraEnabled
    public String SalesGuid {get;set;}
    @AuraEnabled
    public String IPAddress {get;set;}
    @AuraEnabled
    public String OPOSPrinterName {get;set;}
    @AuraEnabled
    public Integer Port {get;set;}
    @AuraEnabled
    public Decimal DeliveryFee {get;set;}
    @AuraEnabled
    public Decimal SubTotal {get;set;}
    @AuraEnabled
    public Decimal Tax {get;set;}
    @AuraEnabled
    public Decimal SaleTotal {get;set;}
    @AuraEnabled
    public Decimal TransactionAmount {get;set;}
    @AuraEnabled
    public Decimal BalanceDue {get;set;}
    @AuraEnabled
    public boolean IsDiscountApplied {get;set;}
    @AuraEnabled
    public Decimal YouSavePercentage {get;set;}
    @AuraEnabled
    public Decimal YouSaveAmount {get;set;}
    @AuraEnabled
    public String ProfitCenter {get;set;}
    @AuraEnabled
    public String TenderCode {get;set;}
    @AuraEnabled
    public String TenderCodeDescription {get;set;}
    @AuraEnabled
    public String TermsCode {get;set;}
    @AuraEnabled
    public Integer DocumentNumber {get;set;}
    @AuraEnabled
    public String Reference {get;set;}
    @AuraEnabled
    public boolean IsVoid {get;set;}
    @AuraEnabled
    public String CustomerId {get;set;}
       @AuraEnabled
    public String sfGuestId {get;set;}
       @AuraEnabled
    public String storeid {get;set;}
       @AuraEnabled
    public String RSAId {get;set;}
    @AuraEnabled
    public ShoppingCartDeliveryWrapper ShipTo {get;set;}
    @AuraEnabled
    public ShoppingCartDeliveryWrapper BillTo {get;set;}
}