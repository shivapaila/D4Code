global class SendEmailControllerInbound implements Messaging.InboundEmailHandler {
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
        String myPlainText= '';
        // Add the email plain text into the local variable 
        myPlainText = email.plainTextBody;        
        system.debug('####unique message ID##'+email.messageId);
        
        // For storing Relation Id
        string oppcid ='';
        
        string sub = email.subject;
        string [] a = new string[]{};
        string [] bb = new string[]{};
        system.debug(' Email Subject'+sub);
        if(String.isNotEmpty(sub) && String.isNotBlank(sub)){
            System.debug('sss '+ sub);
            a = sub.split('\\(');
            system.debug('a0 ='+ a[0]);
            //system.debug('a1 ='+ a[1]);
            bb = a[1].split('\\)');
            system.debug('bb>>>Final ID>>>> '+bb[0] );
            
            string subrecid = bb[0] ;
            //Add Inbound Email Message for Case
            EmailMessage caseEmailMessage = new EmailMessage();
            caseEmailMessage.ToAddress =  String.join(email.toAddresses, ',');
            caseEmailMessage.FromAddress = email.FromAddress;
            caseEmailMessage.FromName = email.FromName;
            caseEmailMessage.Subject = sub;
            caseEmailMessage.status = '2';
            caseEmailMessage.HtmlBody = email.htmlBody;
            System.debug('htmlBody:>>>> ' + email.htmlBody );
            caseEmailMessage.Incoming= True;
            caseEmailMessage.TextBody = myPlainText;
            System.debug('TextBody:>>>>> ' + email.plainTextBody);
            caseEmailMessage.ParentId =subrecid;
            insert caseEmailMessage;
            System.debug('Reply Email: ' + caseEmailMessage ); 
            
            // Add Email Message Relation for id of the sender
            List<Case> cid = [SELECT Id,CaseNumber,ContactEmail,ContactId FROM Case WHERE Id =:subrecid LIMIT 1];
            for (Case opc : cid){
                oppcid = opc.ContactId;
            }
            
            EmailMessageRelation emr = new EmailMessageRelation();
            emr.EmailMessageId = caseEmailMessage.Id;
            emr.RelationId = oppcid;// user id of the sender
            emr.RelationAddress = email.FromAddress;
            emr.RelationType = 'FromAddress';
            insert emr; 
            system.debug('>>>>>=='+ emr );
        }
        else{
             //Send an Email to Queue
            QueueSobject Qso = new QueueSobject();
            Qso = [SELECT Id,QueueId,SobjectType,Queue.Name,Queue.Email FROM QueueSobject WHERE Queue.Name = 'Cases without Accounts'];
            Qso.Queue.Email = 'Avabbani@ashleyfurniture.com';
            String us = Qso.Queue.Email;
            
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[] {us};
            mail.setToAddresses(toAddresses );
            mail.setSubject('CaseReplyEmail: Without Subject');
            mail.setHtmlBody(email.htmlBody);
            mail.setPlainTextBody(myPlainText);
            Messaging.SendEmail(new Messaging.SingleEmailMessage[] {mail});   
            
        }
        return result;
    }
    
}