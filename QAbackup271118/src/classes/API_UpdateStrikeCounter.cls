/* This is an Apex Rest API exposed for  Ashley backend systems to increment the strike counter on a person Account. The strike counter 
 * indicates the number of times a customer was wronged by Ashely and will be used by Customer Care reps to give special attention to 
 * customers that have high strike counts. Some events in salesforce will increase the count as well as events external to salesforce which 
 * will use this API to increment the count. 
 */
@RestResource(urlMapping='/Customer/UpdateStrikeCounter/*')
global with sharing class API_UpdateStrikeCounter {

    /**
     * Increments strike counter by one for Contacts passed in request.
     * @param  customerIDs list of salesforce Person Account Ids
     * @return a list of API_BaseResponse instances that will indicate the success/failure of each strike counter update
     */
	@HttpPatch
    global static List<API_BaseResponse>  doPatch(List<Id> customerIDs) {
    	List<API_BaseResponse> response = new List<API_BaseResponse>();
        Map<Id,string> updateErrorMap = new Map<Id,String>();
        Set<Id> successfullyUpdatedCustomerIds = new Set<Id>();

    	List<Account> customers = [Select Id, Strike_Counter__pc 
                                  from Account 
                                  where Id in: customerIDs and IsPersonAccount = true];
        if(!customers.isEmpty()){
        	for(Account a: customers){
        		a.Strike_Counter__pc = (a.Strike_Counter__pc > 0 ? a.Strike_Counter__pc : 0) + 1;
        	}

        	Database.SaveResult[] saveResults = Database.update(customers, false);       	

        	for(Database.SaveResult sr: saveResults){
        		if(!sr.isSuccess()){
        			updateErrorMap.put(sr.getId(), sr.getErrors()[0].message);
        		}
        		else{
        			successfullyUpdatedCustomerIds.add(sr.getId());
        		}
        	}
        }

    	for(Id customerID: customerIDs){
    		API_BaseResponse baseResponse = new API_BaseResponse();
    		baseResponse.uniqueId = customerID;
    		if(updateErrorMap.get(customerID) != null){
    			baseResponse.isSuccess = false;
    			baseResponse.message = updateErrorMap.get(customerID);
    		}
    		else if(successfullyUpdatedCustomerIds.contains(customerID)){
    			baseResponse.isSuccess = true;
    		}
    		else{
    			baseResponse.isSuccess = false;
    			baseResponse.message = Label.Strike_Counter_Update_Invalid_Contact_Id_Error;
    		}
    		response.add(baseResponse);
    	}

       return response;
    }

}