public class TechSchedulingController {
    //Use @AuraEnabled to enable client- and server-side access to the method
    //
    public static string endpointTech = system.label.TechSchedulingEndPoint;
    public static string apiKeyTech = system.label.TechSchedulingApiKey;

    @AuraEnabled
    public static list<Case> getRelatedCaseObj(Id recordId) {
		case selectedCase = [select id, Technician_Schedule_Date__c, AccountId, Description from case where id=:recordId limit 1];

		list<case> RelatedCases  = new list<case>();

		if(selectedCase.Technician_Schedule_Date__c>=system.today()){
		    return RelatedCases;
		}
		try{
		    RelatedCases  = [select id, CaseNumber, Technician_Schedule_Date__c, Description from case where AccountId=:selectedCase.AccountId and Technician_Schedule_Date__c>=TODAY];
		}catch(Exception ex){}

		return RelatedCases;
    }

    @AuraEnabled
    public static Case getCaseObj(Id recordId) {
        Case caseObj = [select id, Legacy_Assignee__c, Technician_Schedule_Date__c, TechnicianNameScheduled__c, AccountId, Technician_Address__c, Address__c, Address__r.Id, Address__r.Name,
        				Address__r.Address_Line_1__c, Address__r.Address_Line_2__c, Address__r.City__c, Address__r.State__c, Address__r.StatePL__c, Address__r.Zip_Code__c, Sales_Order__c,
						Legacy_technician__c, Technician_ServiceReqId__c, Address__r.Country__c, Contact.Name, CaseNumber, ContactEmail, Profit_Center__c, Company__c, Technician_Company__c, Subject,
                        ContactMobile, ContactPhone, Status, followup_Priority_EstimatedTime__c, Priority, Description, SuppliedEmail, CreatedDate, Contact.Email, Contact.Email_2__c,
                        Contact.Phone, Contact.Phone_2__c, Legacy_Service_Request_ID__c, Legacy_Account_Ship_To__c, Follow_up_Date__c, Estimated_time_for_stop__c, Tech_Scheduled_Date__c
                        from Case Where Id = : recordId
                       ];

        return caseObj;
    }

    @AuraEnabled
    public static boolean isValidCase(Id recordId) {
        Case caseObj = new Case();
        caseObj = getCaseObj(recordId);

        boolean isValid = true;
        if (caseObj.Sales_Order__c == '' || caseObj.Sales_Order__c == null) {
            isValid = false;
        }

        return isValid;
    }

    @AuraEnabled
    public static string getApiResponse1(Id recordId) {
        TechSchedulingAuthorization sora = new TechSchedulingAuthorization();
        string accessTkn = sora.accessTokenData();

        string accountIden = EncodingUtil.urlEncode(recordId, 'UTF-8');
        string httpReqVar = 'PersonAccountID eq'+ ' ' + '\'' +accountIden + '\'' ;
        string replacereqvar = httpReqVar.replaceAll(' ','%20');
        string replacereqvarupd = EncodingUtil.urlEncode(httpReqVar, 'UTF-8');
        string EPoint = system.label.caratechschedulingApiendpoint + replacereqvarupd;
        EPoint = EPoint.replace('+','%20');

        Http http = new http();
        Httprequest req = new HttpRequest();
        req.setHeader('Authorization', 'Bearer '+accessTkn);
        req.setHeader('Accept' ,'application/json');
        req.setHeader('Content-Type', 'application/json');
        req.setEndpoint(EPoint);
        req.setTimeOut(120000);
        req.setMethod('GET');

        HttpResponse res = http.send(req);

        system.debug('****** getApiResponse1: ' + res.getBody());

        return res.getBody();//resultsmap;
    }

    @AuraEnabled
    public static string getApiResponseforlinesku(Id recordId) {
        TechSchedulingAuthorization sora = new TechSchedulingAuthorization();
        string accessTkn = sora.accessTokenData();

        string accountIden = EncodingUtil.urlEncode(recordId, 'UTF-8');
        string httpReqVar = 'PersonAccountID eq'+ ' ' + '\'' +accountIden + '\'' ;
        string replacereqvar = httpReqVar.replaceAll(' ','%20');
        string replacereqvarupd = EncodingUtil.urlEncode(httpReqVar, 'UTF-8');
        string EPoint = system.label.caratechschedulingApiendpoint + replacereqvarupd + '&starSkuOnly=true';
        EPoint = EPoint.replace('+','%20');

        Http http = new http();
        Httprequest req = new HttpRequest();
        req.setHeader('Authorization', 'Bearer '+accessTkn);
        req.setHeader('Accept' ,'application/json');
        req.setHeader('Content-Type', 'application/json');
        req.setEndpoint(EPoint);
        req.setTimeOut(120000);
        req.setMethod('GET');

        HttpResponse res = http.send(req);

        system.debug('****** getApiResponseforlinesku: ' + res.getBody());

        return res.getBody();//resultsmap;
    }

    @AuraEnabled
    // Get Zipcode from External Id
    public static string getZipCode(string extId){
        SalesOrderItem__x salesOrderItemObj = new SalesOrderItem__x();
        if(Test.isRunningTest()){
            salesOrderItemObj = new SalesOrderItem__x(phdShipZip__c = '30548',
                                                      ExternalId = '204258:0012900000GRH2LAAX');
        }else{
            salesOrderItemObj = [SELECT DisplayUrl, ExternalId, Id, phdSalesOrder__c, phdShipZip__c 
                                 FROM SalesOrderItem__x 
                                 WHERE phdSalesOrder__r.ExternalId=: extId
                                 limit 1];
        }
        system.debug('****** ZipCode: '+ salesOrderItemObj.phdShipZip__c);
        return salesOrderItemObj.phdShipZip__c;
    }

    @AuraEnabled
    public static List < object > getAssignees(string fulfillerId) {
        string httpReqVar = endpointTech + fulfillerId + '/customer-service/service-request-assignees';
        //https://ashley-preprod-qa.apigee.net/homestores/8888300-164/customer-service/service-request-assignees?apikey=bGna5ABiJwsJyqV9DDtQmTBEH2Kpz713

        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setHeader('apikey', apiKeyTech);
        req.setHeader('Accept', 'application/json');
        req.setEndpoint(httpReqVar);
        req.setTimeOut(120000);
        req.setMethod('GET');
        HttpResponse res = http.send(req);

        // Deserialize the JSON string into collections of primitive data types.
        List < object > resultsMap = (List < object > ) JSON.deserializeUntyped(res.getBody());
        system.debug('****** getAssignees: ' + resultsMap);

        return resultsMap;
    }

    @AuraEnabled
    public static List < object > getRequestStatus(string fulfillerId) {
        string httpReqVar = endpointTech +  fulfillerId +  '/customer-service/service-request-statuses';
        //https://ashley-preprod-qa.apigee.net/homestores/8888300-164/customer-service/service-request-statuses?apikey=bGna5ABiJwsJyqV9DDtQmTBEH2Kpz713   --> Go to tech Scheduled

        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setHeader('apikey', apiKeyTech);
        req.setHeader('Accept', 'application/json');
        req.setEndpoint(httpReqVar);
        req.setTimeOut(120000);
        req.setMethod('GET');
        HttpResponse res = http.send(req);

        // Deserialize the JSON string into collections of primitive data types.
        List < object > resultsMap = (List < object > ) JSON.deserializeUntyped(res.getBody());
        system.debug('****** getRequestStatus: ' + resultsMap);

        return resultsMap;
    }

