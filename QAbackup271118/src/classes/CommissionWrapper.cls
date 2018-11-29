public class CommissionWrapper {
    @AuraEnabled
    public Decimal Percent{get;set;}
    @AuraEnabled
    public String SalespersonId{get;set;}
}