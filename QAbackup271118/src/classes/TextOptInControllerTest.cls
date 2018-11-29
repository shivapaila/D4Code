@isTest
public class TextOptInControllerTest {
    
    
	@isTest
    public static void getOpptyTest(){
        List<Account> lstAccountsCreated = TestDataFactory.initializePersonAccounts(1);
        insert lstAccountsCreated;
        Opportunity opptyCreated = prepareShoppingCart(lstAccountsCreated[0]);
        Electronic_Signature__c signObj = inserteSignTestData(lstAccountsCreated[0].Id, opptyCreated.Id);
        TestDataFactory.prepareAPICustomSetting();
        StoreInfoMock fakeResponse = new StoreInfoMock();
        
        Test.setMock(HttpCalloutMock.class, fakeResponse);
        // Producation Validation Fix
        System.runAs(TestDataFactory.createRSAUser()) {
            Test.startTest();
            TextOptInController.getOpty(lstAccountsCreated[0].Id, opptyCreated.Id);
            Test.stopTest();
        }
    }
    
    @isTest
    public static void getOrCreateESignatureTest(){
        List<Account> lstAccountsCreated = TestDataFactory.initializePersonAccounts(1);
        insert lstAccountsCreated;
        Opportunity opptyCreated = prepareShoppingCart(lstAccountsCreated[0]);
        Electronic_Signature__c signObj = inserteSignTestData(lstAccountsCreated[0].Id, opptyCreated.Id);
        
        TextOptInController.getOrCreateESignature(lstAccountsCreated[0].Id, opptyCreated.Id, signObj.Id);
        
        TextOptInController.getOrCreateESignature(lstAccountsCreated[0].Id, opptyCreated.Id, '');
    }
    
    @isTest
    public static void declineOptionsTest(){
        List<Account> lstAccountsCreated = TestDataFactory.initializePersonAccounts(1);
        insert lstAccountsCreated;
        Opportunity opptyCreated = prepareShoppingCart(lstAccountsCreated[0]);
        Electronic_Signature__c signObj = inserteSignTestData(lstAccountsCreated[0].Id, opptyCreated.Id);
        
        TextOptInController.declineOptions(lstAccountsCreated[0].Id, opptyCreated.Id);
    }
    
    @isTest
    public static void acceptOptionsTest(){
        List<Account> lstAccountsCreated = TestDataFactory.initializePersonAccounts(1);
        insert lstAccountsCreated;
        Opportunity opptyCreated = prepareShoppingCart(lstAccountsCreated[0]);
        Electronic_Signature__c signObj = inserteSignTestData(lstAccountsCreated[0].Id, opptyCreated.Id);
        
        ContentVersion cv = new ContentVersion();
        cv.title = 'test content trigger';      
        cv.PathOnClient ='test';           
        cv.VersionData = Blob.valueOf('TestingSignature');          
        insert cv;         
                                                
        ContentVersion testContent = [SELECT id, ContentDocumentId FROM ContentVersion where Id = :cv.Id];

        ContentDocumentLink newFileShare = new ContentDocumentLink();
        newFileShare.contentdocumentid = testcontent.contentdocumentid;
        newFileShare.LinkedEntityId = signObj.Id;
        newFileShare.ShareType= 'V';
        insert newFileShare;
        TextOptInController.acceptOptions(lstAccountsCreated[0].Id, opptyCreated.Id, signObj.Id, true, true, System.now()-3,' Legal Verbiage');
        TextOptInController.acceptOptions(lstAccountsCreated[0].Id, opptyCreated.Id, signObj.Id, true, false, System.now()-3,' ');
        
    }
    
    public static Opportunity prepareShoppingCart(Account acc){
        Opportunity opp =  new Opportunity();
        opp.AccountId = acc.Id;
        opp.Name=acc.Name+'-'+system.today().format();
        opp.StageName='Saved Shopping Cart';
        opp.CloseDate=Date.Today().addDays(30);
        
        insert opp;
        return opp;
    }
    
    public static Electronic_Signature__c inserteSignTestData(String accId, String opptyId){
        Electronic_Signature__c signObj = new Electronic_Signature__c();
        signObj.AccountId__c = accId;
        signObj.Signature_Type__c = 'Opt into text messages';
        signObj.ObjectID__c = opptyId;
        
        insert signObj;
        return signObj;
    }
}