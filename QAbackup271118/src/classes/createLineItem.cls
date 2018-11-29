public class createLineItem{

    public static Id caseId1;

    public createLineItem(Id myCaseId){
        caseId1 = myCaseId;
        System.debug('My passed CaseId---'+caseId1);
    }

    @TestVisible private static list<SalesOrder__x> mockedcustlist = new List<SalesOrder__x>();
    @TestVisible private static list<SalesOrderItem__x> mockedcustlist1 = new List<SalesOrderItem__x>();

    @AuraEnabled
    //Get Product line item by sales order external ID
    public static Map<String, SalesOrderItem__x> getOrderLineItemsByOrderSelectedId(List<String> sProcId) {
        List<SalesOrderItem__x> lineItemRecList = new List<SalesOrderItem__x>();
        Map<String, SalesOrderItem__x> LieItemMap = new Map<String, SalesOrderItem__x>();
        if(Test.isRunningTest()){
            SalesOrderItem__x lineItems = new SalesOrderItem__x(); 
            lineItems = new SalesOrderItem__x(phdItemDesc__c = '8888300-164',
                                              ExternalId = '204258:0012900000GRH2LAAX');
            LieItemMap.put(lineItems.Id,lineItems);
            return LieItemMap;
        }
        else{
            lineItemRecList = [SELECT ExternalId, Id, phdItemDesc__c, phdItemSKU__c, phdItemStatus__c, phdDeliveryDueDate__c, phdQuantity__c,
                               phdWarrantyExpiredOn__c, phdShipAddress1__c, phdShipAddress2__c, phdShipCity__c, phdShipState__c, phdPurchaseDate__c,
                               phdShipZip__c, phdCustomerID__c, phdInvoiceNo__c, phdAckNo__c, phdCustomerPo__c, phdItemSeq__c, phdLOC_PO__c
                               FROM SalesOrderItem__x WHERE Id IN: sProcId];
            System.debug('my ExternalId'+lineItemRecList);

            for(SalesOrderItem__x oI : lineItemRecList)
            {
                LieItemMap.put(oI.Id, oI);
            }
            return LieItemMap;
        }
    }

    @AuraEnabled
    public static SalesOrder__x getSalesOrderNumber(String salesorder) {
        SalesOrder__x salesOrderObj = new SalesOrder__x();
        if(Test.isRunningTest()){
            salesOrderObj = new SalesOrder__x(fulfillerID__c = '8888300-164',
                                              ExternalId = '204258:0012900000GRH2LAAX');
            
        }else{
            salesOrderObj = [SELECT ExternalId, fulfillerID__c, phhCustomerID__c, phhERPAccounShipTo__c, phhERPCustomerID__c, Id, phhSalesOrder__c FROM SalesOrder__x
                             WHERE ExternalId=:salesorder];
        }
        return salesOrderObj;
    }

    @AuraEnabled
    public static void newProductLineItemRecordwithCaseId(List<string> ProductId, Id caseId, string salesorder){
        createProductLineItem(ProductId, caseId, salesorder, 'New Case from Sales Order');
    }

    @AuraEnabled
    public static void newProductLineItemRecordwithCaseId2(List<string> ProductId, Id caseId, string salesorder){
    	createProductLineItem(ProductId, caseId, salesorder, 'New Product Line Item');
    }

    public static void createProductLineItem(List<string> ProductId, Id caseId, string salesorder, string pliType){
        system.debug('Product Id: ' + ProductId);
        system.debug('Case Id: ' + caseId);
        system.debug('salesorder: ' + salesorder);
        system.debug('pli Type: ' + pliType);

        SalesOrder__x salesorderDetail = new SalesOrder__x();
        salesorderDetail = getSalesOrderNumber(salesorder);

        Map<String, SalesOrderItem__x> mapofSalesorder =  new Map<String, SalesOrderItem__x>();
        mapofSalesorder = getOrderLineItemsByOrderSelectedId(ProductId);

		boolean caseAddressAvailable = false;
		Case csObj = new Case();
		csObj = TechSchedulingController.getCaseObj(caseId);
		if(csObj.Address__c != null){
			caseAddressAvailable = true;
		}
		system.debug('******* csObj: ' + csObj);

        List<ProductLineItem__c> listofProductLineItem = new list<ProductLineItem__c>();
        for(Id sProcId : ProductId){
            system.debug('ProcID: ' + sProcId);

            SalesOrderItem__x listofSalesorder =  new SalesOrderItem__x();
            //This query is not a query exactly it does a callout. we have a searchquery API. 
            listofSalesorder = mapofSalesorder.get(sProcId);
            
            ProductLineItem__c oProductLineItem = new ProductLineItem__c();
            oProductLineItem.Case__c = caseId;
            oProductLineItem.Sales_Order_Number__c = salesorderDetail.phhSalesOrder__c;

			if(!string.isBlank(salesorderDetail.fulfillerID__c)){
	            oProductLineItem.Fulfiller_ID__c = salesorderDetail.fulfillerID__c;
	            oProductLineItem.Customer_Number__c = salesorderDetail.phhCustomerID__c;
			} else {
	            oProductLineItem.Fulfiller_ID__c = salesorderDetail.phhERPAccounShipTo__c;
	            oProductLineItem.Customer_Number__c = salesorderDetail.phhERPCustomerID__c;
			}

            oProductLineItem.Item_SKU__c = listofSalesorder.phdItemSKU__c;
            oProductLineItem.Item_Seq_Number__c = string.valueof(listofSalesorder.phdItemSeq__c);
            oProductLineItem.Item_Description__c = listofSalesorder.phdItemDesc__c;
            oProductLineItem.Address_Line1__c = (caseAddressAvailable ? csObj.Address__r.Address_Line_1__c : listofSalesorder.phdShipAddress1__c);
            oProductLineItem.Address_Line2__c = (caseAddressAvailable ? csObj.Address__r.Address_Line_2__c : listofSalesorder.phdShipAddress2__c);
            oProductLineItem.City__c = (caseAddressAvailable ? csObj.Address__r.City__c : listofSalesorder.phdShipCity__c);
            oProductLineItem.State__c = (caseAddressAvailable ? csObj.Address__r.State__c : listofSalesorder.phdShipState__c);
            oProductLineItem.Zip__c = (caseAddressAvailable ? csObj.Address__r.Zip_Code__c : listofSalesorder.phdShipZip__c);
            oProductLineItem.Sales_Status__c = listofSalesorder.phdItemStatus__c;
            oProductLineItem.Invoice_Number__c = listofSalesorder.phdInvoiceNo__c;
            oProductLineItem.Quantity__c = 1;
            oProductLineItem.AckNo__c = listofSalesorder.phdAckNo__c;
            oProductLineItem.Sales_Order_Item_PO__c = listofSalesorder.phdLOC_PO__c;
            oProductLineItem.Delivery_Date__c =  string.valueof(listofSalesorder.phdPurchaseDate__c);
            oProductLineItem.warranty_date__c =  string.valueof(listofSalesorder.phdWarrantyExpiredOn__c);
            oProductLineItem.Record_Source__c = pliType;
            listofProductLineItem.add(oProductLineItem);
        }
        system.debug('******* PLI List: ' + listofProductLineItem);
        insert listofProductLineItem;
    }
}