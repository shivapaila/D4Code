/****** v1 | Description: Shared methods used by different Payment components | 6/25/2018 | Sorna */

public class ConciergePaymentHelper {
	// get the current balance due amount to pass it on to transaction input requests
	public static Decimal getCurrentBalanceDue(Id opportunityId, Decimal targetAmount) {
		Decimal balanceDue = 0;
		Decimal amountPaid = 0;
		for(Cart_Payment_Transaction__c trans : [SELECT Payment_Amount__c
                                                 FROM Cart_Payment_Transaction__c 
                                                 WHERE Opportunity__c =:opportunityId and isVoid__c = false]) {
			if(trans.Payment_Amount__c != null) {
				amountPaid += trans.Payment_Amount__c;
			}
		}
		if(targetAmount != null) {
			balanceDue = targetAmount - amountPaid;
		}
		return balanceDue;
	}
}