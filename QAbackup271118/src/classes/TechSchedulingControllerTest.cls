@isTest
private class TechSchedulingControllerTest {

    @testSetup
    static void setup() {
        List<Account> accList = new List<Account>();
        accList = TestDataFactory.initializeAccounts(1);
        insert accList;

        List<Contact> contList = new List<Contact>();
        contList = TestDataFactory.initializeContacts(accList[0].Id, 1);
        insert contList;

        /*Address__c addr = new Address__c (Address_Line_1__c = '1234 test av',
        Address_Line_2__c = 'apt 1111',
        City__c = 'test',
        State__c = 'fl',
        Zip_Code__c = '12345'
        ) ;
        insert addr;
        */

        // Insert Sales Order
        Test.startTest();
        SalesOrder__x salesOrder = new SalesOrder__x(fulfillerID__c = '8888300-164',
                                                 ExternalId = '17331400:001q000000raDkvAAE',
                                                 phhProfitcenter__c = 1234567,
                                                 Phhcustomerid__c = '784584585',
                                                 phhSalesOrder__c = '88845758'
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
                            Type = 'Open Order Inquiry', Subject = 'Test',
                            Description = 'Test', ContactId = contList[0].Id );
        insert caseObj;

        Case Casee = new Case();
        Casee.Subject='Test record';
        Casee.Type = 'General Inquiry';
        Casee.ContactId = contList[0].Id;
        Casee.Description = 'test record';
        Casee.Origin = 'Phone';
        Casee.Status = 'New';
        Casee.Priority='Medium';
        insert Casee;

        Case_Line_Item__c cli = new Case_Line_Item__c();
        cli.Defect_Details__c = 'Test';
        cli.Case__c = caseObj.Id;
        insert cli;

        Test.stopTest();
    }

    @isTest static void getZipCodeTest() {
        Case caseObj = [Select Id,Sales_Order__c from Case Where Sales_Order__c = '17331400:001q000000raDkvAAE'];
        Test.startTest();
        SalesOrderItem__x salesOrderLineItem = new SalesOrderItem__x(ExternalId = '17331400:001q000000raDkvAAE', 
                                                                 phdShipZip__c = '30548'
                                                                );

        ExternalRequestModel.mockedSalesOrderItems.add(salesOrderLineItem);
        SalesOrderItem__x salesOrderLineItemObj = ExternalRequestModel.findByOrderItemId(salesOrderLineItem.Id);
        TechSchedulingController.getZipCode(caseObj.Sales_Order__c);
        Test.stopTest();
    }

