@RestResource (urlMapping='/ServiceRequests-CaseUpdate/*')
global class EDAServiceRequestCaseUpdate {    
    Public Class CaseLineItemWrap{
        Public String SFDCAccountId  {get;set;}
        public String ItemInvoiceDate  {get;set;}
        public String ItemSerialNumber  {get;set;}
        public String ProfitCenter  {get;set;}
        public String ItemUniqueID  {get;set;}
        public String ItemSaleNumber  {get;set;}
        public String ItemDescription  {get;set;}
        public String ItemSKUNumber  {get;set;}
        public String ItemInvoiceNumber  {get;set;}
        public String ItemDefect  {get;set;}
        public String DefectDesc  {get;set;}
        public String PartOrderTrackNumber  {get;set;}
        public String OrderNumber  {get;set;}
        public String OrderStatus  {get;set;}
        public String OrderShipToInfo  {get;set;}
        public String OrderShipDate  {get;set;}
        public String OrderShipDateAsChar  {get;set;}
        public String PieceExchangedFixed  {get;set;}
        public String CreatedTime  {get;set;}
        public String CreatedUserID  {get;set;}
        public String LastTime  {get;set;}
        public String LastUserID  {get;set;}
        public String PartNumber  {get;set;}
        public String PartDescription  {get;set;}
        public String DeliveryDate  {get;set;}
        public String DeliveryDateAsChar {get;set;}
        public String SignedBy {get;set;}
        public String ItemSaleSeqNumber {get;set;}
        public String AccountShipto {get;set;}
        public String RequestID {get;set;}
        public String CustomerType {get;set;}
        public String CustomerID {get;set;}
        public String ShipToAddress1 {get;set;}
        public String ShipToAddress2 {get;set;}
        public String ShipToCityName {get;set;}
        public String ShipToStateCode {get;set;}
        public String ShipToZipCode {get;set;}
        public Boolean IsDeleted {get;set;}
    }
    global class testWrap {
        List<CaseLineItemWrap> testwrapper;
        testWrap(){
            testwrapper = new List<CaseLineItemWrap>();
        }
    }
    @HttpPost
    global static String doPost() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        req.httpMethod = 'POST';
        req.addHeader('Content-Type', 'application/json');
        String JSONString = req.requestBody.toString();
        Map<String, Object> Someval = (Map<String, Object>)JSON.deserializeUntyped(JSONString);
        List<Map<String, Object>> data = new List<Map<String, Object>>();
        Set<String> reqId = new Set<String>();
        Set<String> AccId = new Set<String>();
        Set<String> uniqid = new set<String>();
       	List<Case> myCase = new List<Case>();
        String mycaseId;
        List<Case_Line_Item__c> CLIreq = new List<Case_Line_Item__c>();
        List<Contact> Con = new List<Contact>();
        List<Account> Acc = new List<Account>();
        Case_Line_Item__c CLIreqinsert = new Case_Line_Item__c();
        for (Object instance : (List<Object>)Someval.get('CsrLineItems')){
            data.add((Map<String, Object>)instance);
            system.debug('data-->'+data);
        }
        Boolean flag = false;
        Boolean InsertLineitemFlag = false;
        Boolean DeleteFlag = false;
        Boolean updateLineitemFlag = false;
        Boolean InsertCaseFlag = false;
        List<CaseLineItemWrap> CLIList = new List<CaseLineItemWrap>();
        for(integer i=0; i<data.size(); i++){
            String Someval3 = JSON.serialize(data[i]);
            CaseLineItemWrap Someval4 = (CaseLineItemWrap)JSON.deserialize(Someval3,CaseLineItemWrap.class);
            system.debug('data val-->'+Someval4.SFDCAccountId);
            AccId.add(Someval4.SFDCAccountId);
            reqId.add(Someval4.RequestID);
            uniqid.add(Someval4.ItemUniqueID);
            system.debug('uniquedata-->'+uniqid);
            CLIList.add(Someval4);
        }
        if(data.size()>0){
            myCase = [SELECT AccountId,Id,Legacy_Service_Request_ID__c
                      FROM Case WHERE AccountId IN :AccId AND Legacy_Service_Request_ID__c IN :reqId];
            CLIreq = [SELECT Case__c,Id,Name,Legacy_Service_Request_ID__c,Legacy_Service_Request_Item_ID__c 
                      FROM Case_Line_Item__c WHERE Case__c IN :myCase AND Legacy_Service_Request_ID__c IN :reqId
                      AND Legacy_Service_Request_Item_ID__c IN :uniqid];    
            con = [SELECT AccountId,Id FROM Contact WHERE AccountId IN :AccId];
            Acc = [SELECT Id FROM Account WHERE ID IN :AccId];
        }
        System.debug('listof'+CLIList.size());
        for(CaseLineItemWrap CLIW : CLIList){
            Boolean isValidAcc = false;
            boolean isexistingCLI = false;
            String cwReqId = CLIW.RequestID;
            String cwAccId = CLIW.SFDCAccountId;
            ID existingCaseId = null;
            ID existingCLIiD = null;
            Boolean isExistingCase = false;
            System.debug('Acc size-->'+Acc.size());
            System.debug('Acc -->'+Acc);
            if(Acc.size() > 0){
                for(Account a : Acc){
                    System.debug('a-->'+a.id);
                    if(Id.valueOf(CLIW.SFDCAccountId) == a.Id){
                        isValidAcc = true;
                        //break;
                    }
                }
            }
            System.debug('CLIW-->'+CLIW);
            if(isValidAcc == true){
                System.debug('myCase-->'+myCase);
                for(integer i = 0; i < myCase.size(); i++){
                    if((myCase[i].AccountId == CLIW.SFDCAccountId) && (myCase[i].Legacy_Service_Request_ID__c== CLIW.RequestID)){
                        isExistingCase = true;
                        existingCaseId = myCase[i].ID;
                        System.debug('existingCaseId'+existingCaseId);
                        break;
                    }
                }
                System.debug('isExistingCase-->'+isExistingCase);
                if (isExistingCase == false){
                    //Insert case and CLI
                    //create case;
                    Id acID = CLIW.SFDCAccountId;
                    Case newCase = createNewCase(acID,CLIW,con);
                    InsertCaseFlag = true;
                    system.debug('Case Inserted-->'+newCase);
                    //get case number from the created case
                    //create new line items
                    CLIreqinsert = getCaseLineItem(newCase.Id,isExistingCase,CLIW,CLIreq);
                    CLIreqinsert.Case__c = newCase.Id;
                    insert CLIreqinsert;
                    system.debug('Inserted-->'+CLIreqinsert);
                    InsertLineitemFlag = true;
                }
                else{
                    System.debug('CLIreq-->'+CLIreq);
                    integer isexistingCLIIndex = null;
                    for(integer i = 0; i < CLIreq.size(); i++)
                    {
                        if((CLIreq[i].Legacy_Service_Request_Item_ID__c == CLIW.ItemUniqueID) && 
                           (CLIreq[i].Legacy_Service_Request_ID__c== CLIW.RequestID) && (CLIreq[i].Case__c == existingCaseId))
                        {
                               isexistingCLI = true;
                               isexistingCLIIndex = i;
                               existingCLIiD = CLIreq[i].ID;
                               break;
                        }
                    }
                    System.debug('isexistingCLI-->'+isexistingCLI);
                    if (isexistingCLI == true)
                    {   //Update or delete CLI
                        //Check ISDELETE 
                        if(CLIW.IsDeleted == false)
                        {
                            //update the line item record
                            CLIreqinsert = getCaseLineItem(existingCaseId,isexistingCLI,CLIW,CLIreq);
                            System.debug('before'+CLIreqinsert);
                            Update CLIreqinsert;
                            system.debug('Updated-->'+CLIreqinsert);
                            updateLineitemFlag = true;
                        }
                        else if(CLIW.IsDeleted == true)
                        {
                            //Delete the CLI
                            Delete CLIreq[isexistingCLIIndex];
                            system.debug('Deleted-->'+CLIreqinsert);
                            DeleteFlag = true;
                        }
                        
                    }
                    else
                    {
                        //Insert the line item record
                        CLIreqinsert = getCaseLineItem(existingCaseId,isexistingCLI,CLIW,CLIreq);
                        CLIreqinsert.Case__c = existingCaseId ;
                        insert CLIreqinsert;
                        system.debug('Inserted-->'+CLIreqinsert);
                        InsertLineitemFlag = true;
                    }
                 }
            }
        }
        if(InsertLineitemFlag == true)
        {
            if(InsertCaseFlag == true && updateLineitemFlag == true && DeleteFlag == true )
            {
                return 'Lineitem inserted ; Case and Lineitem inserted ; Lineitem updated ; Lineitem deleted';
            }else if(InsertCaseFlag == true && updateLineitemFlag == true && DeleteFlag == false){
                return 'Lineitem inserted ; Case and Lineitem inserted ; Lineitem updated';
            }else if(InsertCaseFlag == true && updateLineitemFlag == false && DeleteFlag == true){
                return 'Lineitem inserted ; Case and Lineitem inserted ; Lineitem deleted';
            }else if(InsertCaseFlag == true && updateLineitemFlag == false && DeleteFlag == false){
                return 'Lineitem inserted ; Case and Lineitem inserted ';
            }
            else
            { 
                if(InsertCaseFlag == false && updateLineitemFlag == false && DeleteFlag == false){
                    return 'Lineitem inserted';
                }else if(InsertCaseFlag == false && updateLineitemFlag == true && DeleteFlag == false){
                    return 'Lineitem inserted ; Lineitem updated';
                }else if(InsertCaseFlag == false && updateLineitemFlag == false && DeleteFlag == true){
                    return 'Lineitem inserted ; Lineitem deleted';
                }
                
            }
        }
        else
        {
            if (InsertCaseFlag == true && updateLineitemFlag == true && DeleteFlag == true)
            {
                return 'Case and Lineitem inserted ; Lineitem updated ; Lineitem deleted';
            }else if (InsertCaseFlag == true && updateLineitemFlag == false && DeleteFlag == false){
                return 'Case and Lineitem inserted';
            }else if(InsertCaseFlag == true && updateLineitemFlag == true && DeleteFlag == false){
                return 'Case and Lineitem inserted ; Lineitem updated';
            }else if(InsertCaseFlag == true && updateLineitemFlag == false && DeleteFlag == true){
                return 'Case and Lineitem inserted ; Lineitem deleted';
            }
            else
            { 
                if(InsertCaseFlag == false && updateLineitemFlag == true && DeleteFlag == true){
                    return 'Lineitem updated ; Lineitem deleted';
                }else if(InsertCaseFlag == false && updateLineitemFlag == false && DeleteFlag == true){
                    return 'Lineitem deleted';
                }else if(InsertCaseFlag == false && updateLineitemFlag == true && DeleteFlag == false){
                    return 'Lineitem updated';
                }
            }
        }
       /* if((updateLineitemFlag == true) || (InsertLineitemFlag == true) || (DeleteFlag == true)){
        return 'Insertion Success..';
        } */
       return 'Insertion Failed..';
    }
    
    public static Case_Line_Item__c getCaseLineItem(Id caseId,Boolean flag,CaseLineItemWrap Someval,List<Case_Line_Item__c> cliList){
        Case_Line_Item__c CLI = new Case_Line_Item__c();
        if(flag == true ){
            system.debug('myvals-->'+Someval);
			for(integer i = 0; i< cliList.size(); i++){
                if((cliList[i].Legacy_Service_Request_Item_ID__c == Someval.ItemUniqueID) && 
                           (cliList[i].Legacy_Service_Request_ID__c== Someval.RequestID) && (cliList[i].Case__c == caseId)){
                    CLI= cliList[i];
                    system.debug('thisCase-->'+CLI);
                    break;
                }
            }
        }
        CLI.Item_Serial_Number__c = Someval.ItemSerialNumber;
        CLI.Item_SKU__c = Someval.ItemSKUNumber;
        CLI.Invoice_Number__c = Someval.ItemInvoiceNumber;
        if (Someval.ItemInvoiceDate == null || Someval.ItemInvoiceDate == ''){
            CLI.Invoice_Date__c = null; 
        }else{
            CLI.Invoice_Date__c = Date.parse(Someval.ItemInvoiceDate);
        }
        if (Someval.DeliveryDate == null || Someval.DeliveryDate == ''){
            CLI.Delivery_Date__c = null; 
        }else{
            CLI.Delivery_Date__c = Date.parse(Someval.DeliveryDate);
        }
        if (Someval.OrderShipDate == null || Someval.OrderShipDate == ''){
            CLI.Part_Order_Shipping_Date__c = null; 
        }else{
            CLI.Part_Order_Shipping_Date__c = Date.parse(Someval.OrderShipDate);
        }
        CLI.Item_Defect__c = Someval.ItemDefect;
        CLI.Item_Description__c = Someval.ItemDescription;
        CLI.Item_Resolution__c = Someval.PieceExchangedFixed;
        CLI.Part_Order_Tracking_Number__c = Someval.PartOrderTrackNumber;
        CLI.Sales_Order_Number__c = Someval.ItemSaleNumber;
        CLI.Part_Order_Ship_To_Info__c = Someval.OrderShipToInfo;
        CLI.Part_Order_Status__c = Someval.OrderStatus;
        CLI.Part_Order_Number__c = Someval.OrderNumber;
        CLI.Customer_Number__c = Someval.CustomerID;
        CLI.Fulfiller_ID__c = Someval.AccountShipto;
        CLI.Legacy_Service_Request_ID__c = Someval.RequestID;
        CLI.Legacy_Service_Request_Item_ID__c = Someval.ItemUniqueID;
        CLI.Address_1__c = Someval.ShipToAddress1;
        CLI.Address_2__c = Someval.ShipToAddress2;
        CLI.City__c = Someval.ShipToCityName;
        CLI.State__c = Someval.ShipToStateCode;
        CLI.Zip__c = Someval.ShipToZipCode;
        
        return CLI;
    }
    public static Case createNewCase(Id accId, CaseLineItemWrap Someval, List<Contact> contactList){
        Case thisCase = new Case();
        Id myContactId = null;
		for(Integer i = 0; i < contactList.size(); i++){
			if(contactList[i].AccountId == accId){
				myContactId = contactList[i].ID;
				break;
			}
		} 
        thisCase.Status = 'New';
        thisCase.Type = 'General Inquiry';
        thisCase.Sub_Type__c = 'Product Inquiry';
        thisCase.Description = 'Product Inquiry';
        thisCase.Subject ='General Inquiry';
        thisCase.Origin = 'Phone';
        thisCase.ContactId = myContactId;
        thisCase.AccountId = accId;
        thisCase.Legacy_Service_Request_ID__c = Someval.RequestID;
        insert thisCase;
        return thisCase;
    }
}