@isTest
public class EDAServiceRequestCaseTest {

    @isTest static void testPostMethodUpdateCase(){
        Account acc = new Account();
        acc.Name = 'ARON';
        Insert acc;
        System.debug('Account'+acc);

        List<Contact> conlist = new List<Contact>();
        Contact con = new Contact();
        con.AccountId = acc.Id;
        con.LastName = 'ARON';
        con.Email = 'abc@abc.com';
        Insert con;
        conlist.add(con);

        List<Case> caselist = new List<Case>();
        Case Casee = new Case();
        Casee.Subject='Test record';
        Casee.Type = 'General Inquiry';
        Casee.AccountId = acc.Id;
        Casee.Description = 'test record';
        Casee.Origin = 'Phone';
        Casee.Status = 'New';
        Casee.Priority='Medium';
        Casee.Legacy_Service_Request_ID__c = '88804';
        Casee.Estimated_time_for_stop__c = '2';
        Casee.Request_Status__c = 'New';
        Casee.Legacy_Assignee__c = '1';
        Casee.Legacy_Account_Ship_To__c = '8888300-164';
        Casee.Reason = 'Delivery Issue';
        Casee.Category_Reason_Codes__c = 'Delivery Issue';
        Casee.Tech_Scheduled_Date__c =date.parse('12/27/2018');
        //Casee.TechnicianNameScheduled__c = 'qq';
        //Casee.Technician_Schedule_Date__c = date.parse('12/27/2018');
        Casee.TechnicianNameScheduled__c = null;
        Casee.Technician_Schedule_Date__c = null;
        Casee.Follow_up_Date__c = date.parse('12/25/2018');
        Casee.CreatedDate = date.parse('5/31/2018');
        Insert Casee;
        caselist.add(Casee);
        System.debug('Insertion case'+Casee);

        List<Address__c> addlist = new List<Address__c>();
        /*
        Address__c Add = new Address__c();
        Add.AccountId__c = acc.Id;
        Add.Address_Line_1__c = 'qq';
        Add.Address_Line_2__c = 'QA';
        Add.Preferred__c = true;
        Add.City__c = 'QA';
        Add.State__c = 'CA';
        Add.Zip_Code__c = '522407';
        Add.Address_Type__c = 'Ship To';
        Insert Add;
        addlist.add(Add);
        System.debug('Address'+addlist);
		*/

        Map<String,Object> values = new Map<String,Object>();
        EDAServiceRequestCase.CaseWrap val = new EDAServiceRequestCase.CaseWrap();
        val.SFDCAccountId = acc.Id;
        val.RequestType = 'Part(s) Broken';
        val.RequestSubType = 'Parts Issue';
        val.RequestOrigin = 'Migration';
        val.AssigneeName = 'ASHLEY';
        val.SalesOrderNumber = '';
        val.ServiceTechVendorId = '0';
        val.OpenDate = '06/20/2018';
        val.ReasonCodeText = 'Part(s) Broken';
        val.OpenDateAsChar ='20180620';
        val.RequestPriority ='High';
        val.AssigneeCode = '378';
        val.IsTechResource = 'N';
        val.ReasonCode = '29';
        val.FollowUpDate = '06/22/2018';
        val.FollowUpDateAsChar = '20180622';
        val.ReopenDate = '';
        val.ReopenDateAsChar = '';
        val.ProfitCenterCode = '23';
        val.ServiceTechID = 'ASHLEY B M W F    (Skill Level )';
        val.ScheduleDate = '06/27/2018';
        val.ScheduleDateAsChar = '20180627';
        val.RequestSaleOrderNumber = 'NULL';
        val.RequestStatus = 'Open';
        val.RequestActiveFlag = '';
        val.CreatedTime = '06/20/2018';
        val.CreatedUserID = '378';
        val.LastTime = '06/20/2018';
        val.LastUserID = '378';
        val.CustomerPhone1 = '8056482946';
        val.CustomerPhone2 = '';
        val.CustomerPhone3 = '';
        val.CustomerEmail = '';
        val.EstimatedTimeForStop = '1.08';
        val.ShipToAddress1 = '';
        val.ShipToAddress2 = '';
        val.ShipToCityName = '';
        val.ShipToStateCode = '';
        val.ShipToZipCode = '';
        val.ProfitCenterDescription = null;
        val.Subject = 'Part(s) Broken';
        val.Description = 'Parts Issue';
        val.MarketAccount = 'Kingswere Georgia - #8888300';
        val.AccountShipto = '8888300-164';
        val.RequestID = '88804';
        val.CustomerID = 'HESSDAV';
        val.CustomerType = 'RET';
        val.StoreNameStoreNumberPC = 'SOUTHLAKE-133-23';
        val.UniqueID = '16665277';
        Set<String> AccId = new Set<String>();
        Set<String> reqId = new set<String>();
        reqId.add(val.RequestID);
        AccId.add(val.SFDCAccountId);
        EDAServiceRequestCase reqst=new EDAServiceRequestCase();
        String JsonMsg=JSON.serialize(val);
        Map<String,List<EDAServiceRequestCase.CaseWrap>> JSONreqBody = new Map<String,List<EDAServiceRequestCase.CaseWrap>>();
        List<EDAServiceRequestCase.CaseWrap> JSONm = new List<EDAServiceRequestCase.CaseWrap>();
        JSONm.add(val);
        JSONreqBody.put('CsrMaster', JSONm);
        JsonMsg=JSON.serialize(JSONreqBody);
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/Services/apexrest/ServiceRequests-Case/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        try{
        	RestContext.response = res;
        }
        catch(Exception ex){}

        try{
	        EDAServiceRequestCase.doPost();
        }
        catch(Exception ex){}

        try{
            EDAServiceRequestCase.getAddresses(AccId, reqId);
        }
        catch(Exception ex){}

        try{
        	EDAServiceRequestCase.myCasee(val, false, val.RequestID, val.SFDCAccountId, addlist, conlist, caselist);
        }
        catch(Exception ex){}

        try{
	        EDAServiceRequestCase.myCasee(val, true, val.RequestID, val.SFDCAccountId, addlist, conlist, caselist);
        }
        catch(Exception ex){}
    }

