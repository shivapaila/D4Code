public class techschedulingcancellation {
    @AuraEnabled
    public static string getRelatedServiceRequestsforcancelling(Id recordId) {
        case selectedCase = [select id,Technician_Schedule_Date__c,Technician_ServiceReqId__c from case where id=:recordId];
        system.debug('selectedCase----'+selectedCase);
        list<case> RelatedCases  = new list<case>();
        string confirmMsg;
        if(selectedCase.Technician_Schedule_Date__c>=system.today() && selectedCase.Technician_ServiceReqId__c!=null){
            confirmMsg = 'Allow Unschedule of Request No:'+selectedCase.Technician_ServiceReqId__c;
        }
        system.debug('confirmMsg-------------' + confirmMsg);
        return confirmMsg;
    }

    @AuraEnabled
    public static Case getCaseObj(Id recordId) {
        Case caseObj = [select id, Legacy_Assignee__c,Technician_Schedule_Date__c, Technician_Name__c, Address__r.Id,Address__r.Name, Address__r.Address_Line_1__c,AccountId,
                        Address__r.Address_Line_2__c, Address__r.City__c, Address__r.State__c, Address__r.Zip_Code__c,Sales_Order__c,Legacy_technician__c,
                        Address__r.Country__c, Contact.Name, CaseNumber, ContactEmail, Profit_Center__c,Company__c,Technician_Company__c,Technician_ServiceReqId__c,
                        ContactMobile, ContactPhone, Status,followup_Priority_EstimatedTime__c,Priority, Description, SuppliedEmail, CreatedDate, Contact.Email, Contact.Email_2__c,
                        Contact.Phone, Contact.Phone_2__c
                        from Case Where Id = : recordId
                       ];
        return caseObj;
    }

    public static string getfulfillerId(string extId){
        system.debug('Ext Id Full: '+ extId);
        SalesOrder__x salesOrderObj = new SalesOrder__x();
        if(Test.isRunningTest()){
            salesOrderObj = new SalesOrder__x(fulfillerID__c = '8888300-164',
                                              ExternalId = '204258:0012900000GRH2LAAX');
            
        }else{
            salesOrderObj = [SELECT ExternalId, fulfillerID__c, Id, phhProfitcenter__c, phhCustomerID__c 
                             FROM SalesOrder__x 
                             WHERE ExternalId =: extId];
        }
        system.debug('SO Obj Full fill: '+ salesOrderObj);
        return salesOrderObj.fulfillerID__c;
    }

    @AuraEnabled
    public static string getApiResponse(Id recordId) {
        Case caseObj = getCaseObj(recordId); // getZipCode(caseObj.Sales_Order__c)
        String httpReqVar = system.label.TechSchedulingEndPoint + getfulfillerId(caseObj.Sales_Order__c) + '/customer-service/service-technician-unschedule?requestId=' + caseObj.Technician_ServiceReqId__c + '&userId=1';
        httpReqVar = httpReqVar.trim();

        Http http = new http();
        Httprequest req = new HttpRequest();
        req.setHeader('apikey', system.label.TechSchedulingApiKey);
        req.setHeader('Accept', 'application/json');
        req.setEndpoint(httpReqVar);
        req.setTimeOut(120000);
        req.setMethod('GET');
        HttpResponse res = http.send(req);

        System.debug('apiresponse...' + res.getBody());
        //  List < object > resultsmap = (List < Object > ) JSON.deserializeUntyped(res.getBody());

		User objUser = [Select Id, CommunityNickname, timezonesidkey from User where Id=:UserInfo.getUserId()];
		datetime dtDateTime = system.now();
		string strDateTime = dtDateTime.format('MM/dd/yyyy HH:mm:ss', objUser.timezonesidkey );
		system.debug(strDateTime);

        //create a comment on Scheduling a technician
        JSONGenerator comGen = JSON.createGenerator(true);

		//JSON start
        comGen.writeStartObject();
        comGen.writeNumberField('RequestId', integer.valueOf(caseObj.Technician_ServiceReqId__c));
        comGen.writeFieldName('CommentText');
		comGen.writeStartArray();
		comGen.writeString('Technician Unscheduled from Salesforce Case: ' + caseObj.CaseNumber + ' by ' + objUser.CommunityNickname + ' on ' + strDateTime + ' (' + objUser.timezonesidkey + ')');
        comGen.writeEndArray();
        comGen.writeNumberField('CreatedUserID', 0);
        comGen.writeEndObject();
        //JSON end

        String jsoncomString = comGen.getAsString();

        HttpRequest comReq = new HttpRequest();
        comReq.setEndpoint(system.label.TechSchedulingEndPoint + getfulfillerId(caseObj.Sales_Order__c) +'/customer-service/service-requests/comments');
        comReq.setHeader('apikey', system.label.TechSchedulingApiKey);
        comReq.setMethod('POST');
        comReq.setBody(jsoncomString);
        comReq.setTimeOut(120000);
        comReq.setHeader('Content-Type' ,'application/json');

        System.debug('******* COM POST End Point: ' + comReq.getEndpoint());
        System.debug('******* COM POST body: ' + comReq.getBody());
        system.debug('******* COM POST body des: ' + JSON.deserializeUntyped(comReq.getBody()));

        HttpResponse comRes = new Http().send(comReq);
        System.debug('******* COM POST Response Status: ' + comRes.getStatusCode());
        System.debug('******* COM POST Response: ' + comRes.getBody());

        caseObj.Technician_Schedule_Date__c = null;
        caseObj.Technician_Company__c = '';
        caseObj.TechnicianNameScheduled__c = '';
        caseObj.followup_Priority_EstimatedTime__c = '';
        caseObj.Technician_Address__c = '';
        //caseObj.Technician_ServiceReqId__c = '';
        update caseObj;
        // System.debug('resultsmap..' + resultsmap);
        if(res.getStatusCode()==200){
            return 'Successfully Unscheduled';
        }
        return null;
    }
}