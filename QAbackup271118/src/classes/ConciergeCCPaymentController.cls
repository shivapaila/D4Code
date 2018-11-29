/****** v1 | Description: Credit card payment controller class | 6/8/2018 | Sridhar */
public class ConciergeCCPaymentController {
	public static final String PAYMENT_API_SETTING_NAME = 'PaymentAPI';
	public static final Integer port = Integer.valueOf(System.label.ConciergeCCPaymentPort);
	public static final String CC_PMT_TYPE = 'Credit/Debit Card';
	public static List<String> paymenTerminalIP = new List<String>();
	public class ApiException extends Exception {}

    //Process payment call
	@AuraEnabled
    public static PaymentMethodWrapper addPayment(Id personAccId, String pmtInfoString) 
    {
       ConciergePaymentItemDetailsHelper.ItemDetailsWrapper itemDetailWrapper =  ConciergePaymentItemDetailsHelper.getItemDetails( personAccId,false); 
       // Opportunity oppt = CreateSalesOrderHelper.getOpportunity(personAccId);
        // extract payment info 
        PaymentMethodWrapper pmtInfo = (PaymentMethodWrapper) JSON.deserialize(pmtInfoString,PaymentMethodWrapper.class);
        // set opportunity value
        pmtInfo.paymentTrans.Opportunity__c = itemDetailWrapper.oppt.Id;
        // process payment by type
		if (pmtInfo.paymentTrans.Payment_Type__c==CC_PMT_TYPE) {
            pmtInfo = processCreditcard(pmtInfo,personAccId,itemDetailWrapper, false);
            //pmtInfo.paymentTerminals = paymenTerminalIP;
            if (pmtInfo == null) {
                return pmtInfo;
            } 
        }
		// record the payment
        try {
            insert pmtInfo.paymentTrans;
        } catch (Exception e) {
            throw new AuraHandledException('Error saving payments. Please contact administrator.'+ e.getMessage());
        }
		
        return pmtInfo;
    }

