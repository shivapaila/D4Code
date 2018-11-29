public class ConciergeFinancingAPIResponseWrapper 
{
	public class GenesysAccountLookupResponse {
		public String AccountNumber {get;set;}
		public Decimal AccountBalance {get;set;}
		public String AccountStatus {get;set;}
		public String Address {get;set;}
		public String Address2 {get;set;}
		public Decimal AvailableCredit {get;set;}
		public Decimal CreditLine {get;set;}
		public Datetime DueDate {get;set;}
		public String ExpirationMonth {get;set;}
		public String ExpirationYear {get;set;}
		public String FirstName {get;set;}
		public String LastName {get;set;}
		public String PhoneNumber {get;set;}
		public String PoliticalDivision1 {get;set;}
		public String PoliticalDivision2 {get;set;}
		public String CountryCode {get;set;}
		public String PostalCode {get;set;}
		public String PromoCode {get;set;}
		public String PromotionDescription {get;set;}
        public String AuthorizationNumber {get;set;}
		public Decimal TotalAmountDue {get;set;}
	}

	public class SynchronyAccountLookupResponse {
		public String accountNumber {get;set;}
		public String address1 {get;set;}
		public String address2 {get;set;}
		public String city {get;set;}
		public Decimal creditLimit {get;set;}
		public Decimal currentBalance {get;set;}
		public String expirationMonth {get;set;}
		public String expirationYear {get;set;}
		public Decimal openToBuy {get;set;}
		public String state {get;set;}
		public String zipCode {get;set;}
		public String firstName {get;set;}
		public String lastName {get;set;}
        public String AuthorizationNumber {get;set;}
	}

	public class UIAccountLookupResponse {
		@AuraEnabled public String AccountNumber {get;set;}
		@AuraEnabled public String Name {get;set;}
		@AuraEnabled public String Address {get;set;}
		@AuraEnabled public String City {get;set;}
		@AuraEnabled public String State {get;set;}
		@AuraEnabled public String PostalCode {get;set;}
		@AuraEnabled public Decimal TotalCredit {get;set;}
		@AuraEnabled public Decimal AvailableCredit {get;set;}

		public UIAccountLookupResponse(GenesysAccountLookupResponse response) {
			AccountNumber = response.accountNumber != null ? response.accountNumber.right(4) : '';
			Name = response.FirstName + ' ' + response.LastName;
			Address = response.Address;
			City = response.PoliticalDivision1;
			State = response.PoliticalDivision2;
			PostalCode = response.PostalCode;
			TotalCredit = response.CreditLine;
			AvailableCredit = response.AvailableCredit;
		}

		public UIAccountLookupResponse(SynchronyAccountLookupResponse response) {
			AccountNumber = response.AccountNumber != null ? response.AccountNumber.right(4) : '';
			Name = response.firstName + ' ' + response.lastName;
			Address = response.address1;
			City = response.city;
			State = response.state;
			PostalCode = response.zipCode;
			TotalCredit = response.creditLimit;
			AvailableCredit = response.openToBuy;
		}
	}

	public class TransactionResponse {
		public String SalesGuid {get;set;}
		public Integer CashGroup {get;set;}
		public Boolean PaymentReceived {get;set;}
		public String AccountNumber {get;set;}
		public Decimal Amount {get;set;}
		public String AuthorizationNumber {get;set;}
		public Integer DocumentNumber {get;set;}
		public String ReferenceNumber {get;set;}
		public String TermsCode {get;set;}
		public String TermsCodeDescription {get;set;}
		public String TenderCode {get;set;}
		public String Status {get;set;}
		public Integer ExpirationDays {get;set;}
		public String TransactionDate {get;set;}
		public String TransactionTime {get;set;}
		public String AccountLookUpRequestID {get;set;}
		public String FinanceTerms {get;set;}
		public String Receipt {get;set;}
	}
}