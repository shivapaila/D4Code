@isTest
public class NewProductLineFromCaseController_Test {
    @isTest
    static void test_method_one() {
        Account acc=new Account();
        acc.name='Test';
        acc.AccountNumber='1232332';
        acc.Site='site';
        insert acc;

        // create a person account
        List<Account> accounts = TestDataFactory.initializePersonAccounts(1);
        insert accounts;
        System.debug('my accnt id-->'+accounts[0].id);
        Id accId = accounts[0].id;

        Contact con = new Contact();
        con.accountid=acc.id;
        con.lastname='test con';
        con.email='abc@gmail.com';
        insert con;

        List<Account> accList = new List<Account>();
        accList = TestDataFactory.initializeAccounts(1);
        insert accList;
        Id tdfAccId = accList[0].Id;

        List<Contact> contList = new List<Contact>();
        contList = TestDataFactory.initializeContacts(tdfAccId, 1);
        insert contList;
/*
        Address__c addr = new Address__c (Address_Line_1__c = '1234 test av',
                                          Address_Line_2__c = 'apt 1111',
                                          City__c = 'test',
                                          State__c = 'fl',
                                          Zip_Code__c = '12345',
                                          AccountId__c = tdfAccId
                                          );
        insert addr;
*/
        // Insert Sales Order
        SalesOrder__x salesOrder = new SalesOrder__x(fulfillerID__c = '8888300-164',
                                                     ExternalId = '17331400:001q000000raDkvAAE',	
                                                     phhProfitcenter__c = 1234567,
                                                     Phhcustomerid__c = '784584585',
                                                     phhSalesOrder__c = '88845758',
                                                     phhGuestID__c = accList[0].id
                                                    );
        system.debug('order' + salesOrder);

        SalesOrderDAO.mockedSalesOrders.add(salesOrder);
        SalesOrder__x salesOrderObj = SalesOrderDAO.getOrderById(salesOrder.Id);
        SalesOrderItem__x salesOrderItem = new SalesOrderItem__x(ExternalId = '17331400:001q000000raDkvAAE', 
                                                                 phdShipZip__c = '30548');
        SalesOrderDAO.mockedSalesOrderLineItems.add(salesOrderItem);
        SalesOrderItem__x salesOrderItemObj = SalesOrderDAO.getOrderLineItemByExternalId(salesOrderItem.ExternalId);
        system.debug('orderitem' + salesOrderItemObj);

        // Insert Case
        Case caseObj = new Case(Sales_Order__c = '17331400:001q000000raDkvAAE', Status = 'New', Origin = 'Phone', 
                                Type = 'Open Order Inquiry',sub_Type__c = 'Finance' , Subject = 'Test',
                                Description = 'Test', ContactId = contList[0].Id );
        insert caseObj;
        List<ProductLineItem__c> pliInsList = new List<ProductLineItem__c>();
        pliInsList.add(new ProductLineItem__c(Sales_Order_Number__c = '88845758', Case__c = caseObj.Id, Item_SKU__c = 'ABCD-1', Item_Serial_Number__c = '123123', Item_Seq_Number__c = '10'));
        pliInsList.add(new ProductLineItem__c(Sales_Order_Number__c = '88845758', Case__c = caseObj.Id, Item_SKU__c = 'ABCD-1', Item_Serial_Number__c = '123123', Item_Seq_Number__c = '10'));
		insert pliInsList;

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
        String salesorders = response.ExternalId;
        SalesOrderItem__x mockedRequest = new SalesOrderItem__x(
            phdItemDesc__c = '8888300-164',
            ExternalId = '204258:0012900000GRH2LAAX'
        );
        //NewProductLineFromCaseController.NewProductLineFromCaseController(Casee, salesorder, con.Id, Casee.Type, Casee.Sub_Type__c);
        
        NewProductLineFromCaseController.InitializationDataResponse responses = NewProductLineFromCaseController.getInitializationData(caseObj.Id);
        NewProductLineFromCaseController.getOrderLineItems(smapleSalesOrderId);
        NewProductLineFromCaseController.getSalesOrderInfo(caseObj.Id);
        NewProductLineFromCaseController.getOrderLineItemsByOrderExternalId(caseObj.Id);
        NewProductLineFromCaseController.getSoLineItemsBySoExternalId(caseObj.Id);
        NewProductLineFromCaseController.getRecordId(salesOrder.Id);
        try{
            NewProductLineFromCaseController.create_case(caseObj, salesorders, contList[0].id, caseObj.Type, caseObj.Sub_Type__c);
        }
        catch(exception e){
            
        }
        try{
            NewProductLineFromCaseController.getCaseObj();
        }catch(exception e){
            
        }
        try{
            NewProductLineFromCaseController.getAddr(salesOrder.Id);
        }
        catch(exception e){
            
        }
        List<String> ProductIds = new List<String>();
        NewProductLineFromCaseController.newProductLineItemRecord(ProductIds, caseObj.Id);
        try{
            NewProductLineFromCaseController ctrl = new NewProductLineFromCaseController(caseObj, salesorders, contList[0].id, caseObj.Type, caseObj.Sub_Type__c);
        }
        catch(exception e){
            
        }
    }
}