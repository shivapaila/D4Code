public class ConciergeFinancingAPIHelper {
	public class GenesysInputWrapper {
		public String SalesGuid {get;set;}
		public String AccountNumber {get;set;}
		public String ProfitCenter {get;set;}
		public String OPOSPrinterName {get;set;}
		public Decimal Tax {get;set;}
		public Decimal SubTotal{get;set;}
		public Decimal SaleTotal {get;set;}
		public Decimal DeliveryFee {get;set;}
		public Decimal TransactionAmount {get;set;}
		public Decimal BalanceDue {get;set;}
		public Boolean IsDiscountApplied {get;set;}
		public Decimal YouSavePercentage {get;set;}
		public Decimal YouSaveAmount {get;set;}
		public String CustomerId {get;set;}
		public String TermsCode {get;set;}
		public String TenderCode {get;set;}
		public Boolean IsAccountLookupview  {get;set;}
		public String TermsCodeDescription {get;set;}
		public String DocumentNumber {get;set;}
		public AddressNameWrapper ShipTo {get;set;}
		public AddressNameWrapperbill BillTo {get;set;}
        public String sfGuestId{get;set;}
        public STring storeid {get;set;}
        public String RSAId {get;set;}
		public String Reference {get;set;}
		public Boolean IsVoid {get;set;}
       
	}

	public class AddressNameWrapper {
		public String FirstName {get;set;}
		public String LastName {get;set;}
       // public String emailAddress {get;set;}
		public AddressWrapper Address {get;set;}

		public AddressNameWrapper(String fName, String lName, /*String emailAddress,*/AddressWrapper addr) {
			FirstName = fName;
			LastName = lName;
          //  emailAddress = emailAddress;
			Address = addr;
		}
	}

	public class AddressWrapper {
		public String Address1 {get;set;}
		public String Address2 {get;set;}
		public String City {get;set;}
		public String PostalCode {get;set;}
		public String StateOrProvince {get;set;}


		public AddressWrapper(String a1, String a2, String c, String p, String sp) {
			Address1 = a1;
			Address2 = a2;
			City = c;
			PostalCode = p;
			StateOrProvince = sp;
		}
	}
    
    	public class AddressNameWrapperbill {
		public String FirstName {get;set;}
		public String LastName {get;set;}
        public String emailAddress {get;set;}
        public String HomePhone {get;set;}
    	public String WorkPhone {get;set;}
        public String CellPhone {get;set;}
       public AddressWrapperbill address{get;set;}

		public AddressNameWrapperbill(String fName, String lName, String e,String p,String wph, String cph,
                                      AddressWrapperbill addr) {
			FirstName = fName;
			LastName = lName;
            emailAddress = e;
            HomePhone = p;
            WorkPhone = wph;
            CellPhone = cph;                         
			Address = addr;
		}
	}

	public class AddressWrapperbill {
		public String Address1 {get;set;}
		public String Address2 {get;set;}
		public String City {get;set;}
		public String PostalCode {get;set;}
		public String StateOrProvince {get;set;}


		public AddressWrapperbill(String a1, String a2, String c, String p, String sp) {
			Address1 = a1;
			Address2 = a2;
			City = c;
			PostalCode = p;
			StateOrProvince = sp;
		}
	}

	public static String constructJSON(String apiName, String sGuid, String accNumber, String prCenter, String printerName,
										Decimal taxInput, Decimal subTotalInput, Decimal saleTotalInput, Decimal deliveryFeeInput,
										Decimal transactionAmountInput, Decimal balanceDueInput, Boolean isDiscountAppliedInput,
										Decimal youSavePercentageInput, Decimal youSaveAmountInput, String customerIdInput,
										String termsCodeInput, String tenderCodeInput, Boolean isAccountLookupInput,
										String termsCodeDescInput, String docNumInput, String fName, String lName,
										Address__c shipToAddress, Address__c billToAddress, String ref, Boolean isV,String personAccId, String Rsaid,String storeid,String emailAddress,
                                       String Phone){
         Account personAcc;
         String emailAdd;
		String Mobile;                         
             if(personAccId != null) {
            personAcc = [Select Id, FirstName, LastName,PersonEmail,Phone from Account where Id = :personAccId];
             emailAdd =  personAcc.PersonEmail;
              Mobile   	 = personAcc.Phone;
             system.debug('personAccIdvals' + emailAdd);
        }                                   
		GenesysInputWrapper wrapper = new GenesysInputWrapper();
		wrapper.SalesGuid = sGuid;
		wrapper.AccountNumber = accNumber;
		wrapper.ProfitCenter = prCenter;
		wrapper.OPOSPrinterName = printerName;
		wrapper.Tax = taxInput;
		wrapper.SubTotal = subTotalInput;
		wrapper.SaleTotal = saleTotalInput;
		wrapper.DeliveryFee = deliveryFeeInput;
		// Place holder amount value until Account lookup API is updated to not require amount field
		// Fix for Balance Due
		//wrapper.TransactionAmount = transactionAmountInput != null ? transactionAmountInput : 1;
		wrapper.TransactionAmount = isAccountLookupInput ? 1 : transactionAmountInput;
		wrapper.BalanceDue = balanceDueInput;
		wrapper.IsDiscountApplied = isDiscountAppliedInput;
		wrapper.YouSavePercentage = youSavePercentageInput;
		wrapper.YouSaveAmount = youSaveAmountInput;
		wrapper.CustomerId = customerIdInput;
		wrapper.TermsCode = termsCodeInput;
		wrapper.TenderCode = tenderCodeInput;
		wrapper.IsAccountLookupview = isAccountLookupInput;
		wrapper.TermsCodeDescription = termsCodeDescInput;
		wrapper.DocumentNumber = docNumInput;
		wrapper.ShipTo = new AddressNameWrapper(fName, lName, new AddressWrapper(shipToAddress.Address_Line_1__c, shipToAddress.Address_Line_2__c,
												shipToAddress.City__c, shipToAddress.Zip_Code__c, shipToAddress.State__c));
		wrapper.BillTo = new AddressNameWrapperbill(fName, lName,emailAdd,Mobile,'','',
                                                    new AddressWrapperbill(billToAddress.Address_Line_1__c, billToAddress.Address_Line_2__c,
												billToAddress.City__c, billToAddress.Zip_Code__c, billToAddress.State__c));
		wrapper.IsVoid = isV;
		wrapper.Reference = ref;
		wrapper.sfGuestId = personAccId;
        wrapper.storeid = storeid;
        wrapper.RSAId = RsaId;                                    
		return JSON.serializePretty(wrapper);
	}
}