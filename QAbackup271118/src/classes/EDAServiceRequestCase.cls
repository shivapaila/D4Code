@RestResource (urlMapping='/ServiceRequests-Case/*')
global class EDAServiceRequestCase {

    global class CaseWrap {
        public string SFDCAccountId { get; set; }
        public string Description { get; set; }
        public string MarketAccount { get; set; }
        public string StoreNameStoreNumberPC { get; set; }
        public string Subject { get; set; }
        public string ProfitCenterDescription { get; set; }
        public string RequestType { get; set; }
        public string RequestSubType { get; set; }
        public string RequestOrigin { get; set; }
        public string AssigneeName { get; set; }
        public string SalesOrderNumber { get; set; }
        public string ServiceTechVendorId { get; set; }
        public string OpenDate { get; set; }
        public string ReasonCodeText { get; set; }
        public string OpenDateAsChar { get; set; }
        public string RequestPriority { get; set; }
        public string AssigneeCode { get; set; }
        public string IsTechResource { get; set; }
        public string ReasonCode { get; set; }
        public string FollowUpDate { get; set; }
        public string FollowUpDateAsChar { get; set; }
        public string ReopenDate { get; set; }
        public string ReopenDateAsChar { get; set; }
        public string ProfitCenterCode { get; set; }
        public string ServiceTechID { get; set; }
        public string ScheduleDate { get; set; }
        public string ScheduleDateAsChar { get; set; }
        public string RequestSaleOrderNumber { get; set; }
        public string RequestStatus { get; set; }
        public string RequestActiveFlag { get; set; }
        public string CreatedTime { get; set; }
        public string CreatedUserID { get; set; }
        public string LastTime { get; set; }
        public string LastUserID { get; set; }
        public string CustomerPhone1 { get; set; }
        public string CustomerPhone2 { get; set; }
        public string CustomerPhone3 { get; set; }
        public string CustomerEmail { get; set; }
        public string EstimatedTimeForStop { get; set; }
        public string AccountShipto { get; set; }
        public string RequestID { get; set; }
        public string CustomerType { get; set; }
        public string CustomerID { get; set; }
        public string ShipToAddress1 { get; set; }
        public string ShipToAddress2 { get; set; }
        public string ShipToCityName { get; set; }
        public string ShipToStateCode { get; set; }
        public string ShipToZipCode { get; set; }
        public string UniqueID { get; set; }
    }

    global class testWrap {
        List<CaseWrap> testwrapper;
        testWrap(){
            testwrapper = new List<CaseWrap>();
        }
    }

    @HttpPost
    global static string doPost(){
        RestResponse res = RestContext.response;

        RestRequest req = RestContext.request;
        req.httpMethod = 'POST';
        req.addHeader('Content-Type', 'application/json');
        string JSONString = req.requestBody.toString();
        Map<string, Object> Someval = (Map<string, Object>)JSON.deserializeUntyped(JSONString);
        system.debug('****** Key val: ' + Someval.keySet());

        List<Map<string, Object>> data = new List<Map<string, Object>>();
        for (Object instance : (List<Object>)Someval.get('CsrMaster')){
            data.add((Map<string, Object>)instance);
            system.debug('****** data: '+data);
        }

        Set<string> reqId = new Set<string>();
        Set<string> AccId = new Set<string>();
        List<CaseWrap> caseList = new List<CaseWrap>();
        for(integer i=0; i<data.size(); i++){
            string Someval3 = JSON.serialize(data[i]);
            CaseWrap Someval4 = (CaseWrap)JSON.deserialize(Someval3, CaseWrap.class);
            system.debug('****** data val: ' + Someval4.SFDCAccountId);
            AccId.add(Someval4.SFDCAccountId);
            reqId.add(Someval4.RequestID);
            caseList.add(Someval4);
        }

		List<Case> myCase = new List<Case>();
		List<Address__c> myAddress = new List<Address__c>();
        List<Contact> Con = new List<Contact>();
        List<Account> Acc = new List<Account>();
        if(data.size()>0){
            myCase = [SELECT AccountId, Address_Line_1__c, Address_Line_2__c, Address__c, CaseNumber, Case_Email__c, Case_Phone_Number__c, Category_Reason_Codes__c, City__c, Company__c,
                      ContactId, CreatedDate, Description, Estimated_time_for_stop__c, Follow_up_Date__c, Id, Legacy_Account_Ship_To__c, Legacy_Assignee__c, Legacy_Priority__c,
                      Legacy_Service_Request_ID__c, Market__c, Origin, Reason,Request_Status__c, Sales_Order__c, Status, Subject, Sub_Type__c, Tech_Scheduled_Date__c, LastModifiedDate,Type,
                      TechnicianNameScheduled__c, Technician_Schedule_Date__c, Technician_Company__c, followup_Priority_EstimatedTime__c, Technician_Address__c, Technician_ServiceReqId__c
                      FROM Case WHERE AccountId IN :AccId AND Legacy_Service_Request_ID__c IN :reqId];
            myAddress = getAddresses(AccId, reqId);
            con = [SELECT Id, AccountId FROM Contact WHERE AccountId IN :AccId];
            Acc = [SELECT Id FROM Account WHERE ID IN :AccId];
        }

        boolean caseTechScheduled = false;
        boolean insertFlag = false;
        boolean updateFlag = false;
        for(CaseWrap cw : caseList){
			system.debug('****** CW: ' + cw);
            string cwReqId = cw.RequestID;
            string cwAccId = cw.SFDCAccountId;

            boolean isValidAcc = false;
            if(Acc.size() > 0){
                for(Account a : Acc){
                    if(Id.valueOf(cwAccId) == a.Id)
                        isValidAcc = true;
                }
            }

            if(isValidAcc == true){

		        boolean caseExist = false;

                for(integer i = 0; i < myCase.size(); i++){
                    if((myCase[i].AccountId == cwAccId) && (myCase[i].Legacy_Service_Request_ID__c == cwReqId)){
                        caseExist = true;
                        system.debug('****** Case available: ' + myCase[i]);
                        if(!string.isBlank(myCase[i].TechnicianNameScheduled__c) && (myCase[i].Technician_Schedule_Date__c != null)){
							system.debug('****** technician scheduled');
                            caseTechScheduled = true;
						}
                        break;
                    } else {
                        caseExist = false;
                    }
                }

				Case CaseToInsert = new Case();
                if(!caseExist) {
                    CaseToInsert = myCasee(cw, caseExist, cwReqId, cwAccId, myAddress, con, myCase);
                    if (!(cw.LastTime == null || cw.LastTime == '')){
						CaseToInsert.CreatedDate = Date.parse(cw.CreatedTime);
						CaseToInsert.LastModifiedDate = Date.parse(cw.LastTime);
						system.debug('****** thisCase: ' + CaseToInsert.CreatedDate);
                    }
                    insert CaseToInsert;
                    system.debug('****** Insertion successfully: ' + CaseToInsert);
                    insertFlag = true; 
                }
                else if(!caseTechScheduled) {
                    CaseToInsert = myCasee(cw, caseExist, cwReqId, cwAccId, myAddress, con, myCase);
                    system.debug('****** Update Case: ' + CaseToInsert.Id);
                  	update CaseToInsert;
                    system.debug('****** Updated successfully: ' + CaseToInsert.Id);
                    updateFlag = true;
                }
            }
        }

        if(caseTechScheduled) {
            if(insertFlag && updateFlag) {
                return 'Insertion and Updation Successful...Cases are having technician scheduled';  
            } else if(insertFlag) {
                return 'Insertion Successful...Cases are having technician scheduled';
            } else if(updateFlag) {
                return 'Updation Successful...Cases are having technician scheduled';
            }
            else {
                return 'Cases are having technician scheduled';
            }
        } else {
            if(insertFlag && updateFlag) {
                return 'Insertion and Updation Successful...';  
            } else if(insertFlag) {
                return 'Insertion Successful...';
            } else if(updateFlag){
                return 'Updation Successful...';
            }
        }
        system.debug('****** myvals: ' + Someval);
        return 'Insertion Failed...';
    }

    @TestVisible
    private static Case myCasee(CaseWrap Someval, boolean flag, string Reqid, string Accid, List<Address__c> AddressList, List<Contact> Con, List<Case> caseList){
        Case thisCase = new Case();
        system.debug('****** flag: ' + flag);

        if(flag) {
        	//if case exist
            system.debug('****** myvals: ' + Someval);
            for(integer i = 0; i < caseList.size(); i++){
            	if(caseList[i].AccountId == Someval.SFDCAccountId && caseList[i].Legacy_Service_Request_ID__c == Someval.RequestID){
                    thisCase = caseList[i];
                    if(!string.isBlank(thisCase.TechnicianNameScheduled__c) && (thisCase.Technician_Schedule_Date__c != null)){
						return thisCase;
					}
                    system.debug('****** thisCase: ' + thisCase);
                    break;
                }
            }
        }

        system.debug('****** thisCase: ' + thisCase);
        boolean AddressFlag = false;
        List<Address__c> Addr = new List<Address__c>();
        try{
            if(AddressList.size() > 0){
                for(integer i= 0; i < AddressList.size(); i++){
                    if(Someval.SFDCAccountId == AddressList[i].AccountId__c)
                        Addr.add(AddressList[i]);
                }
            }
            if(Addr.size() > 0)
                AddressFlag = true;
        }
        catch(Exception e){}

        Address__c AddressToInsert = new Address__c();
        Address__c myAddress = new Address__c();
        if(AddressFlag){
        	//if address is available in the pay load
			if((!string.isBlank(Someval.ShipToAddress1)) && 
			(Someval.ShipToCityName != null || Someval.ShipToCityName != '') &&
			(Someval.ShipToStateCode != null || Someval.ShipToStateCode != '') &&
			(Someval.ShipToZipCode != null || Someval.ShipToZipCode != '')){
				//if all address values are available in the pay load
				for(Address__c A: Addr){
					if((A.Address_Line_1__c == Someval.ShipToAddress1) && (A.Address_Line_2__c == Someval.ShipToAddress2)
                      && (A.City__c == Someval.ShipToCityName) && (A.State__c == Someval.ShipToStateCode) && 
                      (A.Zip_Code__c == Someval.ShipToZipCode)){
						//if the pay load address matches with customer address
						if(A.Address_Type__c != 'Ship To'){
							//if the matching address type is not equal ship to then set it to ship to
							A.Address_Type__c = 'Ship To';
							update A;
						}
						thisCase.Address__c = A.Id;
						AddressFlag = false;
						system.debug('****** Assign Address to the case: ' + thisCase.Address__c);
						break;
					}
               }

               if(AddressFlag){
               		//if the pay load address not matches with the customer address then insert in address and assign to case
					//insert new address record to the Account
					system.debug('****** Insert Address to account having other Addresses');
					AddressFlag = false;
					AddressToInsert = myAdd(Someval);
					AddressToInsert.AccountId__c = Someval.SFDCAccountId;
					insert AddressToInsert;
					thisCase.Address__c = AddressToInsert.Id;
					system.debug('****** Insert Address to account having other Addresses: ' + thisCase.Address__c);
				}
            } else {
            	//if any of the address value is not available in the pay load
                //Assign Address to the Case
                try{
                    system.debug('****** myAddress initial-->'+thisCase.Address__c);
                    for(integer i= 0; i < AddressList.size(); i++){
                        if(AddressList[i].Preferred__c == true){
                            thisCase.Address__c = AddressList[i].Id;
                            Addressflag = true;
                            system.debug('****** myAddress final: ' + thisCase.Address__c);
                            break;
                        }
                    }
                }
                catch(Exception e){
                    system.debug('****** myAddress initial without preferred address: ' + thisCase.Address__c);
                    if(AddressList.size() > 0){
                        thisCase.Address__c = AddressList[0].Id;
                        Addressflag = true;
                        system.debug('myAddress final-->'+thisCase.Address__c);
                    }
                    else{
                        thisCase.Address__c = NULL;
                    }
                    Addressflag = true;
                    system.debug('****** myAddress final without preferred address: ' + thisCase.Address__c);
                }
            }
        }
        else{
        	//if there is no address available for the customer then insert from the pay load if available
            if(!string.isBlank(Someval.ShipToAddress1)){
                //insert new address record to the Acccount from the pay load
                system.debug('****** Insert Address to account having No Address');
                AddressToInsert = myAdd(Someval);
                AddressToInsert.AccountId__c  = Someval.SFDCAccountId;
                system.debug('****** AddressToInsert: ' + AddressToInsert);
                insert AddressToInsert;
                thisCase.Address__c = AddressToInsert.Id;
                system.debug('****** Insert Address to account having No Address'+thisCase.Address__c);
            }
            else{
            	//no address available in the pay load as well as for the customer
                thisCase.Address__c = null;
            }
        }

        If(!string.isBlank(Someval.SalesOrderNumber)){
            string SOexternalID = Someval.SalesOrderNumber + ':' + Someval.SFDCAccountId;
            thisCase.Sales_Order__c = SOexternalID;
        } else {
            thisCase.Sales_Order__c = null;
        }

        for(integer i=0; i<Con.size(); i++){
            if(Con[i].AccountId == Someval.SFDCAccountId)
                thisCase.ContactId = Con[i].Id;
        }

		if (!string.isBlank(Someval.EstimatedTimeForStop)){
			//2Hour40
			string estTimeStop = Someval.EstimatedTimeForStop;
			integer dotIndex = estTimeStop.indexOf('.');
			string hrs, tmpMin, mins = ''; 
			if(dotIndex != -1){
				hrs = estTimeStop.substring(0, dotIndex);
				tmpMin = estTimeStop.substring(++dotIndex, estTimeStop.length());
			} else {
				hrs = estTimeStop;
			}

			if((tmpMin == '8') || (tmpMin == '08')){
				mins = '5';
			} else if(tmpMin == '17'){
				mins = '10';
			} else if(tmpMin == '25'){
				mins = '15';
			} else if(tmpMin == '33'){
				mins = '20';
			} else if(tmpMin == '42'){
				mins = '25';
			} else if(tmpMin == '50'){
				mins = '30';
			} else if(tmpMin == '58'){
				mins = '35';
			} else if(tmpMin == '67'){
				mins = '40';
			} else if(tmpMin == '75'){
				mins = '45';
			} else if(tmpMin == '83'){
				mins = '50';
			} else if(tmpMin == '92'){
				mins = '55';
			}

			thisCase.Estimated_time_for_stop__c = hrs + 'Hour' + mins;
		}

        thisCase.AccountId = Id.valueOf(Someval.SFDCAccountId);
        thisCase.Status = Someval.RequestStatus;
        thisCase.Type = Someval.RequestType;
        thisCase.Sub_Type__c = Someval.RequestSubType;
        thisCase.Description = Someval.Description;
        thisCase.Market__c = Someval.MarketAccount;
        thisCase.Subject = Someval.Subject;
        thisCase.Origin = Someval.RequestOrigin;
        thisCase.Reason = Someval.ReasonCodeText;
        thisCase.Category_Reason_Codes__c = Someval.ReasonCode;
        thisCase.Request_Status__c = Someval.RequestStatus;
        thisCase.Priority = Someval.RequestPriority;
        thisCase.Profit_Center__c = Someval.StoreNameStoreNumberPC;
        thisCase.Legacy_Service_Request_ID__c = Someval.RequestID;
        thisCase.Case_Phone_Number__c = Someval.CustomerPhone1;
        thisCase.SuppliedPhone = Someval.CustomerPhone2;
        thisCase.Case_Email__c = Someval.CustomerEmail;
		thisCase.Follow_up_Date__c = null;
		thisCase.Tech_Scheduled_Date__c = null;

		//as per the work item# 247852, clearing legacy section tech schedule details
		if(thisCase.Technician_ServiceReqId__c != null){
			//Case updated from HOMES / Techinican was scheduled from SF
			//blank out all legacy field under 'Legacy data information' section except 'Legacy_Service_Request_ID__c' and update 'Service technician information' section

			//'Service technician information' section field update
            thisCase.TechnicianNameScheduled__c = Someval.ServiceTechID;
            thisCase.Technician_Company__c = Someval.ServiceTechVendorId;
            thisCase.followup_Priority_EstimatedTime__c = thisCase.Estimated_time_for_stop__c;

            string adrStr = '';
            if (!string.isBlank(Someval.ShipToAddress1)){
	            adrStr += Someval.ShipToAddress1 + ',';
	        }
            if (!string.isBlank(Someval.ShipToAddress2)){
	            adrStr += Someval.ShipToAddress2 + ',';
	        }
            if (!string.isBlank(Someval.ShipToCityName)){
	            adrStr += Someval.ShipToCityName + ',';
	        }
            if (!string.isBlank(Someval.ShipToStateCode)){
	            adrStr += Someval.ShipToStateCode + ',';
	        }
            if (!string.isBlank(Someval.ShipToZipCode)){
	            adrStr += Someval.ShipToZipCode;
	        }
	        thiscase.Technician_Address__c = adrStr;

			if (!string.isBlank(Someval.ScheduleDate)){
    	        thisCase.Technician_Schedule_Date__c = Date.parse(Someval.ScheduleDate);
	        }

			//'Legacy data information' section field update
			thisCase.Legacy_Assignee__c = null;
			thisCase.Legacy_Account_Ship_To__c = null;
			thisCase.Legacy_Technician__c = null;
			thisCase.Company__c = null;
			thisCase.Estimated_time_for_stop__c = null;
		}
		else{
			//First time case is created from HOMES / Techinican is yet to schedule from SF
			thisCase.Legacy_Assignee__c = Someval.AssigneeName;
			thisCase.Legacy_Account_Ship_To__c = Someval.AccountShipto;
			thisCase.Legacy_Technician__c = Someval.ServiceTechID;
			thisCase.Company__c = Someval.ServiceTechVendorId;
	        if (!string.isBlank(Someval.FollowupDate)){
	            thisCase.Follow_up_Date__c = Date.parse(Someval.FollowupDate);
	        }
			if (!string.isBlank(Someval.ScheduleDate)){
    	        thisCase.Tech_Scheduled_Date__c = Date.parse(Someval.ScheduleDate);
	        }
		}


        return thisCase;
    }

    public static Address__c myAdd(CaseWrap Someval) {
        Address__c Add = new Address__c();
        Add.Address_Line_1__c = Someval.ShipToAddress1;
        Add.Address_Line_2__c = Someval.ShipToAddress2;
        Add.City__c = Someval.ShipToCityName;
        Add.State__c = Someval.ShipToStateCode;
        Add.Zip_Code__c = Someval.ShipToZipCode;
        Add.Address_Type__c = 'Ship To';
        return Add;
    }

    public static List<Address__c> getAddresses(Set<string> AccId, Set<string> reqId) {
        List<Address__c> AddressList = new List<Address__c>();
        AddressList = [SELECT AccountId__c, Address_Line_1__c, Address_Line_2__c, Address_Type__c, Address_Validation_Status__c,
                       Address_Validation_Timestamp__c, City__c, Country__c, Geocode__c, Geocode__Latitude__s, Geocode__Longitude__s,
                       Id, LastModifiedDate, Preferred__c, State__c, Zip_Code__c 
                       FROM Address__c WHERE AccountId__c IN :AccId ORDER BY LastModifiedDate DESC];
        return AddressList;
    }
}