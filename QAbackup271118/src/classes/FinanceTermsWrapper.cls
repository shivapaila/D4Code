public class FinanceTermsWrapper {
    @AuraEnabled
    public string Code{get;set;}

    @AuraEnabled
    public string Description{get;set;}
    // finance API defect fix
    @AuraEnabled
    public string ThirdPartyTermCode{get;set;}
}