public class ThresholdAvailableDays {
    
    public class TADResponseWrapper{   
     public boolean isSuccess {get;set;}
     public string message {get;set;}
     public List<ThresholdDay> ThresholdDays {get;set;}
         
        public TADResponseWrapper(){
            ThresholdDays = new List<ThresholdDay>();
        }
   }
    public class ThresholdDay {
        
    public String DefaultValue {get;set;}
    public String Name {get;set;}
    public Integer ProfitCenter {get;set;}
    public String SubProfitCenter {get;set;}
    public String PropertyGroup {get;set;}
    public String Value {get;set;}
        
        

}

    @AuraEnabled
    public static TADResponseWrapper TresholdAvlbDays(){
      TADResponseWrapper response = new TADResponseWrapper();
     try{
     StoreInfoWrapper si;
     si = StoreInfo.getStoreInfo();
     string fulfiller = si.fulfillerId;
     string profitcenter = si.profitCtr;
     system.debug('fulfiller,profitcenter'+fulfiller+profitcenter);  
     String endpoint = system.label.AshleyApigeeEndpoint+fulfiller+'/salesorders/sales-orders/settings/THRES_HOLD_AVAILABLE_DAYS?profitCenter='+22;
      Http http = new http();
      Httprequest req = new HttpRequest();
      req.setHeader('apikey', system.label.AshleyApigeeApiKey);
      req.setEndpoint(endpoint);
      system.debug('tresholdenabledcall enpoint' + endpoint);
      req.setTimeOut(120000);
      req.setMethod('GET');
      HttpResponse res = http.send(req);

     
        if(res.getStatusCode()==200){
          response.isSuccess=true;
          system.debug('threshold Response'+res.getBody());
		
        
            if(res.getBody() != null){
             TADResponseWrapper resvalue = (TADResponseWrapper)JSON.deserializeUntyped(res.getBody());
             for(ThresholdDay T: resvalue.ThresholdDays){   
              ThresholdDay TD = new ThresholdDay();
              TD.DefaultValue = T.DefaultValue;
              TD.Name= T.Name;
              TD.ProfitCenter= T.ProfitCenter;
              TD.SubProfitCenter= T.SubProfitCenter;
              TD.PropertyGroup = T.PropertyGroup;
              TD.Value = T.Value;
              response.ThresholdDays.add(TD);
            }
        
        }else{
        response.isSuccess = false;
        response.message = res.getStatusCode() + ' - ' + res.getBody();
        }
        }
    }catch(Exception ex){
            response.isSuccess = false;
            response.message = ex.getMessage();
            System.debug(ex.getStackTraceString());
        }
        system.debug('response is -->'+response);
        return response;
    }
}