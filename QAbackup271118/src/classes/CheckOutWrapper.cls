/* *******************************************************************************************************************
* Class Name   : CheckOutWrapper
* Description  : Wrapper class for radio button selections of shipping address and billing address in checkout component     
* Author       : Prabha Kannan (Perficient, Inc.)
* Created On   : 02/06/2018
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer                                   Date                   Modification ID      Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
*
**************************************************************************************************************************************/
public class CheckOutWrapper {
    @AuraEnabled
    public String label { get;set; }
    @AuraEnabled
    public String value { get;set; }
    
    public CheckOutWrapper(String label, String value) {
        this.label = label;
        this.value = value;
    }
}