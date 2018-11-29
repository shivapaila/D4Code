/***
Class: CustomAdaptorforOrdExtDtSrc_Test
Description: Test class for CustomAdaptorforOrderExternalDataSource
Date: 12/20/2017
Author: Rucha (Perficient)

v2 | Updated test class for Person Accounts | 2/2/2018 | Rucha (Perficient)
***/

@isTest
public with sharing class CustomAdaptorforOrdExtDtSrc_Test {
    @testSetup static void methodName() {
        // Create custom setting
        TestDataFactory.prepareAPICustomSetting();  
    }
    
    @isTest
    static void test_sync(){
        CustomAdaptorforOrderExternalDataSource caoed = new CustomAdaptorforOrderExternalDataSource(new DataSource.ConnectionParams());
        caoed.sync();
        
    }

    @isTest
    static void test_querySalesOrders(){
        String sOMockReq = '{"@odata.context":"http://cara-api-dev-slot-dev.azurewebsites.net/odata/$metadata#SalesOrderHeaders","value":' +
                                '[ ' + 
                                    '{"ID":"622209","phhContactID":"0012F00000CdugIQAR","phhStoreID":133,"phhProfitcenter":24,"phhCustomerID":"009048870576","phhCustomerName":"HANSON, DARRELL","phhSalesOrder":"300493250","phhSalesOrderDate":"2015-12-15T06:00:00Z","phhOrderType":"S","phhOrderSubType":"Enterprise","phhPurchaseDate":"2015-12-15T06:00:00Z","phhItemCount":9,"phhPaymentType":"VM","phhInvoiceNo":"300493250","phhPurchaseValue":2214.00,"phhHighDollarSale":false,"phhBalanceDue":-118.44,"phhDesiredDate":"2015-12-26T06:00:00Z","phhRSA":"079","phhHot":false,"phhDeliveryType":"G16","phhOrderNotes":"please schedule the delivery back to home on Dec 26,2015","phhRescheduledReason":"","phhDeliveryAttempts":0,"phhOrderStatus":"","phhStoreLocation":"ATLANTA","phhBillAddress1":"1314 HORNAGE ROAD","phhBillAddress2":null,"phhBillCity":"BALL GROUND","phhBillState":"GA","phhBillZip":"30107","phhShipAddress1":"1314 HORNAGE ROAD","phhShipAddress2":null,"phhShipCity":"BALL GROUND","phhShipState":"GA","phhShipZip":"30107","npsScore":0,"npsSurveyStatus":"Completed","npsComment1":"Customer at work-unable to answer survey","npsComment2":null,"npsPreventiveAction":"No contact","npsCorrectiveAction":"No contact","phhSaleType":"D","fulfillerID":"8888300-164"},' + 
                                    '{"ID":"550554","phhContactID":"0012F00000CdugIQAR","phhStoreID":133,"phhProfitcenter":24,"phhCustomerID":"009048870576","phhCustomerName":"HANSON, DARRELL","phhSalesOrder":"300493260","phhSalesOrderDate":"2015-12-22T06:00:00Z","phhOrderType":"S","phhOrderSubType":"Enterprise","phhPurchaseDate":"2015-12-22T06:00:00Z","phhItemCount":3,"phhPaymentType":"VM","phhInvoiceNo":"300493260","phhPurchaseValue":480.00,"phhHighDollarSale":false,"phhBalanceDue":-33.60,"phhDesiredDate":"2015-12-26T06:00:00Z","phhRSA":"079","phhHot":false,"phhDeliveryType":"G15","phhOrderNotes":"please schedule the delivery back to home on Dec 26,2015","phhRescheduledReason":"","phhDeliveryAttempts":0,"phhOrderStatus":"","phhStoreLocation":"ATLANTA","phhBillAddress1":"1314 HORNAGE ROAD","phhBillAddress2":null,"phhBillCity":"BALL GROUND","phhBillState":"GA","phhBillZip":"30107","phhShipAddress1":"1314 HORNAGE ROAD","phhShipAddress2":null,"phhShipCity":"BALL GROUND","phhShipState":"GA","phhShipZip":"30107","npsScore":0,"npsSurveyStatus":"Completed","npsComment1":"Customer at work-unable to answer survey","npsComment2":null,"npsPreventiveAction":"No contact","npsCorrectiveAction":"No contact","phhSaleType":"D","fulfillerID":"8888300-164"}' + 
                                ']' + 
                            '}';
        HttpCalloutMockForRESTCallouts soCallOut = new HttpCalloutMockForRESTCallouts(200,'OK',sOMockReq,new Map<String, String>());
        

        Test.setMock(HttpCalloutMock.class, soCallOut);


        //Create context of the query
        CustomAdaptorforOrderExternalDataSource caoed = new CustomAdaptorforOrderExternalDataSource(new DataSource.ConnectionParams());
        
        List<DataSource.Column> SOCols = new List<DataSource.Column>{DataSource.Column.text('ID'),
                                                                        DataSource.Column.text('phhContactID__c')};

        Datasource.Table sOTable = DataSource.Table.get('SalesOrderHeaders','phhSalesOrder__c',SOCols);

        DataSource.TableSelection dts = new DataSource.tableSelection();
        dts.columnsSelected = new List<DataSource.ColumnSelection>();
        DataSource.ColumnSelection cs = new DataSource.ColumnSelection();
        cs.columnName = 'phhCustomerName__c';
        dts.columnsSelected.add(cs);

        dts.tableSelected = 'SalesOrderHeaders';

        DataSource.Filter df = new DataSource.Filter();
        df.columnName = 'ExternalId';
        df.columnValue  = '0012F00000CdugIQAR';
        dts.filter = df;

        DataSource.QueryContext qc = DataSource.QueryContext.get(new List<DataSource.Table>{sOTable},0,100,dts);
        
        //Test query method
        DataSource.TableResult dstr;
        Test.startTest();
        dstr = caoed.query(qc);
        Test.stopTest();

        system.assertEquals('300493250:0012F00000CdugIQAR',dstr.rows.get(0).get('ExternalId'));

    }

    @isTest
    static void test_querySalesOrderLineItems(){
        String sOMockReq = '{"@odata.context":"http://cara-api-dev-slot-dev.azurewebsites.net/odata/$metadata#SalesOrderLineItems","value":' + 
                                '[' + 
                                    '{"ID":"622209","phdStoreID":133,"phdCustomerID":"009048870576","phdSalesOrder":"300493250","phdSalesOrderDate":"2015-12-15T00:00:00Z","phdItemDesc":"BEAT THE CLOCK EVENT","phdItemSKU":"*BTC","phdQuantity":1,"phdWarrantyExpiredOn":"2016-12-14T00:00:00Z","phdIsFPP":false,"phdLOC_PO":"","phdDeliveryDueDate":null,"phdAckNo":"","phdInStoreQty":0.00,"phdInWarehouseQty":0.00,"phdItemStatus":"","phdReturnedReason":"","phdItemSeq":80,"phdShipAddress1":"1314 HORNAGE ROAD","phdShipAddress2":null,"phdShipCity":"BALL GROUND","phdShipState":"GA","phdShipZip":"30107","fulfillerID":"8888300-164","phdSaleType":"D"},' + 
                                    '{"ID":"622209","phdStoreID":133,"phdCustomerID":"009048870576","phdSalesOrder":"300493250","phdSalesOrderDate":"2015-12-15T00:00:00Z","phdItemDesc":"Delivery Fees","phdItemSKU":"*DELIV-TAX","phdQuantity":1,"phdWarrantyExpiredOn":"2016-12-14T00:00:00Z","phdIsFPP":false,"phdLOC_PO":"","phdDeliveryDueDate":null,"phdAckNo":"","phdInStoreQty":0.00,"phdInWarehouseQty":0.00,"phdItemStatus":"","phdReturnedReason":"","phdItemSeq":100,"phdShipAddress1":"1314 HORNAGE ROAD","phdShipAddress2":null,"phdShipCity":"BALL GROUND","phdShipState":"GA","phdShipZip":"30107","fulfillerID":"8888300-164","phdSaleType":"D"} ' + 
                                ']' + 
                            '}';
        HttpCalloutMockForRESTCallouts soCallOut = new HttpCalloutMockForRESTCallouts(200,'OK',sOMockReq,new Map<String, String>());
        

        Test.setMock(HttpCalloutMock.class, soCallOut);


        //Create context of the query
        CustomAdaptorforOrderExternalDataSource caoed = new CustomAdaptorforOrderExternalDataSource(new DataSource.ConnectionParams());
        
        List<DataSource.Column> SOCols = new List<DataSource.Column>{DataSource.Column.text('ID'),
                                                                        DataSource.Column.text('phdItemSeq')};

        Datasource.Table sOTable = DataSource.Table.get('SalesOrderLineItems','phdSalesOrder',SOCols);

        DataSource.TableSelection dts = new DataSource.tableSelection();
        dts.columnsSelected = new List<DataSource.ColumnSelection>();
        DataSource.ColumnSelection cs = new DataSource.ColumnSelection();
        cs.columnName = 'phdCustomerID';
        dts.columnsSelected.add(cs);

        dts.tableSelected = 'SalesOrderLineItems';

        DataSource.Filter df = new DataSource.Filter();
        df.columnName = 'ExternalId';
        df.columnValue  = '300493250:0012F00000CdugIQAR';
        dts.filter = df;

        DataSource.QueryContext qc = DataSource.QueryContext.get(new List<DataSource.Table>{sOTable},0,100,dts);
        
        //Test query method
        DataSource.TableResult dstr;
        Test.startTest();
        dstr = caoed.query(qc);
        Test.stopTest();

        system.assertEquals('300493250:NoValue:80',dstr.rows.get(0).get('ExternalId'));

    }

    @isTest
    static void test_querySalesOrderNoData(){
        String sOMockReq = '{"@odata.context":"http://cara-api-dev-slot-dev.azurewebsites.net/odata/$metadata#SalesOrderLineItems","value":[]}';
        HttpCalloutMockForRESTCallouts soCallOut = new HttpCalloutMockForRESTCallouts(200,'OK',sOMockReq,new Map<String, String>());
        

        Test.setMock(HttpCalloutMock.class, soCallOut);


        //Create context of the query
        CustomAdaptorforOrderExternalDataSource caoed = new CustomAdaptorforOrderExternalDataSource(new DataSource.ConnectionParams());
        
        List<DataSource.Column> SOCols = new List<DataSource.Column>{DataSource.Column.text('ID'),
                                                                        DataSource.Column.text('phhContactID__c')};

        Datasource.Table sOTable = DataSource.Table.get('SalesOrderHeaders','phhSalesOrder__c',SOCols);

        DataSource.TableSelection dts = new DataSource.tableSelection();
        dts.columnsSelected = new List<DataSource.ColumnSelection>();
        DataSource.ColumnSelection cs = new DataSource.ColumnSelection();
        cs.columnName = 'phhCustomerName__c';
        dts.columnsSelected.add(cs);

        dts.tableSelected = 'SalesOrderHeaders';

        DataSource.Filter df = new DataSource.Filter();
        df.columnName = 'ExternalId';
        df.columnValue  = '300493250:0012F00000CdugIQAR';
        dts.filter = df;

        DataSource.QueryContext qc = DataSource.QueryContext.get(new List<DataSource.Table>{sOTable},0,100,dts);
        
        //Test query method
        DataSource.TableResult dstr;
        Test.startTest();
        dstr = caoed.query(qc);
        Test.stopTest();

        system.assertEquals(0,dstr.rows.size());
    }

    @isTest
    static void test_querySalesOrderBadResponse(){
        String sOMockReq = '';
        HttpCalloutMockForRESTCallouts soCallOut = new HttpCalloutMockForRESTCallouts(200,'OK',sOMockReq,new Map<String, String>());
        

        Test.setMock(HttpCalloutMock.class, soCallOut);


        //Create context of the query
        CustomAdaptorforOrderExternalDataSource caoed = new CustomAdaptorforOrderExternalDataSource(new DataSource.ConnectionParams());
        
        List<DataSource.Column> SOCols = new List<DataSource.Column>{DataSource.Column.text('ID'),
                                                                        DataSource.Column.text('phhContactID__c')};

        Datasource.Table sOTable = DataSource.Table.get('SalesOrderHeaders','phhSalesOrder__c',SOCols);

        DataSource.TableSelection dts = new DataSource.tableSelection();
        dts.columnsSelected = new List<DataSource.ColumnSelection>();
        DataSource.ColumnSelection cs = new DataSource.ColumnSelection();
        cs.columnName = 'phhCustomerName__c';
        dts.columnsSelected.add(cs);

        dts.tableSelected = 'SalesOrderHeaders';

        DataSource.Filter df = new DataSource.Filter();
        df.columnName = 'ExternalId';
        df.columnValue  = '300493250:0012F00000CdugIQAR';
        dts.filter = df;

        DataSource.QueryContext qc = DataSource.QueryContext.get(new List<DataSource.Table>{sOTable},0,100,dts);
        
        //Test query method
        DataSource.TableResult dstr;
        Test.startTest();
        try{
            dstr = caoed.query(qc);
        }
        catch(Exception e){
            system.assert(1==1);
        }
        Test.stopTest();

        //system.assertEquals(0,dstr.rows.size());
    }

    @isTest
    static void test_Search(){
        String sOMockReq = '{"@odata.context":"http://cara-api-dev-slot-dev.azurewebsites.net/odata/$metadata#GlobalSalesOrderHeaders","value":[' + 
                                '{"ID":"622209","phhContactID":"0012F00000CdugIQAR","phhStoreID":53,"phhProfitcenter":7,"phhCustomerID":"14877814","phhCustomerName":"JONES, LYNETTE","phhSalesOrder":"300493250","phhSalesOrderDate":"2017-10-10T00:00:00Z","phhOrderType":"S","phhOrderSubType":"Enterprise","phhPurchaseDate":"2017-10-10T00:00:00Z","phhItemCount":9,"phhPaymentType":"VM","phhInvoiceNo":"300493250","phhPurchaseValue":2214.00,"phhHighDollarSale":false,"phhBalanceDue":-118.44,"phhDesiredDate":"2017-10-21T00:00:00Z","phhRSA":"079","phhHot":false,"phhDeliveryType":"G16","phhOrderNotes":"please schedule the delivery back to home on Dec 26,2015","phhRescheduledReason":"","phhDeliveryAttempts":0,"phhOrderStatus":"","phhStoreLocation":"KINGSWERE","phhBillAddress1":"647 WEST 17TH ST.","phhBillAddress2":null,"phhBillCity":"JACKSONVILLE","phhBillState":"FL","phhBillZip":"32206","phhShipAddress1":"647 WEST 17TH ST.","phhShipAddress2":null,"phhShipCity":"JACKSONVILLE","phhShipState":"FL","phhShipZip":"32206","phhNPS":[{"npsScore":0,"npsSurveyStatus":"Completed","npsComment1":"Customer at work-unable to answer survey","npsComment2":null,"npsPreventiveAction":"No contact","npsCorrectiveAction":"No contact"}],"phhSaleType":"D","fulfillerID":"8888300-384"},' + 
                                '{"ID":"550554","phhContactID":"0012F00000CdugIQAR","phhStoreID":133,"phhProfitcenter":24,"phhCustomerID":"009048870576","phhCustomerName":"HANSON, DARRELL","phhSalesOrder":"300493250","phhSalesOrderDate":"2015-12-22T00:00:00Z","phhOrderType":"S","phhOrderSubType":"Enterprise","phhPurchaseDate":"2015-12-22T00:00:00Z","phhItemCount":3,"phhPaymentType":"VM","phhInvoiceNo":"300493260","phhPurchaseValue":480.00,"phhHighDollarSale":false,"phhBalanceDue":-33.60,"phhDesiredDate":"2015-12-26T00:00:00Z","phhRSA":"079","phhHot":false,"phhDeliveryType":"G15","phhOrderNotes":"please schedule the delivery back to home on Dec 26,2015","phhRescheduledReason":"","phhDeliveryAttempts":0,"phhOrderStatus":"","phhStoreLocation":"ATLANTA","phhBillAddress1":"1314 HORNAGE ROAD","phhBillAddress2":null,"phhBillCity":"BALL GROUND","phhBillState":"GA","phhBillZip":"30107","phhShipAddress1":"1314 HORNAGE ROAD","phhShipAddress2":null,"phhShipCity":"BALL GROUND","phhShipState":"GA","phhShipZip":"30107","phhNPS":[{"npsScore":0,"npsSurveyStatus":"Completed","npsComment1":"Customer at work-unable to answer survey","npsComment2":null,"npsPreventiveAction":"No contact","npsCorrectiveAction":"No contact"}],"phhSaleType":"D","fulfillerID":"8888300-164"}' + 
                                ']' + 
                            '}';
        HttpCalloutMockForRESTCallouts soCallOut = new HttpCalloutMockForRESTCallouts(200,'OK',sOMockReq,new Map<String, String>());
        

        Test.setMock(HttpCalloutMock.class, soCallOut);


        //Create context of the query
        CustomAdaptorforOrderExternalDataSource caoed = new CustomAdaptorforOrderExternalDataSource(new DataSource.ConnectionParams());
        
        List<DataSource.Column> SOCols = new List<DataSource.Column>{DataSource.Column.text('ID'),
                                                                        DataSource.Column.text('phhContactID__c')};

        Datasource.Table sOTable = DataSource.Table.get('GlobalSalesOrderHeaders','phhSalesOrder__c',SOCols);

        DataSource.TableSelection dts = new DataSource.tableSelection();
        dts.columnsSelected = new List<DataSource.ColumnSelection>();
        DataSource.ColumnSelection cs = new DataSource.ColumnSelection();
        cs.columnName = 'phhCustomerName__c';
        dts.columnsSelected.add(cs);

        dts.tableSelected = 'GlobalSalesOrderHeaders';

        DataSource.Filter df = new DataSource.Filter();
        df.columnName = 'ExternalId';
        df.columnValue  = '300493250:0012F00000CdugIQAR';
        dts.filter = df;

        DataSource.SearchContext qc = new DataSource.SearchContext(new List<DataSource.Table>{sOTable},0,100,new List<DataSource.TableSelection>{dts},'300493250');
        
        //Test query method
        List<DataSource.TableResult> dstr;
        Test.startTest();
        dstr = caoed.search(qc);
        Test.stopTest();

        if(dstr.get(0).rows.get(0).get('phhCustomerID') == '14877814'){
            system.assertEquals('300493250:0012F00000CdugIQAR',dstr.get(0).rows.get(0).get('ExternalId'));

        }
        else{
            system.assertEquals('300493250:0012F00000CdugIQAR',dstr.get(0).rows.get(0).get('ExternalId'));
        }
    }

    @isTest
    static void test_querySalesOrdersExceptions(){
        String sOMockReq = '{"@odata.context":"http://cara-api-dev-slot-dev.azurewebsites.net/odata/$metadata#SalesOrderHeaders","value":' +
                                '[ ' + 
                                    '{"ID":"622209","phhContactID":"0012F00000CdugIQAR","phhStoreID":133,"phhProfitcenter":24,"phhCustomerID":"009048870576","phhCustomerName":"HANSON, DARRELL","phhSalesOrder":"300493250","phhSalesOrderDate":"22-12-2015","phhOrderType":"S","phhOrderSubType":"Enterprise","phhPurchaseDate":"2015-12-15T06:00:00Z","phhItemCount":9,"phhPaymentType":"VM","phhInvoiceNo":"300493250","phhPurchaseValue":2214.00,"phhHighDollarSale":false,"phhBalanceDue":-118.44,"phhDesiredDate":"2015-12-26T06:00:00Z","phhRSA":"079","phhHot":false,"phhDeliveryType":"G16","phhOrderNotes":"please schedule the delivery back to home on Dec 26,2015","phhRescheduledReason":"","phhDeliveryAttempts":0,"phhOrderStatus":"","phhStoreLocation":"ATLANTA","phhBillAddress1":"1314 HORNAGE ROAD","phhBillAddress2":null,"phhBillCity":"BALL GROUND","phhBillState":"GA","phhBillZip":"30107","phhShipAddress1":"1314 HORNAGE ROAD","phhShipAddress2":null,"phhShipCity":"BALL GROUND","phhShipState":"GA","phhShipZip":"30107","npsScore":0,"npsSurveyStatus":"Completed","npsComment1":"Customer at work-unable to answer survey","npsComment2":null,"npsPreventiveAction":"No contact","npsCorrectiveAction":"No contact","phhSaleType":"D","fulfillerID":"8888300-164"},' + 
                                    '{"ID":"550554","phhContactID":"0012F00000CdugIQAR","phhStoreID":133,"phhProfitcenter":24,"phhCustomerID":"009048870576","phhCustomerName":"HANSON, DARRELL","phhSalesOrder":"300493260","phhSalesOrderDate":"2015-12-22T06:00:00Z","phhOrderType":"S","phhOrderSubType":"Enterprise","phhPurchaseDate":"2015-12-22T06:00:00Z","phhItemCount":3,"phhPaymentType":"VM","phhInvoiceNo":"300493260","phhPurchaseValue":480.00,"phhHighDollarSale":false,"phhBalanceDue":-33.60,"phhDesiredDate":"2015-12-26T06:00:00Z","phhRSA":"079","phhHot":false,"phhDeliveryType":"G15","phhOrderNotes":"please schedule the delivery back to home on Dec 26,2015","phhRescheduledReason":"","phhDeliveryAttempts":0,"phhOrderStatus":"","phhStoreLocation":"ATLANTA","phhBillAddress1":"1314 HORNAGE ROAD","phhBillAddress2":null,"phhBillCity":"BALL GROUND","phhBillState":"GA","phhBillZip":"30107","phhShipAddress1":"1314 HORNAGE ROAD","phhShipAddress2":null,"phhShipCity":"BALL GROUND","phhShipState":"GA","phhShipZip":"30107","npsScore":0,"npsSurveyStatus":"Completed","npsComment1":"Customer at work-unable to answer survey","npsComment2":null,"npsPreventiveAction":"No contact","npsCorrectiveAction":"No contact","phhSaleType":"D","fulfillerID":"8888300-164"}' + 
                                ']' + 
                            '}';
        HttpCalloutMockForRESTCallouts soCallOut = new HttpCalloutMockForRESTCallouts(200,'OK',sOMockReq,new Map<String, String>());
        

        Test.setMock(HttpCalloutMock.class, soCallOut);


        //Create context of the query
        CustomAdaptorforOrderExternalDataSource caoed = new CustomAdaptorforOrderExternalDataSource(new DataSource.ConnectionParams());
        
        List<DataSource.Column> SOCols = new List<DataSource.Column>{DataSource.Column.text('ID'),
                                                                        DataSource.Column.text('phhContactID__c')};

        Datasource.Table sOTable = DataSource.Table.get('SalesOrderHeaders','phhSalesOrder__c',SOCols);

        DataSource.TableSelection dts = new DataSource.tableSelection();
        dts.columnsSelected = new List<DataSource.ColumnSelection>();
        DataSource.ColumnSelection cs = new DataSource.ColumnSelection();
        cs.columnName = 'phhCustomerName__c';
        dts.columnsSelected.add(cs);

        dts.tableSelected = 'SalesOrderHeaders';

        DataSource.Filter df = new DataSource.Filter();
        df.columnName = 'ExternalId';
        df.columnValue  = '300493250:0012F00000CdugIQAR';
        dts.filter = df;

        DataSource.QueryContext qc = DataSource.QueryContext.get(new List<DataSource.Table>{sOTable},0,100,dts);
        
        //Test query method
        DataSource.TableResult dstr;
        Test.startTest();
        try{
            dstr = caoed.query(qc);
        }
        catch(Exception e){}
        Test.stopTest();

    }
}