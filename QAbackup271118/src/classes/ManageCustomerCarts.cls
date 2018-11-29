/* *******************************************************************************************************************
* Class Name   : ManageCustomerCarts
* Description  : Controller class for AllCustomerCarts and ActiveCustomerCarts Lightning Component.     
* Author       : Theyagarajan Sadhasivam (Perficient, Inc.)
* Created On   : 01/11/2017
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer                                   Date                   Modification ID      Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* JoJo Zhao                                   02/02/2018             REQ-349              update contact to account related to opportunity
* Theyagarajan 								  04/05/2018			 REQ-468			  Sorting by last modified date
* Theyagarajan 								  04/05/2018			 REQ-439			  Removing Cart from Active Carts
**************************************************************************************************************************************/
public class ManageCustomerCarts {
    
    @AuraEnabled
    public Opportunity oppRecord= new Opportunity();
     @AuraEnabled
    public Boolean selected = false;
    
    @AuraEnabled
    public static List<Opportunity> getAllCarts(String Id) {
        List<Opportunity> cartLst= new List<Opportunity>();
        String oppExpireLimit=System.Label.Cart_limit;
        String query='Select Id,Name, AccountId, Account.Name,CreatedDate,StageName,Cart_Grand_Total__c '+
            'From Opportunity '+
            'Where  Account.RecordType.DeveloperName=\'Customer\' and  AccountId =:Id and StageName != \'Closed Won\' and StageName != \'Closed Lost\' and StageName != \'Sale Suspended\' and CreatedDate <= LAST_N_DAYS:'+oppExpireLimit;
        
        cartLst=Database.query(query);
        
        return cartLst;
    }
    
    //get customers having active carts
    @AuraEnabled
    public static List<ManageCustomerCarts> getCustomerwithActiveCarts() {
        
        List<Opportunity> cartLst= new List<Opportunity>();
        List<ManageCustomerCarts> validCartLst= new List<ManageCustomerCarts>();
        List<Account> accountLst= new List<Account>();
        Set<Id> accountIds= new Set<Id>();
        String oppExpireLimit=System.Label.Cart_limit;
        String UserId=UserInfo.getUserId();
        String query='Select Id,Name,AccountId,Account.Name,CreatedDate,StageName,LastModifiedDate,(Select Id, Product_SKU__c from  Shopping_cart_line_items__r ) '+
            'From Opportunity '+
            'Where Account.RecordType.DeveloperName=\'Customer\' and OwnerId=:UserId and StageName != \'Closed Won\' and StageName != \'Closed Lost\' and StageName != \'Sale Suspended\' and CreatedDate = LAST_N_DAYS:'+oppExpireLimit+'ORDER BY Last_Cart_Edit_Date__c DESC NULLS LAST Limit 10';
        
        cartLst=Database.query(query);
        
        for(Opportunity opp: cartLst){
            ManageCustomerCarts ctrl = new ManageCustomerCarts();
            ctrl.oppRecord=opp;
            validCartLst.add(ctrl);
        }
        return validCartLst;
        
    }
    
    @AuraEnabled
    public static List <ManageCustomerCarts> fetchAccount(String searchKeyWord) {
        String searchKey = '%'+searchKeyWord+'%';
        List<Opportunity> cartLst= new List<Opportunity>();
        List<ManageCustomerCarts> validCartLst= new List<ManageCustomerCarts>();
        //List<Account> accountLst= new List<Account>();
        Set<Id> accountIds= new Set<Id>();
        String oppExpireLimit=System.Label.Cart_limit;
        String UserId=UserInfo.getUserId();
        
        String query='Select Id,Name, AccountId,Account.Name,CreatedDate,StageName,LastModifiedDate,(Select Id, Product_SKU__c from  Shopping_cart_line_items__r ) '+
            'From Opportunity '+
            'Where Account.RecordType.DeveloperName=\'Customer\' and OwnerId=\''+UserId+'\' and StageName != \'Closed Won\' and StageName != \'Closed Lost\' and StageName != \'Sale Suspended\' and CreatedDate = LAST_N_DAYS:'+oppExpireLimit+' and Account.Name like :searchKey ORDER BY Last_Cart_Edit_Date__c DESC NULLS LAST';
        
        cartLst=Database.query(query);
        
        for(Opportunity opp: cartLst){
            ManageCustomerCarts ctrl = new ManageCustomerCarts();
            
            ctrl.oppRecord=opp;               
            validCartLst.add(ctrl);
            
        }
		
       return validCartLst;
        
    }
    
    @AuraEnabled
    public static void closeOpp (Opportunity opp) {
        if(opp != null){
            opp.StageName='Closed Lost';
            update opp;
        }
    }
}