    @AuraEnabled
    public static List < object > getReasonCodes(string fulfillerId) {
        string httpReqVar = endpointTech +  fulfillerId + '/customer-service/service-reason-codes';
        //https://ashley-preprod-qa.apigee.net/homestores/8888300-164/customer-service/service-reason-codes?apikey=bGna5ABiJwsJyqV9DDtQmTBEH2Kpz713

        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setHeader('apikey', apiKeyTech);
        req.setHeader('Accept', 'application/json');
        req.setEndpoint(httpReqVar);
        req.setTimeOut(120000);
        req.setMethod('GET');
        HttpResponse res = http.send(req);

        // Deserialize the JSON string into collections of primitive data types.
        List < object > resultsMap = (List < object > ) JSON.deserializeUntyped(res.getBody());
        system.debug('****** getReasonCodes: ' + resultsMap);

        return resultsMap;
    }

    @AuraEnabled
    public static List < object > getPriority(string fulfillerId) {
        string httpReqVar = endpointTech +  fulfillerId + '/customer-service/service-request-priorities';
        //https://ashley-preprod-qa.apigee.net/homestores/8888300-164/customer-service/service-request-priorities?apikey=bGna5ABiJwsJyqV9DDtQmTBEH2Kpz713

        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setHeader('apikey', apiKeyTech);
        req.setHeader('Accept', 'application/json');
        req.setEndpoint(httpReqVar);
        req.setTimeOut(120000);
        req.setMethod('GET');
        HttpResponse res = http.send(req);

        // Deserialize the JSON string into collections of primitive data types.
        List < object > resultsMap = (List < object > ) JSON.deserializeUntyped(res.getBody());
        system.debug('****** getPriority: ' + resultsMap);

        return resultsMap;
    }

    @AuraEnabled
    public static SalesOrder__x getSalesOrderInfo(Id recordId){
        Case caseObj = getCaseObj(recordId);
        SalesOrder__x salesOrderObj = new SalesOrder__x();
        if(Test.isRunningTest()){
            salesOrderObj = new SalesOrder__x(fulfillerID__c = '8888300-164',
                                              ExternalId = '204258:0012900000GRH2LAAX');
        }else{
            salesOrderObj = [SELECT ExternalId, fulfillerID__c, phhERPAccounShipTo__c, phhERPCustomerID__c, Id, phhProfitcenter__c, phhCustomerID__c, phhSalesOrder__c, phhSaleType__c, phhCustomerType__c, phhShipToName__c
                             FROM SalesOrder__x 
                             WHERE ExternalId =: caseObj.Sales_Order__c];
        }
        
        return salesOrderObj;
    }

    @AuraEnabled
    public static SalesOrderItem__x getSalesOrderLineInfo(Id recordId){
        Case caseObj = getCaseObj(recordId);
        SalesOrderItem__x salesOrderObj1 = new SalesOrderItem__x();
        if(Test.isRunningTest()){
            salesOrderObj1 = new SalesOrderItem__x(ExternalId = '204258:0012900000GRH2LAAX', 
                                                   phdShipZip__c = '30548');
        }else{
            salesOrderObj1 = [SELECT Id, ExternalId, phdSalesOrderDate__c, phdSalesOrder__c, Ship_Customer_Name__c,
            				  phdShipAddress1__c, phdShipAddress2__c, phdShipCity__c, phdShipState__c, phdShipZip__c 
                              FROM SalesOrderItem__x Where phdSalesOrder__r.ExternalId =: caseObj.Sales_Order__c limit 1];
        }
        
        return salesOrderObj1;
    }

    @AuraEnabled
    public static List < object > getApiResponse(string fulfillerId, string zipcode) {
        string httpReqVar = endpointTech + fulfillerId + '/customer-service/service-provider-names?zipcode=' + zipcode ;
        //https://ashley-preprod-qa.apigee.net/homestores/8888300-164/customer-service/service-provider-names?zipcode=32757&apikey=bGna5ABiJwsJyqV9DDtQmTBEH2Kpz713
        httpReqVar = httpReqVar.trim();

        Http http = new http();
        Httprequest req = new HttpRequest();
        req.setHeader('apikey', apiKeyTech);
        req.setHeader('Accept', 'application/json');
        req.setEndpoint(httpReqVar);
        req.setTimeOut(120000);
        req.setMethod('GET');
        HttpResponse res = http.send(req);

        List < object > resultsmap = (List < object > ) JSON.deserializeUntyped(res.getBody());
        system.debug('****** getApiResponse: ' + resultsmap);
        return resultsmap;
    }

    @AuraEnabled
    public static List < object > getTechnicians(string fulfillerId, string companyvalue, string zipcode) {
        string httpReqVar = endpointTech + fulfillerId + '/customer-service/service-technicians?zipcode=' + zipcode + '&companyId=' + companyvalue;

        Http http = new http();
        Httprequest req = new HttpRequest();
        req.setHeader('apikey', apiKeyTech);
        req.setHeader('Accept', 'application/json');
        req.setEndpoint(httpReqVar);
        req.setTimeOut(120000);
        req.setMethod('GET');
        HttpResponse res = http.send(req);

        //deserialize the JSON String into collectyion of primitive data types
        List < object > resultsmap = (List < object > ) JSON.deserializeUntyped(res.getBody());
        system.debug('****** getTechnicians: ' + resultsmap);
        return resultsmap;
    }

    @AuraEnabled
    public static Map<string, object> getProgressValue(string fulfillerId, string resourceId, string selecteddate) {
        system.debug('***Get Prog Val: '+ fulfillerId + ':' + resourceId + ':' + selecteddate);
        string httpReqVar = endpointTech + fulfillerId + '/customer-service/service-technicians?techId=' + resourceId + '&scheduledate=' + selecteddate;
        // https://ashley-preprod-dev.apigee.net/homestores/8888300-164/service-technicians?techId=49&scheduledate=2018-04-27&apikey=bGna5ABiJwsJyqV9DDtQmTBEH2Kpz713

        Http http = new http();
        Httprequest req = new HttpRequest();
        req.setHeader('Accept', 'application/json');
        req.setHeader('apikey', apiKeyTech);
        req.setEndpoint(httpReqVar);
        req.setTimeOut(120000);
        req.setMethod('GET');
        HttpResponse res = http.send(req);

        //deserialize the JSON String into collectyion of primitive data types
        Map<string, object> resultsmap = (Map<string, object> ) JSON.deserializeUntyped(res.getBody());
        system.debug('****** getProgressValue: ' + resultsmap);
        return resultsmap;
    }

