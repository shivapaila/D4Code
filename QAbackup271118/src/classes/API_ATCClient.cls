public with sharing class API_ATCClient {
    public static final string ATC_NAMED_CREDENTIAL_PRODUCTION = 'ATC_Prod';
    public static final string ATC_NAMED_CREDENTIAL_SANDBOX = 'ATC_Sandbox';

    public static final string INTEGRATION_SETTING_KEY_PRODUCTION = 'ATC_Prod';
    public static final string INTEGRATION_SETTING_KEY_SANDBOX = 'ATC_Sandbox'; 

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
    public static ATCResponseWrapper getAvailableDeliveryWindows(string accountNumber, string rdcId, Date startDate, Date endDate, ATCPayload payLoad){

        ATCResponseWrapper response = new ATCResponseWrapper();
        try{
            HttpRequest req = new HttpRequest();
            //use sandbox named creds
            if(Utilities_SalesAndService.isSandbox){
                req.setEndpoint('callout:'+ ATC_NAMED_CREDENTIAL_SANDBOX + buildATCURI(accountNumber, rdcId, startDate, endDate));
                //get key from custom setting
                Integration_Settings__c setting = Utilities_SalesAndService.getIntegrationSetting(INTEGRATION_SETTING_KEY_SANDBOX);
                if(setting != null){
                    req.setHeader('apikey', setting.API_Key__c);
                }
            }
            //use production named creds
            else{
                req.setEndpoint('callout:'+ ATC_NAMED_CREDENTIAL_PRODUCTION + buildATCURI(accountNumber, rdcId, startDate, endDate));
                //get key from custom setting
                Integration_Settings__c setting = Utilities_SalesAndService.getIntegrationSetting(INTEGRATION_SETTING_KEY_PRODUCTION);
                if(setting != null){
                    req.setHeader('apikey', setting.API_Key__c);
                }
            }
            req.setMethod('POST');
            req.setBody(JSON.serialize(payLoad));
            req.setHeader('Content-Type' ,'application/json');

            System.debug('******* End Point: ' + req.getEndpoint());
            System.debug('******* body: ' + req.getBody());

            HttpResponse res = new Http().send(req);
             System.debug('******* res body: ' + res.getBody());
            if(res.getStatusCode() == 200){
                response.isSuccess = true;
                system.debug('calander Response'+res.getBody());
                Map<String, Object> root = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
                system.debug('deliveryWindows is -->'+root.get('deliveryWindows'));
                if(root.get('deliveryWindows') != null){
                    
                    List<Object> windows = (List<Object>)root.get('deliveryWindows');
                    for(Object w: windows){
                        DeliveryWindow dw = new DeliveryWindow();
                        Map<String, Object> deliveryWindow = (Map<String, Object>)JSON.deserializeUntyped(Json.serialize(w));
                        if(deliveryWindow.containsKey('start')){
                            dw.startDateString = (String)deliveryWindow.get('start');
                        }
                        if(deliveryWindow.containsKey('end')){
                            dw.endDateString = (String)deliveryWindow.get('end');
                        }
                        if(deliveryWindow.containsKey('sortIndex')){
                            dw.sortIndex = (Integer)deliveryWindow.get('sortIndex');
                        }
                        response.deliveryWindows.add(dw);
                    }
                }       
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
        system.debug('response is -->'+response);
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
        public string startDateString {get;set;}
        public string endDateString {get;set;}
        public Integer sortIndex {get;set;}

        public Date getStartDate(){
            return Date.valueof(startDateString.left(10));
        }
    }

    public static string formatDateToISO8601(Date dt){
        Time t = Time.newInstance(0, 0, 0, 0);
        DateTime dateTimeInstance = DateTime.newInstance(dt, t);
        return dateTimeInstance.format('yyyy-MM-dd') + 'T00:00:00.000'; 
    }

    private static string buildATCURI(string accountNumber, string rdcId, Date startDate, Date endDate){
        return '/wholesale-customers/' +accountNumber + '/rdcs/' + rdcId + '/delivery-windows?rangeStart=' + formatDateToISO8601(startDate) + '&rangeEnd='+formatDateToISO8601(endDate);
    }
}