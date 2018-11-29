public class ProductLineItemFromOrderValidation implements PLIInstance{
    @AuraEnabled
    public static boolean Validation(String src, ID PLIID){ 
        system.debug('src'+src);
        system.debug('PLIID'+PLIID);
        Boolean  isValidNum;
        Util__c PLIStatusUpdate = new Util__c();
        try{
            PLIStatusUpdate = [SELECT ID,Callout_Status__c,PLI_ID__c,SetupOwnerId from Util__c 
                               where PLI_ID__c =: PLIID];
            if (src == 'PLIH'){
                PLIStatusUpdate.Callout_Status__c = true;
                PLIStatusUpdate.PLI_ID__c = PLIID;
                Update PLIStatusUpdate;
                isValidNum = PLIStatusUpdate.Callout_Status__c;
                system.debug('isValidNum-->'+isValidNum);
                return isValidNum;
            }
        }
        catch(Exception ex){
            if (src == 'PLIH'){
                try{
                    PLIStatusUpdate = [SELECT ID,Callout_Status__c,PLI_ID__c,SetupOwnerId from Util__c];
                    PLIStatusUpdate.Callout_Status__c = true;
                    PLIStatusUpdate.PLI_ID__c = PLIID;
                    Upsert PLIStatusUpdate;
                    isValidNum = PLIStatusUpdate.Callout_Status__c;
                    system.debug('isValidNum-->'+isValidNum);
                    return isValidNum;
                }
                catch(Exception e){
                    PLIStatusUpdate.Callout_Status__c = true;
                    PLIStatusUpdate.PLI_ID__c = PLIID;
                    Insert PLIStatusUpdate;
                    isValidNum = PLIStatusUpdate.Callout_Status__c;
                    system.debug('isValidNum-->'+isValidNum);
                    return isValidNum;
                }
            }
        }
        return false;
    }
    
    
    @AuraEnabled
    public static boolean UpdateValidation(String src, ID PLIID){ 
        system.debug('src'+src);
        system.debug('PLIID'+PLIID);
        Boolean  isValidNum;
        Util__c PLIStatusUpdate = new Util__c();
        try{
            PLIStatusUpdate = [SELECT ID,Callout_Status__c,PLI_ID__c from Util__c where PLI_ID__c =: PLIID];
            PLIStatusUpdate.Callout_Status__c = false;
            PLIStatusUpdate.PLI_ID__c = PLIID;
            Update PLIStatusUpdate;
            isValidNum = PLIStatusUpdate.Callout_Status__c;
            system.debug('isValidNum-->'+isValidNum);
            return isValidNum;
        }
        catch(Exception ex){
            if (src == 'PLIH'){
                PLIStatusUpdate.Callout_Status__c = false;
                PLIStatusUpdate.PLI_ID__c = PLIID;
                Upsert PLIStatusUpdate;
                isValidNum = PLIStatusUpdate.Callout_Status__c;
                system.debug('isValidNum-->'+isValidNum);
                return isValidNum;
            }
        }
        return false;
    }
    
    @AuraEnabled
    public static boolean updateTrackingNumber(ID PLIID, string POTrackingNum){ 
        system.debug('PLIID'+PLIID);
        ProductLineItem__c PLITrackingNumUpdate = new ProductLineItem__c();
        try{
            PLITrackingNumUpdate = [SELECT id, Part_Order_Tracking_Number__c FROM ProductLineItem__c WHERE Id =: PLIID];
            PLITrackingNumUpdate.Part_Order_Tracking_Number__c = POTrackingNum;
            Update PLITrackingNumUpdate;
            return true;
        }
        catch(Exception ex){
            
            return false;
        }
    }
    
    
}