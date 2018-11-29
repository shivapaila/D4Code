/****** v1 | Description: Test class for ConciergeCCPaymentController.cls | 6/30/2018 | Sorna */
@isTest
public class ConciergeCCPaymentController_Test {
	// setup method to create test data
	@testSetup static void createTestData() {
		TestDataFactory.prepareAPICustomSetting();
		TestDataFactory.createOneSourceSetting();
		Account personAcc = TestDataFactory.initializePersonAccounts(1)[0];
		insert personAcc;

		Address__c address = new Address__c(AccountId__c = personAcc.Id, Address_Line_1__c = '1 Cal St',
										Address_Line_2__c = 'STE 101', City__c = 'San Francisco', State__c = 'CA',
										Zip_Code__c = '94000', Country__c = 'US');
		insert address;

		Opportunity opp = new Opportunity();
        opp.stageName ='Saved Shopping Cart';
        opp.accountId = personAcc.Id;
        opp.closeDate = Date.newInstance(System.now().year(), System.now().month(), System.now().day())+7;
        opp.name = 'Test Opportunity Name';
        opp.Cart_Item_Details__c = '{"Delivery":{"Address":{"StateOrProvince":"GA","PostalCode":"30041","City":"Cumming"}},'
					+'"CartGuid":"7eb11243-b25a-45a6-b00e","RSAId":null,"POSPassword":null,"POSUserName":null,'
					+'"CustomerId":null,"TaxContactNumber":null,"TaxContactName":null,"TaxExemptNumber":0,'
					+'"TaxExemptExpirationDate":"0001-01-01T00:00:00","IsTaxExemptCertificateOnFile":false,"TaxExemptCode":null,'
					+'"IsTaxExempt":null,"YouSaveDiscountPercent":0.0,"YouSaveDiscountAmount":0.0,"TotalConfiguredStarSKUAmount":0.0,'
					+'"TotalRecycleAmount":0.0,"TotalDeliveryAmount":149.99,"TotalWarrantyAmount":0.0,"TotalTaxAmount":73.50,"TotalNextDayCharge":0.0,'
					+'"TotalDiscountAmount":0.0,"TotalCost":1049.98,"SalesGrandTotal":1123.48}';
		opp.SalesGuid__c = '7eb11243-b25a-45a6-b00e';
		opp.Bill_To_Address__c = opp.ShipTo_Address__c = address.Id;
        insert opp;
	}
	// query all input data and api response data
	static TestWrapper getAllInputData() {
		Id personAccountId = [Select Id from Account].Id;
		/*Map<String,Payment_Type__c> paymentTypeMap = ConciergeFinancingPaymentController.getPaymentOptions();
		System.assertEquals(3, paymentTypeMap.size());
		*/
		List<API_PaymentType.PaymentTermWrapper> pTermWrapperList = ConciergeFinancingPaymentController.getPaymentTerms('MC');
		System.assertEquals(1, pTermWrapperList.size());
	
		ConciergePaymentItemDetailsHelper.ItemDetailsWrapper itemDetails = ConciergeFinancingPaymentController.getItemDetails(personAccountId);
		Opportunity opty = itemDetails.oppt;
		Map<String, Object> objectMap = itemDetails.objectMap;
		System.assertEquals('7eb11243-b25a-45a6-b00e', opty.SalesGuid__c);
		System.assertEquals('7eb11243-b25a-45a6-b00e', objectMap.get('CartGuid'));
		return new TestWrapper(personAccountId, opty, objectMap, pTermWrapperList);
	}
	// 1 - payment transaction for Master card
	static testMethod void testAddPayment() {
		System.runAs(TestDataFactory.createRSAUser()) {
			Test.startTest();
			Test.setMock(HttpCalloutMock.class, new Mock('Add Payment'));
			TestWrapper wrapper = getAllInputData();
			PaymentMethodWrapper pmWrapper = ConciergeCCPaymentController.addPayment(wrapper.personAccountId, 
																		ConciergeCC_TestAPIResponses.pmJSON);
			System.assertEquals(1, [Select count() from Cart_Payment_Transaction__c 
											where Opportunity__c = :wrapper.Opty.Id
														and IsVoid__c = :false]);
			Test.stopTest();
		}
	}
	// 2 - void transaction for Master Card
	static testMethod void testRemovePayment() {
		Opportunity opty = [Select Id from Opportunity];
		Cart_Payment_Transaction__c payTrans = new Cart_Payment_Transaction__c(Payment_Type__c = 'Credit/Debit Card',
												Payment_Amount__c = 10, isVoid__c = false, TenderCode__c = 'MC',
												ReferenceNumber__c = '30485109',
												SalesGuid__c = '249ef4ef-addd-4faf-bd38-3610965ca0e3',
												Check_DocumentNumber__c = 500,
												AuthorizationNumber__c = '1047812',
												TermsCode__c = 'M/V',
												VerifoneIP__c = '10.151.19.26',
												Opportunity__c = opty.Id);
		insert payTrans;
		PaymentMethodWrapper pmWrapper = new PaymentMethodWrapper();
		pmWrapper.paymentTrans = payTrans;
		pmWrapper.paymentTerminalSelected = '10.151.19.26';
		System.runAs(TestDataFactory.createRSAUser()) {
			Test.startTest();
			Test.setMock(HttpCalloutMock.class, new Mock('Remove Payment'));
			TestWrapper wrapper = getAllInputData();
			Boolean isSuccess = ConciergeCCPaymentController.removePayment(wrapper.personAccountId, 
																		JSON.serialize(pmWrapper));
			System.assertEquals(1, [Select count() from Cart_Payment_Transaction__c 
											where Opportunity__c = :wrapper.Opty.Id
														and IsVoid__c = :true]);
			Test.stopTest();
		}
	}
	// 3 - payment transaction for Master card with server busy status
	static testMethod void testAddPaymentSLRBusy() {
		System.runAs(TestDataFactory.createRSAUser()) {
			Test.startTest();
			Test.setMock(HttpCalloutMock.class, new Mock('Add Payment SLR Busy'));
			TestWrapper wrapper = getAllInputData();
			PaymentMethodWrapper pmWrapper = ConciergeCCPaymentController.addPayment(wrapper.personAccountId, 
																		ConciergeCC_TestAPIResponses.pmJSON);
			System.assertEquals(0, [Select count() from Cart_Payment_Transaction__c 
											where Opportunity__c = :wrapper.Opty.Id
														and IsVoid__c = :false]);
			Test.stopTest();
		}
	}
	// 4 - payment transaction for Master card with server busy status
	static testMethod void testOrphanPayment() {
		System.runAs(TestDataFactory.createRSAUser()) {
			Test.startTest();
			Test.setMock(HttpCalloutMock.class, new Mock('Orphan Payment'));
			TestWrapper wrapper = getAllInputData();
			PaymentMethodWrapper pmWrapper = ConciergeCCPaymentController.addPayment(wrapper.personAccountId, 
																		ConciergeCC_TestAPIResponses.pmJSON);
			/*System.assertEquals(0, [Select count() from Cart_Payment_Transaction__c 
											where Opportunity__c = :wrapper.Opty.Id
														and IsVoid__c = :false]);*/
			Test.stopTest();
		}
	}

