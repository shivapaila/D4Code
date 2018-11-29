/****** v1 | Description: Test methods for ts & cs controller class | 2/21/2018 | L OMeara */
@isTest
public class TsAndCsCtrl_Test {
    /* test create sig obj */
    @isTest
    static void testCreateSignatureObj() {
		Account testAcc = setup();
        TestDataFactory.createOneSourceSetting();
        StoreInfoMock fakeResponse = new StoreInfoMock();
        
        Test.setMock(HttpCalloutMock.class, fakeResponse);
        // Producation Validation Fix
        System.runAs(TestDataFactory.createRSAUser()) {
            Test.startTest();        
            TsAndCsCtrl.createSignatureObj(testAcc.Id);
            Test.stopTest();
        }
    } 
    
    /* test create sig obj exception */
    @isTest
    static void testCreateSignatureObjException() {
        String custTypeId =[Select id From RecordType Where DeveloperName='Customer' AND SobjectType='Account'].id;

        // create test account
        Account testAcc = new Account(
            RecordTypeId = custTypeId, 
            FirstName    = 'Sig',
            LastName     = 'Test',
            Phone        = '6155551212'
        );
        
        insert testAcc;

        try {
            TsAndCsCtrl.createSignatureObj(testAcc.Id);
        } catch (Exception e) {
            
        }
    }   
    
    /* test check for sig */
    @isTest
    static void testCheckForSignature() {
		Account testAcc = setup();
        TestDataFactory.createOneSourceSetting();
    	StoreInfoMock fakeResponse = new StoreInfoMock();
        
        Test.setMock(HttpCalloutMock.class, fakeResponse);
        // Producation Validation Fix
        System.runAs(TestDataFactory.createRSAUser()) {
     		Test.startTest();    
            Electronic_Signature__c sigId = TsAndCsCtrl.createSignatureObj(testAcc.Id);
            Blob beforeblob=Blob.valueOf('Unit Test Attachment Body');

        ContentVersion cv = new ContentVersion();
        cv.title = 'test content trigger';      
        cv.PathOnClient ='test';           
        cv.VersionData =beforeblob;          
        insert cv;         

        ContentVersion testContent = [SELECT id, ContentDocumentId FROM ContentVersion where Id = :cv.Id];

        ContentDocumentLink contentlink=new ContentDocumentLink();
        contentlink.LinkedEntityId=sigId.id;
        contentlink.ShareType= 'V';
        contentlink.ContentDocumentId=testcontent.ContentDocumentId;

            insert contentlink;
            TsAndCsCtrl.checkForSignature(sigId.Id);
            Test.stopTest();
        }
    } 
    
    /* test check for sig + generate exception */
    @isTest
    static void testCheckForSignatureException() {
        try {
            TsAndCsCtrl.checkForSignature('abc');
        } catch (Exception e) {
            system.debug('exception is ' + e.getMessage());
        }
    } 
    
    static Account setup () {
        TestDataFactory.prepareAPICustomSetting();
      
        String custTypeId =[Select id From RecordType Where DeveloperName='Customer' AND SobjectType='Account'].id;

        // create test account
        Account testAcc = new Account(
            RecordTypeId = custTypeId, 
            FirstName    = 'Sig',
            LastName     = 'Test',
            Phone        = '6155551212'
        );
        
        insert testAcc;
        
        // create test opportunity
        Opportunity testOpp = new Opportunity(
            Name      = 'Signature Test',
            StageName = 'Saved Shopping Cart', 
            AccountId = testAcc.Id, 
            CloseDate = system.today()
        );
        
        insert testOpp;  
        
        return testAcc;
    }
}