public class ShoppingCartAddressWrapper {
    @AuraEnabled
    public String PostalCode{
        get{ 
            if(!String.isBlank(PostalCode) && PostalCode.indexOf('-') !=-1)
            	return PostalCode.split('-')[0];
        	else
                return PostalCode;}
        set;
    }
    @AuraEnabled
    public String StateOrProvince{get;set;}
    
    @AuraEnabled
    public String City{get;set;}
    @AuraEnabled
    public String Address1{get;set;}
    @AuraEnabled
    public String Address2{get;set;}
}