	@isTest
    public static void testCCSalesLookupResponseWrapper(){
    	CCSalesLookupResponseWrapper cprw = (CCSalesLookupResponseWrapper)JSON.deserialize(ConciergeCC_TestAPIResponses.salesLookupJSON, CCSalesLookupResponseWrapper.class);
        System.assertEquals(true, cprw!=null);
        System.assertEquals(true, cprw.SalesOrderNumber!=null);
		System.assertEquals(true, cprw.CustomerID!=null);
		System.assertEquals(true, cprw.AccountNumber!=null);
		System.assertEquals(true, cprw.ReferenceNumber!=null);
		System.assertEquals(true, cprw.AuthorizationNumber!=null);
		System.assertEquals(true, cprw.TransactionAmount!=null);
		System.assertEquals(true, cprw.TransactionDate!=null);
		System.assertEquals(true, cprw.TransactionTime!=null);
		System.assertEquals(true, cprw.ExpirationDate!=null);
		System.assertEquals(true, cprw.RequestDate!=null);
		System.assertEquals(true, cprw.IsVoidSale!=null);
		System.assertEquals(true, cprw.TransactionStatus!=null);
		System.assertEquals(true, cprw.TermsCode!=null);
		System.assertEquals(true, cprw.CardType!=null);
		System.assertEquals(true, cprw.ReasonCode!=null);
		System.assertEquals(true, cprw.ReasonDescription!=null);
		System.assertEquals(true, cprw.SignatureFilePath!=null);
    } 

