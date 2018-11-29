global class CustomerResponseWrapper {
    global boolean isSuccess {get;set;}
    global string message {get;set;}
    global List<CustomerIdStruct> createdIds {get;set;}
    
    global class CustomerIdStruct {
        global ID sfId {get;set;}
        global String globalID {get;set;}
        public CustomerIdStruct(String gid, ID contactId) {
            globalID = gid;
            sfId = contactId;
        }
    }
}