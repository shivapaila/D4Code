@isTest
public class EDAServiceRequestCaseCommentsTest {        
    @isTest static void testPostMethod(){ 
        Account acc=new Account();
        acc.name='Test';
        acc.AccountNumber='1232332';
        acc.Site='site';
        insert acc;
        System.debug('my accnt id-->'+acc.id);
        List<Contact> conlist = new List<Contact>();
        Contact con = new Contact();
        con.AccountId = acc.id;
        con.LastName = 'Test';
        con.Email = 'abc@abc.com';
        insert con;
        conlist.add(con);
        System.debug('my con.AccountId-->'+con.AccountId);
        List<Case> caselist = new List<Case>();
        Case Casee = new Case();
        Casee.Subject='Test record';
        Casee.Type = 'General Inquiry';
        Casee.AccountId = acc.id;
        Casee.Description = 'test record';
        Casee.Origin = 'Phone';
        Casee.Status = 'New';
        Casee.Priority='Medium';
        Casee.Legacy_Service_Request_ID__c = '88731';
        insert Casee; 
        caselist.add(Casee);
        
        List<Legacy_Comment__c> comlist = new List<Legacy_Comment__c>();
        Legacy_Comment__c newComment = new Legacy_Comment__c();
        newComment.Case__c = Casee.id;
        newComment.Legacy_Service_Request_ID__c = '88731';
        newComment.Comment__c = 'CaseComment';
        newComment.Legacy_CSMComment_ID__c = '735928';
        System.debug('New Comment inserting :'+newComment.Comment__c);        
        insert  newComment;
        comlist.add(newComment);
        EDAServiceRequestCaseComments.CommentWrap someval = new EDAServiceRequestCaseComments.CommentWrap();
        someval.SFDCAccountId = acc.id;
        someval.CommentID = '735928';
        someval.EntityType = '1';
        someval.EntityID = '88731';
        someval.CommentType = '2';
        someval.CommentText = 'test';
        someval.OrderNumber = null;
        someval.AccountShipto = '8888300-164';
        someval.RequestID = '88731';
        someval.CustomerType = 'RET';
        someval.CustomerID = 'JOSHDEE';
        someval.ShipToAddress1 = '1670 E 8TH AVE';
        someval.ShipToAddress2 = 'test';
        someval.ShipToCityName = 'ATLANTA';
        someval.ShipToStateCode = 'GA';
        someval.ShipToZipCode = '30309';
        
        Set<String> AccId = new Set<String>();
        Set<String> reqId = new set<String>();
        Set<String> commentId = new Set<String>();
        commentId.add(someval.CommentID);
        reqId.add(someval.RequestID);
        AccId.add(someval.SFDCAccountId);
        
        Boolean flag = true;
        EDAServiceRequestCaseComments reqst=new EDAServiceRequestCaseComments();
        String JsonMsg=JSON.serialize(someval);
        Map<String,List<EDAServiceRequestCaseComments.CommentWrap>> JSONreqBody = new Map<String,List<EDAServiceRequestCaseComments.CommentWrap>>();
        List<EDAServiceRequestCaseComments.CommentWrap> JSONm = new List<EDAServiceRequestCaseComments.CommentWrap>();
        JSONm.add(someval);
        JSONreqBody.put('CsrComments', JSONm);
        JsonMsg=JSON.serialize(JSONreqBody);
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/Services/apexrest/ServiceRequests-CaseComments/';  
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        RestContext.response = res;
        EDAServiceRequestCaseComments.getComment(Casee.id, Someval);
        EDAServiceRequestCaseComments.createNewCase(acc.id, Someval, conlist);
        String result = EDAServiceRequestCaseComments.doPost();
           
    }
    
    @isTest static void testPostMethod2(){ 
        
        Account acc=new Account();
        acc.name='Test';
        acc.AccountNumber='1232332';
        acc.Site='site';
        insert acc;
        System.debug('my accnt id-->'+acc.id);
        List<Contact> conlist = new List<Contact>();
        Contact con = new Contact();
        con.AccountId = acc.id;
        con.LastName = 'Test';
        con.Email = 'abc@abc.com';
        insert con;
        conlist.add(con);
        System.debug('my con.AccountId-->'+con.AccountId);
        List<Case> caselist = new List<Case>();
        Case Casee = new Case();
        Casee.Subject='Test record';
        Casee.Type = 'General Inquiry';
        Casee.AccountId = acc.id;
        Casee.Description = 'test record';
        Casee.Origin = 'Phone';
        Casee.Status = 'New';
        Casee.Priority='Medium';
        Casee.Legacy_Service_Request_ID__c = '88731';
        insert Casee; 
        caselist.add(Casee);
        
        List<Legacy_Comment__c> comlist = new List<Legacy_Comment__c>();
        Legacy_Comment__c newComment = new Legacy_Comment__c();
        newComment.Case__c = Casee.id;
        newComment.Legacy_Service_Request_ID__c = '88731';
        newComment.Comment__c = 'CaseComment';
        newComment.Legacy_CSMComment_ID__c = '735928';
        System.debug('New Comment inserting :'+newComment.Comment__c);        
        insert  newComment;
        comlist.add(newComment);
        EDAServiceRequestCaseComments.CommentWrap someval = new EDAServiceRequestCaseComments.CommentWrap();
        someval.SFDCAccountId = acc.id;
        someval.CommentID = '735928';
        someval.EntityType = '1';
        someval.EntityID = '88731';
        someval.CommentType = '2';
        someval.CommentText = 'test';
        someval.OrderNumber = null;
        someval.AccountShipto = '8888300-164';
        someval.RequestID = '88731';
        someval.CustomerType = 'RET';
        someval.CustomerID = 'JOSHDEE';
        someval.ShipToAddress1 = '1670 E 8TH AVE';
        someval.ShipToAddress2 = 'test';
        someval.ShipToCityName = 'ATLANTA';
        someval.ShipToStateCode = 'GA';
        someval.ShipToZipCode = '30309';
        
        Set<String> AccId = new Set<String>();
        Set<String> reqId = new set<String>();
        Set<String> commentId = new Set<String>();
        commentId.add(someval.CommentID);
        reqId.add(someval.RequestID);
        AccId.add(someval.SFDCAccountId);
        
        Boolean flag = false;
        EDAServiceRequestCaseComments reqst=new EDAServiceRequestCaseComments();
        String JsonMsg=JSON.serialize(someval);
        Map<String,List<EDAServiceRequestCaseComments.CommentWrap>> JSONreqBody = new Map<String,List<EDAServiceRequestCaseComments.CommentWrap>>();
        List<EDAServiceRequestCaseComments.CommentWrap> JSONm = new List<EDAServiceRequestCaseComments.CommentWrap>();
        JSONm.add(someval);
        JSONreqBody.put('CsrComments', JSONm);
        JsonMsg=JSON.serialize(JSONreqBody);
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/Services/apexrest/ServiceRequests-CaseComments/';  
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        RestContext.response = res;
        EDAServiceRequestCaseComments.getComment(Casee.id, Someval);
        EDAServiceRequestCaseComments.createNewCase(acc.id, Someval, conlist);
        String result = EDAServiceRequestCaseComments.doPost();
        
    }   
}