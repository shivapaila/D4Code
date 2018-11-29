@isTest
private class SalesOrderLineWrapperTest
{
	@isTest
	static void testSalesOrderLineWrapper()	{

        SalesOrderLineWrapper line = new SalesOrderLineWrapper();
        line.ActionCode = 1;
        
        Date ATCDate = Date.Today().addDays(1);
        line.AvailableDate = ''+ ATCDate.year() +'-'+ATCDate.month() +'-' + ATCDate.day();
        line.ItemNumber='*KSADJPR5YNT';
        line.OriginalPrice = 210.99;
        
        line.UnitCost = 50.99;
        
        line.Quantity = 1;
        line.LineNumber = 1;
        line.DeliverViaCode='HD';    
        line.TotalTax = 9.99;

        line.PackageLineNumber = 123;
        line.ItemType = 1.23;
        line.ExtendedPrice = 230.99;
        line.WarrantySku = 'sdftd';
        line.WarrantyPlanNumber = 1;
        line.Iscall = true;
        line.HDServiceType = 'THD';

        line.UnitPriceAdjustments = new List<SalesOrderLineWrapper.DiscountInfo>{
        							new SalesOrderLineWrapper.DiscountInfo('1', 1)
        							, new SalesOrderLineWrapper.DiscountInfo(1, '1')
        						};

        System.assertEquals(true, line!=null);

	}
}