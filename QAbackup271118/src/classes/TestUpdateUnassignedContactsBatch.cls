@isTest
public class TestUpdateUnassignedContactsBatch {

@testSetup
  static void setup() {

    //insert contacts
    list<contact>contactList = new list<contact>();
         contact cnt = new contact (FirstName = 'test first Name',
                                lastName = 'test last Name',
                                Email    = 'test@ashleyfurniture.com',
                                phone    = '1234567890',
                               MobilePhone = '5455455450',
                               Phone_2__c = '4567891230',
                               Phone_3__c = '7894561230'
                              );
            contactList.add(cnt);
             contact cnt1 = new contact (FirstName = 'test first Name1',
                                lastName = 'test last Name1',
                                Email    = 'test1@ashleyfurniture.com',
                                phone    = '1245467890',
                               MobilePhone = '6455455450',
                               Phone_2__c = '6547891230',
                               Phone_3__c = '8974561230'
                              );
             contactList.add(cnt1);
             insert contactList;
        
    list<incomingemailattachment__c> incomingemail = new list<incomingemailattachment__c>();

    for(integer i=0;i<10;i++) {

    incomingemailattachment__c inmailattach = new incomingemailattachment__c();
    inmailattach.email__c = 'test' +i+ '@ashleyfurniture.com';
    incomingemail.add(inmailattach); 
    }
    insert incomingemail;


   list<Attachment> attachments = new list<Attachment>();
         for(incomingemailattachment__c ineattch: incomingemail){
            Attachment attachment = new Attachment();
             attachment.Name = 'textfileone.txt';
             attachment.Body = blob.valueOf('my attachment text');
             attachment.ParentId = ineattch.id;
             attachments.add(attachment);
         }
         
         insert attachments;
    }
    
    @isTest
    static void testMethod1() {
      Database.executeBatch(new UpdateUnassignedContactsBatch());
    }
}