    @AuraEnabled
    public static List < object > getWorkloadInfo(string fulfillerId, string resourceId) {
        string httpReqVar = endpointTech + fulfillerId + '/customer-service/service-technicians/' + resourceId;
        //https://ashley-preprod-qa.apigee.net/homestores/8888300-164/customer-service/service-technicians/27?apikey=bGna5ABiJwsJyqV9DDtQmTBEH2Kpz713

        Http http = new http();
        Httprequest req = new HttpRequest();
        req.setHeader('apikey', apiKeyTech);
        req.setHeader('Accept', 'application/json');
        req.setEndpoint(httpReqVar);
        req.setTimeOut(120000);
        req.setMethod('GET');
        HttpResponse res = http.send(req);

        //deserialize the JSON String into collectyion of primitive data types
        List < object > resultsmap = new List < object >();
        for(object techInfo : (List < object > ) JSON.deserializeUntyped(res.getBody())){
		    Map<string, object> techData = (Map<string, object>) techInfo;
		    string lvDate = (string) techData.get('LeaveDate');
		    integer tIndex = lvDate.indexOf('T');
			string datePart = lvDate.substring(0, tIndex);
		    List<String> dParts = datePart.split('\\-');
			date ipDate = date.newinstance(integer.valueOf(dParts[0]), integer.valueOf(dParts[1]), integer.valueOf(dParts[2]));
			date cuDate = date.newinstance(date.today().year(), date.today().month(), date.today().day());

            if(ipDate >= cuDate){
		        resultsmap.add(techInfo);
		    }

            if(resultsmap.size() == 0) {
                //just in case if there is no future leave available for the techn
                resultsmap.add(techInfo);
            }
		}

        system.debug('****** getWorkloadInfo: ' + resultsmap);
        return resultsmap;
    }
    
    @AuraEnabled
    public static List < object > getAvailableDates(string fulfillerId, String resourceId, String cYear, String cMonth) {

    	cYear = string.valueOf(cYear);
    	cMonth = string.valueOf(cMonth);

    	system.debug('fulfillerId-->' + fulfillerId);
    	system.debug('resourceId-->' + resourceId);
    	system.debug('cYear-->' + cYear);
    	system.debug('cMonth-->' + cMonth);

        string httpReqVar = endpointTech + fulfillerId + '/customer-service/service-technicians/' + resourceId + '/appointments?year=' + cYear + '&month=' + cMonth;
        //https://ashley-preprod-qa.apigee.net/homestores/8888300-164/customer-service/service-technicians/27/appointments?year=2018&month=10&apikey=bGna5ABiJwsJyqV9DDtQmTBEH2Kpz713
        //OLD - https://ashley-preprod-qa.apigee.net/homestores/8888300-164/customer-service/service-technicians/27/appointments/?apikey=bGna5ABiJwsJyqV9DDtQmTBEH2Kpz713

        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setHeader('apikey', apiKeyTech);
        req.setHeader('Accept', 'application/json');
        req.setEndpoint(httpReqVar);
        req.setTimeOut(120000);
        req.setMethod('GET');
        HttpResponse res = http.send(req);

        List < object > resultsMap = new List < object >();
        if(res.getStatusCode() == 200){
	        // Deserialize the JSON string into collections of primitive data types.
	        resultsMap = (List < object > ) JSON.deserializeUntyped(res.getBody());
        }
        system.debug('****** getAvailableDates: ' + resultsMap);

        return resultsMap;
    }
    
    @AuraEnabled
    public static string lineiteminsert(string recordId, string jsonData, string cusNo, string ship1, string ship2, string city, string state, string zip, string fulfiller) {
		//based on record id get the list of product line item associated to that case
		List<ProductLineItem__c> pliList = [SELECT Id, Sales_Order_Number__c, Item_SKU__c, Item_Seq_Number__c, Item_Serial_Number__c FROM ProductLineItem__c WHERE Case__c = :recordId];

		Map<string, List<ProductLineItem__c>> pliMap = new Map<string, List<ProductLineItem__c>>();
		string tmpKey;
		List<ProductLineItem__c> tmpPliList;
		if(pliList.size() > 0){
			for(ProductLineItem__c pli:pliList){
				tmpPliList = new List<ProductLineItem__c>();
				tmpKey = '';
				tmpKey = pli.Sales_Order_Number__c + '|' + pli.Item_SKU__c + '|' + pli.Item_Seq_Number__c;
				if(pliMap.get(tmpKey) != null){
					tmpPliList = pliMap.get(tmpKey);
				}

				tmpPliList.add(pli);
				pliMap.put(tmpKey, tmpPliList);
			}
		}

        list<ProductLineItem__c> pliInsertList = new list<ProductLineItem__c>();
        list<ProductLineItem__c> pliUpdateList = new list<ProductLineItem__c>();

        integer lineItemQty;
        boolean insPli;
        List < object > resultsMap = (List < object > ) JSON.deserializeUntyped(jsonData);
        for(object eachObject:resultsMap){
        	tmpPliList = new List<ProductLineItem__c>();
        	tmpKey = '';
        	insPli = false;

			map<string, object> data = (map<string, object>)eachObject;
			lineItemQty = 0;
			lineItemQty = integer.ValueOf(data.get('qty'));
			
			tmpKey = string.ValueOf(data.get('salesorder_number')) + '|' + formatSku(string.ValueOf(data.get('sku'))) + '|' + string.valueOf(data.get('seqNumber'));

			if(pliMap.get(tmpKey) != null){
				tmpPliList = pliMap.get(tmpKey);
				if(((lineItemQty == 0) && (tmpPliList.size() == 0)) || (lineItemQty > tmpPliList.size())){
					//insert line item
					insPli = true;
				}
				else{
					//update line item
					for(ProductLineItem__c tmpPli : tmpPliList){
						if((tmpPli.Item_Serial_Number__c == null) || (tmpPli.Item_Serial_Number__c == '99999') || (tmpPli.Item_Serial_Number__c == '999999')){
							// if the serial number of the existing product line item is null or 99999 or 999999 then update the serial number
							tmpPli.Item_Serial_Number__c = string.valueOf(data.get('serialNo'));
							pliUpdateList.add(tmpPli);
							break;
						}
					}
				}
			}
			else{
				//insert line item
				insPli = true;
			}

			if(insPli){
	            ProductLineItem__c eachPl = new ProductLineItem__c();
				eachPl.Sales_Order_Number__c = string.ValueOf(data.get('salesorder_number'));
	            eachPl.Quantity__c = 1;
	            eachPl.Item_SKU__c = formatSku(string.ValueOf(data.get('sku')));
	            eachPl.Delivery_Date__c = string.ValueOf(data.get('deldate'));
	            eachPl.warranty_date__c = string.ValueOf(data.get('wardate'));
	            eachPl.Item_Serial_Number__c = string.valueOf(data.get('serialNo'));
	            eachPl.Item_Seq_Number__c = string.valueOf(data.get('seqNumber'));
	            // eachPl.Delivery_Date__c = deldate;
	            eachPl.Item_Description__c = string.ValueOf(data.get('desc'));
	
	            eachPl.Case__c = recordId;
	            eachPl.Customer_Number__c = cusNo;
	            eachPl.Address_Line1__c = ship1;
	            eachPl.Address_Line2__c = ship2;
	            eachPl.City__c = city;
	            eachPl.State__c = state;
	            eachPl.Zip__c = zip;
	            eachPl.Fulfiller_ID__c = fulfiller;
	            eachPl.Record_Source__c = 'Technician Scheduling';
	            pliInsertList.add(eachPl);
			}
        }

        if(pliInsertList.size() > 0){
        	insert pliInsertList;
        }
		if(pliUpdateList.size() > 0){
			update pliUpdateList;
		}
        return 'success';
    }

