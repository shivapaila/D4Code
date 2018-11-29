/****** v1 | Description: Test coverage for error log utility | 12/1/2017 | L OMeara */
@isTest
public class ErrorLogController_Test {
    /* test method for creating a single log entry */
	testMethod
    static void createErrorLog() {
        try {
            Integer result = 1/0;
        } catch (Exception ex) {
            new ErrorLogController().createLog(
                new ErrorLogController.Log(
                    'ErrorLogController_Test', 
                    'createErrorLog', 
                    'This is the test exception error: ' + ex.getMessage()
				)
			);

			List <ErrorLog__c> logsCreated = [ SELECT Id, ApexClass__c, Method__c, Message__c 
                                               FROM ErrorLog__c
                                               WHERE Method__c = 'createErrorLog'];
			System.assertEquals(1, logsCreated.size());
			System.assertEquals('ErrorLogController_Test', logsCreated.get(0).ApexClass__c);            
			System.assertEquals('createErrorLog', logsCreated.get(0).Method__c);            
        }
    }

    /* test method for creating a list of log entries */
    testMethod
    static void createErrorLogs() {
        List <Account> accounts = new List<Account>{
            new Account(), new Account(), new Account()
        };
       	Database.SaveResult[] results = Database.insert(accounts, FALSE);
        
        List <ErrorLogController.Log> logs = new List<ErrorLogController.Log>();
        for (Database.SaveResult result : results) {
            if (!result.isSuccess()) {
                for (Database.Error err : result.getErrors()) {
                    logs.add(new ErrorLogController.Log(
                        'ErrorLogController_Test', 
                        'createErrorLogs', 
                        'This is the test exception error: ' + err.getMessage() + 
                        ' status code: ' + err.getStatusCode() + 
                        ' fields: ' + err.getFields()
                    ));                      
                }
            }
        }
        
        new ErrorLogController().createLog(logs);
        
        List <ErrorLog__c> logsCreated = [ SELECT Id, ApexClass__c, Method__c, Message__c 
                                          FROM ErrorLog__c
                                          WHERE Method__c = 'createErrorLogs'];
        System.assertEquals(3, logsCreated.size());
        System.assertEquals('ErrorLogController_Test', logsCreated.get(0).ApexClass__c);            
        System.assertEquals('createErrorLogs', logsCreated.get(0).Method__c);  
    }
}