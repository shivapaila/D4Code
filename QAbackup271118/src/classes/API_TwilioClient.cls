/* This is a client class that will facilitate communication with Twilio service. The class uses the Twilio Salesforce Helper Library to execute
* operations against the Twilio API.
*/
public with sharing class API_TwilioClient {
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


    /**
     * Sends a single Text Message synchronously throigh Twulio. Can Processes a single  message.
     * Once a message is successfully sent, the Message Id from Twilio is stamped on the incoming message wrapper so that it can be used for refrence.
     *
     * @param  message a TwilioSmsWrapper instance that represent text message to be sent
     * @returns a TwilioSmsWrapper instance that represents the text message with status indicators as to if it was successfully submitted to Twilio
     */
    public static TwilioSmsWrapper sendSms(TwilioSmsWrapper message){
        try{
            TwilioRestClient client = new TwilioRestClient(TWILIO_ACCOUNT_ID, TWILIO_TOKEN);            
            Map<String,String> properties = new Map<String,String> {
            'To'   => message.toPhoneNumber,
            'From' => MESSAGING_SERVICE_ID,
            'Body' => message.body
            };           
        
            TwilioMessage smsMessage = client.getAccount().getMessages().create(properties);
            message.isSuccess = true;
            message.twilioMessageId = smsMessage.getSid();
        }
        catch(Exception ex){
            message.isSuccess = false;
            message.errorMessage = ex.getMessage();
        }
    
        return message;
    }

    /**
      * REQ-195 - Sends a single text message with a call back url so that Twilio will report back the status
      * Right now used for Sooner messages
      */
    public static TwilioSmsWrapper sendSMSWithCallback(TwilioSmsWrapper message){
        try{
            TwilioRestClient client = new TwilioRestClient(TWILIO_ACCOUNT_ID, TWILIO_TOKEN);
            Map<String,String> properties = new Map<String,String> {
            'To'   => message.toPhoneNumber,
            'From' => MESSAGING_SERVICE_ID,
            'Body' => message.body,
            'StatusCallback' => Label.TwilioCallBackURL
            };          
        
            TwilioMessage smsMessage = client.getAccount().getMessages().create(properties);
            system.debug('=====> ' + smsMessage);
            message.isSuccess = true;
            message.twilioMessageId = smsMessage.getSid();
        }
        catch(Exception ex){
            message.isSuccess = false;
            message.errorMessage = ex.getMessage();
        }
    
        return message;
    }

    /**
     * Sends Text Messages asynchronously throigh Twulio. Can Processes more than one message.
     * Once a message is successfully sent, the Message Id from Twilio is stamped on the incoming message wrapper so that it can be used for refrence.
     *
     * @param  messages a list of TwilioSmsWrapper that represent text messages to be sent
     * @returns the batch id so it can be monitored
     */
    
    public static String sendSms(List<TwilioSmsWrapper> messages){
        return Database.executeBatch(new TwilioClientSmsBatch(messages), 1);
    }
    
    public class TwilioSmsWrapper{
        public string toPhoneNumber {get;set;}
        public string body {get;set;}
        public boolean isSuccess {get;set;}
        public string errorMessage {get;set;}
        public string uniqueIdentifier {get;set;}
        public string twilioMessageId {get;set;}
        public string sfAccountID {get;set;} // REQ-195 - added by Sorna: for API Sooner bulk messages which will be used by TwilioClientSmsBatch
        //public string description {get;set;} // REQ-195 - added by Sorna: for API Sooner bulk messages which will be used by TwilioClientSmsBatch
        public string existingTaskId {get;set;} // REQ-195 - for retrying msgs so same task will be updated with new smsID
        public string salesOrderNumber{get;set;}
        
        public TwilioSmsWrapper(string toPhoneNumber, string body, string uniqueIdentifier){
            this.toPhoneNumber = toPhoneNumber;
            this.body = body;
            this.uniqueIdentifier = uniqueIdentifier;
        }
        // added by Sorna: for API Sooner bulk messages which will be used by TwilioClientSmsBatch
        public TwilioSmsWrapper(string toPhoneNumber, string body, string uniqueIdentifier, string sfAccID){
            this.toPhoneNumber = toPhoneNumber;
            this.body = body;
            this.uniqueIdentifier = uniqueIdentifier;
            this.sfAccountID = sfAccID;
        } 

        // added by Sorna: for API Sooner bulk messages which will be used by TwilioClientSmsBatch
        public TwilioSmsWrapper(Task existingTask){
            this.toPhoneNumber = existingTask.Twilio_Sent_To_Phone_Number__c;
            this.body = existingTask.Description;
            this.sfAccountID = existingTask.WhatId;
            this.existingTaskId = existingTask.Id;
        } 

        // added by Rucha: to populate Sales Order number from input
        public TwilioSmsWrapper(string toPhoneNumber, string body, string uniqueIdentifier, string sfAccID,
                                string soNumber){
            this.toPhoneNumber = toPhoneNumber;
            this.body = body;
            this.uniqueIdentifier = uniqueIdentifier;
            this.sfAccountID = sfAccID;
            this.salesOrderNumber = soNumber;
        } 
    } 
}