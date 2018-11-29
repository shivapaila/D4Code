public class SalesOrderLineWrapper {
    /* Sample
* "ActionCode": 2,

"ItemNumber": "3510038",

"DeliverViaCode": "CPS",

"Quantity": 1,

"AvailableDate": "2018-01-30",

"LineNumber" :1,

"UnitPriceAdjustments":[

{

"Percent":10,

"ReasonCode":"Store Discount"

}]

*/
    @AuraEnabled
    public Integer ActionCode{get;set;}
    @AuraEnabled
    public String ItemNumber{get;set;}
    //REQ-480
       @AuraEnabled
    public Integer PackageLineNumber{get;set;}
     @AuraEnabled
    public Decimal ItemType{get;set;}
    @AuraEnabled
    public String DeliverViaCode{get;set;}
    @AuraEnabled
    public Decimal Quantity{get;set;}
    //fpp amount
    @AuraEnabled
    public Decimal OriginalPrice{get;set;}
     @AuraEnabled
    public Decimal ExtendedPrice{get;set;}
    @AuraEnabled
    public String WarrantySku='';
     @AuraEnabled
    public Integer WarrantyPlanNumber=0;
    //Average Cost
    @AuraEnabled
    public Decimal UnitCost{get;set;}
    @AuraEnabled
    public String AvailableDate{get;set;}
     @AuraEnabled
    public Boolean Iscall{get;set;}
    @AuraEnabled
    public Integer LineNumber{get;set;}
    @AuraEnabled
    public Decimal TotalTax{get;set;}
    @AuraEnabled
    public String HDServiceType{get;set;}
     
    @AuraEnabled
    public List<DiscountInfo> UnitPriceAdjustments{get;set;}
    
    public class DiscountInfo{
        @AuraEnabled
        public Decimal Percent{get;set;}
         @AuraEnabled
        public Decimal Amount{get;set;}
        @AuraEnabled
        public String ReasonCode{get;set;}
        
        public DiscountInfo(Decimal num, String code){
            this.Percent = num;
            this.ReasonCode = code;
            this.Amount =0;
        }
        public DiscountInfo(String code,Decimal num){
            this.Amount = num;
            this.ReasonCode = code;
            this.Percent =0;
        }
    }
}