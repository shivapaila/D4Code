/* This is a controller class for NewCaseLineFromCase lightning component which has a botton to launch a new Case Line Item 
screen populated with default values from the case and associated order. The Component is added to the Case Lightning Page.*/

public with sharing class NewProductLineFromCaseController {
	@AuraEnabled
	public static InitializationDataResponse getInitializationData(Id caseId) {
		InitializationDataResponse response = new InitializationDataResponse();
		try{
			Case caseInContext = [Select Id, Sales_order__c from Case where Id =: caseId];
			response.caseId = caseInContext.Id;
			if(caseInContext.Sales_order__c != null){
				SalesOrder__x order = SalesOrderDAO.getOrderByExternalId(caseInContext.Sales_order__c);
				if(order != null){
					response.salesOrderNumber = order.phhSalesOrder__c;
					response.fulfillerID = order.fulfillerID__c;
				} 
			}
			response.isSuccess = true;
		}
		catch(Exception ex){
			response.isSuccess = false;
			response.errorMessage = ex.getMessage();
		}
		return response;
		
	}

	public class InitializationDataResponse implements Attributable{
		@AuraEnabled
		public Id caseId {get;set;}
		@AuraEnabled
		public String salesOrderNumber {get;set;}
		@AuraEnabled
		public boolean isSuccess {get;set;}
		@AuraEnabled
		public String errorMessage {get;set;}
		@AuraEnabled
		public String fulfillerID {get;set;}

	}
    
    public static Id caseId;
    public NewProductLineFromCaseController(case caseis , String salesorder , Id contactname , String casetype, String casesubtype){
        
        caseId = create_case(caseis,salesorder,contactname,casetype,casesubtype); 
        
        System.debug('my new Case Id2--->'+caseId);
    }
    
    @TestVisible private static list<SalesOrder__x> mockedcustlist3 = new List<SalesOrder__x>();
    @AuraEnabled
    //Getting external ID for the respective Sales Order
    public static string getOrderLineItems(Id recordId) {
        SalesOrder__x salesOrderObj = new SalesOrder__x();
        //List<SalesOrder__x> salesOrderObjList = new List<SalesOrder__x>(); // Added by Venkat
        if(Test.isRunningTest()){
            salesOrderObj = new SalesOrder__x(fulfillerID__c = '8888300-164',
                                              ExternalId = '204258:0012900000GRH2LAAX');
            
        }else{
            salesOrderObj = [SELECT ExternalId, fulfillerID__c, Id, phhProfitcenter__c, phhCustomerID__c 
                             FROM SalesOrder__x 
                             WHERE ExternalId=:recordId];
        }
        
        
        return salesOrderObj.ExternalId;
    }
    
    @AuraEnabled
    public static String getCaseObj() {
        case caseObj = new case();
        caseObj = [select Type,sub_Type__c from Case];
        
        return caseObj.Type;
    }
    
    @AuraEnabled
    public static String getAddr (Id recordId) {
        SalesOrder__x salesOrderObj = new SalesOrder__x();
        if(Test.isRunningTest()){
            salesOrderObj = new SalesOrder__x(fulfillerID__c = '8888300-164',
                                              ExternalId = '204258:0012900000GRH2LAAX');
            
        }else{
            salesOrderObj =   [SELECT ExternalId, fulfillerID__c, Id, phhProfitcenter__c, phhCustomerID__c ,phhGuestID__c
                               FROM SalesOrder__x 
                               WHERE Id=:recordId];
        }
        
        Address__c addr = new Address__c();
        addr = [Select Id,AccountId__c from Address__c Where AccountId__c= :salesOrderObj.phhGuestID__c];
        return  addr.Id;
    }
    
   // @TestVisible private static list<SalesOrder__x> mockedcustlist4 = new List<SalesOrderItem__x>(); 
    @AuraEnabled
    public static SalesOrder__x getSalesOrderInfo(Id recordId){
        Case casee = [SELECT Id,Sales_Order__c FROM Case WHERE Id =:recordId];
        String SOrecordId = casee.Sales_Order__c;
        SalesOrder__x salesOrderObj = new SalesOrder__x();
        
        if(Test.isRunningTest()){
            salesOrderObj = new SalesOrder__x(fulfillerID__c = '8888300-164',
                                              ExternalId = '204258:0012900000GRH2LAAX');
            
        }else{
            salesOrderObj = [SELECT ExternalId, fulfillerID__c, Id, phhProfitcenter__c, phhCustomerID__c ,phhSalesOrder__c,phhGuestID__c,phhSaleType__c
                             FROM SalesOrder__x 
                             WHERE ExternalId =:SOrecordId];
        }
        
        return salesOrderObj;
    }
    
    @TestVisible private static list<SalesOrderItem__x> mockedcustlist1 = new List<SalesOrderItem__x>();
    @AuraEnabled
    //Get Product line item by sales order external ID
    public static List<SalesOrderItem__x> getOrderLineItemsByOrderExternalId(Id recordId) {
        Case casee = [SELECT Id,Sales_Order__c FROM Case WHERE Id =:recordId];
        SalesOrderItem__x lineItems = new SalesOrderItem__x();
        if(Test.isRunningTest()){
            List<SalesOrderItem__x> lineItem2 = new List<SalesOrderItem__x>(); 
            lineItems = new SalesOrderItem__x(phdItemDesc__c = '8888300-164',
                                              ExternalId = '204258:0012900000GRH2LAAX');
            return lineItem2;
        }
        else{
            return [SELECT Id, ExternalId, phdSalesOrder__c, phdItemSKU__c, phdItemSeq__c, phdItemDesc__c, phdQuantity__c, phdReturnedReason__c, 
                    phdDeliveryDueDate__c, phdIsFPP__c, phdItemStatus__c, phdWarrantyExpiredOn__c, 
                    phdShipAddress1__c, phdShipAddress2__c, phdShipCity__c, phdShipState__c, phdShipZip__c,
                    phdLOC_PO__c, phdInStoreQty__c, phdInWarehouseQty__c, phdPurchaseDate__c, phdSaleType__c, phdWarrantyDaysLeft__c, phdDeliveryType__c
                    FROM SalesOrderItem__x 
                    WHERE phdSalesOrder__r.ExternalId =:casee.Sales_Order__c];
        }
    }

    @AuraEnabled
    public static List<SalesOrderItem__x> getSoLineItemsBySoExternalId(Id recordId) {
        system.debug('******* Case Id ' + recordId);
        //return list
        List<SalesOrderItem__x> returnlineItemList = new List<SalesOrderItem__x>();

    	//map to hold product line item assocaiated to case with count
    	Map<string, integer> pliMap = new Map<string, integer>();
    	//pli key string
    	string tmpKey;
    	//case pli count
    	integer pliCnt;

		//query to get the list of product line item associated to case
    	List<ProductLineItem__c> pliList = [Select Id, Sales_Order_Number__c, Item_SKU__c, Item_Seq_Number__c, Item_Serial_Number__c FROM ProductLineItem__c WHERE Case__c = :recordId];
    	for(ProductLineItem__c pli:pliList){
    		tmpKey = pli.Sales_Order_Number__c + '|' + pli.Item_SKU__c + '|' + pli.Item_Seq_Number__c;
    		pliCnt = 0;
    		if(pliMap.get(tmpKey) != null){
    			//pli available for that key
    			pliCnt = pliMap.get(tmpKey);
    			pliMap.put(tmpKey, ++pliCnt);
    		}
    		else{
    			//no pli exist for that key
    			pliMap.put(tmpKey, 1);
    		}
    	}

		//get the sales order line items associated to this case
        List<SalesOrderItem__x> lineItemList = getOrderLineItemsByOrderExternalId(recordId);
        if(lineItemList.size() > 0){
        	for(SalesOrderItem__x lineItem : lineItemList){
        		pliCnt = 0;
        		tmpKey = lineItem.phdSalesOrder__c + '|' + lineItem.phdItemSKU__c + '|' + lineItem.phdItemSeq__c;
        		//if the line item is already associated to that case then reduce the quantity
        		if((pliMap.size() > 0) && (pliMap.get(tmpKey) != null)){
        			//get the list of line items associated
        			pliCnt = pliMap.get(tmpKey);
        		}

        		if(lineItem.phdQuantity__c >= 0){
        			//if the quantity is greater than or equal to 0 then return to display in product line items list
        			if(((lineItem.phdQuantity__c == 0) && (pliCnt == 0)) || (lineItem.phdQuantity__c > pliCnt)){
        				//lineItem.phdQuantity__c = lineItem.phdQuantity__c - pliCnt;
        				returnlineItemList.add(lineItem);
        			}
        		}
        	}
        }

        return returnlineItemList;
    }

    @AuraEnabled
    public static string create_case(case caseis,String salesorder,Id contactname,String casetype, String casesubtype){
        system.debug('cae-->'+ caseis); 
        system.debug('add-->'+ caseis.Address__c);
        system.debug('salesorder-->'+ salesorder);
        Boolean flag=false;
        Boolean Addressflag=false;
        Contact contactid = new Contact();
        Address__c myAddress = new Address__c();
        try{
            contactid = [SELECT AccountId,Id FROM Contact WHERE AccountId =:contactname];
            flag = true;
        }
        catch(Exception e){
            
        }
        system.debug('flag-->'+ flag);
        try{
            myAddress = [SELECT id, AccountId__r.Id FROM Address__c WHERE id =:caseis.Address__c];
            Addressflag = true;
            
        }
        catch(Exception e){
            
        } 
        
        system.debug('Addressflag-->'+ Addressflag);
        if(flag==true){
            caseis.ContactId = contactid.Id;
        }
        else{
            caseis.ContactId = '';
        }
        if(Addressflag==true){
            caseis.Address__r.Id = caseis.Address__C;
        }
        else{
            myAddress = [SELECT id, AccountId__r.Id FROM Address__c WHERE AccountId__r.Id =:contactname Limit 1	];
            caseis.Address__r.Id = myAddress.Id;
        }
        
        
        System.debug('contactname-->'+contactname);
        String ownerId = caseis.OwnerId;
        caseis.Sales_Order__c = salesorder;
        caseis.Type = casetype;
        caseis.Sub_Type__c = casesubtype;
        system.debug('caseis insert values-->'+ caseis);
        insert caseis;
        return caseis.id;
    }
    @AuraEnabled
    public static string getRecordId(Id recordId) {
        SalesOrder__x salesOrderObj = new SalesOrder__x();
        if(Test.isRunningTest()){
            salesOrderObj = new SalesOrder__x(fulfillerID__c = '8888300-164',
                                              ExternalId = '204258:0012900000GRH2LAAX');
            
        }else{
            salesOrderObj = [SELECT ExternalId, fulfillerID__c, Id, phhProfitcenter__c, phhCustomerID__c 
                             FROM SalesOrder__x 
                             WHERE Id=:recordId];
        }
        
        return salesOrderObj.ExternalId;
    }  
    //Creating new line item and a respective case
    @AuraEnabled
    public static void newProductLineItemRecord(List<String> ProductId, Id caseId){
        //Id caseId = create_case(caseis);
        Case casee = [SELECT Id,Sales_Order__c FROM Case WHERE Id =:caseId];
        String salesorder = casee.Sales_Order__c;
        System.debug('my new Case Id'+caseId);
        createLineItem CLI = new createLineItem(caseId);
        createLineItem.newProductLineItemRecordwithCaseId2(ProductId,caseId,salesorder);
        
    }
}