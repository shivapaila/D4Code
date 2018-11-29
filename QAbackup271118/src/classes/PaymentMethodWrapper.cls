public class PaymentMethodWrapper {    
    @AuraEnabled    
    public String CCnum {get;set;}
    @AuraEnabled
    public String CCexp {
        get{
            return CCexpMonth+CCexpYear;
        }
    }
    @AuraEnabled
    public String CCexpMonth {get;set;}
    @AuraEnabled
    public String CCexpYear {get;set;}
    @AuraEnabled
    public String CCcvv {get;set;}

    @AuraEnabled    
    public String FINnum {get;set;}
    @AuraEnabled    
    public String FINterms {get;set;}
    // finance API defect fix
    @AuraEnabled
    public String FINThirdPartyTerms {get;set;}
    
    @AuraEnabled
    public Cart_Payment_Transaction__c paymentTrans{get;set;}
    
    @AuraEnabled
    public List<String> paymentTerminals{get;set;}

    @AuraEnabled
    public String paymentTerminalSelected{get;set;}

    @AuraEnabled
    public String paymentAPIStatus{get;set;}
    
    @AuraEnabled
    public String checkNum{get;set;}

    //for client -> server
    public PaymentMethodWrapper(){}
}