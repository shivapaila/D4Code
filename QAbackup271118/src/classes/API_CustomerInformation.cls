/****** v1 | Description: Customer information endpoints | 12/1/2017 | L OMeara */
@RestResource(urlMapping='/CreateCustomer/*')
global with sharing class API_CustomerInformation {

    /* post endpoint to create customers */
	@HttpPost
    global static CustomerResponseWrapper addCustomerInfo() {
        CustomerResponseWrapper result = new CustomerResponseWrapper ();
        result.message = 'success';
        result.isSuccess = true;
        // to switch off the integration that sends accounts and addresses back to CARA
        API_CaraAccountUpdates.accountsToCARACodeLevelFlag = false;
        
        Savepoint sp = Database.setSavepoint();
        
        try {
            RestRequest request = RestContext.request;
            List<CustomerWrapper> customerList = APIParseHelper.parseCustomerRequest(request.requestBody.toString());

            result.createdIds = AddCustomerController.createAllCustomerRecords(customerList);

        } catch (Exception e) {
            Database.rollback(sp);
            system.debug(e.getMessage());

            new ErrorLogController().createLog(
                new ErrorLogController.Log(
                    'API_CustomerInformation', 
                    'addCustomerInfo', 
                    'Customer Add, create customer Exception: ' + e.getMessage() + 
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