@isTest
private class SalesOrderDAO_Test {
	
	@isTest 
	static void testWithMockedData() {
		//mock records
		SalesOrderDAO.mockedSalesOrders.add(new SalesOrder__x());
		SalesOrderDAO.mockedSalesOrders.add(new SalesOrder__x());

		SalesOrderDAO.mockedSalesOrderLineItems.add(new SalesOrderItem__x());
		SalesOrderDAO.mockedSalesOrderLineItems.add(new SalesOrderItem__x());

		Schema.DescribeSObjectResult describeResult = SalesOrder__x.SobjectType.getDescribe();
		string salesOrderIdPrefix = describeResult.getKeyPrefix();
		string smapleSalesOrderId = salesOrderIdPrefix + '2F0000004eetAAA';

		List<SalesOrder__x> ordersById = SalesOrderDAO.getOrdersByIds(new List<Id>{smapleSalesOrderId});
		System.assert(ordersById.size() == 2);

		SalesOrder__x orderById = SalesOrderDAO.getOrderById(smapleSalesOrderId);
		System.assert(orderById != null);

		SalesOrder__x orderByExternalId = SalesOrderDAO.getOrderByExternalId('xyz');
		System.assert(orderById != null);

		List<SalesOrderItem__x> lineItemsByOrderExternalId = SalesOrderDAO.getOrderLineItemsByOrderExternalId('xyz'); 
		System.assert(lineItemsByOrderExternalId.size() == 2);

		SalesOrderItem__x lineItemByExternalId = SalesOrderDAO.getOrderLineItemByExternalId ('xyz');
		System.assert(lineItemByExternalId != null);
	}

	@isTest 
	static void testWithNoMockedData() {
		Schema.DescribeSObjectResult describeResult = SalesOrder__x.SobjectType.getDescribe();
		string salesOrderIdPrefix = describeResult.getKeyPrefix();
		string smapleSalesOrderId = salesOrderIdPrefix + '2F0000004eetAAA';

		List<SalesOrder__x> ordersById = SalesOrderDAO.getOrdersByIds(new List<Id>{smapleSalesOrderId});
		System.assert(ordersById.size() == 0);

		SalesOrder__x orderById = SalesOrderDAO.getOrderById(smapleSalesOrderId);
		System.assert(orderById == null);

		SalesOrder__x orderByExternalId = SalesOrderDAO.getOrderByExternalId('xyz');
		System.assert(orderById == null);

		List<SalesOrderItem__x> lineItemsByOrderExternalId = SalesOrderDAO.getOrderLineItemsByOrderExternalId('xyz'); 
		System.assert(lineItemsByOrderExternalId.size() == 0);

		SalesOrderItem__x lineItemByExternalId = SalesOrderDAO.getOrderLineItemByExternalId ('xyz');
		System.assert(lineItemByExternalId == null);
	}
	
}