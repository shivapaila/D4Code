global class UpdateUnassignedContactsBatch implements Database.Batchable<sObject> {

    global Database.QueryLocator start(Database.BatchableContext BC) {
        // collect the batches of records or objects to be passed to execute
         
        String query = 'SELECT Id,Name, email__c FROM incomingemailattachment__c';
        return Database.getQueryLocator(query);
    }
     
    global void execute(Database.BatchableContext BC, List<incomingemailattachment__c> unasssignedContactList) {
        
        try {
           // list<string> contactEmails = new list<string>();
            map<Id, string> unassignedContMap = new map<Id, string>();
            
            for(incomingemailattachment__c unassignedCont : unasssignedContactList)
            {        
               // contactEmails.add(unassignedCont.contactemail__c);
                unassignedContMap.put(unassignedCont.Id, unassignedCont.email__c);
            }
            
            // Get Contacts from Email address
            list<Contact> contactList = new List<Contact>();
            contactList = [Select Id, Name, Email
                   FROM Contact
                   WHERE Email IN : unassignedContMap.values() ];
            System.debug('contactList: '+ contactList);
            
            if( contactList.size() > 0 ){
                
                // Get all attachments from unassigned contacts
                list<Attachment> attachments = new list<Attachment>();
                attachments = [Select Id, Name, Body, ParentId
                               from Attachment 
                               Where ParentId IN : unassignedContMap.keyset() ];
                System.debug('attachments: '+ attachments);

                // Create a map for attachments with unassigned contacts
                map<Id, list<Attachment>> attachmentMap = new map<Id, list<Attachment>>();
                for(Attachment attach: attachments){
                    if(attachmentMap.containsKey(attach.ParentId)) {
                        list<Attachment> attaches = attachmentMap.get(attach.ParentId);
                        attaches.add(attach);
                        attachmentMap.put(attach.ParentId, attaches);
                    } else {
                        attachmentMap.put(attach.ParentId, new list<Attachment> { attach });
                    }
                }
                System.debug('attachmentMap: '+ attachmentMap);

              // Get contacts from unassigned contacts and attach attachments into contacts
                list<Attachment> newAttachments = new list<Attachment>();
                set<Id> unasssignedContactIdsToDelete = new set<Id>();
                
              for(Contact cnt: contactList){
                    for(incomingemailattachment__c unassignedCont: unasssignedContactList){
                        if(cnt.Email == unassignedContMap.get(unassignedCont.Id) ){
                            // Add Unassigned contacts to delete 
                            unasssignedContactIdsToDelete.add(unassignedCont.Id);
                            
                            // Create attachments into contacts
              for(Attachment attach: attachmentMap.get(unassignedCont.Id) ){
                              Attachment attachment = new Attachment();
                                attachment.Name = attach.Name;
                                attachment.Body = attach.Body;
                                attachment.ParentId = cnt.id;
                                newAttachments.add(attachment);
                            }
                        }
                    }
                }
                System.debug('newAttachments: '+ newAttachments);  
                
                // Insert attachments in contacts 
                if( newAttachments.size() > 0 ){
                  insert newAttachments;
                }
                
                System.debug('unasssignedContactIdsToDelete: '+ unasssignedContactIdsToDelete);
                // Delete Unassigned contacts after those attachments attached to contacts
                if( unasssignedContactIdsToDelete.size() > 0 ){
                  delete [Select Id from incomingemailattachment__c Where Id IN: unasssignedContactIdsToDelete ];
                }
            }
            
        } catch(Exception e) {
            System.debug(e);
        }
         
    }   
     
    global void finish(Database.BatchableContext BC) {
        // execute any post-processing operations
  }
}