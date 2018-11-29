public class SORoutingItems
{
   @AuraEnabled
    public Integer StoreID {get;set;}
    @AuraEnabled
    public String SalesOrderNumber {get;set;}
    @AuraEnabled
    public String TransportationOrderID {get;set;}
    @AuraEnabled
    public boolean IsConfirmed {get;set;}
    @AuraEnabled
    public String BegunTime{get;set;}
    @AuraEnabled
    public String CompletedTime {get;set;}
    @AuraEnabled
    public String UserName {get;set;}
    @AuraEnabled
    public Integer RoutingPass {get;set;}
    @AuraEnabled
    public Integer TimeChanged {get;set;}
    @AuraEnabled
    public Integer ProfitCenter {get;set;}
    @AuraEnabled
    public Date DeliverDate {get;set;}
    @AuraEnabled
    public String CustomerWindowOpen {get;set;}
    @AuraEnabled
    public String CustomerWindowClose {get;set;}
    @AuraEnabled
    public String TruckID {get;set;}
    @AuraEnabled
    public String SFPersonAccountID {get;set;}
    @AuraEnabled
    public String UniqueID {get;set;}
    @AuraEnabled
    public String ConfirmationDateTime {get;set;}
    @AuraEnabled
    public String ConfirmationMessage {get;set;}
    @AuraEnabled
    public String AccountShipTo {get;set;}
    
    @AuraEnabled
    public SOLineItem[] SOLineItems{get;set;}
   
   
   public class SOLineItem
   {
       @AuraEnabled
       public String SKU {get;set;}  //*DELI-ATHENS
       @AuraEnabled
       public String ItemDescription {get;set;}  //Athens Delivery Charge    
       @AuraEnabled
       public Integer Quantity {get;set;}    //1
   }
}