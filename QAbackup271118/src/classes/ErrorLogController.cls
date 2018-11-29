/****** v1 | Description: Generic error log utility | 12/1/2017 | L OMeara */
public class ErrorLogController {
    /* internal log class */ 
    public class Log {
        public String ApexClass; 
        public String Method;
        public String Message;
        
        public Log(String cls, String routine, String msg) {
            this.ApexClass = cls; 
            this.Method = routine;
            this.Message = msg;
        }
    }
    @future
    public static void createLogFuture(String cls, String routine, String msg) {
         new ErrorLogController().createLog(new ErrorLogController.Log( cls, routine, msg));     
    }
    /* create log entries from a single log */
    public void createLog(Log logToCreate) {
        try {
            if ((Limits.getDmlRows() < Limits.getLimitDmlRows()) && 
                (Limits.getDmlStatements() < Limits.getLimitDmlStatements())) 
            {
                ErrorLog__c errorLog = new ErrorLog__c(
                    ApexClass__c = logToCreate.ApexClass, 
                    Method__c = logToCreate.Method, 
                    Message__c = logToCreate.Message
                );
                Database.insert(errorLog, FALSE);
            }else {
                System.debug('At Governor Limits. Cannot create log entry. ' + 
                             logToCreate.ApexClass + '.' + logToCreate.Method + ':' + 
                             logToCreate.Message);
            }
        } catch (DMLException ex) {
            System.debug('Fatal error creating log: ' + ex.getMessage());
        }
    }

    /* create log entries from a list */
    public void createLog(List<Log> logsToCreate) {
        try {
            List <ErrorLog__c> logsToInsert = new List<ErrorLog__c>(); 
            
            /* check governor limits before inserting logs - make sure we are able to insert */
            if ((Limits.getDmlRows() < Limits.getLimitDmlRows()) && 
                (Limits.getDmlStatements() < Limits.getLimitDmlStatements())) 
            {
                for (Log log : logsToCreate) {
                    logsToInsert.add(
                        new ErrorLog__c(
                            ApexClass__c = log.ApexClass, 
                            Method__c = log.Method, 
                            Message__c = log.Message
                        )
                    );
                }

                Database.insert(logsToInsert, FALSE);
            }else {
                /* who will log the logger? */
                System.debug('At Governor Limits. Cannot create log entries: ' + logsToCreate);
            }
        } catch (DMLException ex) {
            /* who will log the logger? */
            System.debug('Fatal error creating log: ' + ex.getMessage());
        }
    }
}