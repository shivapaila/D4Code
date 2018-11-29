/****** v1 | Description: Methods financing api controller class | 2/9/2018 | L OMeara */
public class FinanceApiHelper {
    public static final String PAYMENT_API_SETTING_NAME = 'PaymentAPI';
    public static final String FINANCE_TERMS_API_SETTING_NAME = 'FinanceTerms';
    public static final String FINANCE_TERMS_INFO_SETTINGS_NAME = 'FinanceTermsInfo';

	public Integration_Settings__c finConf = null;
    public class FinanceApiException extends Exception {}
    
    public FinanceApiHelper(){
        this.finConf= Integration_Settings__c.getValues(PAYMENT_API_SETTING_NAME);
        if(this.finConf==null){
            throw new FinanceApiException('Finance config missing: Custom Setting > Integration Setting' + PAYMENT_API_SETTING_NAME);
        }
    }
    
    public PaymentMethodWrapper processCreditcard(PaymentMethodWrapper pmt, Id personAccId, Opportunity oppt, boolean isVoid) {
        
        system.debug('PaymentMethodWrapper-->'+pmt);
        List<Shopping_cart_line_item__c> lineItems = CreateSalesOrderHelper.getShoppingCartLineItems(oppt.Id);
        System.debug('lineItems:'+lineItems);
        ShoppingCartDeliveryWrapper billToAddress= CreateSalesOrderHelper.getAddress( personAccId, oppt.Bill_To_Address__c, '', '', '', '');
        ShoppingCartDeliveryWrapper shipToAddress= CreateSalesOrderHelper.getAddress( personAccId, oppt.ShipTo_Address__c, '', '', '', '');
        if(billToAddress==null || shipToAddress==null){
              throw new AuraHandledException('please set shipTo and billTo Address');
        }
        if(lineItems.size() >0){
            ShoppingCartItemDetailsAPIHelper ItemAPI = new ShoppingCartItemDetailsAPIHelper();
            String sourceURL = ItemAPI.getAPIEndpoint();
            String rawData = ItemAPI.prepareCheckOutItemsRawPost(lineItems,personAccId,shipToAddress);
            String resJSON = ItemAPI.connectAPIPostJSON(sourceURL, rawData);
            System.debug('resJSON from ItemAPI---->'+resJSON);
            
            Map<String, Object>  objMap = new Map<String, Object>();
            try{
                objMap =(Map<String, Object> ) JSON.deserializeUntyped(resJSON);
            }catch(Exception ex){
                  throw new AuraHandledException('Get Error when calling Tax API, please check the response for reason:'
                                                 +resJSON);
            }
            system.debug('CartGuid-->'+objMap.get('CartGuid'));

            Map<String, Payment_Type__c> paymentTypeMapping = PaymentTypeHelper.getPaymentTypeMapping();
            if(paymentTypeMapping.isEmpty()){
                throw new AuraHandledException('Something wrong in System.');
            }
            
            API_PaymentType.PaymentTypeWrapper ptwUsed = new API_PaymentType.PaymentTypeWrapper();
            List<API_PaymentType.PaymentTypeWrapper> ptWrap = API_PaymentType.getAllPaymentTypes();
            system.debug('ptWrap-->'+ptWrap);
            for(API_PaymentType.PaymentTypeWrapper ptw : ptWrap){
                if(ptw.TenderCode ==pmt.paymentTrans.TenderCode__c){
                    ptwUsed = ptw;
                    break;
                }
            }
            system.debug('ptwUsed-->'+ptwUsed);
            system.debug('pmt.paymentTrans.TenderCode__c-->'+pmt.paymentTrans.TenderCode__c);
            List<API_PaymentType.PaymentTermWrapper> ptermWrap = API_PaymentType.getPaymentTerm(pmt.paymentTrans.TenderCode__c);
            system.debug('ptermWrap-->'+ptermWrap);

            List<PaymentTerminalWrapper> paytms = MultiPaymentMethodsCtrl.FetchPaymentTerminals(true);
            StoreInfoWrapper storeInfo = CreateSalesOrderHelper.getStoreInfo();
            CCPaymentRequestWrapper ccReqWrapper = new CCPaymentRequestWrapper();
            ccReqWrapper.SalesGuid = String.isEmpty(oppt.SalesGuid__c) ?(String)objMap.get('CartGuid') : oppt.SalesGuid__c;
            ccReqWrapper.IPAddress = paytms[0].VerifoneIP;
            ccReqWrapper.OPOSPrinterName = paytms[0].ReceiptPrinter;
            ccReqWrapper.Port = 9092;   
            ccReqWrapper.DeliveryFee = (Decimal)objMap.get('TotalDeliveryAmount');
            ccReqWrapper.SubTotal = (Decimal)objMap.get('TotalCost');
            ccReqWrapper.Tax = (Decimal)objMap.get('TotalTaxAmount');
            ccReqWrapper.SaleTotal = (Decimal)objMap.get('SalesGrandTotal');
            ccReqWrapper.TransactionAmount = pmt.paymentTrans.Payment_Amount__c;
            ccReqWrapper.BalanceDue = ccReqWrapper.SaleTotal - ccReqWrapper.TransactionAmount;
            Decimal  discountAmt = (Decimal)objMap.get('TotalDiscountAmount');
            ccReqWrapper.IsDiscountApplied = (discountAmt > 0)? true: false;
            ccReqWrapper.YouSavePercentage = (Decimal)objMap.get('YouSaveDiscountPercent');
            ccReqWrapper.YouSaveAmount = (Decimal)objMap.get('YouSaveDiscountAmount');
            ccReqWrapper.ProfitCenter = (String)storeInfo.profitCtr;
            ccReqWrapper.TenderCode = pmt.paymentTrans.TenderCode__c;
            ccReqWrapper.TenderCodeDescription = ptwUsed.TenderCodeDescription;
            ccReqWrapper.TermsCode = ptermWrap[0].TermsCode;
            ccReqWrapper.DocumentNumber = Integer.valueOf(ptwUsed.DocumentNumber);
            ccReqWrapper.CustomerId = (String)objMap.get('CustomerId');
            ccReqWrapper.ShipTo = shipToAddress;
            ccReqWrapper.BillTo = billToAddress;
            if(!isVoid){
                CCPaymentResponseWrapper CCResponse = API_CCPayment.makeCCPayment(ccReqWrapper);
                system.debug('CC response-->'+JSON.serialize(CCResponse));
                if(CCResponse !=null){
                        if(CCResponse.Status == 'COMPLETE' && CCResponse.PaymentReceived){
                            pmt.paymentAPIStatus='success';
                            pmt.paymentTrans.Transaction_Number__c = CCResponse.AuthorizationNumber;
                            pmt.paymentTrans.ReferenceNumber__c  = CCResponse.ReferenceNumber;
                            pmt.paymentTrans.TermsCode__c = ccReqWrapper.TermsCode;
                            pmt.paymentTrans.SalesGuid__c = CCResponse.SalesGuid;
                            pmt.paymentTrans.Account_Number__c = CCResponse.AccountNumber;
                            pmt.paymentTrans.Check_DocumentNumber__c = CCResponse.DocumentNumber;
                            pmt.paymentTrans.AuthorizationNumber__c = CCResponse.AuthorizationNumber;
                            if(String.isEmpty(oppt.SalesGuid__c)){
                                oppt.SalesGuid__c = CCResponse.SalesGuid;
                                update oppt;
                            }
                        }
                        else if( CCResponse.Status ==  '*SLR Busy.'){
                            pmt.paymentAPIStatus='Terminal could not be reached as it is busy';
                            pmt.paymentTrans.isvoid__c = true;
                        //}else if( CCResponse.PaymentReceived == null || !CCResponse.PaymentReceived){
                        //    pmt.paymentAPIStatus='Credit/Debit Card Payment Declined';
                        }
                        
                        else{
                            List<CCSalesLookupResponseWrapper> checkVoids = API_CCPayment.checkOrphanPayment(ccReqWrapper);
                            //List<Cart_Payment_Transaction__c> lstValidCarts = [SELECT id,ReferenceNumber__c,isvoid__c FROM Cart_Payment_Transaction__c 
                            //                                                    WHERE Opportunity__c =:oppt.Id];
                            List<String> lstrefNos = new List<String>();
                            for(Cart_Payment_Transaction__c cart :[SELECT id,ReferenceNumber__c,isvoid__c, Payment_Type__c FROM Cart_Payment_Transaction__c 
                                                                                WHERE Opportunity__c =:oppt.Id AND isvoid__c =true
                                                                                AND Payment_Type__c =:MultiPaymentMethodsCtrl.CC_PMT_TYPE]){
                                if(String.isNotBlank(cart.ReferenceNumber__c)){
                                    lstrefNos.add(cart.ReferenceNumber__c);    
                                }
                            }
                            pmt.paymentAPIStatus= CCResponse.Status;
                            pmt.paymentTrans.isvoid__c = true;
                            System.debug('checkVoids--->'+checkVoids);
                            for( CCSalesLookupResponseWrapper resWrapper :checkVoids){
                                if( !lstrefNos.contains(resWrapper.ReferenceNumber)){
                                    CCVoidPaymentRequestWrapper ccvoidReqWrapper = new CCVoidPaymentRequestWrapper();
                                    ccvoidReqWrapper = copyContent(ccReqWrapper, ccvoidReqWrapper);
                                    ccvoidReqWrapper.IsVoid = true;
                                    ccvoidReqWrapper.Reference = resWrapper.ReferenceNumber;
                                    ccvoidReqWrapper.SalesGuid = ccReqWrapper.SalesGuid;
                                    CCVoidPaymentResponseWrapper CCVoidResponse = API_CCPayment.voidCCPayment(ccvoidReqWrapper);
                                }
                            }
                        }
                    return pmt;
                }else{
                    throw new FinanceApiException('API call failed' );
                }
            }else{
                CCVoidPaymentRequestWrapper ccvoidReqWrapper = new CCVoidPaymentRequestWrapper();
                ccvoidReqWrapper = copyContent(ccReqWrapper, ccvoidReqWrapper);
                ccvoidReqWrapper.IsVoid = true;
                ccvoidReqWrapper.Reference = pmt.paymentTrans.ReferenceNumber__c;
                ccvoidReqWrapper.SalesGuid = pmt.paymentTrans.SalesGuid__c;
                CCVoidPaymentResponseWrapper CCResponse = API_CCPayment.voidCCPayment(ccvoidReqWrapper);
                system.debug('CC response-->'+JSON.serialize(CCResponse));
                if(CCResponse !=null){
                    pmt.paymentTrans.isvoid__c = true;
                    return pmt;
                }else{
                    throw new FinanceApiException('API call failed' );
                }
            }
        }
        return null;
    }

