/***
v1 | Controller to get sales order number to set the title of the tab in service console | 1/16/2018 | Rucha (Perficient)
***/
public class TabLabelSetterInServiceConsoleCtrl {

	@AuraEnabled
	public static String getSalesOrderNumber(String salesOrderSalesforceId){
		try{
			return SalesOrderDAO.getOrderById(salesOrderSalesforceId).phhSalesOrder__c;
		}
		catch(Exception e){
			return null;
		}
	}
}