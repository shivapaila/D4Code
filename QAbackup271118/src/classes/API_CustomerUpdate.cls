/****** v1 | Description: Customer update endpoint | 12/13/2017 | L OMeara */
@RestResource(urlMapping='/UpdateCustomer/*')
global with sharing class API_CustomerUpdate {
    
    /* patch endpoint to update customers */
	@HttpPatch
    global static CustomerResponseWrapper updateCustomerInfo() {
        CustomerResponseWrapper result = new CustomerResponseWrapper ();
        result.message = 'success';
        result.isSuccess = true;
        // to switch off the integration that sends accounts and addresses back to CARA
        API_CaraAccountUpdates.accountsToCARACodeLevelFlag = false;
        Savepoint sp = Database.setSavepoint();
        
        try {
            RestRequest request = RestContext.request;
            List<CustomerWrapper> customerList = APIParseHelper.parseCustomerRequest(request.requestBody.toString());
            result.createdIds = AddCustomerController.updateAllCustomerRecords(customerList);
        } catch (Exception e) {
            Database.rollback(sp);
            system.debug(e.getMessage());

            new ErrorLogController().createLog(
                new ErrorLogController.Log(
                    'API_CustomerUpdate', 
                    'updateCustomerInfo', 
                    'Customer Update, update customer Exception: ' + e.getMessage() + 
		            ' Stack Trace: ' + e.getStackTraceString()
                )
			);
            
            RestContext.response.statusCode = 500;
            result.message = e.getMessage();
            result.isSuccess = false;
        }
        
        return result;
    }
}