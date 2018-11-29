/* *******************************************************************************************************************
* Class Name   : WishListApiWrapper
* Description  : Wrapper class for WishListApi Response.     
* Author       : Theyagarajan Sadhasivam (Perficient, Inc.)
* Created On   : 12/18/2017
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer                                   Date                   Modification ID      Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
*
**************************************************************************************************************************************/
public class WishListApiWrapper {
    @AuraEnabled
    public String sku { get;set; }
    
    @AuraEnabled
    public String productName { get;set; }
    
    @AuraEnabled
    public String purchasedQuantity { get;set; }
    
    @AuraEnabled
    public String quantity { get;set; }
}