    /*
    @isTest static void getAssigneesTest() {
        Case caseObj = [Select Id,Sales_Order__c from Case Where Sales_Order__c = '17331400:001q000000raDkvAAE'];
        SalesOrderItem__x salesOrderItem = new SalesOrderItem__x(ExternalId = '17331400:001q000000raDkvAAE', 
                                                             phdShipZip__c = '30548');
        ExternalRequestModel.mockedSalesOrderItems.add(salesOrderItem);
        SalesOrderItem__x salesOrderItemObj = ExternalRequestModel.findByOrderItemId(salesOrderItem.Id);
        String companyvalue = 'ASHLEY';
        String zipcode = '32233';

        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('TechScheduleAssignees');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');

        Test.startTest();
        // Set the mock callout mode
        Test.setMock(HttpCalloutMock.class, mock);
        // Call the method that performs the callout
        List<Object> objList = TechSchedulingController.getAssignees(caseObj.Id);
        Test.stopTest();
    }

    @isTest static void getRequestStatusTest() {
        Case caseObj = [Select Id,Sales_Order__c from Case Where Sales_Order__c = '17331400:001q000000raDkvAAE'];
        SalesOrderItem__x salesOrderItem = new SalesOrderItem__x(ExternalId = '17331400:001q000000raDkvAAE', 
                                                             phdShipZip__c = '30548');
        ExternalRequestModel.mockedSalesOrderItems.add(salesOrderItem);
        SalesOrderItem__x salesOrderItemObj = ExternalRequestModel.findByOrderItemId(salesOrderItem.Id);
        String companyvalue = 'ASHLEY';
        String zipcode = '32233';

        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('TechScheduleAssignees');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');

        Test.startTest();
        // Set the mock callout mode
        Test.setMock(HttpCalloutMock.class, mock);
        // Call the method that performs the callout
        List<Object> objList = TechSchedulingController.getRequestStatus(caseObj.Id);
        Test.stopTest();
    }

    @isTest static void getReasonCodesTest() {
        Case caseObj = [Select Id,Sales_Order__c from Case Where Sales_Order__c = '17331400:001q000000raDkvAAE'];
        SalesOrderItem__x salesOrderItem = new SalesOrderItem__x(ExternalId = '17331400:001q000000raDkvAAE', 
                                                             phdShipZip__c = '30548');
        ExternalRequestModel.mockedSalesOrderItems.add(salesOrderItem);
        SalesOrderItem__x salesOrderItemObj = ExternalRequestModel.findByOrderItemId(salesOrderItem.Id);
        String companyvalue = 'ASHLEY';
        String zipcode = '32233';

        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('TechScheduleAssignees');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');

        Test.startTest();
        // Set the mock callout mode
        Test.setMock(HttpCalloutMock.class, mock);
        // Call the method that performs the callout
        List<Object> objList = TechSchedulingController.getReasonCodes(caseObj.Id);
        Test.stopTest();
    }

    @isTest static void getPriorityTest() {
        Case caseObj = [Select Id,Sales_Order__c from Case Where Sales_Order__c = '17331400:001q000000raDkvAAE'];
        SalesOrderItem__x salesOrderItem = new SalesOrderItem__x(ExternalId = '17331400:001q000000raDkvAAE', 
                                                             phdShipZip__c = '30548');
        ExternalRequestModel.mockedSalesOrderItems.add(salesOrderItem);
        SalesOrderItem__x salesOrderItemObj = ExternalRequestModel.findByOrderItemId(salesOrderItem.Id);
        String companyvalue = 'ASHLEY';
        String zipcode = '32233';

        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('TechScheduleAssignees');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');

        Test.startTest();
        // Set the mock callout mode
        Test.setMock(HttpCalloutMock.class, mock);
        // Call the method that performs the callout
        List<Object> objList = TechSchedulingController.getPriority(caseObj.Id);
        Test.stopTest();
    }
	*/

    @isTest static void salesOrderInfoTest() {
        Case caseObj = [Select Id,Sales_Order__c from Case Where Sales_Order__c = '17331400:001q000000raDkvAAE'];
        // SalesOrder__x salesOrder =[SELECT fulfillerID__c,ExternalId,phhProfitcenter__c,Phhcustomerid__c,phhSalesOrder__c FROM SalesOrder__x WHERE ExternalId='0012900000GRGzzAAH:004049148813:133:300442390:8888300-164:D'];
        Test.startTest();
        SalesOrder__x salesOrder = new SalesOrder__x(fulfillerID__c = '8888300-164',
                                                 ExternalId = '17331400:001q000000raDkvAAE',
                                                 phhProfitcenter__c = 1234567,
                                                 Phhcustomerid__c = '784584585',
                                                 phhSalesOrder__c = '88845758'
                                                );

        ExternalRequestModel.mockedSalesOrders.add(salesOrder);
        SalesOrder__x salesOrderObj = ExternalRequestModel.findById(salesOrder.Id);
        TechSchedulingController.getSalesOrderInfo(caseObj.Id);
        Test.stopTest();
    }

    @isTest static void getSalesOrderLineInfoTest() {
        Case caseObj = [Select Id,Sales_Order__c from Case Where Sales_Order__c = '17331400:001q000000raDkvAAE'];
        Test.startTest();
        SalesOrderItem__x salesOrderLineItem = new SalesOrderItem__x(ExternalId = '17331400:001q000000raDkvAAE', 
                                                                 phdShipZip__c = '30548'
                                                                );

        ExternalRequestModel.mockedSalesOrderItems.add(salesOrderLineItem);
        SalesOrderItem__x salesOrderLineItemObj = ExternalRequestModel.findByOrderItemId(salesOrderLineItem.Id);
        TechSchedulingController.getSalesOrderLineInfo(caseObj.Id);
        Test.stopTest();
    }