    @isTest
    public static void testCCVoidResponseWrapper(){
    	CCVoidPaymentResponseWrapper cprw = (CCVoidPaymentResponseWrapper)JSON.deserialize(ConciergeCC_TestAPIResponses.voidCCResponseJSON, CCVoidPaymentResponseWrapper.class);
        System.assertEquals(true, cprw!=null);
        System.assertEquals(true, cprw.SalesGuid!=null);
		System.assertEquals(true, cprw.CashGroup!=null);
		System.assertEquals(true, cprw.PaymentReceived!=null);
		System.assertEquals(true, cprw.AccountNumber!=null);
		System.assertEquals(true, cprw.Amount!=null);
		System.assertEquals(true, cprw.AuthorizationNumber!=null);
		System.assertEquals(true, cprw.DocumentNumber!=null);
		System.assertEquals(true, cprw.ReferenceNumber!=null);
		System.assertEquals(true, cprw.TermsCode!=null);
		System.assertEquals(true, cprw.TermsCodeDescription!=null);
		System.assertEquals(true, cprw.TenderCode!=null);
		System.assertEquals(true, cprw.Status!=null);
		System.assertEquals(true, cprw.ExpirationDays!=null);
		System.assertEquals(true, cprw.TransactionDate!=null);
		System.assertEquals(true, cprw.TransactionTime!=null);
		System.assertEquals(true, cprw.AccountLookUpRequestID!=null);
		System.assertEquals(true, cprw.FinanceTerms!=null);
		System.assertEquals(true, cprw.Receipt!=null);
    }

    @isTest
    public static void testCCPaymentResponseWrapper(){
    	CCPaymentResponseWrapper cprw = (CCPaymentResponseWrapper)JSON.deserialize(ConciergeCC_TestAPIResponses.addPayment, CCPaymentResponseWrapper.class);
        System.assertEquals(true, cprw!=null);
        System.assertEquals(true, cprw.SalesGuid!=null);
		System.assertEquals(true, cprw.CashGroup !=null);
		System.assertEquals(true, cprw.PaymentReceived!=null);
		System.assertEquals(true, cprw.AccountNumber!=null);
		System.assertEquals(true, cprw.Amount!=null);
		System.assertEquals(true, cprw.AuthorizationNumber!=null);
		System.assertEquals(true, cprw.DocumentNumber!=null);
		System.assertEquals(true, cprw.ReferenceNumber!=null);
		System.assertEquals(true, cprw.TermsCode!=null);
		System.assertEquals(true, cprw.TermsCodeDescription!=null);
		System.assertEquals(true, cprw.TenderCode!=null);
		System.assertEquals(true, cprw.Status!=null);
		System.assertEquals(true, cprw.ExpirationDays!=null);
		System.assertEquals(true, cprw.TransactionDate!=null);
		System.assertEquals(true, cprw.TransactionTime!=null);
		System.assertEquals(true, cprw.AccountLookUpRequestID!=null);
		System.assertEquals(true, cprw.FinanceTerms!=null);
    } 	
	// wrapper class for input data
	class TestWrapper {
		public Id personAccountId;
		public Opportunity opty;
		public Map<String, Object> objectMap;
		public List<API_PaymentType.PaymentTermWrapper> pTermWrapperList;
		public TestWrapper(Id accId, Opportunity opp, Map<String, Object> objMap, List<API_PaymentType.PaymentTermWrapper> termWrapper) {
			personAccountId = accId;
			opty = opp;
			objectMap = objMap;
			pTermWrapperList = termWrapper;
		}
	}
	// Mock callouts for all CC api calls
	public class Mock implements HttpCalloutMock {
		public String callType;
		public Mock(String cType) {
			callType = cType;
		}
		public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            if (req.getEndPoint().contains('/payment-types/MC')){
                res.setBody(ConciergeCC_TestAPIResponses.paymentTerm);            
            }
            else if(req.getEndPoint().contains('/payment-types')) {
            	res.setBody(ConciergeCC_TestAPIResponses.paymentOptions); 
            }
            else if(req.getEndPoint().contains('/payment-terminals/' + TestDataFactory.IPAD_DEVICE_NAME)) {
            	res.setBody(ConciergeCC_TestAPIResponses.paymentTerminal); 
            }
            else if(req.getEndPoint().contains('/finance/payment-terminals/cc-sales') && callType == 'Add Payment') {
            	res.setBody(ConciergeCC_TestAPIResponses.addPayment); 
            }
            else if(req.getEndPoint().contains('/finance/payment-terminals/cc-sales') && callType == 'Remove Payment') {
            	res.setBody(ConciergeCC_TestAPIResponses.removePayment); 
            }
            else if(req.getEndPoint().contains('/finance/payment-terminals/cc-sales') && callType == 'Add Payment SLR Busy') {
            	res.setBody(ConciergeCC_TestAPIResponses.addPaymentSLRBusy); 
            }
            else if(req.getEndPoint().contains('7eb11243-b25a-45a6-b00e') && callType == 'Orphan Payment') {
            	res.setBody(ConciergeCC_TestAPIResponses.orphanPayment); 
            }
            // this is used by testOrphanPayment method which calls void payment at the end
            else {
            	res.setBody(ConciergeCC_TestAPIResponses.removePayment); 
            }
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            res.setStatus('OK');
            return res;
        }
	}
}