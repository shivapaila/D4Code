/*This is a test class for AttachAttachmentsFromEmail
class Name : AttachAttachmentsFromEmail
*/

@isTest
    public class TestAttachmentsfromEmail {
 
   @testSetup
     static void setup() {
         contact cnt = new contact (FirstName = 'test first Name',
                                lastName = 'test last Name',
                                Email    = 'test@ashleyfurniture.com',
                                phone    = '1234567890',
                               MobilePhone = '5455455450',
                               Phone_2__c = '4567891230',
                               Phone_3__c = '7894561230'
                              );
             insert cnt;  
             contact cnt1 = new contact (FirstName = 'test first Name1',
                                lastName = 'test last Name1',
                                Email    = 'test1@ashleyfurniture.com',
                                phone    = '1245467890',
                               MobilePhone = '6455455450',
                               Phone_2__c = '6547891230',
                               Phone_3__c = '8974561230'
                              );
             insert cnt1;  
        }  
        
   @isTest
        
    static void testMethod1() {
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
                
        contact cnt = [SELECT Id FROM Contact WHERE Email = 'test@ashleyfurniture.com'];
                
        email.subject = 'test subject';
        email.fromName= 'test@gmail.com';
        email.plainTextBody = 'email body\n425145\nTitle';
        String[]toAddresses = new String[]{'test@ashleyfurniture.com','test1@ashleyfurniture.com','test@ash.com'};
        email.Toaddresses = toAddresses;
        
        Messaging.InboundEmail.BinaryAttachment attachment = new Messaging.InboundEmail.BinaryAttachment();
        attachment.body = blob.valueOf('my attachment text');
        attachment.fileName = 'textfileone.txt';
        attachment.mimeTypeSubType = 'text/plain';
        email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { attachment };
        
         Messaging.InboundEmail.TextAttachment attachmenttext = new Messaging.InboundEmail.TextAttachment();
         attachmenttext.body = 'my attachment text';
         attachmenttext.fileName = 'textfiletwo3.txt';
         attachmenttext.mimeTypeSubType = 'texttwo/plain';
         email.textAttachments =   new Messaging.inboundEmail.TextAttachment[] { attachmenttext };
        
         // call the email service class and test it with the data in the testMethod
         AttachAttachmentsFromEmail testInbound = new AttachAttachmentsFromEmail();
          testInbound.handleInboundEmail(email, env);


    }
        
}