@isTest
public class createLineItemtest {
    public static Id caseId1;
    @isTest static void TestCreateLineItem(){
        
        Account acc=new Account();
        acc.name='Test';
        acc.AccountNumber='1232332';
        acc.Site='site';
        insert acc;
        
        Case Casee = new Case();
        Casee.Subject='Test record';
        Casee.Type = 'General Inquiry';
        Casee.AccountId = acc.id;
        Casee.Description = 'test record';
        Casee.Origin = 'Phone';
        Casee.Status = 'New';
        Casee.Priority='Medium';
        Casee.Legacy_Service_Request_ID__c = '88731';
        insert Casee; 
      // create a person account
        List<Account> accounts = TestDataFactory.initializePersonAccounts(1);
        insert accounts;
       System.debug('my accnt id-->'+accounts[0].id);
        Id accId = accounts[0].id;
       
        //mock sales order
        List<SalesOrder__x> orders = TestDataFactory.initializeSalesOrders(1);
        orders[0].phhGuestID__c = accounts[0].Id;
        SalesOrderDAO.mockedSalesOrders.add(orders[0]);
        
        //mock sales order Items
        List<SalesOrderItem__x> salesorderitems = TestDataFactory.initializeSalesOrderLineItems(1);
        SalesOrderDAO.mockedSalesOrderLineItems.add(salesorderitems[0]);

        //call controller method
        Schema.DescribeSObjectResult describeResult = SalesOrder__x.SobjectType.getDescribe();
        string salesOrderIdPrefix = describeResult.getKeyPrefix();
        string smapleSalesOrderId = salesOrderIdPrefix + '2F0000004eetAAA';
        Schema.DescribeSObjectResult describeResult2 = SalesOrderItem__x.SobjectType.getDescribe();
       // string sampleSalesOrderItemId = describeResult2.getKeyPrefix();
        
        Id sampleSalesOrderItemId = salesorderitems[0].id;
        List<String> ProductId = new List<string>() ;
            ProductId.add(sampleSalesOrderItemId);
        System.debug('Sales Item ID-->'+sampleSalesOrderItemId);
        SalesOrder__x response = createLineItem.getSalesOrderNumber(smapleSalesOrderId);
        String salesorder = response.ExternalId;
        List<String> mockedRequestList = new List<String>();
        SalesOrderItem__x mockedRequest = new SalesOrderItem__x(
            phdItemDesc__c = '8888300-164',
            phdItemSKU__c = '20',
            ExternalId = '204258:0012900000GRH2LAAX'
        );
        mockedRequestList.add(mockedRequest.id);
        createLineItem controller = new createLineItem(Casee.id);
        createLineItem.mockedcustlist1.add(mockedRequest);
        createLineItem.newProductLineItemRecordwithCaseId(ProductId, Casee.id, salesorder);
        createLineItem.getOrderLineItemsByOrderSelectedId(mockedRequestList);
        createLineItem.newProductLineItemRecordwithCaseId2(ProductId, Casee.id, salesorder);
    }
   
}