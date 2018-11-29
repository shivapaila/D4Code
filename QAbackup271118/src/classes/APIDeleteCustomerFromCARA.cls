/*
* Description: Delete or merge Accounts sent from CARA
* Author: Sudeshna Saha
* 
*/
@RestResource(urlMapping='/v1/contact-cleaning/*')
global class APIDeleteCustomerFromCARA {
    
    @HttpGet
    global static String doGet() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        System.debug('someval-->'+RestContext.request.requestUri);
        String someval = RestContext.request.requestUri.substringAfterLast('/');
        System.debug('someval-->'+someval);
        List<Account> myAcc = new List<Account>();
        /*
         * /services/apexrest/v1/contact-cleaning/DeleteContactId=001q000000raDkvAAE
         * /services/apexrest/v1/contact-cleaning/DeleteContactId=001q000000raDkvAAE&MergeContactId=001q000000raDkvAA3
         */ 
        Map<ID,Account> accountMap = new Map<ID,Account>();
        List<Account> accountList = new List<Account>();
        List<Case> caseList = new List<Case>();
        List<String> accList = new List<String>();
        accList = getVal(someval);
        accountList = getAccounts(accList);
        String responsemessage;
        if(accList.size()>0){
            if(!string.isBlank(accList[0]) && !string.isBlank(accList[1])){
                responsemessage = checkMergeAccount(accList);
            }
            else if (!string.isBlank(accList[1])){
                responsemessage = 'Invalid Data';
            }
            else{
                responsemessage = deleteAccount(accList[0]);
            }
        }
        return responsemessage;
    }
    public static String checkMergeAccount(List<String> accList) {
        String resmsg;
        Account AccounttoBeDeleted = new Account();
        Account AccounttoBeMerged = new Account();
        AccounttoBeDeleted = [SELECT BillingAddress,Email_2__pc,Email_Opt_In__pc,Facebook__pc,
                              FirstName,Id,Instagram__pc,LastName,PersonEmail,Phone,Phone_2_Type__pc,
                              Phone_2__pc,Phone_3_Type__pc,Phone_3__pc,Phone_Type__pc,Pinterest__pc,
                              Primary_Language__pc,Strike_Counter__pc,Type_of_Customer__pc FROM Account WHERE Id =:accList[0]];
        AccounttoBeMerged = [SELECT BillingAddress,Email_2__pc,Email_Opt_In__pc,Facebook__pc,
                             FirstName,Id,Instagram__pc,LastName,PersonEmail,Phone,Phone_2_Type__pc,
                             Phone_2__pc,Phone_3_Type__pc,Phone_3__pc,Phone_Type__pc,Pinterest__pc,
                             Primary_Language__pc,Strike_Counter__pc,Type_of_Customer__pc FROM Account WHERE Id =:accList[1]];
        if(AccounttoBeDeleted.Primary_Language__pc == AccounttoBeMerged.Primary_Language__pc){
            resmsg = mergeAccount(AccounttoBeDeleted,AccounttoBeMerged);
        }
        else{
            resmsg = 'Primary laguages are different. No changes has been made.';
        }
        return resmsg;
    }
    public static String mergeAccount(Account AccToDelete, Account AccToMerge){
        System.debug('Acc to del -->'+AccToDelete);
        System.debug('Acc to merge -->'+AccToMerge);
        String resmsg;
        Map<String,String> DelAccPhone = new Map<String,String>();
        Set<String> DelAccEmail = new Set<String>();
        Map<String,String> MergeAccPhone = new Map<String,String>();
        Set<String> MergeAccEmail = new Set<String>();
        Set<String> DelAccPhoneSet = new Set<String>();
        Set<String> MergeAccPhoneSet = new Set<String>();
        List<Address__c> DelAccAddresses = new List<Address__c>();
        List<Address__c> MergeAccAddresses = new List<Address__c>();
        Contact DeleteContact = new Contact();
        Contact MergeContact = new Contact();
        
        /*
* Get contact of the respective Account
* */
        DeleteContact = getContact(AccToDelete.Id);
        MergeContact = getContact(AccToMerge.Id);
        
        /*
* Assigning phone numbers and phone Type
* */
        DelAccPhone = getPhoneDetail(AccToDelete);
        MergeAccPhone = getPhoneDetail(AccToMerge);
        DelAccPhoneSet = DelAccPhone.keySet();
        System.debug('DelAccPhoneSet list-->'+DelAccPhoneSet);
        MergeAccPhoneSet = MergeAccPhone.keySet();
        for(String ph: MergeAccPhoneSet){
            if(DelAccPhoneSet.contains(ph))
                DelAccPhoneSet.remove(ph);
        }
        System.debug('DelAccPhoneSet updated-->'+DelAccPhoneSet);
        for(String ph: DelAccPhoneSet){
            if(AccToMerge.Phone == null || AccToMerge.Phone == ''){
                AccToMerge.Phone = ph;
                AccToMerge.Phone_Type__pc = DelAccPhone.get(ph);
                continue;
            }
            if(AccToMerge.Phone_2__pc == null || AccToMerge.Phone_2__pc == ''){
                AccToMerge.Phone_2__pc = ph;
                AccToMerge.Phone_2_Type__pc = DelAccPhone.get(ph);
                continue;
            }
            if(AccToMerge.Phone_3__pc == null || AccToMerge.Phone_3__pc == ''){
                AccToMerge.Phone_3__pc = ph;
                AccToMerge.Phone_3_Type__pc = DelAccPhone.get(ph);
                continue;
            }
        }
        
        /*
* Assigning Email Address
* */
        DelAccEmail = getEmailDetail(AccToDelete);
        System.debug('DelAccEmail-->'+DelAccEmail);
        MergeAccEmail = getEmailDetail(AccToMerge);
        for(String em: MergeAccEmail){
            if(DelAccEmail.contains(em))
                DelAccEmail.remove(em);
        }
        System.debug('DelAccEmail updated-->'+DelAccEmail);
        for(String em: DelAccEmail){
            System.debug('em-->'+em);
            if(AccToMerge.PersonEmail == null){
                AccToMerge.PersonEmail = em;
                System.debug('PersonEmail-->'+AccToMerge.PersonEmail);
                continue;
            }
            if(AccToMerge.Email_2__pc == null){
                AccToMerge.Email_2__pc = em;
                System.debug('Email_2__pc-->'+AccToMerge.Email_2__pc);
                continue;
            }
        }
        
        /*
* Assigning Strike Counter = sum of (AccToMerge,AccToDelete)
* */
        if(AccToDelete.Strike_Counter__pc != null){
            AccToMerge.Strike_Counter__pc += AccToDelete.Strike_Counter__pc;
        }
        
        /*
* Assigning Addresses of Delete Account to Merge Account
* 
* */
        DelAccAddresses = getAddress(AccToDelete.Id);
        MergeAccAddresses = getAddress(AccToMerge.Id);
        List<Address__c> UniqueDelAccAddresses = new List<Address__c>();
        List<Address__c> UniqueMergeAccAddresses = new List<Address__c>();
        UniqueDelAccAddresses = findUniqueAddress(DelAccAddresses);        
        UniqueMergeAccAddresses = findUniqueAddress(MergeAccAddresses);
        UniqueMergeAccAddresses = getAddressMerge(UniqueDelAccAddresses,UniqueMergeAccAddresses,MergeContact.Id,AccToMerge.Id);
        Upsert UniqueMergeAccAddresses;
        
        /*
* Assigning Cases of Delete Account to Merge Account
* 
* */
        List<Case> CaseToMove = new List<Case>();
        CaseToMove = getCases(AccToDelete.Id);
        if(CaseToMove.size() > 0){
            for(integer i=0; i < CaseToMove.size(); i++){
                CaseToMove[i].AccountId = AccToMerge.Id;
                CaseToMove[i].ContactId = MergeContact.Id;
                String SOId;
                if(CaseToMove[i].Sales_Order__c != null && CaseToMove[i].Sales_Order__c !=''){
                    CaseToMove[i].Sales_Order__c = CaseToMove[i].Sales_Order__c.substringBefore(':') + ':' + AccToMerge.Id;
                }
            }
        }
        Update CaseToMove;
        
        /*
* Assigning Opportunities of Delete Account to Merge Account
* 
* */
        List<Opportunity> OpportunityToMove = new List<Opportunity>();
        OpportunityToMove = getOpportunities(AccToDelete.Id);
        if(OpportunityToMove.size() > 0){
            for(integer i=0; i < OpportunityToMove.size(); i++){
                OpportunityToMove[i].AccountId = AccToMerge.Id;
           }
        }
        Update OpportunityToMove;
        
        /*
* Assigning Task of Delete Account to Merge Account
* 
* */
        List<Task> TaskToMove = new List<Task>();
        TaskToMove = getTasks(AccToDelete.Id);
        system.debug('TaskToMove-->'+TaskToMove);
        if(TaskToMove.size() > 0){
            for(integer i=0; i < TaskToMove.size(); i++){
                TaskToMove[i].WhatId = AccToMerge.Id;
                if(TaskToMove[i].WhoId != null)
                    TaskToMove[i].WhoId = null;
           }
        }
        system.debug('TaskToMove updated-->'+TaskToMove);
        Update TaskToMove;
        
        /*
* Assigning Event of Delete Account to Merge Account
* 
* */
        List<Event> EventToMove = new List<Event>();
        EventToMove = getEvents(AccToDelete.Id);
        system.debug('EventToMove-->'+EventToMove);
        if(EventToMove.size() > 0){
            for(integer i=0; i < EventToMove.size(); i++){
                EventToMove[i].WhatId = AccToMerge.Id;
                if(EventToMove[i].WhoId != null)
                    EventToMove[i].WhoId = null;
            }
        }
        system.debug('EventToMove updated-->'+EventToMove);
        Update EventToMove;
        
        /*
* Assigning File and Notes of Delete Account to Merge Account
* 
* */
        List<ContentDocumentLink> AttachmentToMove = new List<ContentDocumentLink>();
        AttachmentToMove = getAttachments(AccToDelete.Id);
        List<ContentDocumentLink> insertLinks = new List<ContentDocumentLink>();
        List<ContentDocumentLink> deleteLinks = new List<ContentDocumentLink>();
        for(ContentDocumentLink file: AttachmentToMove){
            ContentDocumentLink newclnk = file.clone();
            newclnk.linkedentityid = AccToMerge.Id;
            insertLinks.add(newclnk);
            deleteLinks.add(file);
        }
        insert insertLinks;
        Delete deleteLinks;
        
        /*
* Assigning Electronic Signature of Delete Account to Merge Account
* 
* */
        List<Electronic_Signature__c> ESToMove = new List<Electronic_Signature__c>();
        ESToMove = getES(AccToDelete.Id);
        if(ESToMove.size() > 0){
            for(integer i=0; i < ESToMove.size(); i++){
                ESToMove[i].AccountId__c = AccToMerge.Id;
           }
        }
        Update ESToMove;
        
        /*
* Assigning remove Delete Account and Update Merge Account
* 
* */
        System.debug('AccToMerge--->'+AccToMerge);
        Update AccToMerge;
        System.debug('AccToDelete--->'+AccToDelete);
        Delete AccToDelete;
        resmsg = 'Account merged and deleted successfully...';
        return resmsg;
    }
    public static List<Task> getTasks(Id accId){
        List<Task> getTask = new List<Task>();
        getTask = [select id,WhoId,WhatId,AccountId,Account__c
                        from Task where Account__c =:accId];
        return getTask;
    }
    public static List<Event> getEvents(Id accId){
        List<Event> getEvent = new List<Event>();
        getEvent = [select id,WhoId,WhatId,AccountId,Account__c
                        from Event where Account__c =:accId];
        return getEvent;
    }
    public static List<ContentDocumentLink> getAttachments(Id accId){
        List<ContentDocumentLink> getAttachment = new List<ContentDocumentLink>();
        getAttachment = [SELECT ContentDocumentId,Id,IsDeleted,LinkedEntityId,ShareType,SystemModstamp,Visibility 
                         FROM ContentDocumentLink 
                         WHERE LinkedEntityId =:accId];
        return getAttachment;
    }
    public static List<Opportunity> getOpportunities(Id accId){
        List<Opportunity> getOpportunities = new List<Opportunity>();
        getOpportunities = [select id,AccountId
                        from Opportunity where AccountId =:accId];
        return getOpportunities;
    }
    public static List<Electronic_Signature__c> getES(Id accId){
        List<Electronic_Signature__c> getES = new List<Electronic_Signature__c>();
        getES = [select id,AccountId__c
                 from Electronic_Signature__c where AccountId__c =:accId];
        return getES;
    }
    public static List<Address__c> getAddress(Id accId){
        List<Address__c> getAddresses = new List<Address__c>();
        getAddresses = [select id,AccountId__c,Address_Line_1__c,Address_Line_2__c,
                        StatePL__c,City__c,State__c,Zip_Code__c,Country__c,Address_Type__c,Preferred__c ,CreatedDate 
                        from Address__c where AccountId__c =:accId];
        return getAddresses;
    }
    public static List<Address__c> findUniqueAddress(List<Address__c> addressList){
        List<Address__c> UniqueAddressList = new List<Address__c>();
        Map<String, Address__c> dupAddressMap = new Map<String, Address__c>();
        Map<String, Address__c> uniqueAddressMap = new Map<String, Address__c>();
        Set<String> addIdset = new Set<String>();
        if(addressList.size() > 0 ){
            for(Address__c addr : addressList){
                addIdset.add(addr.Id);
            }
            list<Case> Caselist =new list<Case>();
            Caselist = [select id,Address__c from Case where Address__c in :addIdset];
            List<Case> CaselistToUpdate = new List<Case>();
            List<Address__c> AddressListToDelete = new List<Address__c>();
            for(Address__c addr: Addresslist){
                String dupAddress= addr.AccountId__c +'-'+ addr.Address_Line_1__c +'-'+ addr.Address_Line_2__c +'-'+ addr.Country__c+'-'+addr.StatePL__c+'-'+addr.City__c+'-'+addr.Zip_Code__c+'-'+addr.Address_Type__c;
                dupAddressMap.put(dupAddress,addr);
            }
            System.debug('dupAddressMap'+dupAddressMap);
            for(Address__c  addr: Addresslist){
                String dupNewAddress= addr.AccountId__c +'-'+ addr.Address_Line_1__c +'-'+ addr.Address_Line_2__c +'-'+ addr.Country__c+'-'+addr.StatePL__c+'-'+addr.City__c+'-'+addr.Zip_Code__c+'-'+addr.Address_Type__c;
                System.debug('dupNewAddress'+dupNewAddress);
                Address__c  existingAddress = uniqueAddressMap.get(dupNewAddress);
                System.debug('existingAddress-->'+existingAddress);
                if(existingAddress != null)
                {
                    /*
* get cases related to the address. Reassign with the existing Address
* And delete the duplicate address
*/
                    for(case cs : Caselist){
                        if(cs.Address__c == addr.Id){
                            cs.Address__c = existingAddress.Id;
                            CaselistToUpdate.add(cs);
                        }
                    }
                    AddressListToDelete.add(addr);
                }
                else{
                    uniqueAddressMap.put(dupNewAddress,addr);
                    UniqueAddressList.add(addr);
                }
            }
            System.debug('UniqueAddressList-->'+UniqueAddressList); 
            Upsert CaselistToUpdate;
            Delete AddressListToDelete;
        }
        return UniqueAddressList;
    }
    public static List<Address__c> getAddressMerge(List<Address__c> DelAccAddList,List<Address__c> MergeAccAddList, Id mergeConId, Id mergeAccId){
        List<Address__c> finalAddList = new  List<Address__c>();
        Map<String, Address__c> DelAccAddListMap = new Map<String, Address__c>();
        Map<String, Address__c> MergeAccAddListMap = new Map<String, Address__c>();
        Set<String> addIdset = new Set<String>();
        if(DelAccAddList.size() > 0 ){
            for(Address__c addr : DelAccAddList){
                addIdset.add(addr.Id);
            }
            List<Case> Caselist = new List<Case>();
            List<Case> CaselistToUpdate = new List<Case>();
            List<Address__c> AddressListToDelete = new List<Address__c>();
            Caselist = [select id,Address__c,Sales_Order__c  from Case where Address__c in :addIdset];
            for(Address__c addr: MergeAccAddList){
                String dupAddress= addr.Address_Line_1__c +'-'+ addr.Address_Line_2__c +'-'+ addr.Country__c+'-'+addr.StatePL__c+'-'+addr.City__c+'-'+addr.Zip_Code__c+'-'+addr.Address_Type__c;
                MergeAccAddListMap.put(dupAddress,addr);
            }
            System.debug('MergeAccAddListMap-->'+MergeAccAddListMap);
            for(Address__c  addr: DelAccAddList) {
                String dupNewAddress= addr.Address_Line_1__c +'-'+ addr.Address_Line_2__c +'-'+ addr.Country__c+'-'+addr.StatePL__c+'-'+addr.City__c+'-'+addr.Zip_Code__c+'-'+addr.Address_Type__c;
                System.debug('dupNewAddress'+dupNewAddress);
                Address__c  existingAddress = MergeAccAddListMap.get(dupNewAddress);
                System.debug('existingAddress-->'+existingAddress);
                if(existingAddress != null) {
                    /*
* get cases related to the address. Reassign with the existing Address
* And delete the duplicate address
*/
                    for(case cs : Caselist) {
                        if(cs.Address__c == addr.Id){
                            cs.AccountId = existingAddress.AccountId__c;
                            cs.ContactId = mergeConId;
                            cs.Address__c = existingAddress.Id;
                            if(cs.Sales_Order__c != null && cs.Sales_Order__c !=''){
                                cs.Sales_Order__c = cs.Sales_Order__c.substringBefore(':') + ':' + existingAddress.AccountId__c;
                            }
                            CaselistToUpdate.add(cs);
                        }
                    }
                    AddressListToDelete.add(addr);
                }
                else{
                    addr.AccountId__c = mergeAccId;
                    if(addr.Preferred__c){
                        for(Address__c ad: MergeAccAddList){
                            if(ad.Preferred__c){
                                if(addr.CreatedDate >= ad.CreatedDate){
                                    system.debug('newAd CreatedDate------->'+ad.CreatedDate);
                                    ad.Preferred__c = false;
                                    finalAddList.add(ad);
                                }
                                else{
                                    addr.Preferred__c = false;
                                    system.debug('newAd Preferred__c------->'+addr.Preferred__c);
                                }
                            }
                        }
                    }
                    MergeAccAddListMap.put(dupNewAddress,addr);
                    MergeAccAddList.add(addr);
                    finalAddList.add(addr);
                }
            }
            System.debug('MergeAccAddList-->'+MergeAccAddList);  
            Upsert CaselistToUpdate;
            Delete AddressListToDelete;
        }
        return finalAddList;
    }
    public static Contact getContact(Id accId){
        Contact getCon = new Contact();
        getCon = [SELECT ID, AccountId from Contact WHERE AccountId =: accId];
        return getCon;
    }
    public static List<Case> getCases(Id accId){
        List<Case> getCasee = new List<Case>();
        getCasee = [SELECT AccountId,Address_Line_1__c,Address_Line_2__c,Address__c,CaseNumber,
                    Case_Email__c,Case_Phone_Number__c,Category_Reason_Codes__c,City__c,Company__c,
                    ContactId,CreatedDate,Description,Estimated_time_for_stop__c,Follow_up_Date__c,
                    Id,Legacy_Account_Ship_To__c,Legacy_Assignee__c,Legacy_Priority__c,
                    Legacy_Service_Request_ID__c,Market__c,Origin,Reason,Request_Status__c,
                    Sales_Order__c,Status,Subject,Sub_Type__c,Tech_Scheduled_Date__c,LastModifiedDate,Type,
                    TechnicianNameScheduled__c
                    FROM Case WHERE AccountId =:accId];
        return getCasee;
    }
    public static Map<String,String> getPhoneDetail(Account accRec){
        Map<String,String> AccPhone = new Map<String,String>();
        if(accRec.Phone != null && accRec.Phone != '')
            AccPhone.put(accRec.Phone,accRec.Phone_Type__pc);
        if(accRec.Phone_2__pc != null && accRec.Phone_2__pc != '')
            AccPhone.put(accRec.Phone_2__pc,accRec.Phone_2_Type__pc);
        if(accRec.Phone_3__pc != null && accRec.Phone_3__pc != '')
            AccPhone.put(accRec.Phone_3__pc,accRec.Phone_3_Type__pc);
        return AccPhone;
    }
    public static Set<String> getEmailDetail(Account accRec){
        System.debug('accRec--->'+accRec);
        Set<String> AccEmail = new Set<String>();
        if(accRec.PersonEmail != null && accRec.PersonEmail != '')
            AccEmail.add(accRec.PersonEmail);
        if(accRec.Email_2__pc != null && accRec.Email_2__pc != '')
            AccEmail.add(accRec.Email_2__pc);
        System.debug('AccEmail--->'+AccEmail);
        return AccEmail;
    }
    public static String deleteAccount(String deleteAccountId) {
        boolean delFlag = false;
        String resmsg;
        try{
            Account deleteAccount = [SELECT Id FROM Account WHERE Id =:deleteAccountId];
            Delete deleteAccount;
            delFlag = true;
            resmsg = 'Account deleted successfully..';
        }
        catch(exception ex){
            resmsg = 'Account deletion failed..';
        }
        return resmsg;
    }
    public static List<String> getVal(String someval) {
        System.debug('getVal someval-->'+someval);
        String accIds;
        List<String> accountIds =new List<String>();
        accIds = someval.substringAfter('DeleteContactId=');
        accIds = accIds.substringBefore('&MergeContactId=');
        accountIds.add(accIds);
        accIds = someval.substringAfter('&MergeContactId=');
        if(string.isBlank(accIds)){
            accIds = null;
        }
        accountIds.add(accIds);
        System.debug('AccList-->'+accountIds);
        return accountIds;
    }
    public static List<Account> getAccounts(List<String> accList) {
        List<Account> accountList = new List<Account>();
        return accountList;
    }
}