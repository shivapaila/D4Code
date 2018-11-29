/* *******************************************************************************************************************
* Class Name   : CustomerOrderAcceptanceCntrlTest
* Description  : Test class for CustomerOrderAcceptanceCntrl class
* Author       : Prabha Kannan (Perficient, Inc.)
* Created On   : 01/06/2018
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer                                   Date                   Modification ID      Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
*
**************************************************************************************************************************************/
@isTest
public class CustomerOrderAcceptanceCntrlTest {
    /* test create sig obj */
    @isTest
    static void testCreateSignatureObj() {
        Account testAcc = setup();
        TestDataFactory.createOneSourceSetting();
        Test.setMock(HttpCalloutMock.class, new StoreInfoMock());
        // Producation Validation Fix
        System.runAs(TestDataFactory.createRSAUser()) {
            Test.startTest();        
            CustomerOrderAcceptanceCntrl.createSignatureObj(testAcc.Id);
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
            CustomerOrderAcceptanceCntrl.createSignatureObj(testAcc.Id);
        } catch (Exception e) {
            
        }
    }   
    
    /* test check for sig */
    @isTest
    static void testCheckForSignature() {
        Account testAcc = setup();
        TestDataFactory.createOneSourceSetting();
        Test.setMock(HttpCalloutMock.class, new StoreInfoMock());
        // Producation Validation Fix
        System.runAs(TestDataFactory.createRSAUser()) {
            Test.startTest();   
            Id sigId = CustomerOrderAcceptanceCntrl.createSignatureObj(testAcc.Id);
            
            ContentVersion contVer = new ContentVersion(
                Title = 'Penguins',
                PathOnClient = 'Penguins.jpg',
                VersionData = Blob.valueOf('Test Content')
            );
            insert contVer;
            
            ContentDocumentLink docLink = new ContentDocumentLink();
            docLink.ContentDocumentId = [SELECT Id,ContentDocumentId FROM ContentVersion][0].ContentDocumentId;
            docLink.LinkedEntityId = sigId;
            docLink.ShareType = 'V';
            insert docLink;
            CustomerOrderAcceptanceCntrl.checkForSignature(sigId);
            Test.stopTest();
        }
    } 
    
    /* test check for sig + generate exception */
    @isTest
    static void testCheckForSignatureException() {
        try {
        	CustomerOrderAcceptanceCntrl.checkForSignature('abc');
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