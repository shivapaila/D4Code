/* *******************************************************************************************************************
* Class Name   : ImageWrapper
* Description  : Wrapper class for product images.     
* Author       : Theyagarajan Sadhasivam (Perficient, Inc.)
* Created On   : 12/18/2017
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer                                   Date                   Modification ID      Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
*
**************************************************************************************************************************************/
public class ImageWrapper {
     @AuraEnabled
    public Double width{get;set;}
     @AuraEnabled
    public Double height{get;set;}
     @AuraEnabled
    public string url{get;set;}

}