    @isTest static void getApiResponse1Test() {
        Case caseObj = [Select Id,Sales_Order__c from Case Where Sales_Order__c = '17331400:001q000000raDkvAAE'];
        SalesOrderItem__x salesOrderItem = new SalesOrderItem__x(ExternalId = '17331400:001q000000raDkvAAE', 
                                                             phdShipZip__c = '30548');
        ExternalRequestModel.mockedSalesOrderItems.add(salesOrderItem);
        SalesOrderItem__x salesOrderItemObj = ExternalRequestModel.findByOrderItemId(salesOrderItem.Id);
        String companyvalue = 'ASHLEY';
        String zipcode = '32233';

        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('TechSchedulePost');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');

        Test.startTest();
        // Set the mock callout mode
        Test.setMock(HttpCalloutMock.class, mock);
        // Call the method that performs the callout
        TechSchedulingController.getApiResponse1(caseObj.Id);
        Test.stopTest();   
    }

    @isTest static void getApiResponseforlineskuTest() {
        Case caseObj = [Select Id,Sales_Order__c from Case Where Sales_Order__c = '17331400:001q000000raDkvAAE'];
        SalesOrderItem__x salesOrderItem = new SalesOrderItem__x(ExternalId = '17331400:001q000000raDkvAAE', 
                                                             phdShipZip__c = '30548');
        ExternalRequestModel.mockedSalesOrderItems.add(salesOrderItem);
        SalesOrderItem__x salesOrderItemObj = ExternalRequestModel.findByOrderItemId(salesOrderItem.Id);
        String companyvalue = 'ASHLEY';
        String zipcode = '32233';

        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('TechSchedulePost');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');

        Test.startTest();
        // Set the mock callout mode
        Test.setMock(HttpCalloutMock.class, mock);
        // Call the method that performs the callout
        TechSchedulingController.getApiResponseforlinesku(caseObj.Id);
        Test.stopTest();   
    }

    @isTest static void getApiResponsetest() {
        Case caseObj = [Select Id,Sales_Order__c from Case Where Sales_Order__c = '17331400:001q000000raDkvAAE'];
        SalesOrderItem__x salesOrderItem = new SalesOrderItem__x(ExternalId = '17331400:001q000000raDkvAAE', 
                                                             phdShipZip__c = '30548');
        ExternalRequestModel.mockedSalesOrderItems.add(salesOrderItem);
        SalesOrderItem__x salesOrderItemObj = ExternalRequestModel.findByOrderItemId(salesOrderItem.Id);
        String companyvalue = 'ASHLEY';
        String zipcode = '32233';

        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('TechScheduleAssignees');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');

        Test.startTest();
        // Set the mock callout mode
        Test.setMock(HttpCalloutMock.class, mock);
        // Call the method that performs the callout
        List<Object> objList = TechSchedulingController.getApiResponse(caseObj.Id,zipcode);
        Test.stopTest();
    }

    @isTest static void getTechniciansTest() {
        Case caseObj = [Select Id,Sales_Order__c from Case Where Sales_Order__c = '17331400:001q000000raDkvAAE'];
        SalesOrderItem__x salesOrderItem = new SalesOrderItem__x(ExternalId = '17331400:001q000000raDkvAAE', 
                                                             phdShipZip__c = '30548');
        ExternalRequestModel.mockedSalesOrderItems.add(salesOrderItem);
        SalesOrderItem__x salesOrderItemObj = ExternalRequestModel.findByOrderItemId(salesOrderItem.Id);
        String companyvalue = 'ASHLEY';
        String zipcode = '32233';

        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('TechScheduleAssignees');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');

        Test.startTest();
        // Set the mock callout mode
        Test.setMock(HttpCalloutMock.class, mock);
        // Call the method that performs the callout
        List<Object> objList = TechSchedulingController.getTechnicians(caseObj.Id, companyvalue,zipcode);
        system.debug('objList: ' + objList);
        Test.stopTest();
    }

