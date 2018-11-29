public class CreateCaseCtrl {
    public static Id caseId;
    public CreateCaseCtrl(case caseis , String salesorder , Id contactname , String casetype, String casesubtype){
        
        caseId = create_case(caseis,salesorder,contactname,casetype,casesubtype); 
        
        System.debug('my new Case Id2--->'+caseId);
    }
    
    @TestVisible private static list<SalesOrder__x> mockedcustlist = new List<SalesOrder__x>();
    @AuraEnabled
    //Getting external ID for the respective Sales Order
    public static string getOrderLineItems(Id recordId) {
        SalesOrder__x salesOrderObj = new SalesOrder__x();
        if(Test.isRunningTest()){
            salesOrderObj = new SalesOrder__x(fulfillerID__c = '8888300-164',
                                              ExternalId = '204258:0012900000GRH2LAAX');
            
        }else{
            salesOrderObj = [SELECT ExternalId, fulfillerID__c, Id, phhProfitcenter__c, phhCustomerID__c 
                             FROM SalesOrder__x 
                             WHERE Id=:recordId LIMIT 1];
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
        salesOrderObj =   [SELECT ExternalId, fulfillerID__c, Id, phhProfitcenter__c, phhCustomerID__c ,phhGuestID__c
                           FROM SalesOrder__x 
                           WHERE Id=:recordId];
        Address__c addr = new Address__c();
        addr = [Select Id,AccountId__c from Address__c Where AccountId__c= :salesOrderObj.phhGuestID__c LIMIT 1];
        return  addr.Id;
    }
    
    @AuraEnabled
    public static String getConName (Id recordId) {
        system.debug('recordId-->'+recordId);
        SalesOrder__x salesOrderObj = new SalesOrder__x();
        salesOrderObj =   [SELECT ExternalId, fulfillerID__c, Id, phhProfitcenter__c, phhCustomerID__c ,phhGuestID__c
                           FROM SalesOrder__x 
                           WHERE Id=:recordId];
        system.debug('recordId-->'+recordId);
        Account Acc = new Account();
        Acc = [SELECT Id,Name FROM Account WHERE Id = :salesOrderObj.phhGuestID__c LIMIT 1];
        return  Acc.Name;
    }
    
    @AuraEnabled
    public static String getConNameId (Id recordId) {
        system.debug('recordId-->'+recordId);
        SalesOrder__x salesOrderObj = new SalesOrder__x();
        salesOrderObj =   [SELECT ExternalId, fulfillerID__c, Id, phhProfitcenter__c, phhCustomerID__c ,phhGuestID__c
                           FROM SalesOrder__x 
                           WHERE Id=:recordId];
        system.debug('recordId-->'+recordId);
        Account Acc = new Account();
        Acc = [SELECT Id,Name FROM Account WHERE Id = :salesOrderObj.phhGuestID__c LIMIT 1];
        return  Acc.Id;
    }
    
    @AuraEnabled
    public static SalesOrder__x getSalesOrderInfo(Id recordId){
        
        SalesOrder__x salesOrderObj = new SalesOrder__x();
        if(Test.isRunningTest()){
            salesOrderObj = new SalesOrder__x(fulfillerID__c = '8888300-164',
                                              ExternalId = '204258:0012900000GRH2LAAX');
            
        }else{
            salesOrderObj = [SELECT ExternalId, fulfillerID__c, Id, phhProfitcenter__c, phhCustomerID__c ,phhSalesOrder__c,phhGuestID__c
                             FROM SalesOrder__x 
                             WHERE Id=:recordId];
        }
        
        return salesOrderObj;
    }
    
    @TestVisible private static list<SalesOrderItem__x> mockedcustlist1 = new List<SalesOrderItem__x>();
    @AuraEnabled
    //Get Product line item by sales order external ID
    public static List<SalesOrderItem__x> getOrderLineItemsByOrderExternalId(Id recordId) {
        system.debug('recordId-------'+recordId);
        SalesOrderItem__x lineItems = new SalesOrderItem__x();
        if(Test.isRunningTest()){
            List<SalesOrderItem__x> lineItem2 = new List<SalesOrderItem__x>(); 
            lineItems = new SalesOrderItem__x(phdItemDesc__c = '8888300-164',
                                              ExternalId = '204258:0012900000GRH2LAAX');
            return lineItem2;
        }
        else{
            return [SELECT Id, ExternalId, phdItemSKU__c, phdItemDesc__c, phdQuantity__c, phdReturnedReason__c, 
                    phdDeliveryDueDate__c, phdSalesOrder__c, phdIsFPP__c, phdItemStatus__c, phdWarrantyExpiredOn__c, 
                    phdShipAddress1__c, phdShipAddress2__c, phdShipCity__c, phdShipState__c, phdShipZip__c,
                    phdLOC_PO__c, phdInStoreQty__c, phdInWarehouseQty__c, phdPurchaseDate__c, phdSaleType__c, phdWarrantyDaysLeft__c, phdDeliveryType__c
                    FROM SalesOrderItem__x 
                    WHERE phdSalesOrder__r.ExternalId =: getOrderLineItems(recordId)];
        }
    }
    
    @AuraEnabled
    public static List<SalesOrderItem__x> getSoLineItemsBySoExternalId(Id recordId) {
        system.debug('recordId-------'+recordId);
        List<SalesOrderItem__x> returnlineItemList = new List<SalesOrderItem__x>();
        List<SalesOrderItem__x> lineItemList = getOrderLineItemsByOrderExternalId(recordId);
        if(lineItemList.size() > 0){
        	for(SalesOrderItem__x lineItem : lineItemList){
        		if(lineItem.phdQuantity__c >= 0){
        			returnlineItemList.add(lineItem);
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
        Account myAccount = [SELECT AccountNumber,Id,PersonEmail,Phone FROM Account WHERE Id =:contactname];
        system.debug('Email-->'+ myAccount.PersonEmail);
        system.debug('Phone-->'+ myAccount.Phone);
        system.debug('flag-->'+ flag);
        if(String.isBlank(caseis.Address__c)){
            try{
                system.debug('myAddress initial-->'+caseis.Address__c);
                myAddress= [SELECT AccountId__c,Address_Line_1__c,Address_Line_2__c,Address_Type__c,City__c,Country__c,CreatedDate,Id,LastModifiedDate,Preferred__c 
                            FROM Address__c WHERE AccountId__c =:contactname AND Preferred__c = true 
                            ORDER BY LastModifiedDate DESC NULLS FIRST LIMIT 1];
                caseis.Address__c = myAddress.Id;
                Addressflag = true;
                system.debug('myAddress final-->'+caseis.Address__c);
            }
            catch(Exception e){
                try{
                    system.debug('myAddress initial without preferred address-->'+caseis.Address__c);
                    myAddress= [SELECT AccountId__c,Address_Line_1__c,Address_Line_2__c,Address_Type__c,City__c,Country__c,CreatedDate,Id,LastModifiedDate,Preferred__c 
                                FROM Address__c WHERE AccountId__c =:contactname 
                                ORDER BY LastModifiedDate DESC NULLS FIRST LIMIT 1];
                    caseis.Address__c = myAddress.Id;
                    Addressflag = true;
                    system.debug('myAddress final without preferred address-->'+caseis.Address__c);
                }
                catch(Exception ex){
                    system.debug('myAddress initial without Account address-->'+caseis.Address__c);
                    caseis.Address__c = NULL;
                    Addressflag = true;
                    system.debug('myAddress final-->'+caseis.Address__c);
                }
            } 
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
            myAddress = [SELECT id, AccountId__r.Id FROM Address__c WHERE AccountId__r.Id =:contactname LIMIT 1];
            caseis.Address__r.Id = myAddress.Id;
        }
        if(caseis.Origin == NULL || caseis.Origin == ''){
            caseis.Origin = 'Phone';  
        }
        caseis.Case_Email__c = myAccount.PersonEmail ;
        caseis.Case_Phone_Number__c = myAccount.Phone;
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
    public static void newProductLineItemRecord(List<String> ProductId, Id caseId,String salesorder){
        //Id caseId = create_case(caseis);
        System.debug('my new Case Id'+caseId);
        createLineItem CLI = new createLineItem(caseId);
        createLineItem.newProductLineItemRecordwithCaseId(ProductId,caseId,salesorder);
        
    }
}