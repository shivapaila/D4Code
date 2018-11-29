/* *******************************************************************************************************************
* Class Name   : PaymentController
* Description  : This is lightning controller class that communicates with the lightning component PaymentModal
*				
* Author       : Sriram (Perficient, Inc.)
* Created On   : 06/04/2018
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer                                   Date                   Modification ID      Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* Sridhar									 6/8/18						1.1				Added fields while querying cart object
**************************************************************************************************************************************/
public class PaymentController {

    public static final String FINANCE_PMT_TYPE = 'Financing';
    public static final String CC_PMT_TYPE = 'Credit/Debit Card';
    public static final String CASH_PMT_TYPE = 'Cash';
    public static final String CHECK_PMT_TYPE = 'Check';
    
    public static final Set<String> VALID_PAYMENT_TYPES = new Set<String>{CC_PMT_TYPE, FINANCE_PMT_TYPE, CASH_PMT_TYPE, CHECK_PMT_TYPE};
    public static final String OPPORTUNITY_STAGE_PAYMENT = 'Payment Process Started';

   /*
   	*	Set the payment stage on the Opportunity
   	*/
	@AuraEnabled
	public static void setPaymentStageOnOpportunity(Id personAccId) {
		try {
			Opportunity opportunity = CreateSalesOrderHelper.getOpportunity(personAccId);
			if (!OPPORTUNITY_STAGE_PAYMENT.equals(opportunity.StageName)){
				opportunity.StageName = OPPORTUNITY_STAGE_PAYMENT;
				update opportunity;
			}
		} catch (Exception ex){
			System.debug(LoggingLevel.ERROR, 'Failed to set payment stage on opportunity for guest Id ' + personAccId + ' : '+ ex.getMessage());
			ErrorLogController.createLogFuture('PaymentController', 'setPaymentStageOnOpportunity', 'Failed to set payment stage on opportunity for guest Id ' + personAccId + ' : '+ ex.getMessage() + ' Stack Trace: ' + ex.getStackTraceString() );			
			throw new AuraHandledException(ex.getMessage());
		}
	}		
   /*
   	*	Get the payment methods for the Account Id
   	*	- Retrieve the opportunity
   	*	- Payment Methods are queried from the Card Payment Transaction Object for the opportunity
   	*	- An external call returns the payment terminals
   	*/
	@AuraEnabled
	public static Map<String, List<PaymentMethodWrapper>> getPaymentMethods(Id personAccId) {
		Map<String, List<PaymentMethodWrapper>> paymentMethodsByType = new Map<String, List<PaymentMethodWrapper>>();
		try {
	        Opportunity oppt = CreateSalesOrderHelper.getOpportunity(personAccId);
	        Id opportunityId = oppt.Id;			
			//Added additional fields - Sridhar
			for(Cart_Payment_Transaction__c trans : [SELECT Name, Transaction_Number__c, Payment_Type__c
													, Payment_Amount__c, isVoid__c, TenderCode__c, ReferenceNumber__c
													, SalesGuid__c,Check_DocumentNumber__c, AuthorizationNumber__c
													, Account_Number__c, TermsCode__c, VerifoneIP__c
                                                 FROM Cart_Payment_Transaction__c 
                                                 WHERE Opportunity__c =:opportunityId and isVoid__c = false]){
	            String paymentType = trans.Payment_Type__c;
	            if (VALID_PAYMENT_TYPES.contains(paymentType)){
	                PaymentMethodWrapper wrapper = new PaymentMethodWrapper();
	                wrapper.paymentTrans = trans;
	                if (trans.Payment_Type__c.equals(CC_PMT_TYPE)){
	                    wrapper.paymentTerminals=getPaymentTerminals();
	                }            
	                if (paymentMethodsByType.containsKey(paymentType)){
	                    paymentMethodsByType.get(paymentType).add(wrapper);
	                } else {
	                    paymentMethodsByType.put(paymentType, new List<PaymentMethodWrapper>{wrapper});
	                }
	            }
	        }
	        for (String paymentType : VALID_PAYMENT_TYPES){
	            if (!paymentMethodsByType.containsKey(paymentType)){
	                PaymentMethodWrapper wrapper = new PaymentMethodWrapper();
	                wrapper.paymentTrans = new Cart_Payment_Transaction__c(Payment_Type__c=paymentType);  
	                if (paymentType.equals(CC_PMT_TYPE)){
	                    wrapper.paymentTerminals=getPaymentTerminals();
	                }
	                paymentMethodsByType.put(paymentType, new List<PaymentMethodWrapper>{wrapper});                               
	            }
	        }
		} catch (Exception ex){
			System.debug(LoggingLevel.ERROR, 'Failed to retrieve Payment Methods: '+ ex.getMessage());
			ErrorLogController.createLogFuture('PaymentController', 'getPaymentMethods', 'Failed to retrieve Payment Methods: ' + ex.getMessage() +  ' Stack Trace: ' + ex.getStackTraceString() );			
			throw new AuraHandledException(ex.getMessage());
		}
		return paymentMethodsByType;
	}
    private static List<String> getPaymentTerminals() {
        PaymentTerminalWrapper ptrWrapper = API_PaymentTerminal.getPaymentTerminal();
        return (ptrWrapper != null ? new List<String>{ptrWrapper.VerifoneIP} : null);
    }
    @AuraEnabled
    public static void clearOpptyFields(Id personAccId){
        try {
	        Opportunity oppt = CreateSalesOrderHelper.getOpportunity(personAccId);
	        Id opportunityId = oppt.Id;	
	        oppt.Cart_Item_Details__c = '';
	        oppt.SalesGuid__c = '';
	        oppt.StageName = 'Saved Shopping Cart';
	        update oppt;
        } 
        catch (Exception ex){
			System.debug(LoggingLevel.ERROR, 'Failed to clear Oppotunity Fields: '+ ex.getMessage());
			ErrorLogController.createLogFuture('PaymentController', 'clearOpptyFields', 'Failed to clear Oppotunity Fields: ' + ex.getMessage() +  ' Stack Trace: ' + ex.getStackTraceString() );			
			throw new AuraHandledException(ex.getMessage());
        }
    }
}