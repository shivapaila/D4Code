public class PaymentsWrapper {
	@AuraEnabled
    public List<PaymentDistributionWrapper> Distributions{get;set;}
    @AuraEnabled
    public Date PaymentDate{get;set;}
}