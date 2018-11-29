/* *******************************************************************************************************************
* Class Name   : WishListApiWrapper
* Description  : Wrapper class for Product information API Response.     
* Author       : Prabha Kannan (Perficient, Inc.)
* Created On   : 02/20/2018
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer                                   Date                   Modification ID      Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
*
**************************************************************************************************************************************/
public class WishListProdApiWrapper {
    
    @AuraEnabled
    public WishListProductWrapper product { get;set; }
	
}