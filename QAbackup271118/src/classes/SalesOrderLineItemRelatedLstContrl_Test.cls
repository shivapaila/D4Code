@isTest
private class SalesOrderLineItemRelatedLstContrl_Test {
	
	@isTest static void testgetLineItems() {

		//get id prefix for sales orders
		Schema.DescribeSObjectResult describeResult = SalesOrder__x.SobjectType.getDescribe();
		string salesOrderIdPrefix = describeResult.getKeyPrefix();
		string smapleSalesOrderId = salesOrderIdPrefix + '2F0000004eetAAA';

		//mock line item data
		SalesOrderDAO.mockedSalesOrders.add(new SalesOrder__x(ExternalId = 'testlieitemid', Id = smapleSalesOrderId));
		SalesOrderDAO.mockedSalesOrderLineItems.add(new SalesOrderItem__x());

		System.assert(SalesOrderLineItemRelatedListController.getLineItems(smapleSalesOrderId).size() == 1);
	}
	
}