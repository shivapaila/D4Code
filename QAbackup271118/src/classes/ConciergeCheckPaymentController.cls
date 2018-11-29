/****** v1 | Description: Check payment controller class | 6/8/2018 | Sridhar */
public class ConciergeCheckPaymentController {
    
    //Process payment call
    @AuraEnabled
    public static PaymentMethodWrapper addPayment(Id personAccId, String pmtInfoString) 
    {
        Opportunity oppt = CreateSalesOrderHelper.getOpportunity(personAccId);
        system.debug('pmtInfoString-->'+pmtInfoString);
        PaymentMethodWrapper pmtInfo = (PaymentMethodWrapper) JSON.deserialize(pmtInfoString,PaymentMethodWrapper.class);
        
        pmtInfo.paymentTrans.Opportunity__c = oppt.Id;
        pmtInfo.paymentTrans.ReferenceNumber__c ='Check';
        pmtInfo.paymentTrans.Transaction_Number__c ='Check';
        pmtInfo.paymentTrans.TenderCode__c='CHK';
        // Logic to populate TermsCode__c
        List<API_PaymentType.PaymentTermWrapper> ptWrap = API_PaymentType.getPaymentTerm(pmtInfo.paymentTrans.TenderCode__c);
        if(ptWrap ==null || ptWrap.size() ==0){
            throw new AuraHandledException('Unable to find Payment Term for ' + pmtInfo.paymentTrans.TenderCode__c);
        }
        API_PaymentType.PaymentTermWrapper payTerm = ptWrap[0];
        pmtInfo.paymentTrans.TermsCode__c = payTerm.TermsCode;
        try {
            insert pmtInfo.paymentTrans;
        } catch (Exception e) {
            throw new AuraHandledException( 'Error in processing check payments. Please contact a system administrator with the following message' + e.getMessage());
        }
        return pmtInfo;
    }
    
    //Void payment call
    @AuraEnabled
    public static boolean removePayment(Id personAccId, String pmtInfoString) 
    {
        PaymentMethodWrapper pmtInfo = (PaymentMethodWrapper) JSON.deserialize(pmtInfoString,PaymentMethodWrapper.class);
        pmtInfo.paymentTrans.isvoid__c = true;
        try {
            update pmtInfo.paymentTrans;
        } catch (Exception e) {
            throw new AuraHandledException('Error in canceling the check payment. Please contact system administrator with the following error message ' + e.getMessage());
        } 
        return true;
    }
}