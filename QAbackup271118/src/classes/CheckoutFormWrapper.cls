/* *******************************************************************************************************************
* Class Name   : CheckoutFormWrapper
* Description  : Wrapper class for forms in Checkout component     
* Author       : Prabha Kannan (Perficient, Inc.)
* Created On   : 02/06/2018
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer                                   Date                   Modification ID      Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
*
**************************************************************************************************************************************/
public class CheckoutFormWrapper {
	
    @AuraEnabled
    public String billFullName		{ get;set; }
    @AuraEnabled
    public String billAddr1 		{ get;set; }
	@AuraEnabled
    public String billAddr2 		{ get;set; }
	@AuraEnabled
    public String billCity 			{ get;set; }
	@AuraEnabled
    public String billState 		{ get;set; }
	@AuraEnabled
    public String billPostalCode 	{ get;set; }
	@AuraEnabled
    public String billPhone 		{ get;set; }
    

	
    @AuraEnabled
    public String shipFullName		{ get;set; }
    @AuraEnabled
    public String shipAddr1 		{ get;set; }
	@AuraEnabled
    public String shipAddr2 		{ get;set; }
	@AuraEnabled
    public String shipCity 			{ get;set; }
	@AuraEnabled
    public String shipState 		{ get;set; }
    @AuraEnabled
    public String shipPostalCode 	{ get;set; }
	@AuraEnabled
    public String shipPhone 		{ get;set; }

	@AuraEnabled
    public String newAddrId 		{ get;set; }
    // REQ 444 - Added
    @AuraEnabled
    public String oldAddrId         { get;set; }
	@AuraEnabled
    public List<CheckOutWrapper> addressList	{ get;set; }
    
    @AuraEnabled
    public List<CheckOutWrapper1> addressList1	{ get;set; }

	@AuraEnabled
	public String billFirstName {get;set;}
	@AuraEnabled
	public String billLastName {get;set;}
	@AuraEnabled
	public String shipFirstName {get;set;}
	@AuraEnabled
	public String shipLastName {get;set;}
	@AuraEnabled
	public String shipEmail {get;set;}
	@AuraEnabled
	public String billEmail {get;set;}
    
    public CheckoutFormWrapper() {
        this.billFullName = '';
        this.billAddr1 = '';
        this.billAddr2 = '';
        this.billCity = '';
        this.billState = '';
        this.billPostalCode = '';
        this.billPhone = '';
        this.shipFullName = '';
        this.shipAddr1 = '';
        this.shipAddr2 = '';
        this.shipCity = '';
        this.shipState = '';
        this.shipPostalCode = '';
        this.shipPhone = '';
        this.newAddrId = '';
        this.addressList = new List<CheckOutWrapper>();
        
		this.billFirstName = '';
		this.billLastName = '';
		this.shipFirstName = '';
		this.shipLastName = '';
		this.shipEmail = '';
		this.billEmail = '';
        this.oldAddrId = '';
    }
}