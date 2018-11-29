@isTest
public class SendEmailController_Test {
    public static testmethod void testvalidate(){
        
        Account newAcc = new Account();
        newAcc.name='test';
        insert newAcc;
        
        Contact con=new Contact();
        con.lastname='Testing';
        con.email='test@test.com';
        insert con;
        
        EmailMessage em = new EmailMessage();
        em.FromAddress = 'noreply@email.com';
        em.Subject = 'Test';
        em.HtmlBody = 'plaintext';
        em.ParentId = '5003D000002w3w5QAA';
        
        insert em;
        SendEmailController.sendMailMethod(em.FromAddress, em.Subject, em.HtmlBody, em.ParentId);
    }
    
}