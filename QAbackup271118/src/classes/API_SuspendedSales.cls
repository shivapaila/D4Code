/********************************************************************************************************************
* Class Name   : API_SuspendedSales
* Description  : API class for Suspended Sales     
* Author       : Perficient, Inc.
* Created On   : 02/16/2018
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer                                   Date                   Modification ID      Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
*
**************************************************************************************************************************************/
global with sharing class API_SuspendedSales{
    public static ResponseWrapper sendDataWithAddressString(Id customerID, String addressString, String phoneNumber){
        if(String.isBlank(addressString)){
            return null;
        }
        API_SuspendedSales.AddressWrapper billingAddress = splitAddress(addressString);
        if(String.isNotBlank(phoneNumber)){
            billingAddress.Phone = phoneNumber;
        }
        return sendData(customerID, billingAddress);
    }

    public static AddressWrapper splitAddress(String addressStr){
        AddressWrapper billingAddress = new AddressWrapper();
        String[] strList = addressStr.split(',');
        if(strList.size() > 2){
            billingAddress.Address1 = strList[0].trim();
            Integer idx = 1;
            if(strList.size() > 3){
                idx++;
            }
            billingAddress.City = strList[idx].trim();
            String stateAndZipCode = strList[idx+1].trim();
            String[] strList2 = stateAndZipCode.split(' ');
            if(strList2.size() > 1){
                billingAddress.State = strList2[0];
                billingAddress.ZipCode = strList2[1];
            }
        }
        return billingAddress;
    }

    public static ResponseWrapper sendData(Id customerID, AddressWrapper billingAddress){
        try{
            Account acct = getAccountInfo(customerID);
            String requestBody = createRequestBody(acct,billingAddress); 
            if(String.isNotBlank(requestBody)){
                ResponseWrapper cartReturned = callSuspendSales(acct,requestBody);
                return cartReturned;
            }
            return null;                           
        }        
        catch(Exception e){
            ErrorLogController.Log log = new ErrorLogController.Log('API_SuspendedSales','sendData',e.getMessage());
            new ErrorLogController().createLog(log); 
        }
        return null;
    }
    
    public static Account getAccountInfo(Id customerID){
         Account acct = [SELECT Id,Name,Profit_Center_Code__c,Store_Id__c, //BillingPostalCode
                            FirstName, LastName, PersonEmail, Phone 
                        FROM Account WHERE Id =:customerID];
        return acct;
    }

    public static String createRequestBody(Account acct,AddressWrapper billingAddress){
        List<Opportunity> oppDetails = [SELECT Id from Opportunity WHERE AccountId =:acct.Id
                                       and StageName != 'Closed Won' 
                              and StageName != 'Sale Suspended' 
                              and createdDate = LAST_N_DAYS:30];
        List<Shopping_cart_line_item__c> lineItems = [SELECT ID,Product_SKU__c,Quantity__c 
                                                      FROM Shopping_cart_line_item__c 
                                                      WHERE Opportunity__c IN :oppDetails];
        User loggedInUser = [SELECT Id,FederationIdentifier,RSA_ID__c,Store_Zip__c 
                             FROM User WHERE Id =:UserInfo.getUserId()];
        
        //If Product present in the Cart
        if(lineItems.size() > 0){   
            List<CartItemWrapper> cartItems = new List<CartItemWrapper>();
            for(Shopping_cart_line_item__c tempOppLineItem :lineItems){
                CartItemWrapper individualItem = new CartItemWrapper();
                individualItem.itemid = tempOppLineItem.Product_SKU__c;  
                individualItem.quantity = String.valueOf(tempOppLineItem.Quantity__c);
                cartItems.add(individualItem);                    
            }
            
            CartWrapper cartDetails = createCartForNewCustomer(loggedInUser,acct,billingAddress);
            JSONWrapper jsonConst = new JSONWrapper();
            jsonConst.cartitem = cartItems;
            jsonConst.cart = cartDetails;
            String body= JSON.serialize(jsonConst);
            return body;
        }
        return null;
    }

    public static CartWrapper createCartForNewCustomer(User loggedInUser, Account acct, AddressWrapper billingAddress){
        //Cart
        CartWrapper cartDetails = new CartWrapper();
        cartDetails.UserName = loggedInUser.FederationIdentifier;    
        cartDetails.FirstName = acct.FirstName;
        cartDetails.LastName = acct.LastName;
        cartDetails.EmailAddress = acct.PersonEmail;
        
        cartDetails.ZipCode = billingAddress.ZipCode;
        cartDetails.Address1 = billingAddress.Address1;
        cartDetails.HomePhone = billingAddress.Phone==null?acct.Phone:billingAddress.Phone;
        cartDetails.City= billingAddress.City;
        cartDetails.StateOrProvince = billingAddress.State;
        cartDetails.RSAID = loggedInUser.RSA_ID__c;
        return cartDetails;
    }

    public static CartWrapper createCartForExistingCustomer(User loggedInUser, Account acct, String customerID ){
        //Cart
        CartWrapper cartDetails = new CartWrapper();
        cartDetails.UserName = loggedInUser.FederationIdentifier;    
        cartDetails.CustomerID = customerID;
        cartDetails.ZipCode = acct.BillingPostalCode;
        return cartDetails;
    }

    public static ResponseWrapper callSuspendSales(Account acct,String body){
        HttpResponse res;
        Http h = new Http();            
        //Getting API key and End Point URL from Custom Settings
        ConciergeProductAPISetting__c prodApiSetting = ConciergeProductAPISetting__c.getValues('ProductAPISetting');
        String path = prodApiSetting.Product_API_SuspendedSales_Path__c;
        Integration_Settings__c suspendedSales = Integration_Settings__c.getValues('SuspendedSalesAPI');
        List<String> strList = new List<String>();
        strList.add(acct.Store_Id__c);
        strList.add(acct.Profit_Center_Code__c);
        //String endPointURL = suspendedSales.End_Point_URL__c+'/homestores/'+acct.Store_Id__c+'/suspended-sales?profitcenter='+acct.Profit_Center_Code__c;
        String endPointURL = suspendedSales.End_Point_URL__c + String.format(path,strList);
        System.debug('>>endPointURL>>' + endPointURL);
        HttpRequest req = new HttpRequest();
        req.setHeader('Content-Type','application/json');
        req.setHeader('apikey',suspendedSales.API_Key__c);
        req.setEndPoint(endPointURL);        
        req.setMethod('POST');                     
        req.setBody(body);
        System.debug('req body: '+body);
        
        res = h.send(req);
        System.debug('res: '+res.getStatusCode());
        System.debug('res: '+res.getBody()); //{"cartId":"1912"}
        if(res.getStatusCode()==200){
            String responseStr = res.getBody();
            ResponseWrapper resObj = (ResponseWrapper)JSON.deserialize(responseStr,ResponseWrapper.class);
            return resObj;                
        }else{
            String errorDetail = 'Response Status Code: ' + res.getStatusCode() + ', response body: ' +res.getBody();
            System.debug(errorDetail);
            ErrorLogController.Log log = new ErrorLogController.Log('API_SuspendedSales','callSuspendSales',errorDetail);
            new ErrorLogController().createLog(log);
            return null;
        }
    }

    public class JSONWrapper{
        public CartWrapper cart {get; set;}
        public List<CartItemWrapper> cartitem {get; set;}
    }
    
    public class CartWrapper{
        public String UserName {get; set;}
        public String CustomerID {get; set;}
        public String ZipCode {get; set;}   
        public String FirstName {get; set;}
        public String LastName {get; set;}
        public String Address1 {get; set;}
        public String HomePhone {get; set;}
        public String EmailAddress {get; set;}
        public String City {get; set;}  
        public String StateOrProvince {get; set;}  
        public String RSAID {get; set;}  
    }
    
    public class CartItemWrapper{
        public String itemid {get; set;}
        public String quantity {get; set;}
    }

    public class ResponseWrapper{
        public String CartId {get;set;}
    }

    public class AddressWrapper{
        public String Address1 {get;set;}
        public String City {get;set;}
        public String State {get;set;}
        public String ZipCode {get;set;}
        public String Phone {get;set;}
    }
}