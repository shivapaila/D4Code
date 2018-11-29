/********************************************************************************************************************
* Class Name   : PaymentTypeHelper
* Description  : Helper class for Payment_Type__c object.  
* Author       : Moon Cui(Perficient, Inc.)
* Created On   : 02/23/2018
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer                                   Date                   Modification ID      Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
*
**************************************************************************************************************************************/
public with sharing class PaymentTypeHelper {
  public static final String ONE_SOURCE_API_CONFIG_NAME = 'OneSourceConfig';
  public static Map<String, Payment_Type__c> getPaymentTypeMapping(){
    Integer maxMinutes = getMaxRefreshMinutes();
    List<Payment_Type__c> pTypeList = [SELECT TenderCode__c,TenderCodeDescription__c,DocumentNumber__c,Last_Updated_PaymentTypes_Info__c 
                       FROM Payment_Type__c where Last_Updated_PaymentTypes_Info__c >= 2018-11-21T21:00:00Z];
    Boolean doUpdate = false;
    if(pTypeList.isEmpty()){
      doUpdate = true;
    }else{
      Integer minutesSinceLastCheck = Integer.valueOf((system.now().getTime() - pTypeList[0].Last_Updated_PaymentTypes_Info__c.getTime())/(60*1000));
          if (minutesSinceLastCheck > maxMinutes) {
            doUpdate = true;
          }
      }
    if(doUpdate){
      pTypeList = getPaymentTypeFromAPI();
    }

    Map<String, Payment_Type__c> paymentMap = new Map<String, Payment_Type__c>();
    for(Payment_Type__c pType: pTypeList){
      paymentMap.put(pType.TenderCode__c,pType);
    }
    return paymentMap;
  }

  public static List<Payment_Type__c> getPaymentTypeFromAPI(){
    List<Payment_Type__c> pTypeList = new List<Payment_Type__c>();
    try{      
      List<API_PaymentType.PaymentTypeWrapper> pTypeWrapperList = API_PaymentType.getAllPaymentTypes();
      if(pTypeWrapperList == null || pTypeWrapperList.isEmpty()){
        return pTypeList;
      }
      Datetime currentTimestamp = system.now();
      //save it      
      for(API_PaymentType.PaymentTypeWrapper pTypeWrapper : pTypeWrapperList){
        Payment_Type__c pType = new Payment_Type__c();
        pType.TenderCode__c = pTypeWrapper.TenderCode;
        pType.TenderCodeDescription__c = pTypeWrapper.TenderCodeDescription;
        pType.DocumentNumber__c = pTypeWrapper.DocumentNumber;
        pType.Last_Updated_PaymentTypes_Info__c = currentTimestamp;
        pTypeList.add(pType);
      }
      //upsert pTypeList;//Commented,  DML before Callout cause: You have uncommitted work pending. Please commit or rollback before calling out
      //TODO refer StoreInfo doUpdate updateUser method, using rest API to do this.
            //UpdatePaymentType(); //future method not work, still get uncommitted work pending.
      return pTypeList;
    }catch(Exception e){
      System.debug(e.getMessage());
            ErrorLogController.Log log = new ErrorLogController.Log('PaymentTypeHelper','getPaymentTypeFromAPI',e.getMessage());
            new ErrorLogController().createLog(log);
            return pTypeList;
    }
  }
    
    //This method must used after callout. because there is DML operation
    public static void maintainPaymentTypeMapping(){
    Integer maxMinutes = getMaxRefreshMinutes();
    List<Payment_Type__c> pTypeList = [SELECT TenderCode__c,TenderCodeDescription__c,DocumentNumber__c,Last_Updated_PaymentTypes_Info__c 
                       FROM Payment_Type__c where Last_Updated_PaymentTypes_Info__c >=  2018-11-21T21:00:00Z];
    Boolean doUpdate = false;
    if(pTypeList.isEmpty()){
      doUpdate = true;
    }else{
      Integer minutesSinceLastCheck = Integer.valueOf((system.now().getTime() - pTypeList[0].Last_Updated_PaymentTypes_Info__c.getTime())/(60*1000));
          if (minutesSinceLastCheck > maxMinutes) {
            doUpdate = true;
          }
      }
    if(doUpdate){
      updatePaymentTypeFromAPI();
    }
  }

    public static void updatePaymentTypeFromAPI(){
    List<Payment_Type__c> pTypeList = new List<Payment_Type__c>();
    try{      
            List<API_PaymentType.PaymentTypeWrapper> pTypeWrapperList = API_PaymentType.getAllPaymentTypes();
            if(pTypeWrapperList != null || !pTypeWrapperList.isEmpty()){
                
                Datetime currentTimestamp = system.now();
                //save it      
                for(API_PaymentType.PaymentTypeWrapper pTypeWrapper : pTypeWrapperList){
                    Payment_Type__c pType = new Payment_Type__c();
                    pType.TenderCode__c = pTypeWrapper.TenderCode;
                    pType.TenderCodeDescription__c = pTypeWrapper.TenderCodeDescription;
                    pType.DocumentNumber__c = pTypeWrapper.DocumentNumber;
                    pType.Last_Updated_PaymentTypes_Info__c = currentTimestamp;
                    pTypeList.add(pType);
                }
                upsert pTypeList;
            }
    }catch(Exception e){
      System.debug(e.getMessage());
            ErrorLogController.Log log = new ErrorLogController.Log('PaymentTypeHelper','getPaymentTypeFromAPI',e.getMessage());
            new ErrorLogController().createLog(log);
    }
  }
  public static Integer getMaxRefreshMinutes(){
    OneSourceSettings__c osSettings;
    Integer maxMinutes = 24*60;
    try{
      osSettings = OneSourceSettings__c.getInstance(ONE_SOURCE_API_CONFIG_NAME);
      if(osSettings!=null){
        maxMinutes = Integer.valueOf(osSettings.One_Source_API_Refresh_Minutes__c);
      }
    }catch(Exception e){
      ErrorLogController.Log log = new ErrorLogController.Log('getMaxRefreshMinutes','getPaymentTypeFromAPI',e.getMessage());
            new ErrorLogController().createLog(log);
    }
    return maxMinutes;
  }
}