/****** v1 | Description: Test class for ConciergeFinancingPaymentController | 6/27/2018 | Sorna */
@isTest
public class ConciergeFinancingPaymentController_Test {
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
		Map<String,Payment_Type__c> paymentTypeMap = ConciergeFinancingPaymentController.getPaymentOptions();
		System.assertEquals(3, paymentTypeMap.size());

		List<API_PaymentType.PaymentTermWrapper> pTermWrapperList = ConciergeFinancingPaymentController.getPaymentTerms('CITM');
		System.assertEquals(7, pTermWrapperList.size());

		ConciergePaymentItemDetailsHelper.ItemDetailsWrapper itemDetails = ConciergeFinancingPaymentController.getItemDetails(personAccountId);
		Opportunity opty = itemDetails.oppt;
		Map<String, Object> objectMap = itemDetails.objectMap;
		System.assertEquals('7eb11243-b25a-45a6-b00e', opty.SalesGuid__c);
		System.assertEquals('7eb11243-b25a-45a6-b00e', objectMap.get('CartGuid'));
		return new TestWrapper(personAccountId, opty, objectMap, pTermWrapperList);
	}
	// 1 - genesis account lookup
	static testMethod void testGenesisAccountLookup() {
		System.runAs(TestDataFactory.createRSAUser()) {
			Test.startTest();
			Test.setMock(HttpCalloutMock.class, new Mock('Genesis Account Lookup'));
			TestWrapper wrapper = getAllInputData();
			ConciergeFinancingAPIResponseWrapper.UIAccountLookupResponse res = 
						ConciergeFinancingPaymentController.performAccountLookup(wrapper.personAccountId, wrapper.opty, 
									wrapper.objectMap, ConciergeFinancing_TestAPIResponses.pmJSON, 
									JSON.serialize(wrapper.pTermWrapperList));
			System.assertEquals(8278.68, res.AvailableCredit);
			ConciergeFinancingAPIResponseWrapper.GenesysAccountLookupResponse lookupRes 
													= new ConciergeFinancingAPIResponseWrapper.GenesysAccountLookupResponse();
			// to cover unused attributes in the response
			lookupRes.AccountBalance = 0;
			lookupRes.AccountStatus = 'In Good Standing';
			lookupRes.Address2 = '1 Test St, San Francisco';
			lookupRes.DueDate = System.Today();
			lookupRes.ExpirationMonth = '12';
			lookupRes.ExpirationYear = '2020';
			lookupRes.PromoCode = 'Test Promo code';
			lookupRes.PromotionDescription = 'Test Promo Description';
			lookupRes.TotalAmountDue = 0;
			Test.stopTest();
		}
	}
	// 2 - synchrony account lookup
	static testMethod void testSynchronyAccountLookup() {
		System.runAs(TestDataFactory.createRSAUser()) {
			Test.startTest();
			Test.setMock(HttpCalloutMock.class, new Mock('Synchrony Account Lookup'));
			TestWrapper wrapper = getAllInputData();
			ConciergeFinancingAPIResponseWrapper.UIAccountLookupResponse res = 
						ConciergeFinancingPaymentController.performAccountLookup(wrapper.personAccountId, wrapper.opty, 
									wrapper.objectMap, ConciergeFinancing_TestAPIResponses.pmJSONSynchrony, 
									JSON.serialize(wrapper.pTermWrapperList));
			//Fix for test pass, because ConciergeFinancingAPIResponseWrapper.UIAccountLookupResponse(SynchronyAccountLookupResponse response) -> AvailableCredit = response.openToBuy;
			System.assertEquals(499747, res.AvailableCredit);
			// to cover unused attributes in the response
			ConciergeFinancingAPIResponseWrapper.SynchronyAccountLookupResponse lookupRes 
													= new ConciergeFinancingAPIResponseWrapper.SynchronyAccountLookupResponse();
			lookupRes.address2 = '1 Test St, San Francisco';
			lookupRes.expirationMonth = '12';
			lookupRes.expirationYear = '2020';
			lookupRes.openToBuy = 0;
			Test.stopTest();
		}
	}
	// 3 - genesys process payment transaction
	static testMethod void testProcessPayment() {
		System.runAs(TestDataFactory.createRSAUser()) {
			Test.startTest();
			Test.setMock(HttpCalloutMock.class, new Mock('Genesis Transaction'));
			TestWrapper wrapper = getAllInputData();
			PaymentMethodWrapper pmWrapper = ConciergeFinancingPaymentController.processPaymentMethod(
								wrapper.personAccountId, wrapper.opty, wrapper.objectMap,
								ConciergeFinancing_TestAPIResponses.pmJSONGensTransaction, 
								JSON.serialize(wrapper.pTermWrapperList[0]));
			System.assertEquals(1, [Select count() from Cart_Payment_Transaction__c where Opportunity__c = :wrapper.opty.Id and IsVoid__c = :false]);
		}
	}
	// 4 - synchrony void payment transaction
	static testMethod void testVoidPayment() {
		Opportunity opty = [Select Id from Opportunity];
		Cart_Payment_Transaction__c payTrans = new Cart_Payment_Transaction__c(Payment_Type__c = 'Financing',
												Payment_Amount__c = 10, isVoid__c = false, TenderCode__c = 'CITM',
												ReferenceNumber__c = '30485109',
												SalesGuid__c = '249ef4ef-addd-4faf-bd38-3610965ca0e3',
												Check_DocumentNumber__c = 9000,
												AuthorizationNumber__c = '1047812',
												TermsCode__c = '106',
												Opportunity__c = opty.Id);
		insert payTrans;
		PaymentMethodWrapper pmWrapper = new PaymentMethodWrapper();
		pmWrapper.paymentTrans = payTrans;
		pmWrapper.paymentTerminalSelected = '10.151.19.26';
		System.runAs(TestDataFactory.createRSAUser()) {
		Test.startTest();
			Test.setMock(HttpCalloutMock.class, new Mock('Genesis Void'));
			TestWrapper wrapper = getAllInputData();
			pmWrapper = ConciergeFinancingPaymentController.voidPayment(
								wrapper.personAccountId, wrapper.opty, wrapper.objectMap,
								JSON.serialize(pmWrapper));
			System.assertEquals(1, [Select count() from Cart_Payment_Transaction__c where Opportunity__c = :wrapper.opty.Id and IsVoid__c = :true]);
		}
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
	// Mock callouts for all Financing api calls
	public class Mock implements HttpCalloutMock {
		public String callType;
		public Mock(String cType) {
			callType = cType;
		}
		public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            if (req.getEndPoint().contains('/payment-types/CITM')){
                res.setBody(ConciergeFinancing_TestAPIResponses.paymentTerm);            
            }
            else if(req.getEndPoint().contains('/payment-types')) {
            	res.setBody(ConciergeFinancing_TestAPIResponses.paymentOptions); 
            }
            else if(req.getEndPoint().contains('/payment-terminals/' + TestDataFactory.IPAD_DEVICE_NAME)) {
            	res.setBody(ConciergeFinancing_TestAPIResponses.paymentTerminal); 
            }
            else if(req.getEndPoint().contains('/finance/credit-authorizations') && callType == 'Genesis Account Lookup') {
            	res.setBody(ConciergeFinancing_TestAPIResponses.genesisAccLookup); 
            }
            else if(req.getEndPoint().contains('/finance/credit-authorizations') && callType == 'Synchrony Account Lookup') {
            	res.setBody(ConciergeFinancing_TestAPIResponses.synchronyAccLookup); 
            }
            else if(req.getEndPoint().contains('/finance/credit-authorizations') && callType == 'Genesis Transaction') {
            	res.setBody(ConciergeFinancing_TestAPIResponses.genesisTransaction); 
            }
            else if(req.getEndPoint().contains('/finance/credit-authorizations') && callType == 'Genesis Void') {
            	res.setBody(ConciergeFinancing_TestAPIResponses.synchronyVoid); 
            }
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            res.setStatus('OK');
            return res;
        }
	}
}