    @AuraEnabled
    public static string POSTCallout(Id recordId, string jsonData, case caseIs, string fulfillerId, string sAdd1, string sAdd2, string sCity, string sState, string sZip) {
    	string resultStr;

        Case caseObj = getCaseObj(recordId);
        system.debug('****** Ip Case detail: ' + caseIs);

        Map<string, object> results = new Map<string, object>();
        results = (Map<string, object>)JSON.deserializeUntyped(jsonData);
        system.debug('****** Results: '+ results);

        Map<string, object> ServiceTechDtoMap = new Map<string, object>();
        ServiceTechDtoMap = (Map<string, object>) results.get('ServiceTechDto');
        system.debug('****** ServiceTechDto: '+ ServiceTechDtoMap);

        List<object> ItemsDtoList = new List<object>();
        ItemsDtoList = (List<object>) results.get('ItemsDto');
        //system.debug('***ItemsDtoList size+: '+ ItemsDtoList.size() + ItemsDtoList );

        //Service Technician Information is empty in case then do POST request else skip to PUT request
        //Technician_Company__c, Technician_Name__c, Technician_Schedule_Date__c, Technician_ServiceReqId__c, followup_Priority_EstimatedTime__c,

    	integer techScheduleRows = 0;
        if(string.isNotBlank(caseObj.Legacy_Service_Request_ID__c)){
			techScheduleRows = Integer.ValueOf(caseObj.Legacy_Service_Request_ID__c);
        }
        else if(string.isNotBlank(caseObj.Technician_ServiceReqId__c)){
			techScheduleRows = Integer.ValueOf(caseObj.Technician_ServiceReqId__c);
        }

		//get all the product line item for this case
		List<ProductLineItem__c> pliList = [Select Id, Sales_Order_Number__c, Item_SKU__c, Item_Serial_Number__c, Item_Seq_Number__c, Delivery_Date__c, Item_Description__c, Invoice_Date__c FROM ProductLineItem__c WHERE Case__c = :caseObj.Id];
		system.debug('****** pliList size: '+ pliList.size());

		boolean performCallout = true;
		//If there is no line item selected for the techinican then thrown below error message
		//Scheduling a Technician requires at least 1 PLI on the case. Please add one by clicking the 'Click Here to Schedule for Items' button
		if((pliList.size() == 0) && (ItemsDtoList.size() == 0)){
			//if there is no product line item associated to this case and if the user is not selecting any line item in tech scheduling page then throw error to user to select atleast on line item to proceed
			resultStr = 'error1';
			performCallout = false;
		}

		string tmpKey;
		List<string> validateSkuList = new List<string>();
		//since the pli can be repeat till it reachs the quantity, this list will hold used pli
		List<string> repeatSkuList = new List<string>();

		//If the line item serial numbers are null or blank then thrown below error message
		//To schedule a technician every PLI on this case must have a serial number. It cannot be blank. Please populate the serial number before continuing
        if(ItemsDtoList.size() > 0){
            for(object itm : ItemsDtoList){
                Map<string, object> itmData = (Map<string, object>)itm;
				tmpKey = '';
				tmpKey = string.ValueOf(itmData.get('ItemSaleNumber')) + '|' + formatSku(string.ValueOf(itmData.get('ItemSKUNumber'))) + '|' + string.valueOf(itmData.get('ItemSaleSequenceNumber'));
				validateSkuList.add(tmpKey);
            }
        }

		if(pliList.size() > 0){
			for(ProductLineItem__c pli : pliList){
				tmpKey = '';
				tmpKey = pli.Sales_Order_Number__c + '|' + pli.Item_SKU__c + '|' + pli.Item_Seq_Number__c;
				if(string.isBlank(pli.Item_Serial_Number__c) && (!validateSkuList.contains(tmpKey) || repeatSkuList.contains(tmpKey))){
					//if the serial number is blank for the associated PLI then throw error to user to update serial for the associated PLI
					resultStr = 'error2';
					performCallout = false;
				}
				else{
					repeatSkuList.add(tmpKey);
				}
			}
		}

		//if there is no error then proceed to callout
		//perform callout start
		if(performCallout){
	        //get priority detail starts
	        integer requestPriority = 0;
	        string requestPriorityText = '';
			List < object > priorityObj = getPriority(fulfillerId);
	        for(object pri:priorityObj){
	            Map<string, object> priData = (Map<string, object>) pri;
	            //PriorityDescription=High, PriorityId=6
	            requestPriority = (integer) priData.get('PriorityId');
	            requestPriorityText = (string) priData.get('PriorityDescription');
	            break;
	        }
	        //get priority detail ends

	        //get assignee detail starts
	        integer assigneeCode = 0;
	        string assigneeName = '';
	        string isTechResource = '';
			List < object > assignObj = getAssignees(fulfillerId);
	        for(object asn:assignObj){
	            Map<string, object> asnData = (Map<string, object>) asn;
	            //AssigneeCode=4647, AssigneeName=27 AMY KIPP, TechResource=N
	            assigneeCode = (integer) asnData.get('AssigneeCode');
	            assigneeName = (string) asnData.get('AssigneeName');
	            isTechResource = (string) asnData.get('TechResource');
	            break;
	        }
	        //get assignee detail ends

	        //get reason detail starts
	        integer reasonCode = 0;
	        string reasonCodeText = '';

	        //As per the bug #238045, business wants to pass blank instead of passing "In Home Damage" which is a very serious claim and causes special attention and processing by the business. We need to avoid that one.
			List < object > reasonObj = getReasonCodes(fulfillerId);
	        for(object reason:reasonObj){
	            Map<string, object> reasonData = (Map<string, object>) reason;
	            //ReasonCodeId=21, ReasonCode=--SELECT--
	            reasonCode = (integer) reasonData.get('ReasonCodeId');
	            reasonCodeText = (string) reasonData.get('ReasonCode');
	            if(reasonCodeText == '--SELECT--') break;
	        }
	        //get reason detail ends

	        //get request detail starts
	        integer requestStatus = 0;
	        string requestStatusText = '';
			List < object > requestObj = getRequestStatus(fulfillerId);
	        for(object reqst:requestObj){
	            Map<string, object> reqstData = (Map<string, object>) reqst;
	            //ConfigOptionId=5, RequestStatus=Tech Scheduled
	            requestStatus = (integer) reqstData.get('ConfigOptionId');
	            requestStatusText = (string) reqstData.get('RequestStatus');
				if(requestStatusText == 'Tech Scheduled') break;
	        }
	        //get request detail ends

	        //If service request is not there for this case then do POST callout starts
	        if(techScheduleRows == 0){

	            //JSON generator to do a POST callout starts
	            JSONGenerator generator = JSON.createGenerator(true);

	            //ServiceTechDto start
	            generator.writeStartObject();

	            string stringFldValue;
	            integer intFldValue;
	            for(string fld : ServiceTechDtoMap.keySet()){
	                stringFldValue = '';
	                intFldValue = 0;
	                if(ServiceTechDtoMap.get(fld) != null){
	                    if(fld == 'ProfitCenterCode'){
	                        intFldValue = (integer) ServiceTechDtoMap.get(fld);
	                    }
	                    else{
	                        stringFldValue = (string) ServiceTechDtoMap.get(fld);
	                    }
	                }

	                if(fld == 'ProfitCenterCode'){
	                    generator.writeNumberField(fld, intFldValue);
	                }
	                else{
	                    generator.writeStringField(fld, stringFldValue);
	                }
	            }

        		if(!Test.isRunningTest()){
                    generator.writeNumberField('RequestPriority', requestPriority);
                    generator.writeStringField('RequestPriorityText', requestPriorityText);
                    generator.writeNumberField('AssigneeCode', assigneeCode);
                    generator.writeStringField('AssigneeName', assigneeName);
                    generator.writeStringField('IsTechResource', isTechResource);
                    generator.writeNumberField('ReasonCode', reasonCode);
                    generator.writeStringField('ReasonCodeText', reasonCodeText);
                    generator.writeNumberField('RequestStatus', requestStatus);
                    generator.writeStringField('RequestStatusText', requestStatusText);
                }

	            generator.writeEndObject();
	            //ServiceTechDto end
	            //JSON generator to do a POST callout ends

	            string jsonString = generator.getAsString();
	            
	            system.debug('****** JSON String: '+ jsonString);
	            system.debug('****** caseObj: ' + caseObj);

				//POST callout starts
	            HttpRequest req = new HttpRequest();
	            req.setEndpoint(endpointTech + fulfillerId +'/customer-service/service-requests');
	            req.setHeader('apikey', apiKeyTech);
	            req.setMethod('POST');
	            req.setBody(jsonString);
	            req.setHeader('Content-Type' ,'application/json');
	            req.setHeader('Accept' ,'application/json');

	            system.debug('****** POST End Point: ' + req.getEndpoint());
	            system.debug('****** POST body: ' + req.getBody());

	            HttpResponse res = new Http().send(req);
	            //POST callout ends

	            system.debug('****** POST Response Status: ' + res.getStatusCode());
	            system.debug('****** POST Response: ' + res.getBody());

                if(!Test.isRunningTest()){
                    //POST callout response body
                    Map<string, object> tS = (Map<string, object>)JSON.deserializeUntyped(res.getBody());
    
                    techScheduleRows = (integer) ts.get('RequestId');
                    system.debug('techrequestid: ' + techScheduleRows);
                }
	        }
	        //If service request is not there for this case then do POST callout ends

			boolean lineItemExist = false;
			if(ItemsDtoList.size() > 0){
				// if there are line items selected from the popup
				lineItemExist = true;
			}
			else{
				if((pliList.size() > 0) && string.isBlank(caseObj.Technician_ServiceReqId__c)){
					//first time when we are scheduling a technician for this case then send 
					//case associated product line item along with selected line item to HOMES
					lineItemExist = true;
				}
			}

			//JSON generator to do a PUT callout starts
	        JSONGenerator putGen = JSON.createGenerator(true);

	        //JSON start
	        putGen.writeStartObject();

	        //ServiceTechDto start
	        if(lineItemExist){
	            putGen.writeFieldName('ServiceTechDto');
	            putGen.writeStartObject();
	        }
	        putGen.writeNumberField('RequestId', techScheduleRows);

	        string stringFldValue;
	        integer intFldValue;
	        // variable used in comment API callout
	        string scheduledDate;
	        Map<string, integer> selectSkuMap = new Map<string, integer>();
	        integer totalItem = 0;

	        for(string fld : ServiceTechDtoMap.keySet()){
	            if(fld == 'ScheduledDate'){
	            	scheduledDate = (string) ServiceTechDtoMap.get(fld);
	            }
	            stringFldValue = '';
	            intFldValue = 0;
	            if(ServiceTechDtoMap.get(fld) != null){
	                if(fld == 'ProfitCenterCode'){
	                    intFldValue = (integer) ServiceTechDtoMap.get(fld);
	                }
	                else{
	                    stringFldValue = (string) ServiceTechDtoMap.get(fld);
	                }
	            }
	            if(fld == 'ProfitCenterCode'){
	                putGen.writeNumberField(fld, intFldValue);
	            }
	            else{
	                putGen.writeStringField(fld, stringFldValue);
	            }
	        }

            if(!Test.isRunningTest()){
                putGen.writeNumberField('RequestPriority', requestPriority);
                putGen.writeStringField('RequestPriorityText', requestPriorityText);
                putGen.writeNumberField('AssigneeCode', assigneeCode);
                putGen.writeStringField('AssigneeName', assigneeName);
                putGen.writeStringField('IsTechResource', isTechResource);
                putGen.writeNumberField('ReasonCode', reasonCode);
                putGen.writeStringField('ReasonCodeText', reasonCodeText);
                putGen.writeNumberField('RequestStatus', requestStatus);
                putGen.writeStringField('RequestStatusText', requestStatusText);
            }

	        if(lineItemExist){
	            putGen.writeEndObject();
	            //ServiceTechDto end

	            //ItemsDto start
	            putGen.writeFieldName('ItemsDto');
	            putGen.writeStartArray();
	            if(ItemsDtoList.size() > 0){
		            for(object itm : ItemsDtoList){
		                Map<string, object> itmData = (Map<string, object>)itm;

						tmpKey = '';
						tmpKey = string.ValueOf(itmData.get('ItemSaleNumber')) + '|' + formatSku(string.ValueOf(itmData.get('ItemSKUNumber'))) + '|' + string.valueOf(itmData.get('ItemSaleSequenceNumber'));

		                putGen.writeStartObject();
		                putGen.writeStringField('IsNewItemRequest', (string) itmData.get('IsNewItemRequest'));
		                putGen.writeStringField('ItemSaleNumber', (string) itmData.get('ItemSaleNumber'));
		                putGen.writeNumberField('ItemSaleSequenceNumber', (integer) itmData.get('ItemSaleSequenceNumber'));
		                putGen.writeStringField('ItemSKUNumber', (string) itmData.get('ItemSKUNumber'));
		                putGen.writeStringField('ItemSerialNumber', (string) itmData.get('ItemSerialNumber'));
		                putGen.writeStringField('ItemInvoiceNumber', (string) itmData.get('ItemInvoiceNumber'));
		                putGen.writeStringField('ItemDefect', '');
		                putGen.writeStringField('PartOrderTrackNumber', (string) itmData.get('PartOrderTrackNumber'));
		                putGen.writeStringField('OrderNumber', (string) itmData.get('OrderNumber'));
		                putGen.writeStringField('PieceExchangedFixed', (string) itmData.get('PieceExchangedFixed'));
		                putGen.writeStringField('PartNumber', (string) itmData.get('PartNumber'));
		                putGen.writeStringField('PartDesc', (string) itmData.get('PartDesc'));
		                putGen.writeStringField('DeliveryDate', (string) itmData.get('DeliveryDate'));
		                putGen.writeStringField('SignedBy', (string) itmData.get('SignedBy'));
		                putGen.writeStringField('RowState', (string) itmData.get('RowState'));
		                putGen.writeNumberField('Select', (integer) itmData.get('Select'));
		                putGen.writeStringField('ItemQuniqueId', (string) itmData.get('ItemQuniqueId'));
		                putGen.writeStringField('OrderStatus', (string) itmData.get('OrderStatus'));
		                putGen.writeStringField('OrderShipInformation', (string) itmData.get('OrderShipInformation'));
		                putGen.writeStringField('ShipDate', (string) itmData.get('ShipDate'));
		                putGen.writeEndObject();

		                selectSkuMap.put(tmpKey, (integer) itmData.get('Qty'));
		                ++totalItem;
		            }
	            }

				if(pliList.size() > 0){

					if(string.isBlank(caseObj.Technician_ServiceReqId__c)){
						//first time when we are scheduling a technician for this case then send 
						//case associated product line item along with selected line item to HOMES
						Map<string, integer> usedSkuMap = new Map<string, integer>();
						integer usedLineCnt;
						boolean sendToHomes;
						for(ProductLineItem__c pli:pliList){

							tmpKey = '';
							usedLineCnt = 0;
							sendToHomes = false;
							tmpKey = string.ValueOf(pli.Sales_Order_Number__c) + '|' + string.ValueOf(pli.Item_SKU__c) + '|' + string.valueOf(pli.Item_Seq_Number__c);

							if(selectSkuMap.get(tmpKey) != null){
								//item selected in associated items, so have to validate the qty then send it to HOMES
								if(usedSkuMap.get(tmpKey) != null){
									usedLineCnt = selectSkuMap.get(tmpKey);
								}

								if(((selectSkuMap.get(tmpKey) == 0) && (usedLineCnt == 0)) || (selectSkuMap.get(tmpKey) > usedLineCnt)){
									sendToHomes = true;
									usedSkuMap.put(tmpKey, ++usedLineCnt);
								}
							}
							else{
								//not selected in associated items, so send this to HOMES
								sendToHomes = true;
							}

							if(sendToHomes){
				                putGen.writeStartObject();
				                putGen.writeStringField('IsNewItemRequest', '1');
				                if(pli.Sales_Order_Number__c != null){
				                	putGen.writeStringField('ItemSaleNumber', string.valueOf(pli.Sales_Order_Number__c));
				                }
				                else{
				                	putGen.writeStringField('ItemSaleNumber', '');
				                }
				                if(pli.Item_Seq_Number__c != null){
				                	putGen.writeNumberField('ItemSaleSequenceNumber', Integer.valueOf(pli.Item_Seq_Number__c));
				                }
				                else{
				                	putGen.writeNumberField('ItemSaleSequenceNumber', 0);
				                }
				                if(pli.Item_SKU__c != null){
				                	putGen.writeStringField('ItemSKUNumber', string.valueOf(pli.Item_SKU__c));
				                }
				                else{
				                	putGen.writeStringField('ItemSKUNumber', '');
				                }
				                if(pli.Item_Serial_Number__c != null){
				                	putGen.writeStringField('ItemSerialNumber', string.valueOf(pli.Item_Serial_Number__c));
				                }
				                else{
				                	//Alan wants the user to enter serial number to associate PLI based on business requirement
				                	//putGen.writeStringField('ItemSerialNumber', '999999');
				                	putGen.writeStringField('ItemSerialNumber', '');
				                }
				                putGen.writeStringField('ItemInvoiceNumber', '');
				                putGen.writeStringField('ItemDefect', '');
				                putGen.writeStringField('PartOrderTrackNumber', '');
				                putGen.writeStringField('OrderNumber', '');
				                putGen.writeStringField('PieceExchangedFixed', '');
				                putGen.writeStringField('PartNumber', '');
				                putGen.writeStringField('PartDesc', '');
				                if(pli.Delivery_Date__c != null){
				                	putGen.writeStringField('DeliveryDate', string.valueOf(pli.Delivery_Date__c));
				                }
				                else{
				                	putGen.writeStringField('DeliveryDate', '');
				                }
				                putGen.writeStringField('SignedBy', '');
				                putGen.writeStringField('RowState', 'A');
				                putGen.writeNumberField('Select', 0);
				                putGen.writeStringField('ItemQuniqueId', '0');
				                putGen.writeStringField('OrderStatus', '');
				                putGen.writeStringField('OrderShipInformation', '');
				                putGen.writeStringField('ShipDate', '');
				                putGen.writeEndObject();

				                ++totalItem;
							}
						}
					}
					else{
						//add PLI count in case of rescheduling techinican if line items are selected from associate item list, if SR already exists
						totalItem = totalItem + pliList.size();
					}
				}
	            putGen.writeEndArray();
	            //ItemsDto end
	        }
			else{
				//add PLI count in case of rescheduling techinican if no line item is selected from associate item list, if SR already exists
				totalItem = totalItem + pliList.size();
			}
	        putGen.writeEndObject();        
	        //JSON end
	        //JSON generator to do a PUT callout starts

	        string jsonPutString = putGen.getAsString();

	        //PUT callout starts
	        HttpRequest req1 = new HttpRequest();
	        if(lineItemExist){
	        	req1.setEndpoint(endpointTech + fulfillerId +'/customer-service/service-technicians-with-items');
	        }
	        else{
	            req1.setEndpoint(endpointTech + fulfillerId +'/customer-service/service-technicians');
	        }

	        req1.setHeader('apikey', apiKeyTech);
	        req1.setMethod('PUT');
	        req1.setBody(jsonPutString);
	        req1.setHeader('Content-Type' ,'application/json');

	        system.debug('****** PUT End Point: ' + req1.getEndpoint());
	        system.debug('****** PUT body: ' + req1.getBody());

	        HttpResponse res1 = new Http().send(req1);
	        //PUT callout ends

	        system.debug('****** PUT Response Status: ' + res1.getStatusCode());
	        system.debug('****** PUT Response: ' + res1.getBody());

			//getting user time zone and community name to pass in comments
			User objUser = [Select Id, CommunityNickname, timezonesidkey from User where Id=:UserInfo.getUserId()];
			Datetime dtDateTime = system.now();
			string strDateTime = dtDateTime.format('MM/dd/yyyy HH:mm:ss', objUser.timezonesidkey );
			//system.debug(strDateTime);
/*
			//JSON generator to do comment callout starts
	        //create a comment on Scheduling a technician
	        JSONGenerator comGen = JSON.createGenerator(true);

			//JSON start
	        comGen.writeStartObject();
	        comGen.writeNumberField('RequestId', techScheduleRows);
	        comGen.writeStringField('CommentText', 'Technician Scheduled from Salesforce Case: ' + caseObj.CaseNumber + ' by ' + objUser.CommunityNickname + ' for ' + scheduledDate + ' on ' + strDateTime + ' (' + objUser.timezonesidkey + ') with ' + totalItem + ' total items - ' + caseObj.Subject + ' - ' + caseObj.Description);
	        comGen.writeNumberField('CreatedUserID', 0);
	        comGen.writeEndObject();        
	        //JSON end
	        //JSON generator to do comment callout ends

	        string jsoncomString = comGen.getAsString();
*/

			transient string CommentText = 'Technician Scheduled from Salesforce Case: ' + caseObj.CaseNumber + ' by ' + objUser.CommunityNickname + ' for ' + scheduledDate + ' on ' + strDateTime + ' (' + objUser.timezonesidkey + ') with ' + totalItem + ' total items - ' + caseObj.Subject + ' - ' + caseObj.Description;

			boolean split = false;
			if(CommentText.length() > 1024){
				split = true;
			}

			transient List<string> resultArray = new List<string>();
			if(split){
				transient List<string> commArray = CommentText.split(' ', 0);
				CommentText = '';
				resultArray = TechSchedulingController.splitComment(commArray, 0, new List<string>());
				//system.debug('Heap size used: ' + Limits.getHeapSize() + ' : ' + resultArray.size());
				//system.debug('commArray: ' + resultArray);
			}
			else{
				resultArray.add(CommentText);
			}

			JSONGenerator comGen = JSON.createGenerator(true);

			comGen.writeStartObject();
			comGen.writeNumberField('RequestId', techScheduleRows);
			comGen.writeFieldName('CommentText');
			comGen.writeStartArray();
			integer cnt = 0;
			for(string res : resultArray){
				if(split){
					++cnt;
					//have to add some text in the front (10 of 99 - 10/29/2018 17:28:28)
					comGen.writeString('(' + cnt + ' of ' + resultArray.size() + ' - ' + strDateTime + ') ' + res);
				}
				else{
					comGen.writeString(res);
				}
			}
			comGen.writeEndArray();
			comGen.writeNumberField('CreatedUserID', 0);
			comGen.writeEndObject();

			string jsoncomString = comGen.getAsString();
			system.debug('****** jsoncomString: ' + jsoncomString);

			//Comment callout starts
	        HttpRequest comReq = new HttpRequest();
	        comReq.setEndpoint(endpointTech + fulfillerId +'/customer-service/service-requests/comments');
	        comReq.setHeader('apikey', apiKeyTech);
	        comReq.setMethod('POST');
	        comReq.setBody(jsoncomString);
	        comReq.setTimeOut(120000);
	        comReq.setHeader('Content-Type' ,'application/json');

	        system.debug('****** COM POST End Point: ' + comReq.getEndpoint());
	        system.debug('****** COM POST body: ' + comReq.getBody());

	        HttpResponse comRes = new Http().send(comReq);
			//Comment callout starts

	        system.debug('****** COM POST Response Status: ' + comRes.getStatusCode());
	        system.debug('****** COM POST Response: ' + comRes.getBody());

	        if(techScheduleRows > 0){
	            //create new address for that customer and update that address id in case address field
	            Address__c addrObj = new Address__c();
	            if(caseObj.Address__c == null){
		            addrObj.Address_Line_1__c = sAdd1;
		            addrObj.Address_Line_2__c = sAdd2;
		            addrObj.City__c = sCity;
		            addrObj.State__c = sState;
		            addrObj.Zip_Code__c = sZip;
		            addrObj.AccountId__c = caseObj.AccountId;
		            addrObj.Preferred__c = true;
		            addrObj.Address_Type__c = 'Ship To';
		            insert addrObj;
	            }
	            else{
	            	addrObj = [SELECT Id, Address_Line_1__c, Address_Line_2__c, City__c, State__c, Zip_Code__c FROM Address__c WHERE Id = :caseObj.Address__c];
		            addrObj.Address_Line_1__c = sAdd1;
		            addrObj.Address_Line_2__c = sAdd2;
		            addrObj.City__c = sCity;
		            addrObj.State__c = sState;
		            addrObj.Zip_Code__c = sZip;
	            	update addrObj;
	            }

	        	//save case details
	        	caseObj.Address__c = addrObj.Id;
	            caseObj.Technician_Schedule_Date__c = caseIs.Technician_Schedule_Date__c;
	            caseObj.Technician_Company__c = caseIs.Technician_Company__c;
	            caseObj.TechnicianNameScheduled__c = caseIs.TechnicianNameScheduled__c;
	            caseObj.followup_Priority_EstimatedTime__c = caseIs.followup_Priority_EstimatedTime__c;
	            caseObj.Technician_Address__c = caseIs.Technician_Address__c;
	            caseObj.Technician_ServiceReqId__c = string.ValueOf(techScheduleRows);
	            if(string.isBlank(caseObj.Legacy_Service_Request_ID__c)){
	            	caseObj.Legacy_Service_Request_ID__c = string.ValueOf(techScheduleRows);
	            }

				//as per the work item# 247852, clearing legacy section tech schedule details
				caseObj.Legacy_Assignee__c = null;
				caseObj.Legacy_Account_Ship_To__c = null;
				caseObj.Legacy_Technician__c = null;
				caseObj.Company__c = null;
				caseObj.Follow_up_Date__c = null;
				caseObj.Estimated_time_for_stop__c = null;
				caseObj.Tech_Scheduled_Date__c = null;

	            update caseObj;
	        }

	        resultStr = string.ValueOf(techScheduleRows);
		}
		//perform callout ends
		return resultStr;
    }
    
