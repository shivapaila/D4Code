/* *******************************************************************************************************************
* Class Name   : RSAAccountInfoWrapper
* Description  : Purpose of this class is to hold the RSA Account Information in a JSON object structure
*				 Following attributes are maintained in this structure
*				 - RSA Name
*				 - RSA Id
*				 - Profit Center
*				 - Market Code 
*				
* Author       : Sriram (Perficient, Inc.)
* Created On   : 05/23/2018
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer                                   Date                   Modification ID      Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* 
**************************************************************************************************************************************/
public class RSAAccountInfoWrapper {
    @AuraEnabled
    public String rsaName {get; set;}

    @AuraEnabled
    public String rsaId {get;set;}

    @AuraEnabled
    public String profitCenter {get; set;}

    @AuraEnabled
    public String marketCode {get; set;}    
}