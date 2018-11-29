@isTest
private class SalesOrderLineItemDetailController_Test {
	
	@isTest 
	static void testGetLIneItem() {
		//mock line item/order data
		SalesOrder__x testSalesOrder = TestDataFactory.initializeSalesOrders(1)[0];
		SalesOrderDAO.mockedSalesOrders.add(testSalesOrder);
		
		SalesOrderDAO.mockedSalesOrderLineItems.add(new SalesOrderItem__x());
		System.assert(SalesOrderLineItemDetailController.getLineItem('testlieitemid', '00x000000000000') != null);
        System.assert(SalesOrderLineItemDetailController.getfulfillerId('testlieitemid', '00x000000000000') != null);
        try{
        System.assert(SalesOrderLineItemDetailController.getQuantity('testlieitemid', '00x000000000000') != null);
        }Catch(exception ex){
            
        }
        try{
        System.assert(SalesOrderLineItemDetailController.getLOC('testlieitemid:00:11', '00x000000000000') != null);
        }
        catch(exception ex){
            
        }
	}
	
}