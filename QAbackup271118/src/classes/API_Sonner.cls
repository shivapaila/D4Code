/* *******************************************************************************************************************
* Class Name   : API_Sonner
* Description  : Class for Sooner API.     
* Author       : Venkat (Perficient, Inc.)
* Created On   : 1/14/2017
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer                 Date            Modification ID             Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* Sorna                     02/09/2018      REQ-195                     Added logic to track Sooner Msgs
* Sorna                     02/09/2018      REQ-323                     Associate Sooner tasks to Person Accounts instead of Contacts
* Rucha (Perficient)        03/17/2018      DEF-0483                    Added sales order number to sooner task
**************************************************************************************************************************************/
@RestResource(urlMapping='/sooner/*')
global with sharing class API_Sonner {
    @HttpPOST
    global static API_BaseResponse doPost(List<SonnerWrapper> sfSoonerObject) {
    
        API_BaseResponse response = new API_BaseResponse();
        try {               
            response.isSuccess = true;
            if(sfSoonerObject != null){
                response.message = JSON.serialize(sfSoonerObject);
            }
            RestRequest req = RestContext.request;        
    
            //once the Sooner orders receive need to send message to the customer
            List<API_TwilioClient.TwilioSmsWrapper> messagesToSend = new List<API_TwilioClient.TwilioSmsWrapper>();
            List<Task> activities = new List<Task>();
            for(SonnerWrapper tempSooner :sfSoonerObject){
                //Checking whether the Customer wants to receive messages or not           
                if(tempSooner.contactStatus!='DNE'){ 
                    String message = getSMSContent(System.Label.Sooner_Text_Message, tempSooner);
                    if(!String.isBlank(tempSooner.Phone)){   
                        messagesToSend.add(new API_TwilioClient.TwilioSmsWrapper(tempSooner.Phone,message,String.valueOf(Math.random()), tempSooner.sfAccountID,
                                                                                    tempSooner.soNumber));
                    }
                    
                    if(!String.isBlank(tempSooner.Phone2)){   
                        //REQ-195 - Each phone # will have it's own task now
                        //description = String.isBlank(description)?TwilioSendSMSController.removePhoneFormatting(tempSooner.Phone2):description+', '+TwilioSendSMSController.removePhoneFormatting(tempSooner.Phone2);
                        messagesToSend.add(new API_TwilioClient.TwilioSmsWrapper(tempSooner.Phone2,message,String.valueOf(Math.random()), tempSooner.sfAccountID,
                                                                                    tempSooner.soNumber));
                    }
                    
                    if(!String.isBlank(tempSooner.Phone3)){   
                        //REQ-195 - Each phone # will have it's own task now
                        //description = String.isBlank(description)?TwilioSendSMSController.removePhoneFormatting(tempSooner.Phone3):description+', '+TwilioSendSMSController.removePhoneFormatting(tempSooner.Phone3);
                        messagesToSend.add(new API_TwilioClient.TwilioSmsWrapper(tempSooner.Phone3,message,String.valueOf(Math.random()), tempSooner.sfAccountID,
                                                                                    tempSooner.soNumber));
                    }
                    // Sorna: Activities will be created after msg is sent so we can capture msg id for polling
                    // REQ-323 - Added AccountID to WhatID field
                    //activities.add(new Task(Type='Text',Status='Completed',Subject=message,ActivityDate=System.today(),Description=description,WhoId=tempSooner.sfContactID, WhatId=tempSooner.sfAccountID));
                }                        
            }
            
            //Sending messages
            if(messagesToSend.size() == 1){
                  // synchronous request for a single message
              if(!Test.isRunningTest())
              {
                    API_TwilioClient.TwilioSmsWrapper smsWrapper = API_TwilioClient.sendSMSWithCallback(messagesToSend[0]);
                    response.isSuccess = smsWrapper.isSuccess;
                    response.message = smsWrapper.errorMessage;
                    //if(response.isSuccess)
                        createSoonerTask(smsWrapper);
                }
                else
                {
                    response.isSuccess = true;
                    createSoonerTask(new API_TwilioClient.TwilioSmsWrapper(messagesToSend[0].toPhoneNumber, messagesToSend[0].Body, null, messagesToSend[0].sfAccountID));
                }
            }
            else if(messagesToSend.size() >= 1){
                // asynchronous request for multiple messages
                if(!Test.isRunningTest())
                    Database.executeBatch(new TwilioClientSmsBatch(messagesToSend, true, true), 1);
                response.isSuccess = true;
                response.message = 'Batch Process Queued';
            }
            /* Sorna: replaced the below logic
            //Creating Activities
            if(activities.size()!=0){
                  //If an activity fails the rest can still succeed
                  Database.SaveResult[] Activitiesr = Database.insert(activities, false);
                  //Additional logic would go here to post-process any failures and its relationship with a certain SMS message
            }   */               
        }
        catch(Exception e){response.isSuccess = false; response.message = e.getMessage();} 
        return response;       
    }

    public static void createSoonerTask(API_TwilioClient.TwilioSmsWrapper smsWrapper)
    {
        Task soonerTask = new Task(Type='Text', Status='Open', Subject=System.Label.Sooner_Msg_Task_Subject, ActivityDate=System.today(), Description=smsWrapper.Body,
                                WhatId=smsWrapper.sfAccountID, Is_Sooner__c = true, Twilio_Message_Id__c = smsWrapper.twilioMessageId, 
                                Twilio_Sent_To_Phone_Number__c = smsWrapper.toPhoneNumber, Id = smsWrapper.existingTaskId, 
                                Sales_Order__c = smsWrapper.salesOrderNumber);
        upsert soonerTask;
    }

    // forms a dynamic map of key value pair from the JSON request
    // use that to replace any content between delimiters < >
    // content within the delimiter should match the same naming convention as the inner class SonnerWrapper member variables (case sensitive)
    public static String getSMSContent(String text, SonnerWrapper tempSooner)
    {
        String smsContent = text;

        String jsonStr = JSON.serialize(tempSooner);
        JSONParser parser = JSON.createParser(jsonStr);
        Map<string, string> jsonKeyToValue = new Map<String, String>();
        while (parser.nextToken() != null){
            if(parser.getText() != null && parser.getText() != '{' && parser.getText() != '}')
            {
                string key = parser.getText();
                parser.nextToken();
                string value = parser.getText();
                if((key == 'newDeliveryDate' || key == 'previousDeliveryDate') && value != '' && value != null){
                    value = Date.valueOf(value).format();
                }
                jsonKeyToValue.put(key, value);
            }
        }

        while(smsContent.contains('<')){
            Integer startIndex = smsContent.indexOf('<');
            Integer endIndex = smsContent.indexOf('>');
            String toReplace = smsContent.subString(startIndex + 1, endIndex);
            smsContent = smsContent.replace('<' + toReplace + '>', jsonKeyToValue.get(toReplace));
        }

        return smsContent;
    }

    global class SonnerWrapper{
        global String sfAccountID {get;set;} // REQ-323
        global String sfContactID {get;set;}
        global Integer storeID {get;set;}
        global String soNumber {get;set;}
        global Datetime previousDeliveryDate {get;set;}
        global DateTime newDeliveryDate {get;set;}
        global String customerName {get;set;}
        global String fulfillerID {get;set;}
        global String contactStatus {get;set;}
        global String orderType {get;set;}
        global String numberOfPieces {get;set;}
        global String Phone {get;set;}
        global String Phone2 {get;set;}
        global String Phone3 {get;set;}
    }
}