    @isTest static void getProgressValue() {
        Case caseObj = [Select Id,Sales_Order__c from Case Where Sales_Order__c = '17331400:001q000000raDkvAAE'];
        SalesOrderItem__x salesOrderItem = new SalesOrderItem__x(ExternalId = '17331400:001q000000raDkvAAE', 
                                                             phdShipZip__c = '30548');
        ExternalRequestModel.mockedSalesOrderItems.add(salesOrderItem);
        SalesOrderItem__x salesOrderItemObj = ExternalRequestModel.findByOrderItemId(salesOrderItem.Id);
        String companyvalue = 'ASHLEY';
        String zipcode = '32233';
        string selecteddate = '10/28/2019';
        String resourceid = '49';
        //Creating Sales Order Object
        String sOMockReq = '{"MaxWorkingHours":20,"MaxRepairStops":6,"MaxPiecesDay":99,"AllocatedWorkingHours":0,"AllocatedRepairStops":0,"AllocatedPieces":0,"CurrentWorkingHours":6.0,"CurrentRepairStops":6,"CurrentPieces":6,"MaxHours":0,"MaxStops":0,"MaxPieces":0,"TechnicianId":49,"Date":"2018-07-20T00:00:00"}';
        HttpCalloutMockForRESTCallouts soCallOut = new HttpCalloutMockForRESTCallouts(200,'OK',sOMockReq,new Map<String, String>());    
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, soCallOut);     
        map<string,object>objlist = TechSchedulingController.getProgressValue(caseObj.Id,resourceid,selecteddate);
        Test.stopTest();
    }

    @isTest static void getWorkloadInfoTest() {
        Case caseObj = [Select Id,Sales_Order__c from Case Where Sales_Order__c = '17331400:001q000000raDkvAAE'];
        String resourceid = '49';
        String workLoadResponse = '[{"TechId": 14, "FirstName": "T, W, TH, F, Sat", "LastName": "ASHLEY PALM SPRINGS", "VendorId": "ASHLEY FURNITURE INDUSTRIES, INC.", '
            + '"CompanyName": "ASHLEY", "ZipCode": "", "MaxHoursPerDay": 7, "MaxRepairPerDay": 7, "MaxPiecesPerDay": 99, "CasegoodsSkillLevel": 10, "UpholsterySkillLevel": 10, '
            + '"LeatherSkillLevel": 10, "WeeklySchedule": "NNYYYYY", "StreetAddress": null, "City": null, "StateCode": "", "HomePhone": "", "CellPhone": "", "EmailID": "", '
            + '"FaxNumber": "", "LeaveDate": "'+date.today().year()+'-'+date.today().month()+'-'+date.today().day()+'T00:00:00", "CreatedTime": "2007-02-22T14:14:47", "CreatedUserID": 195 }]';

        Test.startTest();
        // Set the mock callout mode
        Test.setMock(HttpCalloutMock.class, new MockCallout(200, 'OK', workLoadResponse, new Map<String, String>()));
        // Call the method that performs the callout
        List<Object> objList = TechSchedulingController.getWorkloadInfo(caseObj.Id, resourceid);
        Test.stopTest();
    }

    @isTest static void getAvailabledatesTest() {
        Case caseObj = [Select Id,Sales_Order__c from Case Where Sales_Order__c = '17331400:001q000000raDkvAAE'];
        String resourceid = '13';
        
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('techschedulingservicereasoncodes');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');
        
        Test.startTest();
        
        // Set the mock callout mode
        Test.setMock(HttpCalloutMock.class, mock);
        
        // Call the method that performs the callout
        List<Object> objList = TechSchedulingController.getAvailableDates(caseObj.Id, resourceid, string.valueOf(date.today().year()), string.valueOf(date.today().month()));
        system.debug('objList: ' + objList);
        
        Test.stopTest();
    }

	@isTest static void lineiteminsertTest() {
        Case caseObj = [Select Id,Sales_Order__c from Case Where Sales_Order__c = '17331400:001q000000raDkvAAE'];
        string jsonData = '[{"salesorder_number":"200457950", "sku":"ABCD-1", "seqNumber":"10", "serialNo":"999999", "qty":"1", "deldate":"2018-10-10", "wardate":"2018-10-10", "desc":"Description"}]';
        string jsonData1 = '[{"salesorder_number":"200457950", "sku":"ABCD-1", "seqNumber":"10", "serialNo":"123123", "qty":"1", "deldate":"2018-10-10", "wardate":"2018-10-10", "desc":"Description"}]';
        Test.startTest();
        string rtnStr = TechSchedulingController.lineiteminsert(caseObj.Id, jsonData, 'CUST123', 'ship1', 'ship2', 'City', 'FL', '30315', '8888000-740');
        string rtnStr1 = TechSchedulingController.lineiteminsert(caseObj.Id, jsonData1, 'CUST123', 'ship1', 'ship2', 'City', 'FL', '30315', '8888000-740');
        Test.stopTest();
    }

    @isTest static void POSTCalloutTest() {
        Case caseObj = [Select Id, Subject, Description, Sales_Order__c from Case Where Sales_Order__c = '17331400:001q000000raDkvAAE'];
        caseObj.Subject = 'The first Ashley HomeStore opened in Anchorage, Alaska in 1997. Since then, the company has become the #1 home furniture retailer in North America.';
        string descr = 'They have stores located throughout the United States, Canada, Mexico, Central America, Japan, Kazakhstan and Singapore. Though many Ashley HomeStores are independently owned and operated, all of the furniture sold is manufactured by Ashley. The 100th HomeStore store opened in 2003, the 200th in 2005. It became the fastest-growing furniture chain and top selling furniture brand worldwide in 2006 and open its 300th store in 2007.';
        descr += 'Though many Ashley HomeStores are independently owned and operated, all of the furniture sold is manufactured by Ashley. The 100th HomeStore store opened in 2003, the 200th in 2005. It became the fastest-growing furniture chain and top selling furniture brand worldwide in 2006 and open its 300th store in 2007.';
        descr += 'Though many Ashley HomeStores are independently owned and operated, all of the furniture sold is manufactured by Ashley. The 100th HomeStore store opened in 2003, the 200th in 2005. It became the fastest-growing furniture chain and top selling furniture brand worldwide in 2006 and open its 300th store in 2007.';
        descr += 'Though many Ashley HomeStores are independently owned and operated, all of the furniture sold is manufactured by Ashley. The 100th HomeStore store opened in 2003, the 200th in 2005. It became the fastest-growing furniture chain and top selling furniture brand worldwide in 2006 and open its 300th store in 2007.';

        caseObj.Description = descr;
        update caseObj;

        ProductLineItem__c pliIns = new ProductLineItem__c(Sales_Order_Number__c = '200457950', Case__c = caseObj.Id, Item_SKU__c = 'B164-54', Item_Serial_Number__c = '99999', Item_Seq_Number__c = '10');
		insert pliIns;

        SalesOrderItem__x salesOrderItem = new SalesOrderItem__x(ExternalId = '17331400:001q000000raDkvAAE', 
                                                             phdShipZip__c = '30548');
        ExternalRequestModel.mockedSalesOrderItems.add(salesOrderItem);
        SalesOrderItem__x salesOrderItemObj = ExternalRequestModel.findByOrderItemId(salesOrderItem.Id);

        String expected = '{"ServiceTechDto" : {"VendId" : "AFFINITY"}, "ItemsDto" : [ {"IsNewItemRequest" : "1", "ItemSaleNumber" : "200442410", "ItemSaleSequenceNumber" : 70, "ItemSKUNumber" : "B164-54", "ItemSerialNumber" : "999999", "ItemInvoiceNumber" : "", "PartOrderTrackNumber" : "", "OrderNumber" : "", "PieceExchangedFixed" : "", "PartNumber" : "", "PartDesc" : "", "DeliveryDate" : "2018-06-05T00:00:00Z", "SignedBy" : "", "RowState" : "A", "Select" : 0, "ItemQuniqueId" : "17350999", "OrderStatus" : "", "OrderShipInformation" : "", "ShipDate" : ""} ]}';

        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('TechScheduleAssignees');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');
        
        Test.startTest();
        // Set the mock callout mode
        Test.setMock(HttpCalloutMock.class, mock);
        // Call the method that performs the callout
        string rtnStr = TechSchedulingController.POSTCallout(caseObj.Id, expected, caseObj, '8888000-740', 'add1', 'add2', 'city', 'state', '12345');

        Test.stopTest();
    }

    @isTest static void confirmProductLineItemTest() {
        Case caseObj = [Select Id,Sales_Order__c from Case Where Sales_Order__c = '17331400:001q000000raDkvAAE'];
		ProductLineItem__c pliIns = new ProductLineItem__c(Sales_Order_Number__c = '200457950', Case__c = caseObj.Id, Item_SKU__c = 'ABCD-1', Item_Serial_Number__c = '123123', Item_Seq_Number__c = '10');
		insert pliIns;

        SalesOrderItem__x salesOrderItem = new SalesOrderItem__x(ExternalId = '17331400:001q000000raDkvAAE', 
                                                             phdShipZip__c = '30548');
        ExternalRequestModel.mockedSalesOrderItems.add(salesOrderItem);
        SalesOrderItem__x salesOrderItemObj = ExternalRequestModel.findByOrderItemId(salesOrderItem.Id);

        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('TechSchedulePost');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');

        Test.startTest();
        // Set the mock callout mode
        Test.setMock(HttpCalloutMock.class, mock);
        // Call the method that performs the callout
        TechSchedulingController.confirmProductLineItem('ABCD-1', '123123');
        Test.stopTest();   
    }

    @isTest static void getTechScheduleDurationTest() {
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('TechScheduleDurationResponse');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');

        Test.startTest();
        // Set the mock callout mode
        Test.setMock(HttpCalloutMock.class, mock);
        // Call the method that performs the callout
		Map < string, List<integer> > objList = TechSchedulingController.getTechScheduleDuration('8888300-164');
        Test.stopTest();
    }

    @isTest static void getCasePliTest() {
		Case caseObj = [Select Id,Sales_Order__c from Case Where Sales_Order__c = '17331400:001q000000raDkvAAE'];
		ProductLineItem__c pliIns = new ProductLineItem__c(Sales_Order_Number__c = '200457950', Case__c = caseObj.Id, Item_SKU__c = 'ABCD-1', Item_Serial_Number__c = '123123', Item_Seq_Number__c = '10');
		insert pliIns;
        Test.startTest();
		TechSchedulingController.getCasePli(caseObj.Id);
        Test.stopTest();
    }

    @isTest static void isValidTechScheduleTest() {
		Case caseObj = [Select Id,Sales_Order__c from Case Where Sales_Order__c = '17331400:001q000000raDkvAAE'];
        Test.startTest();
		TechSchedulingController.isValidTechSchedule(caseObj.Id);
        Test.stopTest();
    }

    @isTest static void caseTest() {
        //this is not required
        Case caseObj = [Select Id,Sales_Order__c from Case Where Sales_Order__c = '17331400:001q000000raDkvAAE'];
        Test.startTest();
        TechSchedulingController.updateCase(caseObj);
        TechSchedulingController.getRelatedCaseObj(caseObj.Id);
        TechSchedulingController.isValidCase(caseObj.Id);
        caseObj.Technician_Schedule_Date__c = date.today().addDays(2);
        caseObj.Sales_Order__c = null;
        TechSchedulingController.updateCase(caseObj);
        TechSchedulingController.getRelatedCaseObj(caseObj.Id);
        TechSchedulingController.isValidCase(caseObj.Id);
        Test.stopTest();
    }

    @isTest static void getLineItemcaseTest() {
        //this is not required
        Case caseObj = [Select Id,Sales_Order__c from Case Where Sales_Order__c = '17331400:001q000000raDkvAAE'];
        Case_Line_Item__c caseItemObj = [SELECT Address_1__c,Address_2__c,Customer_Number__c,Defect_Details__c,Case__c FROM Case_Line_Item__c WHERE  Case__c = :caseObj.id];
        Test.startTest();
        TechSchedulingController.getLineItemcase(caseObj.Id);
        Test.stopTest();
    }

    @isTest static void getCasePriorityTest() {
        //this is not required
        Test.startTest();
        TechSchedulingController.getCasePriority();
        Test.stopTest();
    }

}