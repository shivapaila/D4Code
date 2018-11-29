@RestResource (urlMapping='/ServiceRequests-CaseComments/*')
global class EDAServiceRequestCaseComments {
    Public Class CommentWrap{
        public String CommentID;
        public String SFDCAccountId;
        public String EntityType;
        public String EntityID;
        public String CommentType;
        public String CommentText;
        public String CreatedTime;
        public String CreatedUserID;
        public String LastTime;
        public String LastUserID;
        public String OrderNumber;
        public String AccountShipto;
        public String RequestID;
        public String CustomerType;
        public String CustomerID;
        public String ShipToAddress1;
        public String ShipToAddress2;
        public String ShipToCityName;
        public String ShipToStateCode;
        public String ShipToZipCode;
    }
    global class testWrap {
        List<CommentWrap> testwrapper;
        testWrap(){
            testwrapper = new List<CommentWrap>();
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
        for (Object instance : (List<Object>)Someval.get('CsrComments')){
            data.add((Map<String, Object>)instance);
            system.debug('data-->'+data);
        } 
		Set<String> AccIdSet = new Set<String>();
		Set<String> reqIdSet = new Set<String>();
		Set<String> commentIdSet = new Set<String>();
        Boolean InsertCommentFlag = false;
        Boolean DeleteFlag = false;
        Boolean InsertCaseFlag = false;
		List<CommentWrap> commentWrapList = new List<CommentWrap>();
		List<Case> myCase = new List<Case>();
        List<Address__c> myAddress = new List<Address__c>();
        List<Contact> ConList = new List<Contact>();
        List<Account> AccList = new List<Account>();
		List<Legacy_Comment__c> commentList = new List<Legacy_Comment__c>();
		Map<String, CommentWrap> CommentMapJSON = new Map<String, CommentWrap>();
         
		for(integer i=0; i<data.size(); i++){
            String Someval3 = JSON.serialize(data[i]);
            CommentWrap Someval4 = (CommentWrap)JSON.deserialize(Someval3,CommentWrap.class);
            system.debug('data val-->'+Someval4.SFDCAccountId);
			String mapkey = Someval4.SFDCAccountId + '-' + Someval4.RequestID;
            AccIdSet.add(Someval4.SFDCAccountId);
            reqIdSet.add(Someval4.RequestID);
			commentIdSet.add(Someval4.CommentID);
            commentWrapList.add(Someval4);
			CommentMapJSON.put(mapkey,Someval4);
        }
		
		if(data.size()>0){
            myCase = [SELECT AccountId, Id, Legacy_Service_Request_ID__c 
						FROM Case WHERE AccountId IN :AccIdSet AND Legacy_Service_Request_ID__c IN :reqIdSet];
            conList = [SELECT AccountId,Id FROM Contact WHERE AccountId IN :AccIdSet];
            AccList = [SELECT Id FROM Account WHERE ID IN :AccIdSet];
			commentList = [SELECT Case__c,Comment__c,Id,Legacy_CSMComment_ID__c,Legacy_Service_Request_ID__c 
                           FROM Legacy_Comment__c WHERE Legacy_CSMComment_ID__c IN :commentIdSet
                           AND Legacy_Service_Request_ID__c IN :reqIdSet AND Case__c IN :myCase];
        }
		
		
		for(CommentWrap cw : commentWrapList){
            Legacy_Comment__c newComment = new Legacy_Comment__c();
            Boolean isValidAcc = false;
			Boolean flag = false;
			Boolean Commentflag = false;
            String cwReqId = cw.RequestID;
            String cwAccId = cw.SFDCAccountId;
			Id existingCaseId = null;
			Id existingCommentId = null;
            if(AccList.size() > 0){
                for(Account a : AccList){
                    if(Id.valueOf(cw.SFDCAccountId) == a.Id){
                        isValidAcc = true;
                        break;
                    }
                }
            }
            if(isValidAcc == true){
                for(integer i = 0; i < myCase.size(); i++){
                    if((myCase[i].AccountId == cw.SFDCAccountId) && (myCase[i].Legacy_Service_Request_ID__c== cw.RequestID)){
                        flag = true;
						existingCaseId = myCase[i].ID;
                        System.debug('existingCaseId'+existingCaseId);
                        break;
                    }
                }
                if(flag == false){
					//insert case and new comment
					Case newcase = new Case();
                    Id accID = cw.SFDCAccountId;
                    newcase = createNewCase(accID, cw, conList);
                    InsertCaseFlag = true;
                    newComment = getComment(newcase.Id, cw);
                    newComment.Case__c = newcase.Id;
                    insert newComment;
                    System.debug('newComment-->'+newComment.id);
                    InsertCommentFlag = true; 
				}
				else{
					//check comment is existing in case
					Integer commentIndex = null;
					for(integer i = 0; i < commentList.size(); i++){
						if((commentList[i].Legacy_CSMComment_ID__c == cw.commentId) && (commentList[i].Legacy_Service_Request_ID__c == cw.RequestID) && (commentList[i].Case__c == existingCaseId)){
							Commentflag = true;
							existingCommentId = commentList[i].ID;
							commentIndex = i;
							break;
						}
					}
					//if yes--> delete existing comment and insert new comment
					if(Commentflag == true){
                        System.debug('Deleted-->'+commentList[commentIndex]);
						Delete commentList[commentIndex];
						DeleteFlag = true;
						flag = false;
						newComment = getComment(existingCaseId, cw);
						newComment.Case__c = existingCaseId;
						Insert  newComment;
                        System.debug('newComment-->'+newComment.id);
						InsertCommentFlag = true;
					}
					//if No --> insert new comment
					else{
						newComment = getComment(existingCaseId, cw);
						newComment.Case__c = existingCaseId;
						insert newComment;
                        System.debug('newComment-->'+newComment.id);
						InsertCommentFlag = true;
					}
				}
			}	
		}

		Boolean DIFlag = false;
        Boolean IIFlag = false;
        Boolean IFlag = false;
        
        if(InsertCommentFlag == TRUE){
            if(DeleteFlag == TRUE){
                DIFlag = true;
            }
            else if(InsertCaseFlag == TRUE) {
                IIFlag = true;
            }
            else{
                IFlag = true;
            }
        } 
        
        if(IFlag == true){
            if(DIFlag == true && IIFlag == true){
                return 'Comment Inserted;Case and Comment Inserted;Comment Deleted and Inserted successfully..';
            }
            else if(DIFlag == true && IIFlag == false){
                return 'Comment Inserted;Comment Deleted and Inserted successfully..';
            }
            else if(DIFlag == false && IIFlag == true){
                return 'Comment Inserted;Case and Comment Inserted successfully..';
            }
            else
                return 'Comment Inserted successfully..'; 
        } 
        else{
            if(DIFlag == true && IIFlag == true){
                return 'Case and Comment Inserted; Comment Deleted and Inserted successfully..';
            }
            else if(DIFlag == true && IIFlag == false){
                return 'Comment Deleted and Inserted successfully..';
            }
            else if(DIFlag == false && IIFlag == true){
                return 'Case and Comment Inserted successfully..';
            }
            else
                return 'Insertion Failed..'; 
        }
	}				
    public static Legacy_Comment__c getComment(id caseId, CommentWrap Someval){
        	Legacy_Comment__c myComment = new Legacy_Comment__c();
			myComment.Case__c = caseId;
            myComment.Legacy_Service_Request_ID__c = Someval.RequestID;
            myComment.Legacy_CSMComment_ID__c = Someval.CommentID;
            myComment.Comment__c = Someval.CommentText;
            return myComment;
    }
    public static Case createNewCase(Id accId, CommentWrap Someval, List<Contact> contactList){
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
        system.debug('thisCase'+thisCase.Id);
        return thisCase;
    }
}