/****** v1 | Description: Endpoint to update store information on user record | 1/30/2018 | L OMeara */
@RestResource(urlMapping='/User/StoreInformation/*')
global with sharing class API_UpdateUserStoreInfo {
    @HttpPost
    global static void updateStoreInfo() {
        Savepoint sp = Database.setSavepoint();
        try {
            RestRequest request = RestContext.request;
            JSONParser parser = JSON.createParser(request.requestBody.toString());
            system.debug('parser' + parser);
            User userToUpdate = (User)parser.readValueAs(User.class);
            update userToUpdate;
        } catch (Exception e) {
            // error handling & reporting
            Database.rollback(sp);

            system.debug(e.getMessage() + ' ' + e.getStackTraceString());

            new ErrorLogController().createLog(
                new ErrorLogController.Log(
                    'API_UpdateUserStoreInfo',
                    'updateStoreInfo',
                    'User update entry Exception: ' + e.getMessage() +
                    ' Stack Trace: ' + e.getStackTraceString()
                )    
            );
        }
    }
}