public class PaymentTerminalWrapper {

    @AuraEnabled
    public String VerifoneIP{get;set;}
    
    @AuraEnabled
    public String WorkstationIP{get;set;}
    
    @AuraEnabled
    public String ReceiptPrinter{get;set;}
    
    @AuraEnabled
    public String UsingOPOS{get;set;}
}