    @AuraEnabled
    public static boolean confirmProductLineItem(string sku, string serialNo){
        system.debug('****** SKU: '+sku);
        system.debug('****** serialNo: '+serialNo);
        if((serialNo == '99999') || (serialNo == '999999')){
            return true;
        }
        else{
            sku = formatSku(sku);
            ProductLineItem__c record = [SELECT Id,Item_SKU__c,Item_Serial_Number__c FROM ProductLineItem__c WHERE Item_SKU__c =:sku LIMIT 1];

            ID mynum = record.Id;
            string PLSKU = formatSku(record.Item_SKU__c);

            // get Access token call
            ServiceReplacementPartsAuthorization replPart= new ServiceReplacementPartsAuthorization();
            string accessTkn = replPart.accessTokenData();
            system.debug('****** accesstokenresponse: ' + accessTkn);

            //Send the request
            HttpRequest req = new HttpRequest();
            req.setEndpoint(system.label.TechSchedulingLineItemEndPoint + '?serialNumber=' + serialNo + '&itemNumber=' + PLSKU);
            req.setMethod('GET');
            req.setHeader('Content-Type' ,'application/json;charset=utf-8');
            req.setHeader('Authorization', 'Bearer '+accessTkn);
            req.setHeader('apikey', system.label.techSchedulinglineitemKey);

            Http http = new Http();
            HttpResponse res = http.send(req);

            system.debug('****** Serial num Response Status: '+ res.getStatus());
            system.debug('****** Serial num Response Body: '+ res.getBody());
            system.debug('****** Serial num Response Status Code: '+ res.getStatusCode());

            boolean isValid = true;
            if(res.getStatusCode() == 200){
                if(res.getBody() =='false' && serialNo != null){
                    system.debug('serial number not valid'+record);
                    system.debug('mynum--> '+mynum);
                    isValid = ProductLineItemFromOrderValidation.Validation('PLIH',mynum);
                    system.debug('isValid--> '+isValid);
                    return false;
                }
                else{
                    system.debug('No Serial Number'+record);
                    system.debug('mynum--> '+mynum);
                    isValid = ProductLineItemFromOrderValidation.UpdateValidation('PLIH',mynum);
                    system.debug('isValid--> '+isValid);
                    system.debug('true'+record);
                    return true;
                }
            }
            return false;
        }
    }

