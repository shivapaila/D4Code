/**
* This is an API client class that will facilitates calls to Ashley systems to make updates on Orders associated to Customers
* in salesforce. 
 */
public with sharing class API_UpdateSalesOrderClient {
    public static final string ORDER_UPDATE_NAMED_CREDENTIAL_PRODUCTION = 'Order_Update_Prod';
    public static final string ORDER_UPDATE_NAMED_CREDENTIAL_SANDBOX = 'Order_Update_Sandbox';
    public static final string INTEGRATION_SETTING_KEY_PRODUCTION = 'Order_Update_Prod';
    public static final string INTEGRATION_SETTING_KEY_SANDBOX = 'Order_Update_Sandbox'; 
        
    public static final Integer CALLOUT_TIMEOUT_IN_MILLI_SECONDS = 20000;

    public static API_BaseResponse updateShippingAddress(string fullfilledById, string orderNumber, Integer profitCenter, string shipToName,
        string shipToAddress1, string shipToAddress2, string shipToCity, string shipToState, string shipToZip){
        API_BaseResponse response = new API_BaseResponse();

        if(String.isBlank(shipToAddress1) || String.isBlank(shipToCity) || String.isBlank(shipToState) || 
            String.isBlank(shipToZip)){
            response.isSuccess = false;
            response.message = Label.Missing_Required_Field_For_Address_Update;
            return response;
        }
            if(String.isBlank(shipToAddress2)){
                shipToAddress2=null;
            }      
        
        try{
            HttpRequest req = new HttpRequest();
            if(Utilities_SalesAndService.isSandbox){
                req.setEndpoint('callout:'+ ORDER_UPDATE_NAMED_CREDENTIAL_SANDBOX + buildShipToAddressURI(fullfilledById, orderNumber, profitCenter, shipToName,
                shipToAddress1, shipToAddress2, shipToCity, shipToState, shipToZip));
                //get key from custom setting
                Integration_Settings__c setting = Utilities_SalesAndService.getIntegrationSetting(INTEGRATION_SETTING_KEY_SANDBOX);
                if(setting != null){
                    req.setHeader('apikey', setting.API_Key__c);
                }
            }
            //use production named creds
            else{
                req.setEndpoint('callout:'+ ORDER_UPDATE_NAMED_CREDENTIAL_PRODUCTION + buildShipToAddressURI(fullfilledById, orderNumber, profitCenter, shipToName,
                shipToAddress1, shipToAddress2, shipToCity, shipToState, shipToZip));
                //get key from custom setting
                Integration_Settings__c setting = Utilities_SalesAndService.getIntegrationSetting(INTEGRATION_SETTING_KEY_PRODUCTION);
                if(setting != null){
                    req.setHeader('apikey', setting.API_Key__c);
                }
            }           
            req.setMethod('PUT');
            req.setHeader('Content-Type' ,'application/json');
              req.setHeader('Accept' ,'application/json');
            req.setBody('{}');
            req.setTimeout(CALLOUT_TIMEOUT_IN_MILLI_SECONDS);

            HttpResponse res = new Http().send(req);
            System.debug('***** ship address status update url: '+ req.getEndpoint());
            System.debug('***** ship address status response: '+ res.getBody() + '-' + res.getStatus());

            if(res.getStatusCode() == 200){
                response.isSuccess = true;
                response.message = Label.Order_Ship_To_Updated_SUccess_Message;
            }
            else{
                response.isSuccess = false;
                response.message = Label.Order_Ship_To_Updated_Error_Message + res.getStatusCode() + ' - ' + res.getBody();
            }
        }
        catch(Exception ex){
            response.isSuccess = false;
            response.message = Label.Order_Ship_To_Updated_Error_Message + ex.getMessage();
        }
        return response;
        
    }
    public static API_BaseResponse updateSalesOrderHotStatus(string fullfilledById, string orderNumber, boolean hotStatus, String WindowBegin, String WindowEnd, Date deliveryDate,Decimal profitCenter){

        API_BaseResponse response = new API_BaseResponse();

        if(deliveryDate == null){
            response.isSuccess = false;
            response.message = Label.Delivery_Date_Required_For_Hot_Status_Update;
            return response;
        }

        try{
            HttpRequest req = new HttpRequest();
            if(Utilities_SalesAndService.isSandbox){
                system.debug('ORDER_UPDATE-------'+ORDER_UPDATE_NAMED_CREDENTIAL_SANDBOX);
                req.setEndpoint('callout:'+ ORDER_UPDATE_NAMED_CREDENTIAL_SANDBOX + buildHotStatusURI(fullfilledById, orderNumber, hotStatus, WindowBegin, WindowEnd, deliveryDate, profitCenter));
                //get key from custom setting
                Integration_Settings__c setting = Utilities_SalesAndService.getIntegrationSetting(INTEGRATION_SETTING_KEY_SANDBOX);
                if(setting != null){
                    req.setHeader('apikey', setting.API_Key__c);
                }
            }
            //use production named creds
            else{
                req.setEndpoint('callout:'+ ORDER_UPDATE_NAMED_CREDENTIAL_PRODUCTION + buildHotStatusURI(fullfilledById, orderNumber, hotStatus, WindowBegin, WindowEnd, deliveryDate,profitCenter));
                //get key from custom setting
                Integration_Settings__c setting = Utilities_SalesAndService.getIntegrationSetting(INTEGRATION_SETTING_KEY_PRODUCTION);
                if(setting != null){
                    req.setHeader('apikey', setting.API_Key__c);
                }
            }           
            req.setMethod('PUT');
            req.setHeader('Content-Type' ,'application/json');
              req.setHeader('Accept' ,'application/json');
            req.setBody('{}');
            req.setTimeout(CALLOUT_TIMEOUT_IN_MILLI_SECONDS);

            HttpResponse res = new Http().send(req);
            System.debug('***** hot status update url: '+ req.getEndpoint());
            System.debug('***** hot status response: '+ res.getBody() + '-' + res.getStatus());
            if(res.getStatusCode() == 200){
                response.isSuccess = true;
                response.message = Label.Order_Hot_Status_Updated_Success_Message;
            }
            else{
                response.isSuccess = false;
                response.message = Label.Order_Hot_Status_Updated_Error_Message + res.getStatusCode() + ' - ' + res.getBody();
            }
        }
        catch(Exception ex){
            response.isSuccess = false;
            response.message = Label.Order_Hot_Status_Updated_Error_Message  + ex.getMessage();
        }
        return response;
    }
    
     
    //update VIP and LIB status
     //Added by Anil and Sudeshna-Ashley for VIP functionality – Code starts.
     public static API_BaseResponse updateSalesOrderVIPLIBStatus(String fullfilledById, String orderNumber, Boolean vipStatus,Boolean libStatus, Boolean vipCurStatus, Boolean libCurStatus){

        API_BaseResponse response = new API_BaseResponse();
          try{
            HttpRequest req = new HttpRequest();
              //'https://ashley-preprod-dev.apigee.net/homestores/' add to custom label and specify a name and populate
              //bGna5ABiJwsJyqV9DDtQmTBEH2Kpz713  - add a value in label and Ashley-VIP apikey
            String Endpoint = System.label.AshleyApigeeEndpoint+ fullfilledById+'/salesorders/'+orderNumber+'/VIPLIBStatus?VIPFlag='+vipStatus+'&LIBFlag='+libStatus;
            req.setEndpoint(Endpoint);
            req.setHeader('apikey',System.label.AshleyApigeeApiKey);
            req.setMethod('PUT');
            req.setHeader('Content-Type' ,'application/json');
            req.setHeader('Accept' ,'application/json');
            req.setBody('{}');
            req.setTimeout(CALLOUT_TIMEOUT_IN_MILLI_SECONDS);

            HttpResponse res = new Http().send(req);
            System.debug('***** viplib status update url: '+ req.getEndpoint());
            System.debug('***** viplib status response: '+ res.getBody() + '-' + res.getStatus());
            if(res.getStatusCode() == 200){
                System.debug('My Vip'+vipStatus);
                System.debug('My lib'+libStatus);
                System.debug('My currentvip'+vipCurStatus);
                System.debug('My Currentlib'+libCurStatus);
                response.isSuccess = true;
                if((vipStatus!=vipCurStatus)&&(libStatus==libCurStatus))
                    response.message = Label.Order_vip_Status_Updated_Success_Message;
                else if((libStatus!=libCurStatus)&&(vipStatus==vipCurStatus))
                    response.message = Label.Order_lib_Status_Updated_Success_Message;
                else if((libStatus!=libCurStatus)&&(vipStatus!=vipCurStatus))
                    response.message = Label.Order_VIP_and_LIB_Status_Updated_Success_Message;
            }
            else{
                response.isSuccess = false;
                response.message = Label.Order_vip_Status_Updated_Error_Message + res.getStatusCode() + ' - ' + res.getBody();
            }
        }
        catch(Exception ex){
            response.isSuccess = false;
            response.message = Label.Order_vip_Status_Updated_Error_Message  + ex.getMessage();
        }
        return response;
    }       
 
     //Added by Anil and Sudeshna-Ashley for LIB functionality – Code End.

     public static API_BaseResponse updateSalesOrderDeliveryDate(string fullfilledById, string orderNumber,Boolean asap, Integer profitCenter, 
                                                                Date deliveryDate, string deliveryType, string reasonDescription){
        API_BaseResponse response = new API_BaseResponse();
        //ASAP Functionality By venkat - Start                                                        
        System.debug('ASAP-----'+asap);
        if(asap)
        {
           deliveryDate = null;
        }
        //ASAP Functionality By venkat - End                                                          
        try{
            HttpRequest req = new HttpRequest();
            if(Utilities_SalesAndService.isSandbox){
                system.debug('deliveryDate------'+deliveryDate);
                req.setEndpoint('callout:'+ ORDER_UPDATE_NAMED_CREDENTIAL_SANDBOX + buildDeliveryDateUpdateURI(fullfilledById, orderNumber,asap, profitCenter, deliveryDate, deliveryType, reasonDescription));
                //get key from custom setting
                Integration_Settings__c setting = Utilities_SalesAndService.getIntegrationSetting(INTEGRATION_SETTING_KEY_SANDBOX);
                if(setting != null){
                    req.setHeader('apikey', setting.API_Key__c);
                }
            }
            //use production named creds
            else{
                req.setEndpoint('callout:'+ ORDER_UPDATE_NAMED_CREDENTIAL_PRODUCTION + buildDeliveryDateUpdateURI(fullfilledById, orderNumber,asap, profitCenter, deliveryDate, deliveryType, reasonDescription));
                system.debug('setEndpoint------'+req);
                //get key from custom setting
                Integration_Settings__c setting = Utilities_SalesAndService.getIntegrationSetting(INTEGRATION_SETTING_KEY_PRODUCTION);
                if(setting != null){
                    req.setHeader('apikey', setting.API_Key__c);
                }
            }           
            req.setMethod('PUT');
            req.setHeader('Content-Type' ,'application/json');
              req.setHeader('Accept' ,'application/json');
            req.setBody('{}');
            req.setTimeout(CALLOUT_TIMEOUT_IN_MILLI_SECONDS);

            HttpResponse res = new Http().send(req);            

            System.debug('***** Delivery date update url: '+ req.getEndpoint());
            System.debug('***** Delivery date response: '+ res.getBody() + '-' + res.getStatus());
            
            if(res.getStatusCode() == 200){
                response.isSuccess = true;
                response.message = Label.Order_Delivery_Date_Updated_Success_Message;
            }
            else{
                response.isSuccess = false;
                response.message = Label.Order_Delivery_Date_Updated_Error_Message + res.getStatusCode() + ' - ' + res.getBody();
            }
        }
        catch(Exception ex){
            response.isSuccess = false;
            response.message = Label.Order_Delivery_Date_Updated_Error_Message  + ex.getMessage();
        }
        return response;
    }   

    public static API_BaseResponse updateSalesOrderDeliveryComments(string fullfilledById, string salesOrderDeliveryComments, string orderNumber, Date deliveryDate, string deliveryType){
        API_BaseResponse response = new API_BaseResponse();
        try{
            HttpRequest req = new HttpRequest();
            if(Utilities_SalesAndService.isSandbox){
                req.setEndpoint('callout:'+ ORDER_UPDATE_NAMED_CREDENTIAL_SANDBOX + buildDeliveryCommentsUpdateURI(fullfilledById, salesOrderDeliveryComments, orderNumber, 
                                                                                    deliveryDate, deliveryType));
                //get key from custom setting
                Integration_Settings__c setting = Utilities_SalesAndService.getIntegrationSetting(INTEGRATION_SETTING_KEY_SANDBOX);
                if(setting != null){
                    req.setHeader('apikey', setting.API_Key__c);
                }
            }
            //use production named creds
            else{
                req.setEndpoint('callout:'+ ORDER_UPDATE_NAMED_CREDENTIAL_PRODUCTION + buildDeliveryCommentsUpdateURI(fullfilledById, salesOrderDeliveryComments, orderNumber, 
                                                                                        deliveryDate, deliveryType));
                //get key from custom setting
                Integration_Settings__c setting = Utilities_SalesAndService.getIntegrationSetting(INTEGRATION_SETTING_KEY_PRODUCTION);
                if(setting != null){
                    req.setHeader('apikey', setting.API_Key__c);
                }
           }           
            req.setMethod('PUT');
            req.setHeader('Content-Type' ,'application/json');
              req.setHeader('Accept' ,'application/json');
            req.setBody('{}');
            req.setTimeout(CALLOUT_TIMEOUT_IN_MILLI_SECONDS);


            HttpResponse res = new Http().send(req);

            System.debug('***** comment update url: '+ req.getEndpoint());
            System.debug('***** comment response: '+ res.getBody() + '-' + res.getStatus());
            if(res.getStatusCode() == 200){
                response.isSuccess = true;
                response.message = Label.Order_Delivery_Comment_Updated_Success_Message;
            }
            else{
                response.isSuccess = false;
                response.message = Label.Order_Delivery_Comment_Updated_Error_Message + res.getStatusCode() + ' - ' + res.getBody();
            }
        }
        catch(Exception ex){
            response.isSuccess = false;
            response.message = Label.Order_Delivery_Comment_Updated_Error_Message + ex.getMessage() + ex.getStackTraceString();
        }
        return response;
    }

    public static API_BaseResponse updateSalesOrderComments(string fullfilledById, string salesOrderComments, string orderNumber, Integer profitCenter){
        API_BaseResponse response = new API_BaseResponse();
        try{
            HttpRequest req = new HttpRequest();
            if(Utilities_SalesAndService.isSandbox){
                req.setEndpoint('callout:'+ ORDER_UPDATE_NAMED_CREDENTIAL_SANDBOX + buildOrderCommentsUpdateURI(fullfilledById, salesOrderComments, orderNumber, profitCenter));
                //get key from custom setting
                Integration_Settings__c setting = Utilities_SalesAndService.getIntegrationSetting(INTEGRATION_SETTING_KEY_SANDBOX);
                if(setting != null){
                    req.setHeader('apikey', setting.API_Key__c);
                }
            }
            //use production named creds
            else{
                req.setEndpoint('callout:'+ ORDER_UPDATE_NAMED_CREDENTIAL_PRODUCTION + buildOrderCommentsUpdateURI(fullfilledById, salesOrderComments, orderNumber, profitCenter));
                //get key from custom setting
                Integration_Settings__c setting = Utilities_SalesAndService.getIntegrationSetting(INTEGRATION_SETTING_KEY_PRODUCTION);
                if(setting != null){
                    req.setHeader('apikey', setting.API_Key__c);
                }
            }           
            req.setMethod('PUT');
            req.setHeader('Content-Type' ,'application/json');
              req.setHeader('Accept' ,'application/json');
            req.setBody('{}');
            req.setTimeout(CALLOUT_TIMEOUT_IN_MILLI_SECONDS);

            HttpResponse res = new Http().send(req);
            System.debug('***** Order Comments  update url: '+ req.getEndpoint());
            System.debug('***** Order Comments update response: '+ res.getBody() + '-' + res.getStatus());

            if(res.getStatusCode() == 200){
                response.isSuccess = true;
                response.message = Label.Order_Comment_Updated_Success_Message;
            }
            else{
                response.isSuccess = false;
                response.message = Label.Order_Comment_Updated_Error_Message + res.getStatusCode() + ' - ' + res.getBody();
            }
        }
        catch(Exception ex){
            response.isSuccess = false;
            response.message = Label.Order_Comment_Updated_Error_Message + ex.getMessage() + ex.getStackTraceString();
        }
        return response;
    }
    
    //Added by Venkat D4
    private static string buildASAPStatusURI(string fullfilledById, string orderNumber, Boolean asapStatus, Date deliveryDate){
        string uri = '/' + fullfilledById +'/salesorders/' + orderNumber +'/ASAPStatus?asapflag=' + asapStatus + '&deliveryDate=' + formatDateForOrderAPICall(deliveryDate);
        system.debug('asapuri-----'+uri);
        return  uri;
    }

    private static string buildHotStatusURI(string fullfilledById, string orderNumber, Boolean hotStatus,String WindowBegin, String WindowEnd,  Date deliveryDate, Decimal profitCenter){
        string uri = '/' + fullfilledById +'/salesorders/' + orderNumber +'/HOTStatus?hotflag=' + hotStatus + '&windowOpen=' + WindowBegin + '&windowClose=' + WindowEnd + '&deliveryDate=' + formatDateForOrderAPICall(deliveryDate)+ '&profitCenter=' +profitCenter;
        //string uri = '/8888300-164/salesorders/200564820/HotStatus?hotFlag=true&deliveryDate=2018-07-12&windowOpen=09:00&windowClose=11:00&profitCenter=23';
        system.debug('hoturi-----'+uri);
        return  uri;
    }
    
     private static string buildShipToAddressURI(string fullfilledById, string orderNumber, Integer profitCenter, string shipToName,
        string shipToAddress1, string shipToAddress2, string shipToCity, string shipToState, string shipToZip){
        string uri = '/' + fullfilledById +'/salesorders/' + orderNumber +'/SalesOrderShipTo?profitCenter=' + String.valueOf(profitCenter);
        uri += '&shipToName=' + EncodingUtil.URLENCODE(shipToName,'UTF-8');
        uri += '&shipToAddress1=' + EncodingUtil.URLENCODE(shipToAddress1,'UTF-8');
        if(shipToAddress2 != null){
            uri += '&shipToAddress2=' + EncodingUtil.URLENCODE(shipToAddress2,'UTF-8');
        }
        uri += '&shipToCity=' + EncodingUtil.URLENCODE(shipToCity,'UTF-8');
        uri += '&shipToState=' + EncodingUtil.URLENCODE(shipToState,'UTF-8'); 
        uri += '&shipToZip=' + EncodingUtil.URLENCODE(shipToZip,'UTF-8');
        return  uri;
    }

    private static string buildDeliveryDateUpdateURI(string fullfilledById, string orderNumber,Boolean asap, Integer profitCenter, 
                                                    Date deliveryDate, string deliveryType, string reasonCode){
        //use false for confirmFlag, use user federation id or username for userName
        string uri;
        
        if(deliveryDate != null)
        {
            uri = '/' + fullfilledById +'/salesorders/' + orderNumber +'/SalesOrderDeliveryDate?profitCenter=' + profitCenter + '&newShipDate=' + formatDateForOrderAPICall(deliveryDate);
        }
        else if(deliveryDate == null)
        {
            uri = '/' + fullfilledById +'/salesorders/' + orderNumber +'/SalesOrderDeliveryDate?profitCenter=' + profitCenter + '&newShipDate=' + '';
        }
            uri += '&shipViaCode=' + EncodingUtil.URLENCODE(deliveryType, 'UTF-8');     
            uri += '&reasonCode=' + EncodingUtil.URLENCODE(reasonCode, 'UTF-8'); 
            uri += '&confirmFlag=false';
            uri += '&userName=' + EncodingUtil.URLENCODE(getUserNameForAPiCall(Utilities_SalesAndService.currentUser), 'UTF-8');
        system.debug('deliverydateurl..' + uri);
        return uri;
    }

    private static string buildDeliveryCommentsUpdateURI(string fullfilledById, string salesOrderDeliveryComments, string orderNumber, 
                                                    Date deliveryDate, string deliveryType){
        //use false for confirmFlag, use user federation id or email for userName
        string uri = '/' + fullfilledById +'/salesorders/'+ orderNumber +'/SalesOrderDeliveryComments?deliveryComments=' + EncodingUtil.URLENCODE(salesOrderDeliveryComments, 'UTF-8') + '&deliverDate=' + formatDateForOrderAPICall(deliveryDate);
        uri += '&shipVia=' + EncodingUtil.URLENCODE(deliveryType, 'UTF-8');
        uri += '&ashleyOrderNumber=' + EncodingUtil.URLENCODE(orderNumber, 'UTF-8');
        uri += '&confirmFlag=false';
        uri += '&userName=' + EncodingUtil.URLENCODE(getUserNameForAPiCall(Utilities_SalesAndService.currentUser), 'UTF-8');

        return uri;
    }

    private static string buildOrderCommentsUpdateURI(string fullfilledById, string salesOrderComments, string orderNumber, Integer profitCenter){
        string uri = '/' + fullfilledById +'/salesorders/'+ orderNumber +'/SalesOrderComments?salesOrderComments=' + EncodingUtil.URLENCODE(salesOrderComments, 'UTF-8') ;
        uri += '&profitCenter=' + profitCenter;
        return uri;
    }

    public static string formatDateForOrderAPICall(Date d){
        string formattedString = '';
        if(d.month() <= 9){
            formattedString += '0';
        }
        formattedString += String.valueOf(d.month()) + '-';
        if(d.day() <= 9){
            formattedString += '0';
        }
        formattedString += String.valueOf(d.day()) + '-' + String.valueOf(d.year());
        return formattedString;
    }

    public static string getUserNameForAPiCall(User U){
        if(u.FederationIdentifier != null){
            return u.FederationIdentifier;
        }
        else{
            return u.Email;
        }
    }
}