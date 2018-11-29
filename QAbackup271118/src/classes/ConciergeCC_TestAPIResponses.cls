public class ConciergeCC_TestAPIResponses {
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
									'{"TenderCode":"MC","TenderCodeDescription":"MasterCard","DocumentNumber":500}'+
									']';
	public static String paymentTerminal = '{'+
										'"VerifoneIP": "10.151.19.26",'+
										'"WorkstationIP": "AYBOFLTB0023252",'+
										'"ReceiptPrinter": "TM-T88IVME",'+
										'"UsingOPOS": "True"'+
										'}';
	public static String paymentTerm = '[{"TermsCode":"M/V","TermsCodeDescription":"MASTERCARD/VISA","TermsPlanNumber":"","ExpirationDays":"0"}]';
	public static String addPayment = '{'+
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
											'"Status": "COMPLETE",'+
											'"ExpirationDays": 0,'+
											'"TransactionDate": "051818",'+
											'"TransactionTime": "033501",'+
											'"AccountLookUpRequestID": "183919",'+
											'"FinanceTerms": "No Interest If Paid In Full Within 6 Months on all purchases made with your Genesis Credit Ashley Advantage Card. Interest will accrue and be charged to your Account at an APR of 29.99% from the purchase date if the purchase is not paid in full within 6 months, or your Account becomes 180 days past due, or is charged off for any reason. Monthly minimum payments required.  As a reminder, paying only the monthly minimum payment amount each month may not pay off your purchase within 6 months.  You may have to make additional or increased payments during the deferred interest period to avoid having to pay the accrued deferred interest."'+
											'}';
	public static String removePayment = '{'+
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
	public static String addPaymentSLRBusy = '{'+
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
											'"Status": "*SLR Busy.",'+
											'"ExpirationDays": 0,'+
											'"TransactionDate": "051818",'+
											'"TransactionTime": "033501",'+
											'"AccountLookUpRequestID": "183919",'+
											'"FinanceTerms": "No Interest If Paid In Full Within 6 Months on all purchases made with your Genesis Credit Ashley Advantage Card. Interest will accrue and be charged to your Account at an APR of 29.99% from the purchase date if the purchase is not paid in full within 6 months, or your Account becomes 180 days past due, or is charged off for any reason. Monthly minimum payments required.  As a reminder, paying only the monthly minimum payment amount each month may not pay off your purchase within 6 months.  You may have to make additional or increased payments during the deferred interest period to avoid having to pay the accrued deferred interest."'+
											'}';
	public static String orphanPayment = '[{'+
											'"SalesGuid": "b1a1ddc1-852e-4b24-b085-fa1a3089df52",'+
											'"CashGroup": 0,'+
											'"PaymentReceived": true,'+
											'"AccountNumber": "xxxx-xxxx-xxxx-6951",'+
											'"TransactionAmount": 10,'+
											'"AuthorizationNumber": "1044385",'+
											'"DocumentNumber": 2000,'+
											'"ReferenceNumber": "30484310",'+
											'"TermsCode": "906",'+
											'"TermsCodeDescription": "GENS 6M WPDI",'+
											'"TenderCode": "GENS",'+
											'"Status": "Orphan",'+
											'"ExpirationDays": 0,'+
											'"TransactionDate": "051818",'+
											'"TransactionTime": "033501",'+
											'"AccountLookUpRequestID": "183919",'+
											'"FinanceTerms": "No Interest If Paid In Full Within 6 Months on all purchases made with your Genesis Credit Ashley Advantage Card. Interest will accrue and be charged to your Account at an APR of 29.99% from the purchase date if the purchase is not paid in full within 6 months, or your Account becomes 180 days past due, or is charged off for any reason. Monthly minimum payments required.  As a reminder, paying only the monthly minimum payment amount each month may not pay off your purchase within 6 months.  You may have to make additional or increased payments during the deferred interest period to avoid having to pay the accrued deferred interest."'+
											'}]';
	public static String pmJSON = '{"Object":"PaymentMethodWrapper","paymentTrans":{"SObjectType":"Cart_Payment_Transaction__c","Payment_Type__c":"Credit/Debit Card",'
							+'"TenderCode__c":"MC","Payment_Amount__c":10},"paymentTerminals":["10.151.19.26"],"paymentTerminalSelected":"10.151.19.26",'
							+'"FINnum":"1"}';
	public static String salesLookupJSON =  '{"AccountNumber":"xxxx-xxxx-xxxx-6951", "AuthorizationNumber":"1044385", "CardType":"VISA", "CustomerID":"12345", "ExpirationDate":"122834", "IsVoidSale":"true", "ReasonCode":"123", "ReasonDescription":"Description", "ReferenceNumber":"30484310", "RequestDate":"050128", "SalesOrderNumber":"b1a1ddc1-852e-4b24-b085-fa1a3089df52", "SignatureFilePath":"//Path", "TermsCode":"906", "TransactionAmount":"100", "TransactionDate":"050118", "TransactionStatus":"true", "TransactionTime":"122837"}';
	public static String voidCCResponseJSON = '{'+
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
											'"Status": "Orphan",'+
											'"ExpirationDays": 0,'+
											'"TransactionDate": "051818",'+
											'"TransactionTime": "033501",'+
											'"AccountLookUpRequestID": "183919",'+
											'"FinanceTerms": "No Interest If Paid In Full Within 6 Months on all purchases made with your Genesis Credit Ashley Advantage Card. Interest will accrue and be charged to your Account at an APR of 29.99% from the purchase date if the purchase is not paid in full within 6 months, or your Account becomes 180 days past due, or is charged off for any reason. Monthly minimum payments required.  As a reminder, paying only the monthly minimum payment amount each month may not pay off your purchase within 6 months.  You may have to make additional or increased payments during the deferred interest period to avoid having to pay the accrued deferred interest.",'+
											'"Receipt":"Yes"'+
											'}';
}