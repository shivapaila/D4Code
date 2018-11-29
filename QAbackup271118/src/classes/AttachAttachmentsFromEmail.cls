global class AttachAttachmentsFromEmail implements Messaging.InboundEmailHandler {
 
  global Messaging.InboundEmailResult handleInboundEmail(Messaging.inboundEmail email, 
                                                       Messaging.InboundEnvelope env){
 
    // Create an InboundEmailResult object for returning the result of the 
    // Apex Email Service
    Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
    String sMessage;
    String myPlainText= '';
    
    // Add the email plain text into the local variable 
    myPlainText = email.plainTextBody;
   
    // New Attchment object to be created
    Attachment[] newAttachment = new Attachment[0];
   
    try {
      map<Id,String> contactMap = new map<Id,String>();
      for(Account cont:[SELECT Id,Name, 
                        PersonEmail,Email_2__pc,Email_Opt_In__pc FROM Account WHERE
                        PersonEmail IN :email.toAddresses ]) {
          contactMap.put(cont.Id,cont.PersonEmail);
          }

          list<string> availableEmails = new List<string>();
          list<String> unavailableEmails = new List<string>();

      for(string toAdd :email.toAddresses) {
          if(contactMap.values().contains(toAdd)) {
            availableEmails.add(toAdd);
          } else {
            unavailableEmails.add(toAdd);
           }
        }


      List<Attachment> attachments = new List<Attachment>();

      if(availableEmails.size()>0) {
        list<Account> contactList = [SELECT Id, PersonEmail FROM Account WHERE PersonEmail IN : availableEmails];
        
      // If Contacts found
      if( contactList.size() > 0 ){
           
         for(Account cnt: contactList){
             
           if(email.textAttachments != null) {
              for(Messaging.InboundEmail.textAttachment tAttachment : email.textAttachments) {
                    Attachment attachment = new Attachment();
                    attachment.Name = tAttachment.fileName;
                    attachment.Body = Blob.valueOf(tAttachment.body);
                    attachment.ParentId = cnt.id;
                    attachments.add(attachment);
                }    
             }
             
             if(email.binaryAttachments !=null){
              for(Messaging.InboundEmail.binaryAttachment bAttachment :email.binaryAttachments) {
                   Attachment attachment = new attachment();
                  attachment.Name  = bAttachment.fileName;
                  attachment.Body = bAttachment.body;
                  attachment.Parentid = cnt.id;
                  attachments.add(attachment);
              }
            }
          }
        }
      }

    if(unavailableEmails.size()>0) {
        list<incomingemailattachment__c> unassgdmail = new list<incomingemailattachment__c>();
          
        for(string toAdd : unavailableEmails) {
            incomingemailattachment__c unassignedmails = new incomingemailattachment__c();
            unassignedmails.email__c = toAdd;
            unassgdmail.add(unassignedmails);
          }

          //insert Unassignedmails
          insert unassgdmail;

          for(incomingemailattachment__c unassignedmails: unassgdmail) {
       
          if(email.textAttachments != null) {
              for(Messaging.InboundEmail.textAttachment tAttachment : email.textAttachments) {
                  Attachment attachment = new Attachment();
                  attachment.Name = tAttachment.fileName;
                  attachment.Body = Blob.valueOf(tAttachment.body);
                  attachment.ParentId = unassignedmails.id;
                  attachments.add(attachment);
              }    
          }
          
          if(email.binaryAttachments !=null){
              for(Messaging.InboundEmail.binaryAttachment bAttachment :email.binaryAttachments) {
                  Attachment attachment = new attachment();
                  attachment.Name  = bAttachment.fileName;
                  attachment.Body = bAttachment.body;
                  attachment.Parentid = unassignedmails.id;
                  attachments.add(attachment);
              }
          }
        }
      }
          
     if( attachments.size() > 0 ){
         insert attachments;
        }
      result.success = true;
      
  }

  catch(DMLException ex){
      
             system.debug('error in DML exception..' + ex);
        }
                                                           
   // Return the result for the Apex Email Service
   return result;
  }
}