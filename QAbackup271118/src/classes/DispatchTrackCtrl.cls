/* *******************************************************************************************************************
* Class Name   : DispatchTrackCtrl
* Description  : Controller class for DispatchTrack component     
* Author       : Prabha Kannan (Perficient, Inc.)
* Created On   : 02/06/2018
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer                                   Date                   Modification ID      Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
*
**************************************************************************************************************************************/
public class DispatchTrackCtrl {
    
    @AuraEnabled
    public static String formDispatchTrackUrl(String recId) {
        // Get Dispatch Track Url from custom setting
        String dispatchTrackUrl;
        Integration_Settings__c integSetting = Integration_Settings__c.getInstance('Dispatch_Track');
        if(integSetting != null) {
            dispatchTrackUrl = integSetting.End_Point_URL__c;      
        }
        
        // Append Order Number
        if(!Test.isRunningTest()) {
            List<SalesOrder__x> salesOrderList = [SELECT Id,phhStoreID__c,phhStoreLocation__c,phhCustomerType__c,phhErpNumber__c,phhSalesOrder__c,phhProfitcenter__c FROM SalesOrder__x WHERE Id = :recId];
            if(!salesOrderList.isEmpty()) {
                String parameter;
                if(salesOrderList[0].phhStoreLocation__c == 'ASHCOMM' && salesOrderList[0].phhCustomerType__c == 'DEFAULT'){
                    parameter =  salesOrderList[0].phhErpNumber__c;
                } else {
                    parameter =   salesOrderList[0].phhSalesOrder__c;
                }
                dispatchTrackUrl += '/'+ salesOrderList[0].phhStoreID__c +  '-' + salesOrderList[0].phhProfitcenter__c + '-' + parameter;
            }
            system.debug('dispatch' + dispatchTrackUrl);
            return dispatchTrackUrl;
        } else {
            SalesOrder__x salesOrderObj = new SalesOrder__x();
            salesOrderObj = new SalesOrder__x(fulfillerID__c = '8888300-164',
                                              ExternalId = '204258:0012900000GRH2LAAX',
                                              phhStoreID__c = '123',
                                              phhProfitcenter__c = 1234,
                                              phhSalesOrder__c = '20038860'
                                              
                                             );
        }
        return null;
    }
}