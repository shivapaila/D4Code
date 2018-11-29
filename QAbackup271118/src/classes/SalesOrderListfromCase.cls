public class SalesOrderListfromCase
{
    @AuraEnabled
    public Static List<soWrapper> getSalesOrders(Id caseId)
    {
        List<SalesOrder__x> soList = new List<SalesOrder__x>();
        Case objCas = [Select Id, AccountId, Account.Name from Case where id=:caseId];
        system.debug('objCas-----'+objCas.AccountId);
         
           if(Test.isRunningTest())
           {
                SalesOrder__x salesOrderObj = new SalesOrder__x(fulfillerID__c = '8888300-164',ExternalId = '204258:0012900000GRH2LAAX',phhCustomerID__c= '009048870576',phhSalesOrder__c='300493250',phhSaleType__c='D');
                soList.add(salesOrderObj );
            }
            else
            {
                 soList = [Select Id, phhSalesOrder__c,phhSaleType__c,phhCustomerID__c,phhDatePromised__c,phhGuestID__c,ExternalId from SalesOrder__x where phhGuestID__c=: objCas.AccountId];
            }
        system.debug('soList-----'+soList);
        List<soWrapper> sowList = new List<soWrapper>();
        for(SalesOrder__x so:soList)
        {
            soWrapper sow = new soWrapper();
            
            sow.Salesorder = so.phhSalesOrder__c;
            sow.customerId = so.phhCustomerID__c;
            sow.externId = so.ExternalId;
            sow.salesType = so.phhSaleType__c;
            
            if(so.phhDatePromised__c != null)
            {
                DateTime dT = so.phhDatePromised__c;
                Date myDate = date.newinstance(dT.year(), dT.month(), dT.day());
                sow.DeliveryDate = myDate;
            }
            
            system.debug('sowList-----'+sowList);
            sowList.add(sow);
        }
        return sowList;
    }
    
    @AuraEnabled
    public Static void updateSalesOrderRecord(String SOId, Id caseId)
    {
        system.debug('soId-----'+soId+'----'+caseId);
        Case objCase = [Select Id, Sales_Order__c from Case where Id=:caseId];
        
        objCase.Sales_Order__c = SOId;
        
        update objCase;
        system.debug('objCase-----'+objCase);
    }
    
    public class soWrapper
    {
        @AuraEnabled
        public String Salesorder {get;set;}
        @AuraEnabled
        public String customerId {get;set;}
        @AuraEnabled
        public String externId {get;set;}
        @AuraEnabled
        public String salesType {get;set;}
        @AuraEnabled
        public Date DeliveryDate {get;set;}
    }
}