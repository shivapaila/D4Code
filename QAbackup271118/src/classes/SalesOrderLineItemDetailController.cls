/* This is a controller clas for SalesOrderLineItemDetail lightning component. The Component is used to display detail information About the lne item which might 
not be available in the Limited Information available for Line Items in the custom related list for line items.*/
public with sharing class SalesOrderLineItemDetailController {
	@AuraEnabled
	public static OrderLineWrapper getLineItem(String lineItemExternalId, string OrderId) {
		OrderLineWrapper wrapper = new OrderLineWrapper();
        system.debug('lineItemExternalId-------'+lineItemExternalId);
		SalesOrderItem__x lineItem = SalesOrderDAO.getOrderLineItemByExternalId(lineItemExternalId);
		SalesOrder__x order = SalesOrderDAO.getOrderById(OrderId);

		wrapper.lineItem = lineItem;
		wrapper.orderExternalId = order.ExternalId;

		//drive the account number/rdc id from fulfiller Id
		if(order.fulfillerID__c != null && order.fulfillerID__c.contains('-')){
			List<String> parts = order.fulfillerID__c.split('-');
			wrapper.orderAccountNumber = parts[0];
			wrapper.orderRdcId = parts[1];
		}
		 return wrapper;
	}


    
       public static string getfulfillerId(string lineItemExternalId,string OrderId){
          
         SalesOrderItem__x lineItem = SalesOrderDAO.getOrderLineItemByExternalId(lineItemExternalId);
         SalesOrder__x salesOrderObj = new SalesOrder__x();
         if(Test.isRunningTest()){
             salesOrderObj = new SalesOrder__x(fulfillerID__c = '8888300-164',
                                                         ExternalId = '204258:0012900000GRH2LAAX');

         }else{
            salesOrderObj = [SELECT ExternalId, fulfillerID__c, Id, phhProfitcenter__c, phhCustomerID__c 
                                    FROM SalesOrder__x 
                                    WHERE ExternalId =: lineItemExternalId];
         }
         system.debug('SO Obj Full fill: '+ salesOrderObj);
        return salesOrderObj.fulfillerID__c;
     }
    
    @AuraEnabled
    public static String getQuantity(String lineItemExternalId, string OrderId ) {
 	SalesOrder__x order = SalesOrderDAO.getOrderById(OrderId);
       String fulfiller = order.fulfillerID__c;
       Decimal profitcenter = order.phhProfitcenter__c;
   
    SalesOrderItem__x lineItem = SalesOrderDAO.getOrderLineItemByExternalId(lineItemExternalId);
       String sku = lineItem.phdItemSKU__c;
      String endpoint = system.label.AshleyApigeeEndpoint + fulfiller +'/inventory/api/inventory/available-items/'+ sku + '?profitcenter='+profitcenter;
   // String endpoint =     'https://ashley-preprod-qa.apigee.net/homestores/8888300-164/inventory/api/inventory/available-items/B175-46?profitcenter=23';
       system.debug('log' + order);
          Http http = new http();
          Httprequest req = new HttpRequest();
          req.setHeader('apikey', system.label.AshleyApigeeApiKey);
          req.setEndpoint(endpoint);
        system.debug('enpoint' + endpoint);
          req.setTimeOut(120000);
          req.setMethod('GET');
          HttpResponse res = http.send(req);


          System.debug('apiresponse...' + res.getBody());
        	system.debug('apiresponse...' + res.getStatusCode());
        if(res.getStatusCode()==200) {
          return res.getBody();
        } else {
              String errMsg='No records founds--';  
                AuraHandledException ex = new AuraHandledException(errMsg);
                return errMsg;
        }
   }
    
    @AuraEnabled
    public static String getLOC(String lineItemExternalId, string OrderId ) {
 	SalesOrder__x order = SalesOrderDAO.getOrderById(OrderId);
       String fulfiller = order.fulfillerID__c;
       String salesordernumber = order.phhSalesOrder__c;
       Decimal profitcenter = order.phhProfitcenter__c;
   	   String itemsequencenumber = lineItemExternalId;
        List<String> splititem = new list<String>();
        for(String s : itemsequencenumber.split(':'))
        {
            splititem.add(s);
            system.debug('stringva' + splititem);
        }
        String itemsequencenumberforcallout = splititem[2];
        
       system.debug('itemid' + itemsequencenumberforcallout);
    SalesOrderItem__x lineItem = SalesOrderDAO.getOrderLineItemByExternalId(lineItemExternalId);
       String sku = lineItem.phdItemSKU__c;
      String endpoint = system.label.AshleyApigeeEndpoint + fulfiller +'/inventory/api/' + salesordernumber + '/location/'+ sku + '/'+itemsequencenumberforcallout;
   // String endpoint =     'https://ashley-preprod-qa.apigee.net/homestores/8888300-164/inventory/api/inventory/available-items/B175-46?profitcenter=23';
       system.debug('log' + order);
          Http http = new http();
          Httprequest req = new HttpRequest();
          req.setHeader('apikey', system.label.AshleyApigeeApiKey);
          req.setEndpoint(endpoint);
        system.debug('enpoint' + endpoint);
          req.setTimeOut(120000);
          req.setMethod('GET');
          HttpResponse res = http.send(req);


          System.debug('apiresponse...' + res.getBody());
        	system.debug('apiresponse...' + res.getStatusCode());
        if(res.getStatusCode()==200) {
          return res.getBody();
        } else {
              String errMsg='No records founds--';  
                AuraHandledException ex = new AuraHandledException(errMsg);
                return errMsg;
        }
   }
    
	public class OrderLineWrapper implements Attributable{
		@AuraEnabled
		public SalesOrderItem__x lineItem {get;set;}
		@AuraEnabled
		public string orderExternalId {get;set;}
		@AuraEnabled
		public string orderRdcId {get;set;}
		@AuraEnabled
		public string orderAccountNumber {get;set;}
	}
}