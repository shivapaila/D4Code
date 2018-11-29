/****** v1 | Description: Multi payment controller class | 2/19/2018 | L OMeara */
public class MultiPaymentMethodsCtrl {
    public static final String FINANCE_PMT_TYPE = 'Financing';
    public static final String CC_PMT_TYPE = 'Credit/Debit Card';
    public static final String CASH_PMT_TYPE = 'Cash';
    public static final String CHECK_PMT_TYPE = 'Check';
    public static List<String> paymenTerminalIP = new List<String>();
    
    @AuraEnabled
    public static Boolean updatePayment( String pmtInfoString) 
    {
          // extract payment info 
        PaymentMethodWrapper pmtInfo = (PaymentMethodWrapper) JSON.deserialize(pmtInfoString,PaymentMethodWrapper.class);
       
        Cart_Payment_Transaction__c trans =  [SELECT Name,Transaction_Number__c,	Payment_Type__c,Payment_Amount__c 
                                              FROM Cart_Payment_Transaction__c 
                                              WHERE Id =:pmtInfo.paymentTrans.Id AND isVoid__c = false];
        
        trans.Payment_Amount__c = pmtInfo.paymentTrans.Payment_Amount__c;
        try {
            update trans;
        } catch (Exception e) {
            throw new AuraHandledException('Error update cash payments. Please contact administrator.'+ e.getMessage());
        }
        
        return true;
    }
    @AuraEnabled
    public static PaymentMethodWrapper addPayment(Id personAccId, String pmtInfoString) 
    {
        Opportunity oppt = CreateSalesOrderHelper.getOpportunity(personAccId);
        system.debug('pmtInfoString-->'+pmtInfoString);
        // extract payment info 
        PaymentMethodWrapper pmtInfo = (PaymentMethodWrapper) JSON.deserialize(pmtInfoString,PaymentMethodWrapper.class);
        
        // set opportunity value
        pmtInfo.paymentTrans.Opportunity__c = oppt.Id;
        
        // process payment by type
        system.debug('processing type ' + pmtInfo.paymentTrans.Payment_Type__c);
        if (pmtInfo.paymentTrans.Payment_Type__c==FINANCE_PMT_TYPE) {
            FinanceApiHelper fah = new FinanceApiHelper();
            pmtInfo = fah.processFinancing(pmtInfo);
            if (pmtInfo == null) {
                return pmtInfo;
            }
        } else if (pmtInfo.paymentTrans.Payment_Type__c==CC_PMT_TYPE) {
            FinanceApiHelper fah = new FinanceApiHelper();
            pmtInfo = fah.processCreditcard(pmtInfo,personAccId,oppt, false);
            FetchPaymentTerminals(false);
            pmtInfo.paymentTerminals = paymenTerminalIP;
            if (pmtInfo == null) {
                return pmtInfo;
            } 
        } else if (pmtInfo.paymentTrans.Payment_Type__c==CASH_PMT_TYPE) { 
            // if cash, just set a transaction number
            pmtInfo.paymentTrans.Transaction_Number__c = 'cash';
        } else if (pmtInfo.paymentTrans.Payment_Type__c==CHECK_PMT_TYPE) { 
            pmtInfo.paymentTrans.Transaction_Number__c = 'check';
        }
         else {
            throw new AuraHandledException('Unrecognized payment type.');
        }

        // record the payment
        try {
            insert pmtInfo.paymentTrans;
        } catch (Exception e) {
            throw new AuraHandledException('Error saving payments. Please contact administrator.'+ e.getMessage());
        }
		
        return pmtInfo;
    }

    @AuraEnabled
    public static FinanceTermsWrapper[] getPaymentTerms(String pmtInfoStr){
        PaymentMethodWrapper pmtInfo = (PaymentMethodWrapper)JSON.deserialize(pmtInfoStr, PaymentMethodWrapper.class);
        FinanceApiHelper fah = new FinanceApiHelper();
        FinanceTermsWrapper[] result = fah.getTerms(pmtInfo);
        return result;
    }
    
    
    @AuraEnabled
    public static Map<String,Payment_Type__c> getPaymentOptions(){
        Map<String,Payment_Type__c> paymentOptions = PaymentTypeHelper.getPaymentTypeMapping();
        return paymentOptions;
    }
    
    @AuraEnabled
    public static List<PaymentTerminalWrapper> FetchPaymentTerminals(boolean isfetchWrapper){
        PaymentTerminalWrapper ptrWrapper = API_PaymentTerminal.getPaymentTerminal();
        // To be changed when more IP's are available
        /*for( PaymentTerminalWrapper terminal: paytms){
            paymenTerminalIP.add(terminal.VerifoneIP);
        }*/
        paymenTerminalIP.add(ptrWrapper.VerifoneIP);
        return new List<PaymentTerminalWrapper>{ptrWrapper};
    }
}