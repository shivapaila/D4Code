/* ******************************************************************************************************************************************************************************
* Class Name   : Case_SalesOrderDetails_Controller
* Description  : Controller class for component Case_SalesOrderDetails.     
* Author       : Venkat (Perficient, Inc.)
* Created On   : 12/11/2017
* Modification Log:  
* ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* Developer                                   Date                   Modification ID      Description 
* ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* Theyagarajan S							02/07/2018				    REQ-375		 		CHANGED NAME OF FIELD phhContactID__c TO phhGuestId__c(Person Account Changes)
*******************************************************************************************************************************************************************************/
public class Case_SalesOrderDetails_Controller {
    
    @AuraEnabled
    public static SalesOrder__x getDetails(Id objectID){
        
        //getting the case details
        Case caseRec = [SELECT Id,Sales_Order__c 
                        FROM Case 
                        WHERE Id =:objectID LIMIT 1];
        
        //checking whether the Sales Order is null or not
        if(caseRec.Sales_Order__c!=null){
            //querying the sales order details based on the Case SalesOrder value 

            //CHANGED NAME OF FIELD phhContactID__c TO phhGuestId__c.-theyagu(REQ-375) 
            List<SalesOrder__x> testSalesOrderRecords = [SELECT Id,phhGuestId__c,phhContactStatus__c,phhItemCount__c,phhPurchaseValue__c,
                                                        phhSaleType__c, phhSalesOrder__c
                                                        FROM SalesOrder__x 
                                                        WHERE ExternalId =:caseRec.Sales_Order__c LIMIT 1];
            
				system.debug('here' + testSalesOrderRecords);
            if(testSalesOrderRecords.size()!=0){
            	return testSalesOrderRecords[0];   
            }   
            //END OF CHANGED FIELD NAME          	
        }
        return null;
    }
}