global class UpdAdrStateBatch implements Database.Batchable<sObject> {

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([SELECT Id, State__c, StatePL__c FROM Address__c]); 
    }

    global void execute(Database.BatchableContext bc, List<Address__c> adrList) {
        List<string> statePlList = new List<string> ();
        Schema.DescribeFieldResult fieldResult = Address__c.StatePL__c.getDescribe();
        List<schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for (schema.PicklistEntry f : ple) {
            if(f.isActive()) {
                statePlList.add(f.getValue());
            }
        }

        for(Address__c adr : adrList) {
            if(!string.isBlank(adr.State__c)) {
                if(statePlList.contains(adr.State__c)) {
                    adr.StatePL__c = adr.State__c;
                } else if(adr.State__c == 'FLORIDA') {
                    adr.StatePL__c = 'FL';
                } else if(adr.State__c == 'Minnesota') {
                    adr.StatePL__c = 'MN';
                } else if(adr.State__c == 'N') {
                    adr.StatePL__c = 'NE';
                } else if(adr.State__c == 'Ohio') {
                    adr.StatePL__c = 'OH';
                } else {
                    adr.StatePL__c = null;
                }
            }
            else {
                adr.StatePL__c = null;
            }
        }

        Database.SaveResult[] srList = Database.update(adrList, false);
        List<string> errMsgList = new List<string>();
        for(Database.SaveResult sr : srList) {
            if(!sr.isSuccess()) {
                for(Database.Error err : sr.getErrors()) {
                    system.debug(err.getStatusCode() + ': ' + err.getMessage());
                    errMsgList.add(err.getStatusCode() + ': ' + err.getMessage());
                }
            }
        }

        if(errMsgList.size() > 0) {
            //insert in ErrorLog__c object
            ErrorLog__c errLog = new ErrorLog__c(Name = 'State PL Update Batch Error', ApexClass__c = 'UpdAdrStateBatch', Method__c = 'execute', Message__c = string.join(errMsgList,' | '));
            insert errLog;
        }
    }

    global void finish(Database.BatchableContext bc) {}
}