    public static string formatSku(String ipSku){
    	/*string opSku;
		if(ipSku != null)
        {
            string[] ItemNum1 = ipSku.split('[^0]*');
            integer i=0;
            for(i=0; i< ItemNum1.size(); i++){
                if(ItemNum1[i]=='') break;
                system.debug('Num1-->'+ItemNum1[i]);
                system.debug('\n');
            }
            system.debug('i-->'+i);
            opSku = ipSku.substring(i);
            opSku.trim();
            system.debug('opSku-->'+opSku);
		}*/
    	return ipSku;
    }

    @AuraEnabled
    public static Map < string, List<integer> > getTechScheduleDuration(string fulfillerId) {
        string httpReqVar = endpointTech + fulfillerId + '/customer-service/service-technicians-schedule-duration';
        //https://ashley-preprod-qa.apigee.net/homestores/8888300-164/customer-service/service-technicians-schedule-duration?apikey=bGna5ABiJwsJyqV9DDtQmTBEH2Kpz713

        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setHeader('apikey', apiKeyTech);
        req.setHeader('Accept', 'application/json');
        req.setEndpoint(httpReqVar);
        req.setTimeOut(120000);
        req.setMethod('GET');
        HttpResponse res = http.send(req);

        // Deserialize the JSON string into collections of primitive data types.
        Map < string, object > resultsMap = (Map < string, object > ) JSON.deserializeUntyped(res.getBody());
        system.debug('****** TechScheduleDuration Map: ' + resultsMap);

		List<integer> hrsList = new List<integer>();
		for(integer h=integer.valueOf(resultsMap.get('Minimum')); h<=integer.valueOf(resultsMap.get('Maximum')); h++){
		    hrsList.add(h);
		}
		system.debug('****** hrsList: ' + hrsList);

		List<integer> minsList = new List<integer>();
		for(integer m=0; m<60; m=m+integer.valueOf(resultsMap.get('Increments'))){
		    minsList.add(m);
		}
		system.debug('****** minsList: ' + minsList);

		Map < string, List<integer> > returnMap = new Map < string, List<integer> >();
		returnMap.put('hours', hrsList);
		returnMap.put('mins', minsList);

        return returnMap;
    }