    private  CCVoidPaymentRequestWrapper copyContent(CCPaymentRequestWrapper ccReqWrapper,
                                                    CCVoidPaymentRequestWrapper ccvoidReqWrapper){
        ccvoidReqWrapper.SalesGuid = ccReqWrapper.SalesGuid;
		ccvoidReqWrapper.IPAddress = ccReqWrapper.IPAddress;
		ccvoidReqWrapper.OPOSPrinterName = ccReqWrapper.OPOSPrinterName;
		ccvoidReqWrapper.Port = ccReqWrapper.Port;
		ccvoidReqWrapper.DeliveryFee = ccReqWrapper.DeliveryFee;
		ccvoidReqWrapper.SubTotal = ccReqWrapper.SubTotal;
		ccvoidReqWrapper.Tax = ccReqWrapper.Tax;
		ccvoidReqWrapper.TransactionAmount = ccReqWrapper.TransactionAmount;
		ccvoidReqWrapper.BalanceDue = ccReqWrapper.BalanceDue;
		ccvoidReqWrapper.IsDiscountApplied = ccReqWrapper.IsDiscountApplied;
		ccvoidReqWrapper.YouSavePercentage = ccReqWrapper.YouSavePercentage;
		ccvoidReqWrapper.YouSaveAmount = ccReqWrapper.YouSaveAmount;
		ccvoidReqWrapper.ProfitCenter = ccReqWrapper.ProfitCenter;
		ccvoidReqWrapper.TenderCode = ccReqWrapper.TenderCode;
		ccvoidReqWrapper.TermsCode = ccReqWrapper.TermsCode;
        ccvoidReqWrapper.TenderCodeDescription = ccReqWrapper.TenderCodeDescription;
		ccvoidReqWrapper.DocumentNumber = ccReqWrapper.DocumentNumber;
		ccvoidReqWrapper.CustomerId = ccReqWrapper.CustomerId;
		ccvoidReqWrapper.ShipTo = ccReqWrapper.ShipTo;
		ccvoidReqWrapper.BillTo = ccReqWrapper.BillTo;
        ccvoidReqWrapper.SaleTotal = ccReqWrapper.SaleTotal;
        return ccvoidReqWrapper;
    }

