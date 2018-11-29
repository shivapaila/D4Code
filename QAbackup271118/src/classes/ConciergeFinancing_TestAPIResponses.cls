/****** v1 | Description: Provides mock responses for ConciergeFinancingPaymentController_Test.cls | 6/30/2018 | Sorna */
public class ConciergeFinancing_TestAPIResponses {
	public static String paymentOptions = '['+
									'{'+
									'"TenderCode": "AMEX",'+
									'"TenderCodeDescription": "American Express Card",'+
									'"DocumentNumber": 300'+
									'},'+
									'{'+
									'"TenderCode": "ASH",'+
									'"TenderCodeDescription": "ASHCOMM",'+
									'"DocumentNumber": 0'+
									'},'+
									'{'+
									'"TenderCode": "CITM",'+
									'"TenderCodeDescription": "SY - Manual",'+
									'"DocumentNumber": 2000'+
									'},'+
									'{'+
									'"TenderCode": "CITS",'+
									'"TenderCodeDescription": "SY - Swipe",'+
									'"DocumentNumber": 2000'+
									'},'+
									'{'+
									'"TenderCode": "GENS",'+
									'"TenderCodeDescription": "GENS - Manual",'+
									'"DocumentNumber": 9000'+
									'}'+
									']';
	public static String paymentTerminal = '{'+
										'"VerifoneIP": "10.151.19.26",'+
										'"WorkstationIP": "AYBOFLTB0023252",'+
										'"ReceiptPrinter": "TM-T88IVME",'+
										'"UsingOPOS": "True"'+
										'}';
	public static String paymentTerm = '['+
								'{'+
								'"TermsCode": "106",'+
								'"TermsCodeDescription": "SY 6M WPDI",'+
								'"TermsPlanNumber": "106",'+
								'"ExpirationDays": "180"'+
								'},'+
								'{'+
								'"TermsCode": "124",'+
								'"TermsCodeDescription": "SY 24M WPDI",'+
								'"TermsPlanNumber": "124",'+
								'"ExpirationDays": "180"'+
								'},'+
								'{'+
								'"TermsCode": "212",'+
								'"TermsCodeDescription": "SY 12M WPDI",'+
								'"TermsPlanNumber": "212",'+
								'"ExpirationDays": "180"'+
								'},'+
								'{'+
								'"TermsCode": "236",'+
								'"TermsCodeDescription": "SY 36M EPNI",'+
								'"TermsPlanNumber": "236",'+
								'"ExpirationDays": "180"'+
								'},'+
								'{'+
								'"TermsCode": "260",'+
								'"TermsCodeDescription": "SY 60M EPNI",'+
								'"TermsPlanNumber": "260",'+
								'"ExpirationDays": "180"'+
								'},'+
								'{'+
								'"TermsCode": "448",'+
								'"TermsCodeDescription": "SY 48M EPNI",'+
								'"TermsPlanNumber": "448",'+
								'"ExpirationDays": "180"'+
								'},'+
								'{'+
								'"TermsCode": "551",'+
								'"TermsCodeDescription": "SY 72M EPNI",'+
								'"TermsPlanNumber": "551",'+
								'"ExpirationDays": "180"'+
								'}'+
								']';
	public static String genesisAccLookup = '{'+
									    '"AccountNumber": "7632001000476951",'+
									    '"AccountBalance": 0,'+
									    '"AccountStatus": "InGoodStanding",'+
									    '"Address": "1607 E. 8TH AVE",'+
									    '"Address2": "",'+
									    '"AvailableCredit": 8278.68,'+
									    '"CreditLine": 9999,'+
									    '"DueDate": null,'+
									    '"ExpirationMonth": null,'+
									    '"ExpirationYear": null,'+
									    '"FirstName": "KREYNOLDS",'+
									    '"LastName": "SIX",'+
									    '"PhoneNumber": "8030129999",'+
									    '"PoliticalDivision1": "TAMPA",'+
									    '"PoliticalDivision2": "FL",'+
									    '"CountryCode": "USA",'+
									    '"PostalCode": "336050000",'+
									    '"PromoCode": "3006",'+
									    '"PromotionDescription": "6 Mo Promo",'+
									    '"TotalAmountDue": 0'+
									'}';
	public static String synchronyAccLookup = '{'+
										    '"accountNumber": "xxxxxxxxxxxx1221",'+
										    '"address1": "19 WESTON ST",'+
										    '"address2": "",'+
										    '"city": "DAYTON",'+
										    '"creditLimit": 500000,'+
										    '"currentBalance": 0,'+
										    '"expirationMonth": "99",'+
										    '"expirationYear": "99",'+
										    '"openToBuy": 499747,'+
										    '"state": "OH",'+
										    '"zipCode": "45420",'+
										    '"firstName": "TESTCASE",'+
										    '"lastName": "TECHSOLUTIONS"'+
										'}';
	public static String genesisTransaction = '{'+
											'"SalesGuid": "b1a1ddc1-852e-4b24-b085-fa1a3089df52",'+
											'"CashGroup": 0,'+
											'"PaymentReceived": true,'+
											'"AccountNumber": "xxxx-xxxx-xxxx-6951",'+
											'"Amount": 10,'+
											'"AuthorizationNumber": "1044385",'+
											'"DocumentNumber": 2000,'+
											'"ReferenceNumber": "30484310",'+
											'"TermsCode": "906",'+
											'"TermsCodeDescription": "GENS 6M WPDI",'+
											'"TenderCode": "GENS",'+
											'"Status": "Approved",'+
											'"ExpirationDays": 0,'+
											'"TransactionDate": "051818",'+
											'"TransactionTime": "033501",'+
											'"AccountLookUpRequestID": "183919",'+
											'"FinanceTerms": "No Interest If Paid In Full Within 6 Months on all purchases made with your Genesis Credit Ashley Advantage Card. Interest will accrue and be charged to your Account at an APR of 29.99% from the purchase date if the purchase is not paid in full within 6 months, or your Account becomes 180 days past due, or is charged off for any reason. Monthly minimum payments required.  As a reminder, paying only the monthly minimum payment amount each month may not pay off your purchase within 6 months.  You may have to make additional or increased payments during the deferred interest period to avoid having to pay the accrued deferred interest."'+
											'}';
	public static String synchronyVoid = '{'+
										'"SalesGuid": "a825a9eb-cd9d-4824-87a6-ebfe50598d60",'+
										'"CashGroup": 0,'+
										'"PaymentReceived": true,'+
										'"AccountNumber": "Void",'+
										'"Amount": 1,'+
										'"AuthorizationNumber": "1043231",'+
										'"DocumentNumber": 100,'+
										'"ReferenceNumber": "30484046",'+
										'"TermsCode": "906",'+
										'"TermsCodeDescription": "GENS 6M WPDI",'+
										'"TenderCode": "GENS",'+
										'"Status": "Void",'+
										'"ExpirationDays": 60,'+
										'"TranscationDate": "050118",'+
										'"TranscationTime": "122837",'+
										'"AccountLookUpRequestID": "",'+
										'"FinanceTerms": "No Interest If Paid In Full Within 6 Months on all purchases made with your Genesis Credit Ashley Advantage Card. Interest will accrue and be charged to your Account at an APR of 29.99% from the purchase date if the purchase is not paid in full within 6 months, or your Account becomes 180 days past due, or is charged off for any reason. Monthly minimum payments required.  As a reminder, paying only the monthly minimum payment amount each month may not pay off your purchase within 6 months.  You may have to make additional or increased payments during the deferred interest period to avoid having to pay the accrued deferred interest."'+
										'}';
	// Test PaymentMethodWrapper JSON inputs for each call from js helper
	public static String pmJSON = '{"Object":"PaymentMethodWrapper","paymentTrans":{"SObjectType":"Cart_Payment_Transaction__c","Payment_Type__c":"Financing",'
							+'"TenderCode__c":"GENS","Payment_Amount__c":0},"paymentTerminals":["10.151.19.26"],"paymentTerminalSelected":"10.151.19.26",'
							+'"FINnum":"7632001000476951"}';
	public static String pmJSONSynchrony = '{"Object":"PaymentMethodWrapper","paymentTrans":{"SObjectType":"Cart_Payment_Transaction__c","Payment_Type__c":"Financing",'
							+'"TenderCode__c":"CITM","Payment_Amount__c":0},"paymentTerminals":["10.151.19.26"],"paymentTerminalSelected":"10.151.19.26",'
							+'"FINnum":"7632001000476951"}';
	public static String pmJSONGensTransaction = '{"Object":"PaymentMethodWrapper","paymentTrans":{"SObjectType":"Cart_Payment_Transaction__c",'
							+'"Payment_Type__c":"Financing","TenderCode__c":"GENS","Payment_Amount__c":10},"paymentTerminals":["10.151.19.26"],'
							+'"paymentTerminalSelected":"10.151.19.26","FINnum":"7632001000476951","FINterms":"906"}';
}