    @AuraEnabled
    public static List<string> getCasePli(string caseId) {
    	//method used to get the pli assigned to the case to calculate estimate time for stop in the tech schedule calendar
		List<ProductLineItem__c> pliList = [Select Id, Sales_Order_Number__c, Item_SKU__c, Item_Seq_Number__c, Item_Serial_Number__c FROM ProductLineItem__c WHERE Case__c = :caseId];
		List<string> pliReturnList = new List<string>();
		if(pliList.size() > 0){
			for(ProductLineItem__c pli : pliList){
				pliReturnList.add(pli.Sales_Order_Number__c + '|' + pli.Item_SKU__c + '|' + pli.Item_Seq_Number__c);
			}
		}
		return pliReturnList;
    }

	public static List<string> splitComment(List<string> commArray, integer len, List<string> rtnArray){
		transient string tmpStr = '', rtnStr = '';
		for(integer c=len; c<commArray.size(); c++){
			transient string comm = commArray[c];

			tmpStr = '';
			tmpStr = rtnStr;

			if(tmpStr != ''){
				tmpStr += ' ';
			}
			tmpStr += comm;

			if(tmpStr.length() > 950){
				rtnArray.add(rtnStr);
				//system.debug('Heap size used: ' + len + ':' + Limits.getHeapSize());
				return splitComment(commArray, c, rtnArray);
			}
			else{
				rtnStr = tmpStr;
			}
		}
		rtnArray.add(rtnStr);
		return rtnArray;
	}

