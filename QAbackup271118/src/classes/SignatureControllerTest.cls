/****** v1 | Description: Test methods for SignatureController class | 8/16/2018 | JoJo Zhao */
@isTest
public class SignatureControllerTest {

    @isTest
    public static void testSaveCapturedSignature(){
        TestDataFactory.prepareAPICustomSetting();
        User rsaUser = TestDataFactory.createRSAUser();
        insert rsaUser;
        
        System.runAs(rsaUser) {     
            Account acc= TestDataFactory.prepareCustomerInfo();
            ContentVersion cv = new ContentVersion();
            cv.title = 'Signature.png';      
            cv.PathOnClient ='test';           
            cv.VersionData = Blob.valueOf('TestingSignature');          
            insert cv;         
            
            ContentVersion testContent = [SELECT id, ContentDocumentId FROM ContentVersion where Id = :cv.Id];
            
            Test.startTest();
            Boolean savedFlag = SignatureController.checkSignatureSaved();
            System.assertEquals(true, savedFlag);
            Id escObjId = SignatureController.saveCapturedSignature();
            Boolean saveFlagCheck = SignatureController.checkSignatureSaved();
            System.assertEquals(false, saveFlagCheck);
            List<Id> attId = SignatureController.getCaliforniaSignatureList();
            System.assertNotEquals(null, attId);
            System.assertEquals(1, attId.size());
            
            SignatureController.saveSignatureToCustomer(attId[0], acc.id);
       
        }

    }
    
    @isTest
    public static void testIsCaliforniaStore(){
        TestDataFactory.prepareAPICustomSetting();
        User rsaUser = TestDataFactory.createRSAUser();
        insert rsaUser;
        
        System.runAs(rsaUser) {     
            Test.setMock(HttpCalloutMock.class, new StoreInfoMock());
            Test.startTest();
            Boolean isCaliforniaStore = SignatureController.isCaliforniaStore();
            System.assertEquals(false, isCaliforniaStore);
  
            Test.stopTest();
        }
        
    }   
}