public class SalesOrderResultWrapper {
    /*{"SalesOrderNumber":400316150,
"DeliveryViaCode":"HD",
"SalesOrderReferenceId":"349d15ea-5142-4301-a221-c3eacbaa57fa"}*/
    @AuraEnabled
    public String SalesOrderNumber{get;set;}
    @AuraEnabled
    public String DeliveryViaCode{get;set;}
    @AuraEnabled
    public String SalesOrderReferenceId{get;set;}
    
}