    public List<FinanceTermsWrapper> getTerms(PaymentMethodWrapper pmt) {
        try {
            // run terms api
            String saltStr = Finance_Terms_Info__c.getInstance(FINANCE_TERMS_INFO_SETTINGS_NAME).Salt__c;
            String keyStr = Finance_Terms_Info__c.getInstance(FINANCE_TERMS_INFO_SETTINGS_NAME).Key__c;
            Blob cryptoKey = Blob.valueOf(keyStr);
            Blob cryptoSalt = Blob.valueOf(saltStr);
            Blob data = Blob.valueOf(pmt.FINnum);
            system.debug('=====> ' + pmt.FINnum);
            Blob encryptedData = Crypto.encrypt('AES256', cryptoKey, cryptoSalt, data);
            String encryptedNum = EncodingUtil.base64Encode(encryptedData);

            // Replacement logic as url encoding will not work with Ashley side
            if(encryptedNum.endsWith('=')){
                encryptedNum = encryptedNum.substring(0,encryptedNum.length()-1);
            }
            if(encryptedNum.contains('+')) {
                encryptedNum = encryptedNum.replaceAll('\\+', '-');
            }
            if(encryptedNum.contains('/')) {
                encryptedNum = encryptedNum.replaceAll('/', '_');
            }
            
            // create string for endpoint
            String endpointAmt = pmt.paymentTrans.Payment_Amount__c.toPlainString();
            
            // build endpoint
            // NOTE - should have used the value from the constructor - ljo
            Integration_Settings__c endPointInfo = Integration_Settings__c.getInstance(FINANCE_TERMS_API_SETTING_NAME);
            String endpointBase = endPointInfo.End_Point_URL__c;
            String endpoint = endpointBase + encryptedNum + '-' + endpointAmt + '-USD';
            
            HttpResponse res = doCallout(endpoint, endPointInfo.API_Key__c, 'GET', null);
            if(res.getStatusCode() == 200){
                String result = res.getBody();
                system.debug('=====> ' + result);
            	return (List<FinanceTermsWrapper>)JSON.deserialize(result, List<FinanceTermsWrapper>.class);             
            }
	        throw new FinanceApiException(res.getStatusCode() + ' - ' + res.getBody());
        } catch(Exception ex) {
            throw new AuraHandledException('Failure to get terms ' + ex.getMessage());
        }
    }
    
