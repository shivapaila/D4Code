/* *******************************************************************************************************************
* Class Name   : WishListWrapper
* Description  : Wrapper class to merge responses of wishlist api and product information api    
* Author       : Theyagarajan Sadhasivam (Perficient, Inc.)
* Created On   : 12/18/2017
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer                                   Date                   Modification ID      Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
*
**************************************************************************************************************************************/
public class WishListWrapper {
    
    @AuraEnabled
    public String sku { get;set; }
    
    @AuraEnabled
    public String productName 		{ get;set; }
    
    @AuraEnabled
    public String purchasedQuantity { get;set; }
    
    @AuraEnabled
    public String quantity 			{ get;set; }

	@AuraEnabled
    public String eCommLargeImage	{ get;set; }
    
    @AuraEnabled
    public String eCommSmallImage	{ get;set; }
      
    public WishListWrapper(String sku, String prodName, String purQuantity, String quantity, String lImage, String sImage) {
        this.sku = sku;
        this.productName = prodName;
        this.purchasedQuantity = purQuantity;
        this.quantity = quantity;
        this.eCommLargeImage = lImage;
        this.eCommSmallImage = sImage;
    }
}