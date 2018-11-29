/* This is a controller class for TwilioSendSMS Lighting component. The component can be launced from Account/Contact or Case pages and will allow 
 * users to send text messages to Customers using Twilio. The Mobile phone of the Contact in context will be populated when the component loads and 
 * users can override it with any number they like. Once the text message is successuly passed to Twilio and Queued for delivery, the component
 * creates an activity log for the text message and closses the Action dialog window.
 */
public with sharing class TwilioSendSMSController {

	public static final string MOBILE_PHONE_IDENTIFIER = 'Cell';
	public static final string SMS_SENT_TASK_STATUS = 'Completed';
	public static final string SMS_SENT_TASK_SUBJECT = 'Sent SMS';
	public static final string SMS_SENT_TASK_TYPE = 'Text';


	/**
     * Gets A Mobile phone number that will be used  to pre populate the "To" field in the Send SMS Form. The Mobile number will be retrived from
     * The contact in context if it Exists. If Record in Context is a contact object, that contact will be used. If the Object in context is an Account
     * and has only one Contact, that contact will be used. If the Object in Context is a Case and has a contact populated, that contact is used as the default
     * contact for finding a mobile number.
     *
     * @param  recordId a salesforce Account, Contact or Case Id from wjich the Send SMS component is launched
     * @return a string representing the most prefered mobile number for the contact in context
     */
	@AuraEnabled
	public static string getMobilePhoneNumber(Id recordId){
		string mobileNumber;
		if(recordId != null){
			//sending from Contact page
			if(recordId.getSobjectType() == Contact.SobjectType){
				Contact c = [Select Id, MobilePhone,Phone, Phone_Type__c, Phone_2__c, Phone_2_Type__c, Phone_3__c, Phone_3_Type__c 
							from Contact 
							where Id =: recordId];				
				mobileNumber = getMobileNumberFromContact(c);
			
			}
			//sending from account page
			if(recordId.getSobjectType() == Account.SobjectType){
				List<Contact> contacts = [Select Id, MobilePhone,Phone, Phone_Type__c, Phone_2__c, Phone_2_Type__c, Phone_3__c, Phone_3_Type__c 
										from Contact 
										where AccountId =: recordId limit 2];
				if(contacts.size() == 1){
					mobileNumber = getMobileNumberFromContact(contacts[0]);
				}
			}
			//sending from case page
			if(recordId.getSobjectType() == Case.SobjectType){
				Case c = [Select Id, ContactId, Contact.MobilePhone, Contact.Phone, Contact.Phone_Type__c, Contact.Phone_2__c, Contact.Phone_2_Type__c, 
						Contact.Phone_3__c, Contact.Phone_3_Type__c 
						from Case where Id =: recordId];
				if(c.ContactId != null){
					mobileNumber = getMobileNumberFromContact(c.Contact);
				}
			}
		}
		return mobileNumber;
	}

	/**
     * Message sends Text message through Twilio and Creates an Activity Log for the message sent.
     *
     * @param  recordId a salesforce Account/Contact/case Id
     * @param  toPhoneNumber a Phone number to which a text message is sent
     * @param  message the content of the text message
     * @return a response indicating if the Text was passed to Twilio and Queued for Delivery
     */
	@AuraEnabled
	public static SendTextMessageResponse sendTextMessageViaTwilio(Id recordId, string toPhoneNumber, string message){
		SendTextMessageResponse response = new SendTextMessageResponse();
		try{

			API_TwilioClient.TwilioSmsWrapper messageWrapper = new API_TwilioClient.TwilioSmsWrapper(toPhoneNumber, message, null);
			API_TwilioClient.TwilioSmsWrapper smsResponse = API_TwilioClient.sendSms(messageWrapper);
			//For more than one sms use this code and check for completion of the batch
			//String smsResponseBatchId = API_TwilioClient.sendSms(new List<API_TwilioClient.TwilioSmsWrapper>{messageWrapper});
			if(smsResponse.isSuccess == false){
				response.isSuccess = false;
				response.errorMessage = smsResponse.errorMessage;
			}
			else{
				//create an activity log for the SMS
				Task smsTask = new Task();
				smsTask.ActivityDate = Date.Today();
				smsTask.Description = toPhoneNumber + ' - ' + message;
				smsTask.Status = SMS_SENT_TASK_STATUS;
				smsTask.Subject = SMS_SENT_TASK_SUBJECT;
				smsTask.Type = SMS_SENT_TASK_TYPE;
				smsTask.Twilio_Message_Id__c = smsResponse.twilioMessageId;
				smsTask.Twilio_Sent_To_Phone_Number__c = removePhoneFormatting(toPhoneNumber);
				if(recordId != null){
					if(recordId.getSobjectType() == Contact.SobjectType){
						smsTask.WhoId = recordId;
					}
					else{
						smsTask.WhatId = recordId;
					}
				}
				insert smsTask;

				response.isSuccess = true;
			}
		}
		catch(Exception ex){
			response.isSuccess = false;
			response.errorMessage = ex.getMessage();
		}
		return response;
	}

	public class SendTextMessageResponse implements Attributable{
		@AuraEnabled
		public boolean isSuccess {get;set;}
		@AuraEnabled
		public string errorMessage {get;set;}
	}

	/**
     * Extracts a Mobile number from a contact object following a hierarchy of peference. Mobile Phone has the highst preference followed by Phone, 
     * Phone 2 and Phone 3/ For Phone, Phone 2 and Phone 3 fields to be considered, the Associated Phone type should be "cell"
     *
     * @param  C a contact object from which Mobile phone is going to be extracted
     * @return a string representing the most prefered mobile number
     */
	public static string getMobileNumberFromContact(Contact c){
		string mobileNumber;
		if(c.MobilePhone != null){
			mobileNumber = c.MobilePhone;
		}
		else if (c.Phone != null && MOBILE_PHONE_IDENTIFIER.equalsIgnoreCase(c.Phone_Type__c)){
			mobileNumber = c.Phone;
		}
		else if (c.Phone_2__c != null && MOBILE_PHONE_IDENTIFIER.equalsIgnoreCase(c.Phone_2_Type__c)){
			mobileNumber = c.Phone_2__c;
		}
		else if (c.Phone_3__c != null && MOBILE_PHONE_IDENTIFIER.equalsIgnoreCase(c.Phone_3_Type__c)){
			mobileNumber = c.Phone_3__c;
		}

		return mobileNumber;
	}

	/**
     * removes characters used for formatting from a phone number. 
     *
     * @param  PhoneNumber a phone number with possible formatting
     * @return a string representing the right most 10 digits of a phone with out any formatting
     */
	public static string removePhoneFormatting(string phoneNumber){
		string formattedPhone;
		if(phoneNumber != null){
			formattedPhone = phoneNumber.replace('(', '');
			formattedPhone = formattedPhone.replace(')', '');
			formattedPhone = formattedPhone.replace('-', '');
			formattedPhone = formattedPhone.replace(' ', '');
			if(formattedPhone.length() > 10){
				formattedPhone = formattedPhone.right(10);
			}
		}
		return formattedPhone;
	}
}