    @isTest static void testPostMethodScheduledCase(){
        Account acc = new Account();
        acc.Name = 'ARON';
        Insert acc;
        System.debug('Account'+acc);

        List<Contact> conlist = new List<Contact>();
        Contact con = new Contact();
        con.AccountId = acc.Id;
        con.LastName = 'ARON';
        con.Email = 'abc@abc.com';
        Insert con;
        conlist.add(con);

        List<Case> caselist = new List<Case>();
        Case Casee = new Case();
        Casee.Subject='Test record';
        Casee.Type = 'General Inquiry';
        Casee.AccountId = acc.Id;
        Casee.Description = 'test record';
        Casee.Origin = 'Phone';
        Casee.Status = 'New';
        Casee.Priority='Medium';
        Casee.Legacy_Service_Request_ID__c = '88804';
        Casee.Estimated_time_for_stop__c = '2';
        Casee.Request_Status__c = 'New';
        Casee.Legacy_Assignee__c = '1';
        Casee.Legacy_Account_Ship_To__c = '8888300-164';
        Casee.Reason = 'Delivery Issue';
        Casee.Category_Reason_Codes__c = 'Delivery Issue';
        Casee.Tech_Scheduled_Date__c =date.parse('12/27/2018');
        Casee.TechnicianNameScheduled__c = 'qq';
        Casee.Technician_Schedule_Date__c = date.parse('12/27/2018');
        Casee.Follow_up_Date__c = date.parse('12/25/2018');
        Casee.CreatedDate = date.parse('5/31/2018');
        Insert Casee;
        caselist.add(Casee);
        System.debug('Insertion case'+Casee);

        List<Address__c> addlist = new List<Address__c>();

        Map<String,Object> values = new Map<String,Object>();
        EDAServiceRequestCase.CaseWrap val = new EDAServiceRequestCase.CaseWrap();
        val.SFDCAccountId = acc.Id;
        val.RequestType = 'Part(s) Broken';
        val.RequestSubType = 'Parts Issue';
        val.RequestOrigin = 'Migration';
        val.AssigneeName = 'ASHLEY';
        val.SalesOrderNumber = '';
        val.ServiceTechVendorId = '0';
        val.OpenDate = '06/20/2018';
        val.ReasonCodeText = 'Part(s) Broken';
        val.OpenDateAsChar ='20180620';
        val.RequestPriority ='High';
        val.AssigneeCode = '378';
        val.IsTechResource = 'N';
        val.ReasonCode = '29';
        val.FollowUpDate = '06/22/2018';
        val.FollowUpDateAsChar = '20180622';
        val.ReopenDate = '';
        val.ReopenDateAsChar = '';
        val.ProfitCenterCode = '23';
        val.ServiceTechID = 'ASHLEY B M W F    (Skill Level )';
        val.ScheduleDate = '06/27/2018';
        val.ScheduleDateAsChar = '20180627';
        val.RequestSaleOrderNumber = 'NULL';
        val.RequestStatus = 'Open';
        val.RequestActiveFlag = '';
        val.CreatedTime = '06/20/2018';
        val.CreatedUserID = '378';
        val.LastTime = '06/20/2018';
        val.LastUserID = '378';
        val.CustomerPhone1 = '8056482946';
        val.CustomerPhone2 = '';
        val.CustomerPhone3 = '';
        val.CustomerEmail = '';
        val.EstimatedTimeForStop = '1.25';
        val.ShipToAddress1 = '';
        val.ShipToAddress2 = '';
        val.ShipToCityName = '';
        val.ShipToStateCode = '';
        val.ShipToZipCode = '';
        val.ProfitCenterDescription = null;
        val.Subject = 'Part(s) Broken';
        val.Description = 'Parts Issue';
        val.MarketAccount = 'Kingswere Georgia - #8888300';
        val.AccountShipto = '8888300-164';
        val.RequestID = '88804';
        val.CustomerID = 'HESSDAV';
        val.CustomerType = 'RET';
        val.StoreNameStoreNumberPC = 'SOUTHLAKE-133-23';
        val.UniqueID = '16665277';
        Set<String> AccId = new Set<String>();
        Set<String> reqId = new set<String>();
        reqId.add(val.RequestID);
        AccId.add(val.SFDCAccountId);
        EDAServiceRequestCase reqst=new EDAServiceRequestCase();
        String JsonMsg=JSON.serialize(val);
        Map<String,List<EDAServiceRequestCase.CaseWrap>> JSONreqBody = new Map<String,List<EDAServiceRequestCase.CaseWrap>>();
        List<EDAServiceRequestCase.CaseWrap> JSONm = new List<EDAServiceRequestCase.CaseWrap>();
        JSONm.add(val);
        JSONreqBody.put('CsrMaster', JSONm);
        JsonMsg=JSON.serialize(JSONreqBody);
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/Services/apexrest/ServiceRequests-Case/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        try{
        	RestContext.response = res;
        }
        catch(Exception ex){}

        try{
	        EDAServiceRequestCase.doPost();
        }
        catch(Exception ex){}

        try{
            EDAServiceRequestCase.getAddresses(AccId, reqId);
        }
        catch(Exception ex){}

        try{
        	EDAServiceRequestCase.myCasee(val, false, val.RequestID, val.SFDCAccountId, addlist, conlist, caselist);
        }
        catch(Exception ex){}

        try{
	        EDAServiceRequestCase.myCasee(val, true, val.RequestID, val.SFDCAccountId, addlist, conlist, caselist);
        }
        catch(Exception ex){}
    }