    @AuraEnabled
    public static list<string> isValidTechSchedule(Id recordId) {
    	list<string> returnList = new list<string>();
    	Case caseDetail = new Case();
    	caseDetail = getCaseObj(recordId);
    	if(caseDetail != null) {
    		if(caseDetail.Address__c == null){
    			returnList.add('AddressErr');
    		}
    	}
		//system.debug('caseDetail: ' + caseDetail);

		List<string> pliList = new List<string>();
		pliList = getCasePli(recordId);
		if(pliList.size() == 0){
			returnList.add('PliErr');
		}
		//system.debug('pliList: ' + pliList);

		system.debug('****** returnList: ' + returnList);
    	return returnList;
    }

    @AuraEnabled
    public static List <string> getStateVal() {
        List<string> statePlList = new List<string>();
        Schema.DescribeFieldResult fieldResult = Address__c.StatePL__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry f: ple) {
        	if(f.isActive()){
        		statePlList.add(f.getValue());
        	}
        }
        return statePlList;
    }

    @AuraEnabled
    public static void updateCase(Case caseObj) {
    	//this method is not used
        update caseObj;
    }

    // Get fulfiller Id from External Id
    @AuraEnabled
    public static string getfulfillerId(string extId){
    	//this method is not used
        system.debug('****** Ext Id Full: '+ extId);
        SalesOrder__x salesOrderObj = new SalesOrder__x();
        if(Test.isRunningTest()){
            salesOrderObj = new SalesOrder__x(fulfillerID__c = '8888300-164',
                                              ExternalId = '204258:0012900000GRH2LAAX');
        }else{
            salesOrderObj = [SELECT ExternalId, fulfillerID__c, Id, phhProfitcenter__c, phhCustomerID__c 
                             FROM SalesOrder__x 
                             WHERE ExternalId =: extId];
        }
        system.debug('****** SO Obj Full fill: '+ salesOrderObj);
        return salesOrderObj.fulfillerID__c;
    }

    @AuraEnabled
    public static Address__c getAddr(Id accountId,String addressId, String add1, String add2, String city, String state, String zip) {
        //this method is not used
        Address__c addr = new Address__c();
        List<Address__c> addresses = new List<Address__c>([select id from Address__c where id =:addressId LIMIT 1]);
        system.debug('****** address: ' + addresses);
        for(Address__c add:addresses) {
            if(addresses.size() ==0) {
                add.AccountId__c = accountId;
                add.Address_Line_1__c = add1;
                add.Address_Line_2__c = add2;
                add.City__c = city;
                add.State__c = state;
                add.Zip_Code__c = zip;
                insert add;
                system.debug('****** insert: ' + add);
            }
            else {
                add.Address_Line_1__c = add1;
                add.Address_Line_2__c = add2;
                add.City__c = city;
                add.State__c = state;
                add.Zip_Code__c = zip;
                update add;
                system.debug('****** update: ' + add);
            }  
        }
        
        return addr;
    }

    @AuraEnabled
    public static Case_Line_Item__c getLineItemcase(Id recordId){
    	//this method is not used
        Case_Line_Item__c caseItemObj = [SELECT Address_1__c,Address_2__c,Customer_Number__c,Defect_Details__c,Case__c FROM Case_Line_Item__c WHERE  Case__c = :recordId];
        return caseItemObj;
    }

    @AuraEnabled
    public static void newProductLineItemRecord(Id recordId){
    	//this method is not used
        Case caseObj = getCaseObj(recordId);
        String accId = caseObj.AccountId;
    }
    
    @AuraEnabled
    public static Boolean getSerialNumber(String jsonSchItem){ 
        //this method is not used
        system.debug('jsonSchItem-----'+jsonSchItem);
        return false;
    }
}