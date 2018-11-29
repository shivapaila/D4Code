public class SORoutingWrapper
{
   //public String @odata.context;   //https://cara-api-dev-slot1.azurewebsites.net/odata/$metadata#DTRouting
    public value[] value;
    public class value {
        public Integer StoreID; //133
        public String SalesOrderNumber; //200442870
        public String TransportationOrderID;    //01330000861945
        public boolean IsConfirmed;
        public DateTime BegunTime;    
        public DateTime CompletedTime;    
        public String UserName; //SBalasubraman
        public Integer RoutingPass; //1
        public Integer TimeChanged; //0 SOLineItems SOLItems
        public Integer ProfitCenter;
        public Date DeliverDate;
        public String CustomerWindowOpen;
        public String CustomerWindowClose;
        public String TruckID;
        public String SFPersonAccountID;
        public String UniqueID;
        public String ConfirmationDateTime;
        public String ConfirmationMessage;
        public String AccountShipTo;
        public SOLineItems[] SOLineItems;
    }
    public class SOLineItems {
        public String SKU;  //*DELI-ATHENS
        public String ItemDescription;  //Athens Delivery Charge             
        public Integer Quantity;    //1
    }
    
}