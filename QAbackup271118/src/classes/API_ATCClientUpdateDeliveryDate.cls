public with sharing class API_ATCClientUpdateDeliveryDate {
    public static final string ATC_NAMED_CREDENTIAL_PRODUCTION = 'ATC_Prod';
    public static final string ATC_NAMED_CREDENTIAL_SANDBOX = 'ATC_Sandbox';

    public static final string INTEGRATION_SETTING_KEY_PRODUCTION = 'ATC_Prod_UpdateDelDate';
    public static final string INTEGRATION_SETTING_KEY_SANDBOX = 'ATC_Sandbox_UpdateDelDate'; 

    /**
     * Gets available delivery dates for a given account number, dates and products to a specified address.
     * Method makes an API call to get the desired information.
     *
     * @param  accountNumber the Backend wholesale customer account number, which uniquely identify a wholesale customer
     * @param  rdcId the backend RDC id, which uniquely identify RDC
     * @param  startDate the start date of the delivery window requested
     * @param  endDate the end date of the delivery window requested
     * @param  payLoad a payload that will be sent to the external API containg address, delivery mode and products associated to the order
     * @return a responseWrapper indicating the success/failiure of the call, delivery windows if available and messages as applicable
     */
    public static ATCResponseWrapper getAvailableDeliveryWindows(string accountNumber, string rdcId, Date startDate, Date endDate, ATCPayload payLoad, string orderNumber, integer profitCenter, string futureDate){
            system.debug('ordervalue is '+orderNumber);
        ATCResponseWrapper response = new ATCResponseWrapper();
        try{
            HttpRequest req = new HttpRequest();
             if(Utilities_SalesAndService.isSandbox){
                req.setEndpoint('callout:'+ ATC_NAMED_CREDENTIAL_SANDBOX + buildATCURI(accountNumber, rdcId, startDate, endDate, orderNumber,profitCenter,futureDate));
                //get key from custom setting
                    Integration_Settings__c setting = Utilities_SalesAndService.getIntegrationSetting(INTEGRATION_SETTING_KEY_SANDBOX);
                if(setting != null){
                    req.setHeader('apikey', setting.API_Key__c);
                }
                    
                   //   req.setHeader('apikey','bGna5ABiJwsJyqV9DDtQmTBEH2Kpz713');
            }
            //use production named creds
            else{
                req.setEndpoint('callout:'+ ATC_NAMED_CREDENTIAL_PRODUCTION + buildATCURI(accountNumber, rdcId, startDate, endDate,orderNumber,profitCenter,futureDate));
                //get key from custom setting
               Integration_Settings__c setting = Utilities_SalesAndService.getIntegrationSetting(INTEGRATION_SETTING_KEY_PRODUCTION);
                if(setting != null){
                    req.setHeader('apikey', setting.API_Key__c);
                }
                    //req.setHeader('apikey','bGna5ABiJwsJyqV9DDtQmTBEH2Kpz713');
                
            }
            //req.setEndpoint('https://stageapigw.ashleyfurniture.com/homestores/8888300-164/salesorders/200458220/DeliveryCalendar?apikey=bGna5ABiJwsJyqV9DDtQmTBEH2Kpz713&profitCenter=23&startDate=11/01/2018&endDate=01/10/2019');
            req.setMethod('GET');
            req.setHeader('Content-Type' ,'application/json');
            req.setTimeout(20000);
            System.debug('******* End Point: ' + req.getEndpoint());
            HttpResponse res = new Http().send(req);
            System.debug('******* body: ' + res.getBody());
            if(res.getStatusCode() == 200){
                response.isSuccess = true;
                List<Object> deliveryWindows = (List<Object>)JSON.deserializeUntyped(res.getBody());
                system.debug('deliveryWindows:' + deliveryWindows);
                
               // if(root.get('deliveryWindows') != null){
                    
              //  List<Object> windows = (List<Object>)root.get('deliveryWindows');
                integer cap;
                 integer Acap;
                    for(Object w: deliveryWindows){
                        DeliveryWindow dw = new DeliveryWindow();
                        Map<String, Object> deliveryWindow = (Map<String, Object>)JSON.deserializeUntyped(Json.serialize(w));
                        if(deliveryWindow.containsKey('DeliverDateTime')){
                            dw.DeliverDateTime = (String)deliveryWindow.get('DeliverDateTime');
                        }
                        if(deliveryWindow.containsKey('BackColor')){
                          dw.BackColor = (String)deliveryWindow.get('BackColor');
                         }
                        if(deliveryWindow.containsKey('ServiceLevel')){
                          dw.ServiceLevel = (String)deliveryWindow.get('ServiceLevel');
                         }
                        if(deliveryWindow.containsKey('Capacity')){
                            dw.Capacity = (Integer)deliveryWindow.get('Capacity');
                         }
                        if(deliveryWindow.containsKey('AllowbalePromisedCapacity')){
                            dw.AllowbalePromisedCapacity = (Integer)deliveryWindow.get('AllowbalePromisedCapacity');
                         }
                        if(deliveryWindow.containsKey('DeliverDate')){
                            dw.DeliverDate = (string)deliveryWindow.get('DeliverDate');
                         }
                        if(deliveryWindow.containsKey('ResourceGroup')){
                            dw.ResourceGroup = (string)deliveryWindow.get('ResourceGroup');
                         }
                        if(deliveryWindow.containsKey('ResourceGroupType')){
                            dw.ResourceGroupType = (string)deliveryWindow.get('ResourceGroupType');
                         }
                        if(deliveryWindow.containsKey('AllowableOverage')){
                            dw.AllowableOverage = (string)deliveryWindow.get('AllowableOverage');
                         }
                        if(deliveryWindow.containsKey('Promised')){
                            dw.Promised = (Integer)deliveryWindow.get('Promised');
                         }
                        if(deliveryWindow.containsKey('Confirmed')){
                            dw.Confirmed = (Integer)deliveryWindow.get('Confirmed');
                         }
                        if(deliveryWindow.containsKey('PromisedActual')){
                            dw.PromisedActual = (string)deliveryWindow.get('PromisedActual');
                         }
                        if(deliveryWindow.containsKey('PromisedAllowable')){
                            dw.PromisedAllowable = (string)deliveryWindow.get('PromisedAllowable');
                         }
                        if(deliveryWindow.containsKey('Confirmed')){
                            dw.Confirmed = (Integer)deliveryWindow.get('Confirmed');
                         }
                        if(deliveryWindow.containsKey('ConfirmedActual')){
                            dw.ConfirmedActual = (string)deliveryWindow.get('ConfirmedActual');
                         }
                        if(deliveryWindow.containsKey('IsBzEnabledZipcode')){
                            dw.IsBzEnabledZipcode = (boolean)deliveryWindow.get('IsBzEnabledZipcode');
                         }
                        if(deliveryWindow.containsKey('BzNameDescription')){
                            dw.BzNameDescription = (string)deliveryWindow.get('BzNameDescription');
                         }
                        if(deliveryWindow.containsKey('BzNameValue')){
                            dw.BzNameValue = (string)deliveryWindow.get('BzNameValue');
                         }
                        if(deliveryWindow.containsKey('BzOtherCapacity')){
                            dw.BzOtherCapacity = (string)deliveryWindow.get('BzOtherCapacity');
                         }
                        if(deliveryWindow.containsKey('BzOtherPromisedCapacity')){
                            dw.BzOtherPromisedCapacity = (string)deliveryWindow.get('BzOtherPromisedCapacity');
                         }
                        if(deliveryWindow.containsKey('BzOtherAvailableCapacity')){
                            dw.BzOtherAvailableCapacity = (string)deliveryWindow.get('BzOtherAvailableCapacity');
                         }
                        if(deliveryWindow.containsKey('IsNddCapacityEnabled')){
                            dw.IsNddCapacityEnabled = (boolean)deliveryWindow.get('IsNddCapacityEnabled');
                         }
                        if(deliveryWindow.containsKey('NddCapacity')){
                            dw.NddCapacity = (string)deliveryWindow.get('NddCapacity');
                         }
                        response.deliveryWindows.add(dw);
                    }
               // }       
            }
            else{
                response.isSuccess = false;
                response.message = res.getStatusCode() + ' - ' + res.getBody();
            }


        }
        catch(Exception ex){
            response.isSuccess = false;
            response.message = ex.getMessage();
            System.debug(ex.getStackTraceString());
        }
        return response;
    }

    public class ATCPayload{
        public string postalCode {get;set;}
        public string city {get;set;}       
        public string region {get;set;}
        public string country {get;set;}
        public string deliveryMode {get;set;}
        public List<ProductWrapper> products {get;set;}

        public ATCPayload(){
            products = new List<ProductWrapper>();
        }

    }

    public class ProductWrapper{
        public string sku {get;set;}
        public Integer qnty {get;set;}

        public ProductWrapper(string sku, Integer qnty){
            this.sku = sku;
            this.qnty = qnty;
        }
    }

    public class ATCResponseWrapper{
        public boolean isSuccess {get;set;}
        public string message {get;set;}
        public List<DeliveryWindow> deliveryWindows {get;set;}

        public ATCResponseWrapper(){
            deliveryWindows = new List<DeliveryWindow>();
        }

    }

    public class DeliveryWindow{
        public string DeliverDate {get;set;}
        public string DeliverDateTime {get;set;}
        public string ResourceGroup {get;set;}
        public string ResourceGroupType {get;set;}
        public string AllowableOverage {get;set;}
        public Integer Capacity {get;set;}
        public Integer AllowbalePromisedCapacity {get;set;}
        public integer Promised {get;set;}
        public string PromisedActual {get;set;}
        public string PromisedAllowable {get;set;}
        public integer Confirmed {get;set;}
        public string ConfirmedActual {get;set;}
        public boolean IsBzEnabledZipcode {get;set;}
        public string BzNameDescription {get;set;}
        public string BzNameValue {get;set;}
        public string BzOtherCapacity {get;set;}
        public string BzOtherPromisedCapacity {get;set;}
        public string BzOtherAvailableCapacity {get;set;}
        public boolean IsNddCapacityEnabled {get;set;}
        public string NddCapacity {get;set;}
        public string BackColor {get;set;}
        public string ServiceLevel {get;set;}
        public Date getStartDate(){
            
            return Date.valueof(DeliverDateTime.left(10));
        }
        
    }

 public static string formatDateToISO8601(Date dt){
        Time t = Time.newInstance(0, 0, 0, 0);
        DateTime dateTimeInstance = DateTime.newInstance(dt, t);
        return dateTimeInstance.format('MM/dd/yyyy') ; 
    }

    private static string buildATCURI(string accountNumber, string rdcId, Date startDate, Date endDate,string orderNumber,integer profitCenter,string futureDate){
        system.debug('ordervalue is '+orderNumber);
        system.debug('startDate is '+startDate);
        system.debug('futureDate is '+futureDate);
       if(futureDate == '2049-12-01'){
            return '/homestores/' + accountNumber + '-' + rdcId + '/salesorders/' + orderNumber +'/DeliveryCalendar?profitCenter=' + profitCenter + '&startDate=12/01/2049&endDate=12/31/2049';
        }
        //return '/wholesale-customers/' +accountNumber + '/rdcs/' + rdcId + '/delivery-windows?rangeStart=' + formatDateToISO8601(startDate) + '&rangeEnd='+formatDateToISO8601(endDate);
        //https://stageapigw.ashleyfurniture.com/homestores/8888300-164/salesorders/200458220/DeliveryCalendar?profitCenter=23&startDate=11/01/2018&endDate=01/10/2019&apikey=bGna5ABiJwsJyqV9DDtQmTBEH2Kpz713  
       else{
        return '/homestores/' + accountNumber + '-' + rdcId + '/salesorders/' + orderNumber +'/DeliveryCalendar?profitCenter=' + profitCenter + '&startDate='+ formatDateToISO8601(startDate) + '&endDate=' + formatDateToISO8601(endDate);
   }
}
     
}