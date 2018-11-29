/* *******************************************************************************************************************
* Class Name   : TwilioInboundSMSRestService
* Description  : Rest Service class for Twilio Inbound SMS.     
* Author       : Moon Cui (Perficient, Inc.)
* Created On   : Jan 2018
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer                 Date            Modification ID             Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
**************************************************************************************************************************************/

@RestResource(urlMapping='/TwilioInboundSMS/*')
global class TwilioInboundSMSRestService {
    public static final string TWILIO_ACCOUNT_ID;
    public static final string TWILIO_TOKEN ;
    public static final string MESSAGING_SERVICE_ID ;
    
    public static final string TWILIO_SANDBOX_CONFIG_KEY = 'TWILIO_Sandbox';
    public static final string TWILIO_PRODUCTION_CONFIG_KEY = 'TWILIO_Prod';
    static{
        string keyForEnvironment = Utilities_SalesAndService.isSandbox ? TWILIO_SANDBOX_CONFIG_KEY : TWILIO_PRODUCTION_CONFIG_KEY;
        for(TwilioConfig__c tconfig: TwilioConfig__c.getall().values()){
            if(tconfig.Name.equalsIgnoreCase(keyForEnvironment)){
                MESSAGING_SERVICE_ID = tconfig.Messaging_Service_Id__c;
                TWILIO_ACCOUNT_ID = tconfig.AccountSid__c;
                TWILIO_TOKEN = tconfig.AuthToken__c;
            }
        }
    }

    @HttpPost
    global static void doPost() {
        RestRequest req = RestContext.request;   
        Map<String, String> reqHeaders = req.headers;
        Map<String, String> smsParams = req.params;
        if(checkHeader(reqHeaders,smsParams)){
            //SMSInfo smsInfo = getInfoFromSMS(smsParams);
            saveSMS(smsParams);
            // Set the response values for Web Service
            RestContext.response.statusCode = 200;
            RestContext.response.addHeader('Content-Type', 'text/plain');
            RestContext.response.responseBody = Blob.valueOf(Label.Response_Message_for_Inbound_SMS) ;
        }
    }

    static Boolean checkHeader(Map<String, String> reqHeaders,Map<String, String> smsParams){
        for(String k : smsParams.keySet()){
            System.debug('Param>>' + k + ': '+smsParams.get(k));
        }
        if(reqHeaders != null && reqHeaders.containsKey('X-Twilio-Signature')){
            String twilioSignature =  reqHeaders.get('X-Twilio-Signature');
            //String s = 'https://dev-ashleytwiliotextmessagereceiver.cs91.force.com/services/apexrest/TwilioInboundSMS';
            String s = 'https://' + reqHeaders.get('Host') + '/services/apexrest' + RestContext.request.requestURI;
            //TwilioRestClient client = new TwilioRestClient('AC2bac2e60cda3b9d0d6783dff3d527db2','88eb29ada4f4fe9a1a1423fd3515371d');
            TwilioRestClient client = new TwilioRestClient(TWILIO_ACCOUNT_ID, TWILIO_TOKEN);
            Boolean b = client.validateRequest(twilioSignature,s,smsParams);
            if(Test.isRunningTest()){
                return true;
            }          
            return b;
        }
        return false;
    }
    
    @future(callout=true)
    static void saveSMS(Map<String, String> smsParams){
        SMSInfo smsInfo = getInfoFromSMS(smsParams);        

        Task tsk = null;
        Id whatId = null; //It may be Account Id, may be Case Id.
        Id whoId = null;
        if(String.isNotBlank(smsInfo.fromMobile)) {
            String formatfromMobile = TwilioSendSMSController.removePhoneFormatting(smsInfo.fromMobile);
            tsk = getTargetTask(formatfromMobile);
            if(tsk != null){
                whatId = tsk.whatId;
                whoId = tsk.whoId;
            }else{
                whatId = getAccountId(smsInfo.fromMobile);
            }
        }
        Id ownerId = null;
        if(whatId != null){
            //Get Image only when we are sure it is from some Contact.
            getAllImages(smsInfo);            
            List<User> userList = [SELECT Id FROM User WHERE AccountId = :whatId];
            if(userList.size() > 0){
                ownerId = userList[0].Id;
            }
            saveTask(smsInfo, whoId, whatId, ownerId);
        }
    }

    static Task getTargetTask(String formatfromMobile){
        Integer numofPastDays = 8;
        try{
            Integer.valueOf(System.Label.Query_Task_for_Number_of_Past_days);
        }catch(Exception e){}
        DateTime fewDaysBack = System.today().addDays(0-numofPastDays);
        //Considering Completed Task for Past 8 days
        for(Task tempTask :[SELECT Id,Description,WhoId,WhatId,Twilio_Sent_To_Phone_Number__c FROM Task WHERE Status = 'Completed' AND CreatedDate >= :fewDaysBack ORDER BY CreatedDate DESC]){
            //Considering the Phone details will be stored in description or Twilio_Sent_To_Phone_Number__c                
            if((String.isNotBlank(tempTask.Description) && tempTask.Description.contains(formatfromMobile)) 
                || (String.isNotBlank(tempTask.Twilio_Sent_To_Phone_Number__c) 
                && tempTask.Twilio_Sent_To_Phone_Number__c.contains(formatfromMobile))) {

                return tempTask;
            }
        }  
        return null;    
    }

    static Id getAccountId(String fromMobile){
        List<Account> accountList = new List<Account>([SELECT Id FROM Account 
                                                          WHERE RecordType.DeveloperName='Customer' 
                                                            AND (Phone = :fromMobile OR Phone_2__pc = :fromMobile OR Phone_3__pc = :fromMobile)]);
        if(accountList.size() != 0){
            return accountList[0].Id;
        }
        return null;
    }

    static void saveTask(SMSInfo smsInfo, Id whoId, Id whatId, Id ownerId){
        String msgBody = smsInfo.msgBody;
        String fromMobile = smsInfo.fromMobile;            
        Task inboundTask = new Task();
        inboundTask.Type = 'Text';
        inboundTask.Status = 'Completed';
        inboundTask.ActivityDate = System.today();
        inboundTask.Subject = fromMobile + ' responded at ' + DateTime.now().format();
        inboundTask.WhoId = whoId;
        inboundTask.WhatId = whatId;
        if(ownerId != null){
            inboundTask.OwnerId = ownerId;
        }
        
        inboundTask.Description = msgBody;
        insert inboundTask;
        saveImageToParent(smsInfo, inboundTask.Id, ownerId);
    }
    
    static void saveImageToParent(SMSInfo smsInfo, Id parentId, Id ownerId){
        List<Attachment> attachList = new List<Attachment>();
        for(ImageInfo imgInfo : smsInfo.imageList){
            if(imgInfo.imageBlob != null){
                Attachment attachment = new Attachment();
                attachment.Body = imgInfo.imageBlob;
                attachment.Name = imgInfo.fileName;
                attachment.ParentId = parentId;
                if(ownerId != null){
                    attachment.OwnerId = ownerId;
                }
                attachList.add(attachment);
            }
        }
        if(!attachList.isEmpty()){
            insert attachList;
        }
    }

    static SMSInfo getInfoFromSMS(Map<String, String> smsParams){
        SMSInfo smsInfo = new SMSInfo();
        Integer numMedia = 0;
        if (smsParams.containsKey('From')){
            smsInfo.fromMobile = smsParams.get('From') ;
        }
        if (smsParams.containsKey('To')){
           smsInfo.toDetails = smsParams.get('To') ;
        }       
        if (smsParams.containsKey('Body')){
            smsInfo.msgBody = smsParams.get('Body') ;
        }
        if(smsParams.containsKey('NumMedia')){
            numMedia = Integer.valueOf(smsParams.get('NumMedia'));
        }
        //Twilio only support up to 10 MediaUrls per message
        for(Integer i=0;i<numMedia;i++){
            String mediaType = 'MediaContentType' + i;
            String mediaUrl = 'MediaUrl' + i;
            if(smsParams.containsKey(mediaUrl) && smsParams.containsKey(mediaType)){
                System.debug('>>>>>' + smsParams.get(mediaType));
                ImageInfo info = new ImageInfo();
                info.imageURL = smsParams.get(mediaUrl);
                info.mediaType = smsParams.get(mediaType);
                info.fileName = info.imageURL.substringAfterLast('/')+'.'+info.mediaType.remove('image/');
                smsInfo.imageList.add(info);
            }            
        }
        return smsInfo;
    }
    
    static void getAllImages(SMSInfo smsInfo){
        for(ImageInfo imgInfo : smsInfo.imageList){
            imgInfo.imageBlob = getOneImage(imgInfo.imageURL);
        }
    }

    // Extract the media url if any coming on this message
    //Needs 3 times Http request to get one image.
    static Blob getOneImage(String imageURL){
        Http http = new Http();
        HttpRequest imgReq = new HttpRequest();
        imgReq.setEndpoint(imageURL);
        imgReq.setMethod('GET');
        HttpResponse res = http.send(imgReq);
        Integer statusCode = res.getStatusCode();
        if(statusCode == 307){
            String loc = res.getHeader('Location');
            if(loc != null){
                //HttpRequest imgReqRedirected = new HttpRequest();
                imgReq.setEndpoint(loc);
                res = http.send(imgReq);
                statusCode = res.getStatusCode();
                if(statusCode == 301){
                    String loc2 = res.getHeader('Location');
                    if(loc2 != null){
                        //HttpRequest imgReqRedirected2 = new HttpRequest();
                        imgReq.setEndpoint(loc2);
                        res = http.send(imgReq);
                        statusCode = res.getStatusCode();
                    }
                }
            }
        }
        if(statusCode == 200){
            Blob imageBlob = res.getBodyAsBlob();
            return imageBlob;
        }else{
            return null;
        }
    }



    global class SMSInfo {
        global String fromMobile {get; set;}
        global String msgBody {get; set;}
        global String toDetails {get; set;}
        global List<ImageInfo> imageList {get;set;}
        global SMSInfo(){
            imageList = new List<ImageInfo>();
        }
    }

    global Class ImageInfo{
        String imageURL {get; set;}
        Blob imageBlob {get; set;}
        String mediaType {get; set;}
        String fileName {get;set;}
    }    
}