    //Process Make payment and void payment calls
	public static PaymentMethodWrapper processCreditcard(PaymentMethodWrapper pmt, Id personAccId, ConciergePaymentItemDetailsHelper.ItemDetailsWrapper itemDetailWrapper, boolean isVoid) {

        //Fetching lineItems        
     //   List<Shopping_cart_line_item__c> lineItems = CreateSalesOrderHelper.getShoppingCartLineItems(oppt.Id);
        //Fetching addresses  
      //  ShoppingCartDeliveryWrapper billToAddress= CreateSalesOrderHelper.getAddress( personAccId, oppt.Bill_To_Address__c, '', '', '', '');
     //   ShoppingCartDeliveryWrapper shipToAddress= CreateSalesOrderHelper.getAddress( personAccId, oppt.ShipTo_Address__c, '', '', '', '');
      //  if(billToAddress==null || shipToAddress==null){
       //       throw new AuraHandledException('please set shipTo and billTo Address');
       // }
      //  if(lineItems.size() >0){
           // Map<String, Object>  objMap = new Map<String, Object>();
            //itemDetails API call to get GUID if not already present
          /*  if(String.isEmpty(oppt.SalesGuid__c)){
                ShoppingCartItemDetailsAPIHelper ItemAPI = new ShoppingCartItemDetailsAPIHelper();
                String sourceURL = ItemAPI.getAPIEndpoint();
                String rawData = ItemAPI.prepareCheckOutItemsRawPost(lineItems,personAccId,shipToAddress);
                String resJSON = ItemAPI.connectAPIPostJSON(sourceURL, rawData);
                try{
                    objMap =(Map<String, Object> ) JSON.deserializeUntyped(resJSON);
                }catch(Exception ex){
                      throw new AuraHandledException('Get Error when calling Tax API, please check the response for reason:'
                                                     +resJSON);
                }
            }*/
        	Opportunity oppt = itemDetailWrapper.oppt; 
			Map<String, Object>  objMap = itemDetailWrapper.objectMap;           
            //Fetching fields for payment details population
            Map<String, Payment_Type__c> paymentTypeMapping = PaymentTypeHelper.getPaymentTypeMapping();
            if(paymentTypeMapping.isEmpty()){
                throw new AuraHandledException('Error in retrieving Payment Types. Please contact a system administrator');
            }
            
            API_PaymentType.PaymentTypeWrapper ptwUsed = new API_PaymentType.PaymentTypeWrapper();
            List<API_PaymentType.PaymentTypeWrapper> ptWrap = API_PaymentType.getAllPaymentTypes();
            for(API_PaymentType.PaymentTypeWrapper ptw : ptWrap){
                if(ptw.TenderCode ==pmt.paymentTrans.TenderCode__c){
                    ptwUsed = ptw;
                    break;
                }
            }
            List<API_PaymentType.PaymentTermWrapper> ptermWrap = API_PaymentType.getPaymentTerm(pmt.paymentTrans.TenderCode__c);
            
            //fetching payment terminal info
            PaymentTerminalWrapper paytm = fetchSelectedTerminal(pmt.paymentTerminalSelected);
            
            //fetching store info
            StoreInfoWrapper storeInfo = CreateSalesOrderHelper.getStoreInfo();
             User loggedinuserdetails = [select Id, username,RSA_ID__c,LegacyStoreID__c from User where Id = :UserInfo.getUserId()];
            //Populating wrapper data
            CCPaymentRequestWrapper ccReqWrapper = new CCPaymentRequestWrapper();
            ccReqWrapper.SalesGuid = String.isEmpty(oppt.SalesGuid__c) ?(String)objMap.get('CartGuid') : oppt.SalesGuid__c;
            ccReqWrapper.IPAddress = paytm.VerifoneIP;
            ccReqWrapper.OPOSPrinterName = paytm.ReceiptPrinter;
            ccReqWrapper.Port = port;   
            ccReqWrapper.DeliveryFee = (Decimal)objMap.get('TotalDeliveryAmount');
            ccReqWrapper.SubTotal = (Decimal)objMap.get('TotalCost');
            ccReqWrapper.Tax = (Decimal)objMap.get('TotalTaxAmount');
            ccReqWrapper.SaleTotal = (Decimal)objMap.get('SalesGrandTotal');
            ccReqWrapper.TransactionAmount = pmt.paymentTrans.Payment_Amount__c;
            // Fix for Balance Due
            //ccReqWrapper.BalanceDue = ccReqWrapper.SaleTotal - ccReqWrapper.TransactionAmount;
            ccReqWrapper.BalanceDue = ConciergePaymentHelper.getCurrentBalanceDue(oppt.Id, ccReqWrapper.SaleTotal);
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
            ccReqWrapper.ShipTo = itemDetailWrapper.shipToAddress;
            ccReqWrapper.BillTo = itemDetailWrapper.billToAddress;
        	ccReqWrapper.sfGuestId = personAccId;
        	ccReqWrapper.storeid = loggedinuserdetails.LegacyStoreID__c;
        	ccReqWrapper.RSAId = loggedinuserdetails.RSA_ID__c;
            if(!isVoid){
                //Payment transaction
                CCPaymentResponseWrapper CCResponse = API_CCPayment.makeCCPayment(ccReqWrapper);
                if(CCResponse !=null){
                        if(CCResponse.Status == 'COMPLETE' && CCResponse.PaymentReceived){
                            //Saving data from API response
                            pmt.paymentAPIStatus='success';
                            pmt.paymentTrans.Transaction_Number__c = CCResponse.AuthorizationNumber;
                            pmt.paymentTrans.ReferenceNumber__c  = CCResponse.ReferenceNumber;
                            pmt.paymentTrans.TermsCode__c = ccReqWrapper.TermsCode;
                            pmt.paymentTrans.SalesGuid__c = CCResponse.SalesGuid;
                            pmt.paymentTrans.Account_Number__c = CCResponse.AccountNumber;
                            pmt.paymentTrans.Check_DocumentNumber__c = CCResponse.DocumentNumber;
                            pmt.paymentTrans.AuthorizationNumber__c = CCResponse.AuthorizationNumber;
                            pmt.paymentTrans.VerifoneIP__c = paytm.VerifoneIP;
                            // Credit Card Partial payment fix
                            pmt.paymentTrans.Payment_Amount__c = CCResponse.Amount;
                      /*      if(String.isEmpty(oppt.SalesGuid__c)){
                                oppt.SalesGuid__c = CCResponse.SalesGuid;
                                update oppt;
                            }*/
                        }
                        else if( CCResponse.Status ==  '*SLR Busy.'){
                            //When terminal busy just display message. No need to check for void payment
                            //Transaction can automatically be voided while saving
                            pmt.paymentAPIStatus='Terminal could not be reached as it is busy';
                            pmt.paymentTrans.isvoid__c = true;
                        }
                        
                        else{
                            //Payment api call to fetch all successful transactions
                            List<CCSalesLookupResponseWrapper> checkVoids = API_CCPayment.checkOrphanPayment(ccReqWrapper);
                            List<String> lstrefNos = new List<String>();

                            //Fetch all valid payments
                            for(Cart_Payment_Transaction__c cart :[SELECT id,ReferenceNumber__c,isvoid__c, Payment_Type__c FROM Cart_Payment_Transaction__c 
                                                                                WHERE Opportunity__c =:oppt.Id AND isvoid__c =false
                                                                                AND Payment_Type__c =:MultiPaymentMethodsCtrl.CC_PMT_TYPE]){
                                if(String.isNotBlank(cart.ReferenceNumber__c)){
                                    lstrefNos.add(cart.ReferenceNumber__c);    
                                }
                            }
                            pmt.paymentAPIStatus= CCResponse.Status;
                            pmt.paymentTrans.isvoid__c = true;
                            //Void all transactions which are not already successful
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
                    throw new ApiException('API call failed' );
                }
            }else{
                //Void Payment transaction
                CCVoidPaymentRequestWrapper ccvoidReqWrapper = new CCVoidPaymentRequestWrapper();
                ccvoidReqWrapper = copyContent(ccReqWrapper, ccvoidReqWrapper);
                ccvoidReqWrapper.IsVoid = true;
                ccvoidReqWrapper.Reference = pmt.paymentTrans.ReferenceNumber__c;
                ccvoidReqWrapper.SalesGuid = pmt.paymentTrans.SalesGuid__c;
                ccvoidReqWrapper.sfGuestId = ccReqWrapper.sfGuestId ;
                ccvoidReqWrapper.storeid = ccReqWrapper.storeid;
                ccvoidReqWrapper.RSAId = ccReqWrapper.RSAId;
                
                CCVoidPaymentResponseWrapper CCResponse = API_CCPayment.voidCCPayment(ccvoidReqWrapper);
                if(CCResponse !=null){
                    pmt.paymentTrans.isvoid__c = true;
                    return pmt;
                }else{
                    throw new ApiException('API call failed' );
                }
            }
       // }
      //  return null;
    }

    //Copy request wrapper data to response wrapper
    private  static CCVoidPaymentRequestWrapper copyContent(CCPaymentRequestWrapper ccReqWrapper,
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

    //Fetch payment terminal details based on IP
    public static PaymentTerminalWrapper fetchSelectedTerminal(String paymentTerminalSelected){
    	List<PaymentTerminalWrapper> paytms = MultiPaymentMethodsCtrl.FetchPaymentTerminals(true);
    	for( PaymentTerminalWrapper terminal: paytms){
    		paymenTerminalIP.add(terminal.VerifoneIP);
    	}
    	for( PaymentTerminalWrapper terminal: paytms){
    		if(terminal.VerifoneIP == paymentTerminalSelected){
    			return terminal;
    		}
    	}
    	return null;
    }

    //Void payment call
    @AuraEnabled
    public static boolean removePayment(Id personAccId, String pmtInfoString) 
    {
       // Opportunity oppt = CreateSalesOrderHelper.getOpportunity(personAccId);
        ConciergePaymentItemDetailsHelper.ItemDetailsWrapper itemDetailsWrapper = ConciergePaymentItemDetailsHelper.getItemDetails(personAccId,false);
        PaymentMethodWrapper pmtInfo = (PaymentMethodWrapper) JSON.deserialize(pmtInfoString,PaymentMethodWrapper.class);
        pmtInfo.paymentTerminalSelected = pmtInfo.paymentTrans.VerifoneIP__c;
        pmtInfo = processCreditcard(pmtInfo,personAccId,itemDetailsWrapper, true);
        if (pmtInfo == null) {
            return false;
        }
        // record the payment
        try {
            update pmtInfo.paymentTrans;
        } catch (Exception e) {
            throw new AuraHandledException('Error voiding payments. Please contact administrator.'+ e.getMessage());
        } 
        return true;
    }
}