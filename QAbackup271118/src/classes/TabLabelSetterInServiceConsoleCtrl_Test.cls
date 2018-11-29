@isTest
public with sharing class TabLabelSetterInServiceConsoleCtrl_Test {
	@isTest
	public static void testGetSalesOrderNumber() {
		
		SalesOrderDAO.mockedSalesOrders.add(new SalesOrder__x());

		Schema.DescribeSObjectResult describeResult = SalesOrder__x.SobjectType.getDescribe();
		string salesOrderIdPrefix = describeResult.getKeyPrefix();
		string smapleSalesOrderId = salesOrderIdPrefix + '2F0000004eetAAA';
		List<SalesOrder__x> ordersById = SalesOrderDAO.getOrdersByIds(new List<Id>{smapleSalesOrderId});

		String orderNumber = TabLabelSetterInServiceConsoleCtrl.getSalesOrderNumber(ordersById.get(0).Id);
		system.assertEquals(ordersById.get(0).phhSalesOrder__c,orderNumber);

	}

	@isTest
	public static void testGetSalesOrderNumberException() {
		
		String orderNumber = TabLabelSetterInServiceConsoleCtrl.getSalesOrderNumber('1234567890');
		system.assertEquals(null,orderNumber);

	}
}