    @isTest static void testPostMethodInsertCase(){
        Account acc = new Account();
        acc.Name = 'ARON';
        Insert acc;
        System.debug('Account'+acc);

        List<Contact> conlist = new List<Contact>();
        Contact con = new Contact();
        con.AccountId = acc.Id;
        con.LastName = 'ARON';
        con.Email = 'abc@abc.com';
        Insert con;
        conlist.add(con);

        List<Address__c> addlist = new List<Address__c>();
        List<Case> caselist = new List<Case>();

        Map<String,Object> values = new Map<String,Object>();
        EDAServiceRequestCase.CaseWrap val = new EDAServiceRequestCase.CaseWrap();
        val.SFDCAccountId = acc.Id;
        val.RequestType = 'Part(s) Broken';
        val.RequestSubType = 'Parts Issue';
        val.RequestOrigin = 'Migration';
        val.AssigneeName = 'ASHLEY';
        val.SalesOrderNumber = '';
        val.ServiceTechVendorId = '0';
        val.OpenDate = '06/20/2018';
        val.ReasonCodeText = 'Part(s) Broken';
        val.OpenDateAsChar ='20180620';
        val.RequestPriority ='High';
        val.AssigneeCode = '378';
        val.IsTechResource = 'N';
        val.ReasonCode = '29';
        val.FollowUpDate = '06/22/2018';
        val.FollowUpDateAsChar = '20180622';
        val.ReopenDate = '';
        val.ReopenDateAsChar = '';
        val.ProfitCenterCode = '23';
        val.ServiceTechID = 'ASHLEY B M W F    (Skill Level )';
        val.ScheduleDate = '06/27/2018';
        val.ScheduleDateAsChar = '20180627';
        val.RequestSaleOrderNumber = 'NULL';
        val.RequestStatus = 'Open';
        val.RequestActiveFlag = '';
        val.CreatedTime = '06/20/2018';
        val.CreatedUserID = '378';
        val.LastTime = '06/20/2018';
        val.LastUserID = '378';
        val.CustomerPhone1 = '8056482946';
        val.CustomerPhone2 = '';
        val.CustomerPhone3 = '';
        val.CustomerEmail = '';
        val.EstimatedTimeForStop = '1.17';
        val.ShipToAddress1 = '';
        val.ShipToAddress2 = '';
        val.ShipToCityName = '';
        val.ShipToStateCode = '';
        val.ShipToZipCode = '';
        val.ProfitCenterDescription = null;
        val.Subject = 'Part(s) Broken';
        val.Description = 'Parts Issue';
        val.MarketAccount = 'Kingswere Georgia - #8888300';
        val.AccountShipto = '8888300-164';
        val.RequestID = '88804';
        val.CustomerID = 'HESSDAV';
        val.CustomerType = 'RET';
        val.StoreNameStoreNumberPC = 'SOUTHLAKE-133-23';
        val.UniqueID = '16665277';
        Set<String> AccId = new Set<String>();
        Set<String> reqId = new set<String>();
        reqId.add(val.RequestID);
        AccId.add(val.SFDCAccountId);
        EDAServiceRequestCase reqst=new EDAServiceRequestCase();
        String JsonMsg=JSON.serialize(val);
        Map<String,List<EDAServiceRequestCase.CaseWrap>> JSONreqBody = new Map<String,List<EDAServiceRequestCase.CaseWrap>>();
        List<EDAServiceRequestCase.CaseWrap> JSONm = new List<EDAServiceRequestCase.CaseWrap>();
        JSONm.add(val);
        JSONreqBody.put('CsrMaster', JSONm);
        JsonMsg=JSON.serialize(JSONreqBody);
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/Services/apexrest/ServiceRequests-Case/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        try{
        	RestContext.response = res;
        }
        catch(Exception ex){}

        try{
	        EDAServiceRequestCase.doPost();
        }
        catch(Exception ex){}

        try{
            EDAServiceRequestCase.getAddresses(AccId, reqId);
            EDAServiceRequestCase.myAdd(val);
        }
        catch(Exception ex){}

        try{
        	EDAServiceRequestCase.myCasee(val, false, val.RequestID, val.SFDCAccountId, addlist, conlist, caselist);
        }
        catch(Exception ex){}

        try{
	        EDAServiceRequestCase.myCasee(val, true, val.RequestID, val.SFDCAccountId, addlist, conlist, caselist);
        }
        catch(Exception ex){}
    }
}