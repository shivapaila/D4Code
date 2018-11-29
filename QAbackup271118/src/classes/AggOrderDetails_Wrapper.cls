//Wrapper Class which holds all the details of the Sales Order  
public class AggOrderDetails_Wrapper {
          
    @AuraEnabled public Integer totalCount {get; set;}
    @AuraEnabled public Decimal totalAmount {get; set;}
    @AuraEnabled public String spendLevel {get; set;}
    @AuraEnabled public Boolean isDelTech {get; set;}
    @AuraEnabled public Boolean isException {get; set;}    
    @AuraEnabled public String externalObjectExceptionMsg {get;set;} // DEF-0146
}