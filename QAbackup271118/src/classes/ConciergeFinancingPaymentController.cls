/****** v1 | Description: Financing payment controller class | 6/12/2018 | Sorna */

public class ConciergeFinancingPaymentController {
    public static final String FINANCE_TERMS_API_SETTING_NAME = 'CreditAuthorizationAPI';
    public static final String PATH_SETTING_NAME = 'ProductAPISetting';
    // get Payment options for financing component
    @AuraEnabled
    public static Map<String,Payment_Type__c> getPaymentOptions(){
        Map<String,Payment_Type__c> paymentOptions = PaymentTypeHelper.getPaymentTypeMapping();
        Set<String> availableFinancingOptions = new Set<String>();
        for(String s : system.label.ConciergeFinancingPaymentOptions.split(',')) {
            availableFinancingOptions.add(s.trim().toLowerCase());
        }
        for(string s : paymentOptions.keySet()) {
            if(!availableFinancingOptions.contains(s.toLowerCase())) {
                paymentOptions.remove(s);
            }
        }
        return paymentOptions;
    }
    // get Item details and updates Opportunity.SalesGuid__c if blank
    @AuraEnabled
    public static ConciergePaymentItemDetailsHelper.ItemDetailsWrapper getItemDetails(Id personAccountId) {
        ConciergePaymentItemDetailsHelper.ItemDetailsWrapper iWrapper = ConciergePaymentItemDetailsHelper.getItemDetails( personAccountId,false); 
        return iWrapper;
    }
    // get payment terms
    @AuraEnabled
    public static List<API_PaymentType.PaymentTermWrapper> getPaymentTerms(String selectedTenderCode) {
       string selecttdcode = selectedTenderCode;
        system.debug('selecttdcode is '+selecttdcode);
        List<API_PaymentType.PaymentTermWrapper> ptermWrap = API_PaymentType.getPaymentTerm(selecttdcode);
        system.debug('ptermWrap is'+ptermWrap);
        return ptermWrap;
    }
    // perform account lookup for Genesis and Synchrony
    @AuraEnabled
    public static ConciergeFinancingAPIResponseWrapper.UIAccountLookupResponse performAccountLookup(Id personAccountId, Opportunity oppt,
                                                                Map<String, Object> objectMap, String pmJSON,
                                                                String ptermWrap) {
        PaymentMethodWrapper pmtWrapper = (PaymentMethodWrapper)JSON.deserialize(pmJSON, PaymentMethodWrapper.class);
        Map<String,Payment_Type__c> payOptionsResult = getPaymentOptions();
        List<API_PaymentType.PaymentTermWrapper> paymentTermWrapList = (List<API_PaymentType.PaymentTermWrapper>)JSON.deserialize(ptermWrap, List<API_PaymentType.PaymentTermWrapper>.class);
        HttpResponse res;
        try {
            Http h = new Http();
            HttpRequest req = getHttpRequest(personAccountId, oppt, objectMap, pmtWrapper, payOptionsResult, paymentTermWrapList, 'accountLookup');
            res = h.send(req);
            if(res.getStatusCode()==200){
                String jsonString = res.getBody();
                // different response structure for synchrony (CITM and CITS) and different structure for Gensis (GENS)
                if(pmtWrapper.paymentTrans.TenderCode__c == 'CITM' || pmtWrapper.paymentTrans.TenderCode__c == 'CITS') {
                    ConciergeFinancingAPIResponseWrapper.UIAccountLookupResponse wrapper = 
                    new ConciergeFinancingAPIResponseWrapper.UIAccountLookupResponse(
                            (ConciergeFinancingAPIResponseWrapper.SynchronyAccountLookupResponse)
                            JSON.deserialize(res.getBody(), ConciergeFinancingAPIResponseWrapper.SynchronyAccountLookupResponse.class)
                        );
                    return wrapper;
                }
                // if genesis
                else {
                    ConciergeFinancingAPIResponseWrapper.UIAccountLookupResponse wrapper = 
                    new ConciergeFinancingAPIResponseWrapper.UIAccountLookupResponse(
                            (ConciergeFinancingAPIResponseWrapper.GenesysAccountLookupResponse)
                            JSON.deserialize(res.getBody(), ConciergeFinancingAPIResponseWrapper.GenesysAccountLookupResponse.class)
                        );
                    return wrapper;
                }
            }
            // if account number is invalid
            else if(res.getStatusCode() == 400 && res.getBody() != null && res.getBody().contains('Account Number invalid')) {
                throw new AuraHandledException('Please enter valid PL Account Number');
            }
            else if(res.getStatusCode() == 502) {
                throw new AuraHandledException(res.getStatus());
            }
            // other errors
            else {
                throw new AuraHandledException(parseErrorMsg(res.getBody()));
            }
        }
        // generic errors
        catch(CalloutException ce){
            throw new AuraHandledException(res.getStatusCode() + ' ' + res.getStatus() + ' Account Lookup API Call Failed');
        }
        catch(JSONException e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    // Process payment using genesis/synchrony transaction apis
    @AuraEnabled
    public static PaymentMethodWrapper processPaymentMethod(Id personAccountId, Opportunity oppt,
                                                                Map<String, Object> objectMap, String pmJSON,
                                                                String selectedPayTermJSON) {
        PaymentMethodWrapper pmtWrapper = (PaymentMethodWrapper)JSON.deserialize(pmJSON, PaymentMethodWrapper.class);
        Map<String,Payment_Type__c> payOptionsResult = getPaymentOptions();
        API_PaymentType.PaymentTermWrapper selectedPayTerm = (API_PaymentType.PaymentTermWrapper) JSON.deserialize(selectedPayTermJSON, API_PaymentType.PaymentTermWrapper.class);
        HttpResponse res;
        try {
            Http h = new Http();
            HttpRequest req = getHttpRequest(personAccountId, oppt, objectMap, pmtWrapper, payOptionsResult, new List<API_PaymentType.PaymentTermWrapper>{selectedPayTerm}, 'transaction');
            System.debug('=====> ' + req.getbody());
            res = h.send(req);
            
            if(res.getStatusCode()==200){
                String jsonString = res.getBody();
                // parse response
                ConciergeFinancingAPIResponseWrapper.TransactionResponse wrapper = 
                            (ConciergeFinancingAPIResponseWrapper.TransactionResponse)
                            JSON.deserialize(res.getBody(), ConciergeFinancingAPIResponseWrapper.TransactionResponse.class);
                if(wrapper.Status == 'Approved')//DEF-0867 & DEF-0873 fix - && wrapper.PaymentReceived)
                    return createTransaction(pmtWrapper, wrapper, oppt.Id);
                else if(wrapper.Status == 'Declined') {//DEF-0867 & DEF-0873 fix -  && !wrapper.PaymentReceived) {
                    throw new AuraHandledException('Payment Declined');
                }
                else {
                    throw new AuraHandledException('Unknown Exception');
                }
            }
            else if(res.getStatusCode() == 502) {
                throw new AuraHandledException(res.getStatus());
            }
            // error code other than 200
            else {
                throw new AuraHandledException(parseErrorMsg(res.getBody()));
            }
        }
        // generic errors
        catch(CalloutException ce){
            throw new AuraHandledException(res.getStatusCode() + ' ' + res.getStatus() + ' Transaction API Call Failed');
        }
        catch(JSONException e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    // to void an already successful payment
    @AuraEnabled
    public static PaymentMethodWrapper voidPayment(Id personAccountId, Opportunity oppt,
                                                                Map<String, Object> objectMap, String pmJSON) {
              
            
           system.debug('str is -->'+personAccountId);   
           //system.debug('objectMap is -->'+objectMap.keyset()); 
                                                                    
        // if oppt and objectMap is null, user would have revisited an already pending order 
        // that has a successful financing payment processed in the past
        if(oppt == null || objectMap == null) {
            ConciergePaymentItemDetailsHelper.ItemDetailsWrapper itemDetails = ConciergePaymentItemDetailsHelper.getItemDetails(personAccountId,false);
            if(itemDetails != null) {
                oppt = itemDetails.oppt;
                objectMap = itemDetails.objectMap;
            }
            else {
                throw new AuraHandledException('Could not retrieve Item Details API');
            }
        }
        PaymentMethodWrapper pmtWrapper = (PaymentMethodWrapper)JSON.deserialize(pmJSON, PaymentMethodWrapper.class);
        Map<String,Payment_Type__c> payOptionsResult = getPaymentOptions();
        HttpResponse res;
        try {
            Http h = new Http();
            
            HttpRequest req = getHttpRequest(personAccountId, oppt, objectMap, pmtWrapper, payOptionsResult, null, 'voidPayment');
            
            res = h.send(req);
            // if success
            if(res.getStatusCode()==200){
                String jsonString = res.getBody();
                ConciergeFinancingAPIResponseWrapper.TransactionResponse wrapper = 
                            (ConciergeFinancingAPIResponseWrapper.TransactionResponse)
                            JSON.deserialize(res.getBody(), ConciergeFinancingAPIResponseWrapper.TransactionResponse.class);
                if(wrapper.Status == 'Void') {
                    return updateTransactionVoid(pmtWrapper, wrapper);
                }
                else {
                    throw new AuraHandledException('Unknown Exception');
                }
            }
            else if(res.getStatusCode() == 502) {
                throw new AuraHandledException(res.getStatus());
            }
            // error code other than 200
            else {
                throw new AuraHandledException(parseErrorMsg(res.getBody()));
            }
        }
        // generic errors
        catch(CalloutException ce){
            throw new AuraHandledException(res.getStatusCode() + ' ' + res.getStatus() + ' Void Payment API Call Failed');
        }
        catch(JSONException e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    // a common method to create financing http requests
    public static HttpRequest getHttpRequest(Id personAccountId, Opportunity oppt, Map<String, Object> objectMap, 
                                                PaymentMethodWrapper pmWrapper, Map<String, Payment_Type__c> payOptionsResult, List<API_PaymentType.PaymentTermWrapper> ptermWrap, String requestType) {
        StoreInfoWrapper storeInfo = CreateSalesOrderHelper.getStoreInfo();
        if(Test.isRunningTest()) {
            storeInfo.fulfillerId = '8888300-164';
        }
        HttpRequest req = new HttpRequest();
        Integration_Settings__c settings = Integration_Settings__c.getInstance(FINANCE_TERMS_API_SETTING_NAME);
        ConciergeProductAPISetting__c prodApiSetting = ConciergeProductAPISetting__c.getValues(PATH_SETTING_NAME);
        String path = prodApiSetting.CreditAuthorizationAPI_Path__c;
        List<String> strList = new List<String>();
        strList.add(storeInfo.fulfillerId);
        String endPointURL = settings.End_Point_URL__c + String.format(path,strList);
        req.setEndpoint(endPointURL);
        req.setHeader('Content-Type','application/json');
        req.setHeader('Accept', 'application/json');
        req.setHeader('apiKey', settings.API_Key__c);
        req.setMethod('POST');
        req.setTimeout(120000);
        if(requestType == 'accountLookup') {
            req.setBody(prepareAccountLookupJSON(personAccountId, oppt, storeInfo, objectMap, pmWrapper, payOptionsResult, ptermWrap));
           // system.debug('accountlookuplogs' + req.setBody(prepareAccountLookupJSON(personAccountId, oppt, storeInfo, objectMap, pmWrapper, payOptionsResult, ptermWrap)));
        }
        if(requestType == 'transaction') {
            req.setBody(prepareTransactionJSON(personAccountId, oppt, storeInfo, objectMap, pmWrapper, payOptionsResult, ptermWrap));
        }
        if(requestType == 'voidPayment') {
            system.debug('requestType------'+requestType);
            req.setBody(prepareVoidPaymentJSON(personAccountId, oppt, storeInfo, objectMap, pmWrapper, payOptionsResult));
        }
        return req;
    }
    // prepare the JSON for account looku up api
    public static String prepareAccountLookupJSON(Id personAccountId, Opportunity oppt, StoreInfoWrapper storeInfo, Map<String, Object> objectMap, 
                                                PaymentMethodWrapper pmWrapper, Map<String, Payment_Type__c> payOptionsResult, List<API_PaymentType.PaymentTermWrapper> ptermWrap) {
        Address__c shipToAddress;
        Address__c billToAddress;
        Account personAcc;
        String printerName;
        Payment_Type__c selectedPayOption;
        API_PaymentType.PaymentTermWrapper pTermWrapper;

        if(personAccountId != null) {
            personAcc = [Select Id, FirstName, LastName,PersonEmail,phone from Account where Id = :personAccountId];
        }
        if(oppt.ShipTo_Address__c != null) {
            shipToAddress = [Select Id, Address_Line_1__c, Address_Line_2__c, City__c, Zip_Code__c, State__c
                                    from Address__c where ID = :oppt.ShipTo_Address__c];
        }
        if(oppt.Bill_To_Address__c != null) {
            billToAddress = [Select Id, Address_Line_1__c, Address_Line_2__c, City__c, Zip_Code__c, State__c
                                    from Address__c where ID = :oppt.Bill_To_Address__c];
        }

        if(pmWrapper.paymentTerminalSelected != null
            && pmWrapper.paymentTerminalSelected != '') {
            PaymentTerminalWrapper pTerminalWrapper = fetchSelectedTerminal(pmWrapper.paymentTerminalSelected);
            printerName = pTerminalWrapper.ReceiptPrinter;
        }
        if(pmWrapper.paymentTrans.TenderCode__c != null && 
            pmWrapper.paymentTrans.TenderCode__c != '') {
            for(String s : payOptionsResult.keyset()) {
                if(payOptionsResult.get(s).TenderCode__c == pmWrapper.paymentTrans.TenderCode__c) {
                    selectedPayOption = payOptionsResult.get(s);
                }
            }
            if(selectedPayOption != null) {
                if(ptermWrap != null && !ptermWrap.isEmpty()) {
                    pTermWrapper = ptermWrap[0];
                }
            }
        }
        
        Decimal discountAmount = (Decimal)ObjectMap.get('TotalDiscountAmount');
        User loggedinuserdetails = [select Id, username,RSA_ID__c,LegacyStoreID__c from User where Id = :UserInfo.getUserId()];
        String requestJSON = ConciergeFinancingAPIHelper.constructJSON('Genesys Account Lookup', oppt.SalesGuid__c, pmWrapper.FINnum,
                        storeInfo.profitCtr, printerName, (Decimal)ObjectMap.get('TotalTaxAmount'), 
                        (Decimal)ObjectMap.get('TotalCost'), (Decimal)ObjectMap.get('SalesGrandTotal'), (Decimal)ObjectMap.get('TotalDeliveryAmount'), 
                        pmWrapper.paymentTrans.Payment_Amount__c, 
                        ConciergePaymentHelper.getCurrentBalanceDue(oppt.Id, (Decimal)ObjectMap.get('SalesGrandTotal')), 
                        discountAmount != null && discountAmount > 0 ? true : false, 
                        (Decimal)ObjectMap.get('YouSaveDiscountAmount'), 
                        (Decimal)ObjectMap.get('YouSaveDiscountPercent'), ObjectMap.get('CustomerId') != null ? (String)ObjectMap.get('CustomerId') : '', 
                        pTermWrapper.TermsCode, selectedPayOption.TenderCode__c, true, pTermWrapper.TermsCodeDescription, selectedPayOption.DocumentNumber__c, 
                        personAcc.FirstName, personAcc.LastName, shipToAddress, billToAddress, '', false, 
                        personAcc.Id,loggedinuserdetails.RSA_ID__c,loggedinuserdetails.LegacyStoreID__c,PersonAcc.PersonEmail,PersonAcc.Phone);
        system.debug('accountlookuplogs' + requestJSON);
        return requestJSON;
                                                    
    }
    // prepate the JSON for transaction api
    public static String prepareTransactionJSON(Id personAccountId, Opportunity oppt, StoreInfoWrapper storeInfo, Map<String, Object> objectMap, 
                                                PaymentMethodWrapper pmWrapper, Map<String, Payment_Type__c> payOptionsResult, List<API_PaymentType.PaymentTermWrapper> ptermWrap) {
        Address__c shipToAddress;
        Address__c billToAddress;
        Account personAcc;
        String printerName;
        Payment_Type__c selectedPayOption;
        API_PaymentType.PaymentTermWrapper pTermWrapper;

        if(personAccountId != null) {
            personAcc = [Select Id, FirstName, LastName,PersonEmail,phone from Account where Id = :personAccountId];
        }
        if(oppt.ShipTo_Address__c != null) {
            shipToAddress = [Select Id, Address_Line_1__c, Address_Line_2__c, City__c, Zip_Code__c, State__c
                                    from Address__c where ID = :oppt.ShipTo_Address__c];
        }
        if(oppt.Bill_To_Address__c != null) {
            billToAddress = [Select Id, Address_Line_1__c, Address_Line_2__c, City__c, Zip_Code__c, State__c
                                    from Address__c where ID = :oppt.Bill_To_Address__c];
        }

        if(pmWrapper.paymentTerminalSelected != null
            && pmWrapper.paymentTerminalSelected != '') {
            PaymentTerminalWrapper pTerminalWrapper = fetchSelectedTerminal(pmWrapper.paymentTerminalSelected);
            printerName = pTerminalWrapper.ReceiptPrinter;
        }

        if(pmWrapper.paymentTrans.TenderCode__c != null && 
            pmWrapper.paymentTrans.TenderCode__c != '') {
            for(String s : payOptionsResult.keyset()) {
                if(payOptionsResult.get(s).TenderCode__c == pmWrapper.paymentTrans.TenderCode__c) {
                    selectedPayOption = payOptionsResult.get(s);
                }
            }
        }
        if(ptermWrap != null && !ptermWrap.isEmpty()) {
            pTermWrapper = ptermWrap[0];
        }
        //if(selectedPayOption.TenderCode__c == 'GENS') storeInfo.profitCtr = '24';
        Decimal discountAmount = (Decimal)ObjectMap.get('TotalDiscountAmount');
        User loggedinuserdetails = [select Id, username,RSA_ID__c,LegacyStoreID__c from User where Id = :UserInfo.getUserId()];
        String requestJSON = ConciergeFinancingAPIHelper.constructJSON('Genesys Account Lookup', oppt.SalesGuid__c, pmWrapper.FINnum,
                        storeInfo.profitCtr, printerName, (Decimal)ObjectMap.get('TotalTaxAmount'), 
                        (Decimal)ObjectMap.get('TotalCost'), (Decimal)ObjectMap.get('SalesGrandTotal'), 
                        (Decimal)ObjectMap.get('TotalDeliveryAmount'), pmWrapper.paymentTrans.Payment_Amount__c, 
                        ConciergePaymentHelper.getCurrentBalanceDue(oppt.Id, (Decimal)ObjectMap.get('SalesGrandTotal')), 
                        discountAmount != null && discountAmount > 0 ? true : false, 
                        (Decimal)ObjectMap.get('YouSaveDiscountAmount'), 
                        (Decimal)ObjectMap.get('YouSaveDiscountPercent'), 
                        ObjectMap.get('CustomerId') != null ? (String)ObjectMap.get('CustomerId') : '', 
                        pTermWrapper.TermsCode, selectedPayOption.TenderCode__c, false, 
                        pTermWrapper.TermsCodeDescription, selectedPayOption.DocumentNumber__c, 
                        personAcc.FirstName, personAcc.LastName, shipToAddress, billToAddress, '', false, personAcc.Id,loggedinuserdetails.RSA_ID__c,loggedinuserdetails.LegacyStoreID__c,
                        personAcc.PersonEmail,personAcc.Phone);
        return requestJSON;
    }
    // prepare the JSON request for void payment api
    public static String prepareVoidPaymentJSON(Id personAccountId, Opportunity oppt, StoreInfoWrapper storeInfo, Map<String, Object> objectMap, 
                                                PaymentMethodWrapper pmWrapper, Map<String, Payment_Type__c> payOptionsResult) {
        Address__c shipToAddress;
        Address__c billToAddress;
        Account personAcc;
        String printerName;
        Payment_Type__c selectedPayOption;
        API_PaymentType.PaymentTermWrapper pTermWrapper;

        if(personAccountId != null) {
            personAcc = [Select Id, FirstName, LastName,PersonEmail,Phone from Account where Id = :personAccountId];
        }
        if(oppt.ShipTo_Address__c != null) {
            shipToAddress = [Select Id, Address_Line_1__c, Address_Line_2__c, City__c, Zip_Code__c, State__c
                                    from Address__c where ID = :oppt.ShipTo_Address__c];
        }
        if(oppt.Bill_To_Address__c != null) {
            billToAddress = [Select Id, Address_Line_1__c, Address_Line_2__c, City__c, Zip_Code__c, State__c
                                    from Address__c where ID = :oppt.Bill_To_Address__c];
        }

        if(pmWrapper.paymentTerminalSelected != null
            && pmWrapper.paymentTerminalSelected != '') {
            PaymentTerminalWrapper pTerminalWrapper = fetchSelectedTerminal(pmWrapper.paymentTerminalSelected);
            printerName = pTerminalWrapper.ReceiptPrinter;
        }

        if(pmWrapper.paymentTrans.TenderCode__c != null && 
            pmWrapper.paymentTrans.TenderCode__c != '') {
            for(String s : payOptionsResult.keyset()) {
                if(payOptionsResult.get(s).TenderCode__c == pmWrapper.paymentTrans.TenderCode__c) {
                    selectedPayOption = payOptionsResult.get(s);
                }
            }
            if(selectedPayOption != null) {
                List<API_PaymentType.PaymentTermWrapper> ptermWrap = API_PaymentType.getPaymentTerm(pmWrapper.paymentTrans.TenderCode__c);
                if(ptermWrap != null && !ptermWrap.isEmpty()) {
                    for(API_PaymentType.PaymentTermWrapper pw : ptermWrap) {
                        if(pw.TermsCode == pmWrapper.paymentTrans.TermsCode__c) {
                            pTermWrapper = pw;
                            break;
                        }
                    }
                }
            }
        }
        Decimal discountAmount = (Decimal)ObjectMap.get('TotalDiscountAmount');
        User loggedinuserdetails = [select Id, username,RSA_ID__c,LegacyStoreID__c from User where Id = :UserInfo.getUserId()];
       			system.debug('pmWrapper------'+pmWrapper.paymentTrans.Account_Number__c);
                 String requestJSON;
                  system.debug('contains key '+ObjectMap.containsKey('CustomerId'));                                  
                  requestJSON = ConciergeFinancingAPIHelper.constructJSON('Genesys Account Lookup', oppt.SalesGuid__c, pmWrapper.paymentTrans.Account_Number__c,
                        storeInfo.profitCtr, printerName, (Decimal)ObjectMap.get('TotalTaxAmount'), 
                        (Decimal)ObjectMap.get('TotalCost'), (Decimal)ObjectMap.get('SalesGrandTotal'), 
                        (Decimal)ObjectMap.get('TotalDeliveryAmount'), pmWrapper.paymentTrans.Payment_Amount__c, 
                        ConciergePaymentHelper.getCurrentBalanceDue(oppt.Id, (Decimal)ObjectMap.get('SalesGrandTotal')), 
                        discountAmount != null && discountAmount > 0 ? true : false,
                        (Decimal)ObjectMap.get('YouSaveDiscountAmount'), 
                        (Decimal)ObjectMap.get('YouSaveDiscountPercent'), 
                        ObjectMap.get('CustomerId') != null ? (String)ObjectMap.get('CustomerId') : '', 
                        pTermWrapper.TermsCode, selectedPayOption.TenderCode__c, false, 
                        pTermWrapper.TermsCodeDescription, selectedPayOption.DocumentNumber__c,
                       // pmWrapper.paymentTrans.Account_Number__c,
                        personAcc.FirstName, personAcc.LastName, shipToAddress, billToAddress, pmWrapper.paymentTrans.ReferenceNumber__c, true, personAcc.Id,loggedinuserdetails.RSA_ID__c,loggedinuserdetails.LegacyStoreID__c,
                        personAcc.PersonEmail,personAcc.Phone);
                
          system.debug('requestJSON -->'+requestJSON);                                          
        return requestJSON;
                                                    
    }
    // Cart_payment_Transaction is updated with details from successful payment response
    public static PaymentMethodWrapper createTransaction(PaymentMethodWrapper cpt,
                                        ConciergeFinancingAPIResponseWrapper.TransactionResponse wrapper, Id opptyId) {
        // DEF-0891 - storing last 4 digits of card # is acceptable 
        // so it can be displayed in the UI after a successful payment
        cpt.paymentTrans.Account_Number__c = wrapper.AccountNumber;
        cpt.paymentTrans.AuthorizationNumber__c = wrapper.AuthorizationNumber;
        cpt.paymentTrans.Check_DocumentNumber__c = wrapper.DocumentNumber;
        if(cpt.paymentTrans.Opportunity__c == null) {
            cpt.paymentTrans.Opportunity__c = opptyId;
        }
        cpt.paymentTrans.Payment_Amount__c = wrapper.Amount;
        cpt.paymentTrans.ReferenceNumber__c = wrapper.ReferenceNumber;
        cpt.paymentTrans.SalesGuid__c = wrapper.SalesGuid;
        cpt.paymentTrans.TenderCode__c = wrapper.TenderCode;
        cpt.paymentTrans.TermsCode__c = wrapper.TermsCode;
        cpt.paymentTrans.Third_Party_Terms_Code__c = wrapper.TermsCode;
        upsert cpt.paymentTrans;
        return cpt;
    }
    // Cart_Payment_Transaction__c record will be updated to void
    public static PaymentMethodWrapper updateTransactionVoid(PaymentMethodWrapper cpt,
                                        ConciergeFinancingAPIResponseWrapper.TransactionResponse wrapper) {
        cpt.paymentTrans.IsVoid__c = true;
        //cpt.paymentTrans.Account_Number__c = wrapper.AccountNumber;
        upsert cpt.paymentTrans;
        return cpt;
    }
 
    //Fetch payment terminal details based on IP
    public static PaymentTerminalWrapper fetchSelectedTerminal(String paymentTerminalSelected){
        List<PaymentTerminalWrapper> paytms = MultiPaymentMethodsCtrl.FetchPaymentTerminals(true);
        for( PaymentTerminalWrapper terminal: paytms){
            if(terminal.VerifoneIP == paymentTerminalSelected){
                return terminal;
            }
        }
        return null;
    }
    //parse error msg
    private static String parseErrorMsg(String responseBody) {
        String errorMsg = 'Unknown Exception';
        if(responseBody != null && responseBody != '') {
            errorMsg = responseBody;
            if(errorMsg.contains('"')) {
                errorMsg = errorMsg.replaceAll('"', '');
            }
        }
        return errorMsg;
    }
}