    //FIXME - is this needed for credit card? 
    public String getCCTerms(PaymentMethodWrapper pmt) {
        //https://ashley-preprod-sandbox.apigee.net/homestores/8888300-164/payment-type
        //https://ashley-preprod-sandbox.apigee.net/homestores/8888300-165/payment-terms?tenderCode
        return null;
    }

    public PaymentMethodWrapper processFinancing(PaymentMethodWrapper pmt) {
        // process financing 
        String rawPost = '{'+
            '"InitiatingTransactionId" : "1234", ' + 
            '"Amount" : "'+pmt.paymentTrans.Payment_Amount__c+'", ' + 
            '"AccountNumber" : "'+pmt.FINnum+'", ' + 
            '"FinancingOptionCode" : "' + pmt.FINterms + '"' + 
            '}';
        system.debug('----> ' + rawPost);
        HttpResponse res = doCallout(this.finConf.End_Point_URL__c, this.finConf.API_Key__c, 'POST', rawPost);
        system.debug('=====> ' + res.getBody());
        if(res.getStatusCode() == 200){
            String result = res.getBody();
            PaymentResponse transactionResult = (PaymentResponse)JSON.deserialize(result, PaymentResponse.class);
            if (transactionResult.authorizationId != null) {
                pmt.paymentTrans.Transaction_Number__c = transactionResult.authorizationId;
                pmt.paymentTrans.ReferenceNumber__c  = transactionResult.referenceNumber;
                pmt.paymentTrans.TermsCode__c = pmt.FINterms;
                // finance API defect fix
                pmt.paymentTrans.Third_Party_Terms_Code__c = pmt.FINThirdPartyTerms;
            }
            return pmt;
        }
        throw new FinanceApiException('Finance authorization failure ' + res.getStatusCode() + ' - ' + res.getBody());
	}
    
    private HttpResponse doCallout(String endpoint, String key, String method, String rawPost) {
        try{
            Http h = new Http();
            HttpRequest req = new HttpRequest();
            req.setHeader('Content-Type','application/json');
            req.setHeader('Accept', 'application/json');
            req.setHeader('Connection','close');
            if (key != null) {
                req.setHeader('apiKey',key);
            }
            req.setEndpoint(endpoint);
            req.setMethod(method);
            if (method == 'POST') {
	            req.setBody(rawPost);            
            }
            req.setTimeout(120000); // max out the timeout
            return h.send(req);
        } catch(Exception ex) {
            throw new FinanceApiException('Finance authorization failure' + ex.getMessage());
        }        
    }

    public class PaymentResponse {
        public String authorizationId {get;set;}
        public String referenceNumber {get;set;}
    }  
}