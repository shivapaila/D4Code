/* *******************************************************************************************************************
* Class Name   : ManageObjects
* Description  : Controller class for ConciergeRecordView Lightning Component to handle the Sobjects.     
* Author       : Theyagarajan Sadhasivam (Perficient, Inc.)
* Created On   : 01/05/2018
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer                                   Date                   Modification ID      Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
*
**************************************************************************************************************************************/
public class ManageObjects {
    
    @AuraEnabled
    public static void deleteCurrentRecord(String Id){
        
        Schema.SObjectType objectType=ManageObjects.getSobjectTypeByPrefix(Id.substring(0, 3));
        String objType=String.valueOf(objectType);
		String queryRecordToDelete='Select Id '+
            						' From '+objectType+
            						' Where Id = :Id';      
        List<Sobject> recordToDelete=Database.query(queryRecordToDelete);
        if(!recordToDelete.isEmpty()){
            delete recordToDelete;
        }
        
    }
    
    //get sobjecttype by sobject prefix (3 chars)
    public static Schema.SObjectType getSobjectTypeByPrefix( String SObjectPrefix ){
        for( Schema.SObjectType ot : Schema.getGlobalDescribe().values() ){
            String keyPrefix = (String)ot.getDescribe().getKeyPrefix();
            if( keyPrefix != null && keyPrefix.equals( SObjectPrefix ) ){
                return ot;
            }
        }
        return null;
        
    }
}