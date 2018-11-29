/* *******************************************************************************************************************
* Class Name   : WishListProductWrapper
* Description  : Wrapper class for a product returned from product information api response      
* Author       : Theyagarajan Sadhasivam (Perficient, Inc.)
* Created On   : 12/18/2017
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer                                   Date                   Modification ID      Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
*
**************************************************************************************************************************************/
public class WishListProductWrapper {
	
    @AuraEnabled
    public String sku 				{ get;set; }
    
    @AuraEnabled
    public String productTitle		{ get;set; }
    
    @AuraEnabled
    public String eCommLargeImage	{ get;set; }
    
    @AuraEnabled
    public String eCommSmallImage	{ get;set; }
  
}