public class ProductEcommWrapper {
    // this is the object ecomm returns 
    // including the bare minimum of fields
    @AuraEnabled
    public InternalEcommProductWrapper product{get;set;}
}