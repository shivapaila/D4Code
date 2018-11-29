public class SalesOrderResponseWrapper {
    /*"salesOrderResult":[{"SalesOrderNumber":400316150,
"DeliveryViaCode":"HD",
"SalesOrderReferenceId":"349d15ea-5142-4301-a221-c3eacbaa57fa"}],
"customerId":"006784893732",
"eReceiptBlobStorageUri":"https://caradev.blob.core.windows.net/concierge-ereceipts/8888300-164/20180409/400321770_400321780_400321790.pdf"*/
    @AuraEnabled
    public List<SalesOrderResultWrapper> salesOrderResult{get;set;}
    @AuraEnabled
    public String customerId{get;set;}
    @AuraEnabled
    public String eReceiptBlobStorageUri {get;set;}
}