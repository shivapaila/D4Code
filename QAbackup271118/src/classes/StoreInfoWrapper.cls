public class StoreInfoWrapper {
    public String acctNo{get;set;}
    public String shipTo{get;set;}
    public String profitCtr{get;set;}
    public String marketCode{get;set;}
    public String storeZip{get;set;}
    public String fulfillerId{get;set;}
    public String RDC{get;set;}
    public String legacyStoreID{get;set;}
    //REQ-455 - Text Opt In
    public String legalEntityName{get;set;}
    public String OneSourceID{get;set;}
    public StoreInfoWrapper(String storeInfo) {
        List<String> parts = storeInfo.split('-');
        acctNo = parts[0];
        shipTo = parts[1];
        profitCtr = parts[2];
       // marketCode = parts[3]; //remove this code. In StoreInfo use Fulfiller-Id to get maketCode from custom setting: MarketSettings__c, 
       // because if storeInfo is like this 8888300-164-23-KWF-GA,   maketCode became KWF, that's wrong
    }
}