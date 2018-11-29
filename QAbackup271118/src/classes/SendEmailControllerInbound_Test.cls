@isTest
public class SendEmailControllerInbound_Test {
    @isTest static void testCases1() {
        // Create a new email and envelope object
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        
        email.plainTextBody = 'Here is my plainText body of the email';
        email.fromAddress = 'noreply@gmail.com';
        email.subject = 'My test subject';
        
        EmailMessage em = new EmailMessage();
        em.FromAddress = email.fromAddress;
        em.Subject = email.subject;
        em.HtmlBody = email.plainTextBody;
        em.ParentId = '5003D000002w3w5QAA';
        
        insert em;
        
        SendEmailControllerInbound caseObj = new SendEmailControllerInbound();
        caseObj.handleInboundEmail(email, env);
    }
    
}